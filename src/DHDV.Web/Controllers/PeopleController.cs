using System.Threading.Tasks;
using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers
{
    [Route("[controller]")]
    public class PeopleController : Controller
    {
        private readonly AppDbContext _db;
        public PeopleController(AppDbContext db) { _db = db; }

        // /People?q=&gen=&branch=&sort=&page=&pageSize=
        [HttpGet("")]
        public async Task<IActionResult> Index(string? q = "", int? gen = null, string? branch = "", string sort = "name", int page = 1, int pageSize = 24)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 24;
            if (pageSize > 200) pageSize = 200;

            var query = _db.Persons.AsNoTracking().Where(x => !x.IsDeleted);

            if (!string.IsNullOrWhiteSpace(q))
            {
                var k = q.Trim();
                query = query.Where(x =>
                    (x.DisplayName != null && x.DisplayName.Contains(k)) ||
                    (x.Alias       != null && x.Alias.Contains(k)));
            }
            if (gen.HasValue) query = query.Where(x => x.Generation == gen.Value);
            if (!string.IsNullOrWhiteSpace(branch)) query = query.Where(x => x.Branch == branch);

            sort = (sort ?? "name").ToLowerInvariant();
            query = sort switch
            {
                "gen" => query.OrderBy(x => x.Generation).ThenBy(x => x.Branch).ThenBy(x => x.DisplayName).ThenBy(x => x.Id),
                _     => query.OrderBy(x => x.DisplayName).ThenBy(x => x.Id)
            };

            var total = await query.CountAsync();

            var items = await query
                .Select(x => new DHDV.Web.ViewModels.PeopleListItem
                {
                    Id         = x.Id,
                    Name       = x.DisplayName ?? x.Alias ?? ("#" + x.Id),
                    Alias      = x.Alias,
                    Generation = x.Generation,
                    Branch     = x.Branch,
                    BirthYear  = x.BirthDate.HasValue ? x.BirthDate.Value.Year : (int?)null,
                    DeathYear  = x.DeathDate.HasValue ? x.DeathDate.Value.Year : (int?)null,

                    // Lấy 1 tên vợ/chồng (suy từ cha/mẹ của các con)
                    SpouseName = _db.Persons
                        .Where(sp =>
                            _db.Persons.Any(ch => !ch.IsDeleted &&
                                ((ch.FatherId == x.Id && ch.MotherId == sp.Id) ||
                                 (ch.MotherId == x.Id && ch.FatherId == sp.Id))))
                        .OrderBy(sp => sp.DisplayName)
                        .Select(sp => sp.DisplayName ?? sp.Alias ?? ("#" + sp.Id))
                        .FirstOrDefault()
                })
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            ViewData["q"]=q; ViewData["gen"]=gen; ViewData["branch"]=branch; ViewData["sort"]=sort;
            ViewData["Total"]=total; ViewData["Page"]=page; ViewData["PageSize"]=pageSize;
            return View(items);
        }
        
        [HttpGet("Details/{id:int}")]
        public async Task<IActionResult> Details(int id)
        {
            var p = await _db.Persons.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted);
            if (p == null) return NotFound();

            // father/mother
            var father = p.FatherId.HasValue
                ? await _db.Persons.AsNoTracking()
                    .Where(x => x.Id == p.FatherId.Value)
                    .Select(x => new { x.Id, x.DisplayName, x.Alias, x.FatherId, x.MotherId })
                    .FirstOrDefaultAsync()
                : null;

            var mother = p.MotherId.HasValue
                ? await _db.Persons.AsNoTracking()
                    .Where(x => x.Id == p.MotherId.Value)
                    .Select(x => new { x.Id, x.DisplayName, x.Alias, x.FatherId, x.MotherId })
                    .FirstOrDefaultAsync()
                : null;

            // grandparents
            var paternalGrandFather = father?.FatherId.HasValue == true
                ? await _db.Persons.AsNoTracking()
                    .Where(x => x.Id == father.FatherId.Value)
                    .Select(x => new { x.Id, x.DisplayName, x.Alias })
                    .FirstOrDefaultAsync()
                : null;

            var paternalGrandMother = father?.MotherId.HasValue == true
                ? await _db.Persons.AsNoTracking()
                    .Where(x => x.Id == father.MotherId.Value)
                    .Select(x => new { x.Id, x.DisplayName, x.Alias })
                    .FirstOrDefaultAsync()
                : null;

            var maternalGrandFather = mother?.FatherId.HasValue == true
                ? await _db.Persons.AsNoTracking()
                    .Where(x => x.Id == mother.FatherId.Value)
                    .Select(x => new { x.Id, x.DisplayName, x.Alias })
                    .FirstOrDefaultAsync()
                : null;

            var maternalGrandMother = mother?.MotherId.HasValue == true
                ? await _db.Persons.AsNoTracking()
                    .Where(x => x.Id == mother.MotherId.Value)
                    .Select(x => new { x.Id, x.DisplayName, x.Alias })
                    .FirstOrDefaultAsync()
                : null;

            // siblings (share father or mother, exclude self)
            var siblings = await _db.Persons.AsNoTracking()
                .Where(x => x.Id != id && !x.IsDeleted &&
                            ((p.FatherId.HasValue && x.FatherId == p.FatherId) ||
                             (p.MotherId.HasValue && x.MotherId == p.MotherId)))
                .OrderBy(x => x.BirthDate).ThenBy(x => x.Id)
                .Select(x => new ViewModels.PersonChild
                {
                    Id = x.Id,
                    Name = x.DisplayName ?? x.Alias ?? ("#" + x.Id)
                }).ToListAsync();

            // children
            var children = await _db.Persons.AsNoTracking()
                .Where(x => (x.FatherId == id || x.MotherId == id) && !x.IsDeleted)
                .OrderBy(x => x.BirthDate).ThenBy(x => x.Id)
                .Select(x => new ViewModels.PersonChild { Id = x.Id, Name = x.DisplayName ?? x.Alias ?? ("#" + x.Id) })
                .ToListAsync();

            // spouses (suy từ con: nếu mình là cha -> vợ là mẹ của các con; nếu mình là mẹ -> chồng là cha của các con)
            var spouseIdSet = new System.Collections.Generic.HashSet<int>();
            var childParents = await _db.Persons.AsNoTracking()
                .Where(x => (x.FatherId == id || x.MotherId == id) && !x.IsDeleted)
                .Select(x => new { x.FatherId, x.MotherId }).ToListAsync();

            foreach (var cp in childParents)
            {
                if (cp.FatherId == id && cp.MotherId.HasValue) spouseIdSet.Add(cp.MotherId.Value);
                if (cp.MotherId == id && cp.FatherId.HasValue) spouseIdSet.Add(cp.FatherId.Value);
            }

            var spouses = spouseIdSet.Count == 0
                ? new System.Collections.Generic.List<ViewModels.PersonChild>()
                : await _db.Persons.AsNoTracking()
                    .Where(x => spouseIdSet.Contains(x.Id))
                    .Select(x => new ViewModels.PersonChild
                    {
                        Id = x.Id,
                        Name = x.DisplayName ?? x.Alias ?? ("#" + x.Id)
                    }).ToListAsync();

            var vm = new ViewModels.PersonDetails
            {
                Id = p.Id,
                Name = p.DisplayName ?? p.Alias ?? ("#" + p.Id),
                Alias = p.Alias,
                Generation = p.Generation,
                Branch = p.Branch,
                BirthYear = p.BirthDate?.Year,
                DeathYear = p.DeathDate?.Year,

                FatherId = p.FatherId,
                MotherId = p.MotherId,
                FatherName = father?.DisplayName ?? father?.Alias,
                MotherName = mother?.DisplayName ?? mother?.Alias,

                PaternalGrandFatherId = paternalGrandFather?.Id,
                PaternalGrandFatherName = paternalGrandFather?.DisplayName ?? paternalGrandFather?.Alias,
                PaternalGrandMotherId = paternalGrandMother?.Id,
                PaternalGrandMotherName = paternalGrandMother?.DisplayName ?? paternalGrandMother?.Alias,

                MaternalGrandFatherId = maternalGrandFather?.Id,
                MaternalGrandFatherName = maternalGrandFather?.DisplayName ?? maternalGrandFather?.Alias,
                MaternalGrandMotherId = maternalGrandMother?.Id,
                MaternalGrandMotherName = maternalGrandMother?.DisplayName ?? maternalGrandMother?.Alias,

                Siblings = siblings,
                Spouses = spouses,
                Children = children
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
        // 👉 THÊM DÒNG NÀY:
        public string? SpouseName { get; set; }
        
    }

    public class PersonChild { public int Id { get; set; } public string Name { get; set; } = ""; }

    public class PersonDetails : PeopleListItem
    {
        public int? FatherId { get; set; }
        public int? MotherId { get; set; }
        public string? FatherName { get; set; }
        public string? MotherName { get; set; }

        public int? PaternalGrandFatherId { get; set; }
        public string? PaternalGrandFatherName { get; set; }
        public int? PaternalGrandMotherId { get; set; }
        public string? PaternalGrandMotherName { get; set; }

        public int? MaternalGrandFatherId { get; set; }
        public string? MaternalGrandFatherName { get; set; }
        public int? MaternalGrandMotherId { get; set; }
        public string? MaternalGrandMotherName { get; set; }

        public System.Collections.Generic.List<PersonChild> Siblings { get; set; } = new();
        public System.Collections.Generic.List<PersonChild> Spouses  { get; set; } = new();
        public System.Collections.Generic.List<PersonChild> Children { get; set; } = new();
    }
}
