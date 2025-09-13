using Microsoft.AspNetCore.Mvc;

namespace DHDV.Web.Controllers
{
    public static class ControllerExtensions
    {
        /// <summary>Set OpenGraph/Twitter meta qua ViewData (đọc ở _Layout.cshtml).</summary>
        public static void SetOg(this Controller c, string? title = null, string? desc = null, string? image = null, string? url = null)
        {
            if (!string.IsNullOrWhiteSpace(title)) c.ViewData["OgTitle"] = title;
            if (!string.IsNullOrWhiteSpace(desc))  c.ViewData["OgDesc"]  = desc;
            if (!string.IsNullOrWhiteSpace(image)) c.ViewData["OgImage"] = image;
            if (!string.IsNullOrWhiteSpace(url))   c.ViewData["OgUrl"]   = url;
        }
    }
}
