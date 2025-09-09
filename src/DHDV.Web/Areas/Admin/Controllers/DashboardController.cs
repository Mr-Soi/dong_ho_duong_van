using Microsoft.AspNetCore.Mvc;

namespace DHDV.Web.Areas.Admin.Controllers
{
    [Area("Admin")]                  // KHÔNG dùng [Route(...)]
    public class DashboardController : Controller
    {
        public IActionResult Index() => View();
    }
}
