using System.Text;
using System.Xml.Linq;
using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers
{
    /// <summary>Dynamic sitemap.xml: liệt kê route chính + top items.</summary>
    [Route("sitemap.xml")]
    public class SitemapController : Controller
    {
        private readonly AppDbContext _db;
        public SitemapController(AppDbContext db) { _db = db; }

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            var urls = new List<string>
            {
                $"{baseUrl}/",
                $"{baseUrl}/People",
                $"{baseUrl}/Albums",
                $"{baseUrl}/Posts"
            };

            // Top People/Albums/Posts (giới hạn 100 để sitemap gọn)
            var peopleIds = await _db.Persons.AsNoTracking()
                .Where(x => !x.IsDeleted).OrderBy(x => x.Id).Select(x => x.Id).Take(100).ToListAsync();
            urls.AddRange(peopleIds.Select(id => $"{baseUrl}/People/Details/{id}"));

            var albumIds = await _db.Albums.AsNoTracking()
                .OrderByDescending(x => x.Id).Select(x => x.Id).Take(100).ToListAsync();
            urls.AddRange(albumIds.Select(id => $"{baseUrl}/Photos?albumId={id}"));

            var postIds = await _db.Posts.AsNoTracking()
                .OrderByDescending(x => x.Id).Select(x => x.Id).Take(100).ToListAsync();
            urls.AddRange(postIds.Select(id => $"{baseUrl}/Posts/Details/{id}"));

            XNamespace ns = "http://www.sitemaps.org/schemas/sitemap/0.9";
            var doc = new XDocument(new XElement(ns + "urlset",
                urls.Select(u => new XElement(ns + "url", new XElement(ns + "loc", u)))
            ));
            var xml = doc.ToString(SaveOptions.DisableFormatting);
            return Content(xml, "application/xml", Encoding.UTF8);
        }
    }
}
