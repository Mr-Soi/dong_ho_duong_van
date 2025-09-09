DHDV UI Pack (no-thumbnail) – ASP.NET MVC/Core
- Copy Helpers, Views, wwwroot vào project. Đổi namespace YourApp.Helpers cho khớp.
- Thêm @using YourApp.Helpers vào Views/_ViewImports.cshtml (MVC5: vào Views/Web.config).
- Thêm <link rel="stylesheet" href="~/css/dhdv.ui.css" /> và <script src="~/js/dhdv.ui.js"></script> vào layout.
- Dùng Views/News/Index.cshtml (list) và Views/News/Detail.cshtml (chi tiết).