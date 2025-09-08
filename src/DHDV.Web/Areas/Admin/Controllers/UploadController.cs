using Microsoft.AspNetCore.Mvc;

namespace DHDV.Web.Areas.Admin.Controllers
{
    [Area("Admin")]
    public class UploadController : Controller
    {
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Image(IFormFile file)
        {
            if (file == null || file.Length == 0) return BadRequest("No file");
            var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            var ok = new[] { ".jpg",".jpeg",".png",".webp",".gif" }.Contains(ext);
            if (!ok) return BadRequest("Invalid type");

            var name = $"{Guid.NewGuid():N}{ext}";
            var save = Path.Combine(Directory.GetCurrentDirectory(),
                                    "wwwroot","img","uploads", name);
            Directory.CreateDirectory(Path.GetDirectoryName(save)!);
            using var fs = System.IO.File.Create(save);
            await file.CopyToAsync(fs);

            return Json(new { path = $"/img/uploads/{name}" });
        }
    }
}
