using System.Linq;
using Microsoft.AspNetCore.Mvc;
using DHDV.Web.Data;
using DHDV.Web.Models;

namespace DHDV.Web.Areas.Admin.Controllers
{
    [Area("Admin")]
    public class PostsController : Controller
    {
        private readonly AppDbContext _db;
        public PostsController(AppDbContext db) { _db = db; }

        public IActionResult Index() =>
            View(_db.Posts.OrderByDescending(x => x.CreatedAt).Take(100).ToList());

        public IActionResult Edit(int id)
        {
            var p = _db.Posts.Find(id);
            if (p == null) return NotFound();
            return View(p);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Edit(Post m)
        {
            if (!ModelState.IsValid) return View(m);
            var p = _db.Posts.Find(m.Id);
            if (p == null) return NotFound();

            p.Title = m.Title;
            p.Slug = m.Slug;
            p.Summary = m.Summary;
            p.Content = m.Content;
            p.CoverImage = m.CoverImage;
            p.PublishedAt = m.PublishedAt;
            p.CategoryId = m.CategoryId;

            _db.SaveChanges();
            return RedirectToAction(nameof(Index));
        }
    }
}

