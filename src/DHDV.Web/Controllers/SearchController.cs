using System.Linq;
using System.Threading.Tasks;
using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers
{
    [Route("[controller]")]
    public class SearchController : Controller
    {
        private readonly AppDbContext _db;
        public SearchController(AppDbContext db) { _db = db; }

        // GET /Search?q=
        [HttpGet("")]
        public async Task<IActionResult> Index(string q = "", int take = 10)
        {
            q = q?.Trim() ?? "";
            var vm = new SearchResultVM { Q = q };

            if (string.IsNullOrWhiteSpace(q))
            {
                this.SetOg(title: "Tìm kiếm · Dòng họ Dương Văn", image: Url.Content("~/img/cover.webp"),
                           url: $"{Request.Scheme}://{Request.Host}/Search");
                return View(vm);
            }

            vm.People = await _db.Persons.AsNoTracking()
                .Where(x => !x.IsDeleted &&
                       ((x.DisplayName != null && x.DisplayName.Contains(q)) ||
                        (x.Alias       != null && x.Alias.Contains(q))))
                .OrderBy(x => x.DisplayName).ThenBy(x => x.Id)
                .Select(x => new Hit { Id = x.Id, Title = x.DisplayName ?? x.Alias ?? ("#" + x.Id), Kind = "People" })
                .Take(take).ToListAsync();

            vm.Albums = await _db.Albums.AsNoTracking()
                .Where(a => (a.Title != null && a.Title.Contains(q)) ||
                            (a.Description != null && a.Description.Contains(q)))
                .OrderByDescending(a => a.Id)
                .Select(a => new Hit { Id = a.Id, Title = a.Title ?? ("Album #" + a.Id), Kind = "Album" })
                .Take(take).ToListAsync();

            vm.Posts = await _db.Posts.AsNoTracking()
                .Where(p => p.Title != null && p.Title.Contains(q))
                .OrderByDescending(p => p.Id)
                .Select(p => new Hit { Id = p.Id, Title = p.Title!, Kind = "Post" })
                .Take(take).ToListAsync();

            this.SetOg(
                title: $"Tìm: {q}",
                image: Url.Content("~/img/cover.webp"),
                url:   $"{Request.Scheme}://{Request.Host}/Search?q={Uri.EscapeDataString(q)}"
            );

            return View(vm);
        }
    }

    public class SearchResultVM
    {
        public string Q { get; set; } = "";
        public List<Hit> People { get; set; } = new();
        public List<Hit> Albums { get; set; } = new();
        public List<Hit> Posts  { get; set; } = new();
        public bool HasAny => (People?.Count>0) || (Albums?.Count>0) || (Posts?.Count>0);
    }
    public class Hit { public int Id { get; set; } public string Title { get; set; } = ""; public string Kind { get; set; } = ""; }
}
