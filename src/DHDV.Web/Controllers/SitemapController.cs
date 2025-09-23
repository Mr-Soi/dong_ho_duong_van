// src/DHDV.Web/Controllers/SitemapController.cs
using System.Text;
using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers;
public class SitemapController : Controller
{
    private readonly AppDbContext _db;
    public SitemapController(AppDbContext db){ _db = db; }

    [HttpGet("sitemap.xml")]
    public async Task<IActionResult> Index()
    {
        var baseUrl = $"{Request.Scheme}://{Request.Host}";
        var urls = new List<(string loc, DateTime? lastmod)>
        {
            ($"{baseUrl}/", null),
            ($"{baseUrl}/People", null),
            ($"{baseUrl}/Posts", null),
            ($"{baseUrl}/Albums", null),
        };

        var posts = await _db.Set<Post>().AsNoTracking().OrderByDescending(x=>x.Id).Select(x=>new{ x.Slug, x.PublishedAt, x.CreatedAt }).ToListAsync();
        urls.AddRange(posts.Select(p => ($"{baseUrl}/Posts/{p.Slug}", p.PublishedAt ?? p.CreatedAt)));

        var sb = new StringBuilder();
        sb.Append("""<?xml version="1.0" encoding="UTF-8"?>""");
        sb.Append("""<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">""");
        foreach (var (loc, last) in urls.DistinctBy(u=>u.loc))
        {
            sb.Append("<url><loc>").Append(loc).Append("</loc>");
            if (last is DateTime dt) sb.Append("<lastmod>").Append(dt.ToString("yyyy-MM-dd")).Append("</lastmod>");
            sb.Append("</url>");
        }
        sb.Append("</urlset>");
        return Content(sb.ToString(), "application/xml", Encoding.UTF8);
    }

    private class Post { public int Id {get;set;} public string Slug {get;set;} = ""; public DateTime? PublishedAt {get;set;} public DateTime? CreatedAt {get;set;} }
}
