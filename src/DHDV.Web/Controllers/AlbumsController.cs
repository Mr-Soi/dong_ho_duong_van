using System;
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

        [HttpGet("")]
        public async Task<IActionResult> Index(string? q)
        {
            try
            {
                var albums = _db.Albums.AsNoTracking().AsQueryable();
                if (!string.IsNullOrWhiteSpace(q))
                {
                    var k = q.Trim();
                    albums = albums.Where(a =>
                        (EF.Property<string>(a, "Name") ?? "").Contains(k) ||
                        (EF.Property<string>(a, "Description") ?? "").Contains(k));
                }
                var list = await albums.OrderByDescending(a => EF.Property<int>(a, "Id"))
                                       .Take(60).ToListAsync();
                ViewData["q"] = q;
                return View(list);
            }
            catch (Exception ex)
            {
                // fail-safe: không sập trang
                ViewData["q"] = q;
                ViewData["Error"] = ex.Message;
                return View(Array.Empty<object>());
            }
        }

        [HttpGet("Details/{id:int}")]
        public async Task<IActionResult> Details(int id)
        {
            try
            {
                var a = await _db.Albums.AsNoTracking()
                          .FirstOrDefaultAsync(x => EF.Property<int>(x, "Id") == id);
                if (a == null) return NotFound();
                return View(a);
            }
            catch (Exception ex)
            {
                return Problem(detail: ex.Message);
            }
        }
    }
}
