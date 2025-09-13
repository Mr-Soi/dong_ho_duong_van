using Microsoft.AspNetCore.Mvc;
namespace DHDV.Web.Controllers {
  [Route("Error")]
  public class ErrorController : Controller {
    [Route("{code:int}")] public IActionResult Status(int code) =>
      View("Status", code);
  }
}
