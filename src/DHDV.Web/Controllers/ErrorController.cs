// src/DHDV.Web/Controllers/ErrorController.cs
using Microsoft.AspNetCore.Mvc;

namespace DHDV.Web.Controllers;
public class ErrorController : Controller
{
    [Route("error/{code:int}")]
    public IActionResult Status(int code) { Response.StatusCode = code; ViewData["Code"]=code; return View("Status"); }

    [Route("error")]
    [Route("error/500")]
    public IActionResult Index() { Response.StatusCode = 500; ViewData["Code"]=500; return View("Status"); }
}
