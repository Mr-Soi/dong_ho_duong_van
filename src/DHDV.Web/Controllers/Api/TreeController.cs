using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;

namespace DHDV.Web.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class TreeController : ControllerBase
    {
        private readonly AppDbContext _db;
        public TreeController(AppDbContext db) { _db = db; }

        [HttpGet("{id:int}")]
        public IActionResult Get(int id)
        {
            var root = _db.Persons.FirstOrDefault(p => p.Id == id);
            if (root == null) return NotFound();

            // simple 2-level tree
            var children = _db.Persons.Where(p => p.FatherId == id || p.MotherId == id)
                                      .Select(p => new { id = p.Id, name = p.FullName }).ToList();
            var data = new {
                id = root.Id,
                name = root.FullName,
                children = children
            };
            return Ok(data);
        }
    }
}
