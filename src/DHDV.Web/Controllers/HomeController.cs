using System;
using System.Linq;
using System.Threading.Tasks;
using DHDV.Web.Data;
using DHDV.Web.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

public class HomeController : Controller
{
    private readonly AppDbContext _db;
    public HomeController(AppDbContext db) { _db = db; }

    public async Task<IActionResult> Index()
    {
        // Lấy category "Bản tin/Tin tức" nếu có
        var catId = await _db.Categories
            .Where(c => c.Slug == "ban-tin" || c.Slug == "tin-tuc" || c.Name == "Bản tin" || c.Name == "Tin tức")
            .Select(c => c.Id)
            .FirstOrDefaultAsync();

        // Null-safe: IsPublished ?? false; PublishedAt null → cho qua (hoặc dùng mốc tối thiểu)
        var minDate = new DateTime(1950, 1, 1);
        var q = _db.Posts.AsQueryable()
            .Where(p => (p.IsPublished ?? false) && (p.IsDeleted == false) && ((p.PublishedAt ?? minDate) >= minDate));

        if (catId > 0)
            q = q.Where(p => p.CategoryId == catId);

        var vm = new HomeIndexVM
        {
            Posts = await q
                .OrderByDescending(p => p.PublishedAt ?? p.CreatedAt)
                .Include(p => p.Category)
                .Take(9)
                .ToListAsync(),

            People = await _db.Persons
                .OrderByDescending(p => p.Id)
                .Take(10)
                .ToListAsync()
        };

        return View(vm);
    }

    public IActionResult Intro()   => View();
    public IActionResult Charter() => View();
    public IActionResult Contact() => View();
}
