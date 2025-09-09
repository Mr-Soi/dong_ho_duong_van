using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers
{
    public class AlbumsController : Controller
    {
        private readonly AppDbContext _db;
        public AlbumsController(AppDbContext db) { _db = db; }

        public IActionResult Index()
        {
            var list = _db.Albums.Include(a => a.Photos).ToList();
            return View(list);
        }
    }
}
