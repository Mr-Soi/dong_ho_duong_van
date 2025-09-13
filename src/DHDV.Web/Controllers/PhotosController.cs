using System.Linq;
using System.Threading.Tasks;
using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers
{
    [Route("[controller]")]
    public class PhotosController : Controller
    {
        private readonly AppDbContext _db;
        public PhotosController(AppDbContext db) { _db = db; }

        // /Photos?albumId=123&q=&page=1&pageSize=24
        [HttpGet("")]
        public async Task<IActionResult> Index(int albumId, string q = "", int page = 1, int pageSize = 24)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 24;
            if (pageSize > 200) pageSize = 200;

            var album = await _db.Albums.AsNoTracking().FirstOrDefaultAsync(a => a.Id == albumId);
            if (album == null) return NotFound();
            var albumTitle = album.Title ?? ("Album #" + album.Id);

            var photos = _db.Photos.AsNoTracking().Where(p => p.AlbumId == albumId);
            if (!string.IsNullOrWhiteSpace(q))
            {
                var k = q.Trim();
                photos = photos.Where(p =>
                    (p.Caption  != null && p.Caption.Contains(k)) ||
                    (p.Url      != null && p.Url.Contains(k))     ||
                    (p.ThumbUrl != null && p.ThumbUrl.Contains(k)));
            }

            var total = await photos.CountAsync();
            var items = await photos.OrderBy(p => p.Id)
                .Skip((page - 1) * pageSize).Take(pageSize)
                .Select(p => new PhotoItem {
                    Id = p.Id,
                    Url = p.Url,
                    ThumbUrl = p.ThumbUrl ?? p.Url,
                    Caption = p.Caption
                }).ToListAsync();

            ViewData["AlbumId"] = albumId;
            ViewData["AlbumTitle"] = albumTitle;
            ViewData["q"] = q; ViewData["Total"] = total; ViewData["Page"] = page; ViewData["PageSize"] = pageSize;

            this.SetOg(
                title: albumTitle,
                image: items.FirstOrDefault()?.ThumbUrl ?? Url.Content("~/img/cover.webp"),
                url:   $"{Request.Scheme}://{Request.Host}/Photos?albumId={albumId}"
            );

            return View(items);
        }
    }

    public class PhotoItem
    {
        public int Id { get; set; }
        public string Url { get; set; } = "";
        public string ThumbUrl { get; set; } = "";
        public string? Caption { get; set; }
    }
}
