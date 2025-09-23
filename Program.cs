var builder = WebApplication.CreateBuilder(args);
// ... (phần cấu hình dịch vụ)
builder.Services.AddControllersWithViews();
var app = builder.Build();
// ... (các middleware khác)
app.MapControllers();
app.MapControllerRoute(name: "default", pattern: "{controller=Home}/{action=Index}/{id?}");
app.Run();
