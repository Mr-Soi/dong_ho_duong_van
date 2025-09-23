using System.Text;
using System.Xml;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DHDV.Web.Data;

namespace DHDV.Web.Controllers
{
    public class FeedController : Controller
    {
        private readonly AppDbContext _db;
        public FeedController(AppDbContext db) { _db = db; }

        [HttpGet("feed.xml")]
        public async Task<IActionResult> Index()
        {
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            var posts = await _db.Posts
                .AsNoTracking()
                .OrderByDescending(p => p.PublishedAt ?? p.CreatedAt)
                .Take(100)
                .Select(p => new {
                    p.Title, p.Slug, p.Summary, p.CoverImage, p.PublishedAt, p.CreatedAt
                })
                .ToListAsync();

            var sb = new StringBuilder();
            var settings = new XmlWriterSettings { Encoding = new UTF8Encoding(false), Indent = false };
            using (var xw = XmlWriter.Create(sb, settings))
            {
                xw.WriteStartDocument();
                xw.WriteStartElement("rss"); xw.WriteAttributeString("version", "2.0");
                xw.WriteStartElement("channel");
                xw.WriteElementString("title", "Dòng họ Dương Văn");
                xw.WriteElementString("link",  baseUrl);
                xw.WriteElementString("description", "Bài viết mới nhất");
                xw.WriteElementString("lastBuildDate", DateTime.UtcNow.ToString("r"));

                foreach (var p in posts)
                {
                    var link = $"{baseUrl}/Posts/{p.Slug}";
                    xw.WriteStartElement("item");
                    xw.WriteElementString("title", string.IsNullOrWhiteSpace(p.Title) ? "Bài viết" : p.Title);
                    xw.WriteElementString("link",  link);
                    xw.WriteElementString("guid",  link);
                    var dt = (p.PublishedAt ?? p.CreatedAt) ?? DateTime.UtcNow;
                    xw.WriteElementString("pubDate", dt.ToUniversalTime().ToString("r"));
                    if (!string.IsNullOrWhiteSpace(p.Summary))
                        xw.WriteElementString("description", p.Summary);
                    xw.WriteEndElement(); // item
                }

                xw.WriteEndElement(); // channel
                xw.WriteEndElement(); // rss
                xw.Flush();
            }
            return Content(sb.ToString(), "application/rss+xml", Encoding.UTF8);
        }
    }
}
