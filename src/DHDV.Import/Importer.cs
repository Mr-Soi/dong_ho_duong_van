using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;

namespace DHDV.Import;

public static class Importer
{
    public static async Task RunAsync(string oldCs, string newCs, string etlPath)
    {
        // đọc config
        string postsTable = "dbo.vw_PostsForImport";
        try
        {
            using var doc = JsonDocument.Parse(File.ReadAllText(etlPath));
            if (doc.RootElement.TryGetProperty("Source", out var src) &&
                src.TryGetProperty("PostsTable", out var pt) &&
                pt.GetString() is string s && !string.IsNullOrWhiteSpace(s))
                postsTable = s.Trim();
        } catch { /* dùng mặc định */ }
        if (!postsTable.Contains(".")) postsTable = "dbo." + postsTable;

        Console.WriteLine($"[IMPORT] Reading from {postsTable} ...");

        var posts = new List<SourcePost>();
        using (var srcConn = new SqlConnection(oldCs))
        {
            await srcConn.OpenAsync();
            using var cmd = new SqlCommand($@"
                SELECT Post_ID, Title, Summary, Content, PublishedAt, UpdatedAt, IsPublished, Category
                FROM {postsTable}
            ", srcConn);
            using var rd = await cmd.ExecuteReaderAsync();
            while (await rd.ReadAsync())
            {
                posts.Add(new SourcePost{
                    PostId      = rd.IsDBNull(0) ? 0 : rd.GetInt32(0),
                    Title       = rd.IsDBNull(1) ? "" : rd.GetString(1),
                    Summary     = rd.IsDBNull(2) ? null : rd.GetString(2),
                    Content     = rd.IsDBNull(3) ? null : rd.GetString(3),
                    PublishedAt = rd.IsDBNull(4) ? (DateTime?)null : rd.GetDateTime(4),
                    UpdatedAt   = rd.IsDBNull(5) ? (DateTime?)null : rd.GetDateTime(5),
                    IsPublished = !rd.IsDBNull(6) && rd.GetBoolean(6),
                    Category    = rd.IsDBNull(7) ? null : rd.GetString(7)
                });
            }
        }
        Console.WriteLine($"[IMPORT] Loaded {posts.Count} rows.");

        using var dst = new SqlConnection(newCs);
        await dst.OpenAsync();
        using var tx = await dst.BeginTransactionAsync();

        try
        {
            // cache category
            var catByName = new Dictionary<string,int>(StringComparer.OrdinalIgnoreCase);
            var catSlugs  = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            using (var ccmd = new SqlCommand("SELECT Id,Name,Slug FROM dbo.Categories", dst, (SqlTransaction)tx))
            using (var r = await ccmd.ExecuteReaderAsync())
            {
                while (await r.ReadAsync())
                {
                    int id = r.GetInt32(0);
                    string name = r.GetString(1);
                    string slug = r.GetString(2);
                    catByName[name.Trim()] = id;
                    catSlugs.Add(slug);
                }
            }

            // cache post slugs
            var postSlugs = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            using (var pcmd = new SqlCommand("SELECT Slug FROM dbo.Posts", dst, (SqlTransaction)tx))
            using (var pr = await pcmd.ExecuteReaderAsync())
                while (await pr.ReadAsync()) postSlugs.Add(pr.GetString(0));

            int insCats = 0, insPosts = 0;

            foreach (var p in posts)
            {
                int? categoryId = null;
                if (!string.IsNullOrWhiteSpace(p.Category))
                {
                    var name = p.Category.Trim();
                    if (!catByName.TryGetValue(name, out var cid))
                    {
                        var cSlug = MakeUnique(ToSlug(name), catSlugs, 160);
                        using var ic = new SqlCommand(
                            "INSERT INTO dbo.Categories(Name,Slug) OUTPUT INSERTED.Id VALUES(@n,@s)",
                            dst, (SqlTransaction)tx);
                        ic.Parameters.AddWithValue("@n", name);
                        ic.Parameters.AddWithValue("@s", cSlug);
                        cid = (int)(await ic.ExecuteScalarAsync());
                        catByName[name] = cid;
                        insCats++;
                    }
                    categoryId = cid;
                }

                var pSlug = MakeUnique(ToSlug(p.Title), postSlugs, 160);
                using var ip = new SqlCommand(@"
                    INSERT INTO dbo.Posts(Title,Slug,Summary,Content,PublishedAt,UpdatedAt,IsPublished,CategoryId)
                    VALUES(@Title,@Slug,@Summary,@Content,@PublishedAt,@UpdatedAt,@IsPublished,@CategoryId)
                ", dst, (SqlTransaction)tx);
                ip.Parameters.AddWithValue("@Title", p.Title);
                ip.Parameters.AddWithValue("@Slug",  pSlug);
                ip.Parameters.AddWithValue("@Summary", (object?)p.Summary ?? DBNull.Value);
                ip.Parameters.AddWithValue("@Content", (object)(p.Content ?? p.Summary ?? ""));
                ip.Parameters.AddWithValue("@PublishedAt", (object?)p.PublishedAt ?? DBNull.Value);
                ip.Parameters.AddWithValue("@UpdatedAt", (object?)p.UpdatedAt ?? DBNull.Value);
                ip.Parameters.AddWithValue("@IsPublished", p.IsPublished);
                ip.Parameters.AddWithValue("@CategoryId", (object?)categoryId ?? DBNull.Value);
                await ip.ExecuteNonQueryAsync();
                insPosts++;
            }

            await tx.CommitAsync();
            Console.WriteLine($"[IMPORT] Done. Categories +{insCats}, Posts +{insPosts}");
        }
        catch (Exception ex)
        {
            await tx.RollbackAsync();
            Console.WriteLine("[IMPORT] ERROR: " + ex.Message);
            throw;
        }
    }

    // helpers
    private static string ToSlug(string input)
    {
        if (string.IsNullOrWhiteSpace(input)) return "bai-viet";
        string s = RemoveDiacritics(input).ToLowerInvariant();
        s = Regex.Replace(s, @"[^a-z0-9]+", "-");
        s = s.Trim('-');
        if (s.Length == 0) s = "bai-viet";
        return s.Length > 160 ? s.Substring(0,160).Trim('-') : s;
    }
    private static string MakeUnique(string baseSlug, HashSet<string> used, int maxLen)
    {
        string slug = baseSlug;
        int i = 2;
        while (used.Contains(slug))
        {
            var suffix = "-" + i++;
            var cut = baseSlug.Length > (maxLen - suffix.Length)
                ? baseSlug.Substring(0, maxLen - suffix.Length).Trim('-')
                : baseSlug;
            slug = cut + suffix;
        }
        used.Add(slug);
        return slug;
    }
    private static string RemoveDiacritics(string text)
    {
        var norm = text.Normalize(NormalizationForm.FormD);
        var sb = new StringBuilder();
        foreach (var c in norm)
        {
            var cat = CharUnicodeInfo.GetUnicodeCategory(c);
            if (cat != UnicodeCategory.NonSpacingMark) sb.Append(c);
        }
        return sb.ToString().Normalize(NormalizationForm.FormC);
    }

    private sealed class SourcePost
    {
        public int PostId { get; set; }
        public string Title { get; set; } = "";
        public string? Summary { get; set; }
        public string? Content { get; set; }
        public DateTime? PublishedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public bool IsPublished { get; set; }
        public string? Category { get; set; }
    }
}
