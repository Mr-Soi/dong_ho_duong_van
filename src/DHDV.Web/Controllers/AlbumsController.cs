using System.Linq;
using System.Threading.Tasks;
using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers
{
    [Route("[controller]")]
    public class AlbumsController : Controller
    {
        private readonly AppDbContext _db;
        public AlbumsController(AppDbContext db) { _db = db; }

        // Search + Pagination
        [HttpGet("")]
        public async Task<IActionResult> Index(string q = "", int page = 1, int pageSize = 24)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 24;
            if (pageSize > 200) pageSize = 200;

            var albums = _db.Albums.AsNoTracking();

            if (!string.IsNullOrWhiteSpace(q))
            {
                var k = q.Trim();
                albums = albums.Where(a =>
                    (a.Title != null && a.Title.Contains(k)) ||
                    (a.Description != null && a.Description.Contains(k)));
            }

            var total = await albums.CountAsync();

            var items = await albums
                .OrderByDescending(a => a.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(a => new AlbumListItem
                {
                    Id = a.Id,
                    Title = a.Title ?? ("Album #" + a.Id),
                    Description = a.Description,
                    CoverUrl = a.CoverImageUrl // nếu model khác tên, đổi tại đây
                })
                .ToListAsync();

            ViewData["q"] = q;
            ViewData["Total"] = total;
            ViewData["Page"] = page;
            ViewData["PageSize"] = pageSize;

            return View(items);
        }
    }

    public class AlbumListItem
    {
        public int Id { get; set; }
        public string Title { get; set; } = "";
        public string? Description { get; set; }
        public string? CoverUrl { get; set; }
    }
}
