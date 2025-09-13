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

// Response compression (gzip/br)
builder.Services.AddResponseCompression(opt => { opt.EnableForHttps = true; });

var app = builder.Build();

// Forwarded headers (Cloudflare)
var fh = new ForwardedHeadersOptions {
  ForwardedHeaders = ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedFor,
  RequireHeaderSymmetry = false
};
fh.KnownNetworks.Clear(); fh.KnownProxies.Clear();
app.UseForwardedHeaders(fh);

// Compression
app.UseResponseCompression();

// Static files + cache headers
app.UseStaticFiles(new StaticFileOptions {
  OnPrepareResponse = ctx => {
    var path = ctx.File.PhysicalPath?.ToLowerInvariant() ?? "";
    var h = ctx.Context.Response.Headers;
    if (path.EndsWith(".css") || path.EndsWith(".js") ||
        path.EndsWith(".png") || path.EndsWith(".jpg") ||
        path.EndsWith(".jpeg")|| path.EndsWith(".webp") ||
        path.EndsWith(".svg") || path.EndsWith(".woff2") || path.EndsWith(".woff"))
      h["Cache-Control"] = "public,max-age=31536000,immutable";
    else if (path.EndsWith("robots.txt") || path.EndsWith("sitemap.xml"))
      h["Cache-Control"] = "public,max-age=3600";
  }
});

app.UseRouting();

app.MapGet("/ping", () => Results.Ok("pong"));

// Redirect root nếu muốn:
// app.MapGet("/", () => Results.Redirect("/People", false));

app.MapControllerRoute(name: "default", pattern: "{controller=Home}/{action=Index}/{id?}");
app.Run();
