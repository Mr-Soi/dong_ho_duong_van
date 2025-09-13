using Microsoft.AspNetCore.Mvc;

namespace DHDV.Web.Controllers
{
    public class HomeController : Controller
    {
        // Trang Home an toàn (không query DB)
        public IActionResult Index() => View();

        public IActionResult Intro()   => View();
        public IActionResult Charter() => View();
        public IActionResult Contact() => View();
    }
}
