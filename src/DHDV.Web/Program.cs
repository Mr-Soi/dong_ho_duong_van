using DHDV.Web.Data;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

// Lắng nghe 0.0.0.0:8080
builder.WebHost.UseUrls("http://0.0.0.0:8080");

// MVC
builder.Services.AddControllersWithViews();

// Connection string
var envCs = Environment.GetEnvironmentVariable("CONN_STR");
var cs = !string.IsNullOrWhiteSpace(envCs)
    ? envCs
    : builder.Configuration.GetConnectionString("DHDV")
      ?? builder.Configuration.GetConnectionString("Default")
      ?? "Server=sql,1433;Database=dhdv;User ID=sa;Password=YourStrong@Passw0rd;Encrypt=False;TrustServerCertificate=True;MultipleActiveResultSets=True";

// DbContext
builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseSqlServer(cs, sql => sql.EnableRetryOnFailure(3))
);

// Forwarded headers (Cloudflare)
builder.Services.Configure<ForwardedHeadersOptions>(o =>
{
    o.ForwardedHeaders = ForwardedHeaders.XForwardedFor
                       | ForwardedHeaders.XForwardedProto
                       | ForwardedHeaders.XForwardedHost;
    o.KnownNetworks.Clear();
    o.KnownProxies.Clear();
});

var app = builder.Build();

if (!app.Environment.IsDevelopment())
    app.UseExceptionHandler("/Home/Error");

app.UseForwardedHeaders();
app.UseStaticFiles();
app.UseRouting();

// Health
app.MapGet("/health", async (HttpResponse rsp) =>
{
    const string payload = "{\"ok\":true}";
    rsp.ContentType = "application/json; charset=utf-8";
    rsp.Headers.ContentLength = payload.Length;
    await rsp.WriteAsync(payload);
});

// DB đang dùng
app.MapGet("/__db", () =>
{
    var ic = new SqlConnectionStringBuilder(cs).InitialCatalog ?? "";
    return Results.Text(ic, "text/plain; charset=utf-8");
});

// Basic auth cho /admin/*
app.Use(async (ctx, next) =>
{
    if (ctx.Request.Path.StartsWithSegments("/admin"))
    {
        var u = Environment.GetEnvironmentVariable("ADMIN_USER") ?? "admin";
        var p = Environment.GetEnvironmentVariable("ADMIN_PASS") ?? "changeme";
        var ok = false;

        if (ctx.Request.Headers.TryGetValue("Authorization", out var auth) &&
            auth.ToString().StartsWith("Basic ", StringComparison.OrdinalIgnoreCase))
        {
            var b64 = auth.ToString().Substring("Basic ".Length).Trim();
            var raw = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(b64));
            var parts = raw.Split(':', 2);
            ok = parts.Length == 2 && parts[0] == u && parts[1] == p;
        }

        if (!ok)
        {
            ctx.Response.StatusCode = 401;
            ctx.Response.Headers["WWW-Authenticate"] = "Basic realm=\"Admin\"";
            await ctx.Response.WriteAsync("Unauthorized");
            return;
        }
    }
    await next();
});

// /admin -> Admin/Dashboard/Index
app.MapControllerRoute(
    name: "admin_root",
    pattern: "admin",
    defaults: new { area = "Admin", controller = "Dashboard", action = "Index" }
);

// Area Admin (đặt trước default)
app.MapAreaControllerRoute(
    name: "AdminArea",
    areaName: "Admin",
    pattern: "admin/{controller=Dashboard}/{action=Index}/{id?}"
);

// Default
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}"
);

app.Run();
