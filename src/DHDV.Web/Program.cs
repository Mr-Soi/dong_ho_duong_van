using DHDV.Web.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.HttpOverrides;

var builder = WebApplication.CreateBuilder(args);

// ENV  appsettings
string? Env(string k) => Environment.GetEnvironmentVariable(k);
string? cs =
    Env("ConnectionStrings__DHDV") ??
    Env("ConnectionStrings__Default") ??
    builder.Configuration.GetConnectionString("DHDV") ??
    builder.Configuration.GetConnectionString("Default") ??
    builder.Configuration["ConnectionStrings:DHDV"] ??
    builder.Configuration["ConnectionStrings:Default"];
if (string.IsNullOrWhiteSpace(cs))
    throw new InvalidOperationException("Chưa cấu hình chuỗi kết nối.");

builder.Services.AddDbContext<AppDbContext>(opt => opt.UseSqlServer(cs));
builder.Services.AddControllersWithViews();

var app = builder.Build();
// Program.cs – đặt NGAY sau var app = builder.Build();
app.Use(async (ctx, next) =>
{
    var h = ctx.Response.Headers;
    h["X-Content-Type-Options"] = "nosniff";
    h["X-Frame-Options"] = "DENY";
    h["Referrer-Policy"] = "no-referrer-when-downgrade";
    h["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()";
    await next();
});


app.UseStatusCodePagesWithReExecute("/error/{0}");
app.UseExceptionHandler("/error/500");
// CF proxy headers
app.UseForwardedHeaders(new ForwardedHeadersOptions{
    ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
});

// Static files + cache
app.UseStaticFiles(new StaticFileOptions {
  OnPrepareResponse = ctx => {
    var p = ctx.File.Name.ToLowerInvariant();
    if (p.EndsWith(".css")||p.EndsWith(".js")||p.EndsWith(".png")||p.EndsWith(".jpg")||p.EndsWith(".jpeg")||p.EndsWith(".webp"))
      ctx.Context.Response.Headers["Cache-Control"]="public, max-age=31536000, immutable";
    else
      ctx.Context.Response.Headers["Cache-Control"]="public, max-age=300";
  }
});

if (!app.Environment.IsDevelopment())
    app.UseExceptionHandler("/error");

app.UseRouting();
app.UseAuthorization();

// routes
app.MapControllerRoute(
    name: "postBySlug",
    pattern: "Posts/{slug}",
    defaults: new { controller = "Posts", action = "SlugRouter" });

app.MapGet("/ready", () => Results.Ok("ok"));
app.MapGet("/healthz", () => Results.Ok("OK"));

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=People}/{action=Index}/{id?}");

app.Run();
