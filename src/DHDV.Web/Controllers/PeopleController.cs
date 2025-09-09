using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DHDV.Web.Data;
using DHDV.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers
{
    [Route("[controller]")]                 // /People
    public class PeopleController : Controller
    {
        private readonly AppDbContext _db;
        public PeopleController(AppDbContext db) { _db = db; }

        [HttpGet("")]                       // GET /People
        public async Task<IActionResult> Index(string? q, int? gen)
        {
            var people = _db.Persons.AsNoTracking().Where(x => !x.IsDeleted);

            if (!string.IsNullOrWhiteSpace(q))
            {
                var k = q.Trim();
                people = people.Where(x =>
                    (x.FullName != null && x.FullName.Contains(k)) ||
                    (x.Alias    != null && x.Alias.Contains(k)));
            }
            if (gen.HasValue) people = people.Where(x => x.Generation == gen.Value);

            var list = await people
                .OrderBy(x => x.Generation).ThenBy(x => x.Branch).ThenBy(x => x.FullName).ThenBy(x => x.Id)
                .Select(x => new PeopleListItem {
                    Id         = x.Id,
                    Name       = x.FullName ?? x.Alias ?? ("#" + x.Id),
                    Alias      = x.Alias,
                    Generation = x.Generation,
                    Branch     = x.Branch,
                    BirthYear  = x.BirthDate.HasValue ? x.BirthDate.Value.Year : (int?)null,
                    DeathYear  = x.DeathDate.HasValue ? x.DeathDate.Value.Year : (int?)null
                })
                .ToListAsync();

            ViewData["q"] = q; ViewData["gen"] = gen;
            return View(list);
        }

        [HttpGet("Details/{id:int}")]       // GET /People/Details/123
        public async Task<IActionResult> Details(int id)
        {
            var p = await _db.Persons.AsNoTracking()
                     .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted);
            if (p == null) return NotFound();

            var father = p.FatherId.HasValue
                ? await _db.Persons.AsNoTracking()
                    .Where(x => x.Id == p.FatherId.Value)
                    .Select(x => new { x.Id, x.FullName, x.Alias }).FirstOrDefaultAsync()
                : null;

            var mother = p.MotherId.HasValue
                ? await _db.Persons.AsNoTracking()
                    .Where(x => x.Id == p.MotherId.Value)
                    .Select(x => new { x.Id, x.FullName, x.Alias }).FirstOrDefaultAsync()
                : null;

            var children = await _db.Persons.AsNoTracking()
                .Where(x => (x.FatherId == id || x.MotherId == id) && !x.IsDeleted)
                .OrderBy(x => x.BirthDate).ThenBy(x => x.Id)
                .Select(x => new PersonChild { Id = x.Id, Name = x.FullName ?? x.Alias ?? ("#" + x.Id) })
                .ToListAsync();

            var vm = new PersonDetails {
                Id         = p.Id,
                Name       = p.FullName ?? p.Alias ?? ("#" + p.Id),
                Alias      = p.Alias,
                Generation = p.Generation,
                Branch     = p.Branch,
                BirthYear  = p.BirthDate?.Year,
                DeathYear  = p.DeathDate?.Year,
                FatherId   = p.FatherId,  MotherId = p.MotherId,
                FatherName = father?.FullName ?? father?.Alias,
                MotherName = mother?.FullName ?? mother?.Alias,
                Children   = children
            };
            return View(vm);
        }
    }
}

namespace DHDV.Web.ViewModels
{
    public class PeopleListItem
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
        public string? Alias { get; set; }
        public int? Generation { get; set; }
        public string? Branch { get; set; }
        public int? BirthYear { get; set; }
        public int? DeathYear { get; set; }
    }

    public class PersonChild { public int Id { get; set; } public string Name { get; set; } = ""; }

    public class PersonDetails : PeopleListItem
    {
        public int? FatherId { get; set; }
        public int? MotherId { get; set; }
        public string? FatherName { get; set; }
        public string? MotherName { get; set; }
        public List<PersonChild> Children { get; set; } = new();
    }
}
