using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using DHDV.Web.Data;

var builder = WebApplication.CreateBuilder(args);

// DbContext
var cs = builder.Configuration.GetConnectionString("DefaultConnection")
       ?? builder.Configuration["ConnectionStrings__DefaultConnection"]
       ?? builder.Configuration["ConnectionStrings:DefaultConnection"];
builder.Services.AddDbContext<AppDbContext>(o => o.UseSqlServer(cs));

// MVC
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Forwarded headers (Cloudflare)
var fh = new ForwardedHeadersOptions {
  ForwardedHeaders = ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedFor,
  RequireHeaderSymmetry = false
};
fh.KnownNetworks.Clear(); fh.KnownProxies.Clear();
app.UseForwardedHeaders(fh);

app.UseStaticFiles();
app.UseRouting();
app.UseStatusCodePagesWithReExecute("/Error/{0}");


app.MapGet("/ping", () => Results.Ok("pong"));
app.MapGet("/", () => Results.Redirect("/People", false));
app.MapControllerRoute(name:"default", pattern:"{controller=Home}/{action=Index}/{id?}");


app.Run();
