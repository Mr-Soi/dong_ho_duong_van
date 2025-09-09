using System;
using System.Linq;
using System.Threading.Tasks;
using DHDV.Web.Data;
using DHDV.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class PostsController : Controller
{
    private readonly AppDbContext _db;
    public PostsController(AppDbContext db) { _db = db; }

    public async Task<IActionResult> Index(int? categoryId)
    {
        var q = _db.Posts.Include(p => p.Category)
                 .Where(p => p.IsPublished && p.PublishedAt >= new DateTime(1950,1,1) && !p.IsDeleted);

        if (categoryId.HasValue) q = q.Where(p => p.CategoryId == categoryId.Value);

        ViewBag.Categories = await _db.Categories.OrderBy(c=>c.Name).ToListAsync();
        ViewBag.Selected   = categoryId.HasValue ? await _db.Categories.Where(c=>c.Id==categoryId)
                                .Select(c=>c.Name).FirstOrDefaultAsync() : null;

        var items = await q.OrderByDescending(p => p.PublishedAt).ToListAsync();
        return View(items);
    }

    public async Task<IActionResult> Details(int id)
    {
        var p = await _db.Posts
            .Include(x => x.Category)
            .FirstOrDefaultAsync(x => x.Id == id && x.IsPublished && !x.IsDeleted);

        if (p == null) return NotFound();
        return View(p);
    }
}
