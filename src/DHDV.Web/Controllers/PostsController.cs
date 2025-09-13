using System.Linq;
using System.Threading.Tasks;
using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers
{
    [Route("[controller]")]
    public class PostsController : Controller
    {
        private readonly AppDbContext _db;
        public PostsController(AppDbContext db) { _db = db; }

        // ... giữ nguyên using & lớp PostsController
        [HttpGet("")]
        public async Task<IActionResult> Index(string q = "", int page = 1, int pageSize = 10)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;
            if (pageSize > 50) pageSize = 50;

            var posts = _db.Posts.AsNoTracking();
            if (!string.IsNullOrWhiteSpace(q))
            {
                var k = q.Trim();
                posts = posts.Where(p =>
                    (p.Title   != null && p.Title.Contains(k)) ||
                    (p.Content != null && p.Content.Contains(k)));
            }

            var total = await posts.CountAsync();
            var items = await posts
                .OrderByDescending(p => p.PublishedAt ?? p.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();   // <-- trả Post, không map PostItem

            ViewData["q"] = q; ViewData["Total"] = total; ViewData["Page"] = page; ViewData["PageSize"] = pageSize;

            this.SetOg(
                title: "Bài viết · Dòng họ Dương Văn",
                image: Url.Content("~/img/cover.webp"),
                url:   $"{Request.Scheme}://{Request.Host}/Posts"
            );

            return View(items);
        }

    }

    public class PostItem
    {
        public int Id { get; set; }
        public string Title { get; set; } = "";
        public System.DateTime? PublishedAt { get; set; }
    }
}
