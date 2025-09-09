using DHDV.Web.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using System.Text;
using System.Security;

var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:8080");

builder.Services.AddControllersWithViews();

var cs = builder.Configuration.GetConnectionString("DefaultConnection")
         ?? "Server=dhdv_sql,1433;Database=dhdv;User ID=sa;Password=YourStrong@Passw0rd;Encrypt=True;TrustServerCertificate=True";
builder.Services.AddDbContext<AppDbContext>(o => o.UseSqlServer(cs));

var app = builder.Build();
app.UseStaticFiles();
app.UseRouting();

// no-store cho HTML (đặt header trước khi gửi body)
app.Use(async (ctx, next) =>
{
    ctx.Response.OnStarting(() =>
    {
        var ct = ctx.Response.ContentType;
        if (!string.IsNullOrEmpty(ct) &&
            ct.StartsWith("text/html", StringComparison.OrdinalIgnoreCase))
        {
            ctx.Response.Headers["Cache-Control"] = "no-store, no-cache, must-revalidate";
            ctx.Response.Headers["Pragma"]        = "no-cache";
            ctx.Response.Headers["Expires"]       = "0";
        }
        return Task.CompletedTask;
    });
    await next();
});


// MVC
app.MapControllerRoute(name:"default", pattern:"{controller=Home}/{action=Index}/{id?}");

// health
app.MapGet("/ping", () => Results.Ok("pong"));
app.MapGet("/health", () => Results.Ok(new { ok=true }));
app.MapGet("/ready", async () => {
    try {
        await using var con = new SqlConnection(cs);
        await con.OpenAsync();
        await using var cmd = new SqlCommand("SELECT 1", con);
        await cmd.ExecuteScalarAsync();
        return Results.Ok();
    } catch { return Results.StatusCode(503); }
});

// sitemap.xml
app.MapGet("/sitemap.xml", async (AppDbContext db, HttpContext ctx) =>
{
    ctx.Response.ContentType = "application/xml; charset=utf-8";
    var host = $"{ctx.Request.Scheme}://{ctx.Request.Host}";
    var urls = new List<string> { $"{host}/", $"{host}/People", $"{host}/Posts" };
    var posts = await db.Posts.OrderByDescending(x => x.PublishedAt)
                              .Take(200).Select(x => x.Id).ToListAsync();
    urls.AddRange(posts.Select(id => $"{host}/Posts/Details/{id}"));
    var sb = new StringBuilder();
    sb.AppendLine(@"<?xml version=""1.0"" encoding=""UTF-8""?><urlset xmlns=""http://www.sitemaps.org/schemas/sitemap/0.9"">");
    foreach (var u in urls) sb.AppendLine($"<url><loc>{SecurityElement.Escape(u)}</loc></url>");
    sb.AppendLine("</urlset>");
    await ctx.Response.WriteAsync(sb.ToString());
});

app.Run();
