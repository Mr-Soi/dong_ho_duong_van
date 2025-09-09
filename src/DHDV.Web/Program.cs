using DHDV.Web.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);
builder.WebHost.UseUrls("http://0.0.0.0:8080");

builder.Services.AddControllersWithViews();

var cs = builder.Configuration.GetConnectionString("DefaultConnection")
         ?? "Server=dhdv_sql,1433;Database=dhdv;User ID=sa;Password=YourStrong@Passw0rd;Encrypt=True;TrustServerCertificate=True";
builder.Services.AddDbContext<AppDbContext>(o => o.UseSqlServer(cs));

var app = builder.Build();
app.UseStaticFiles();
app.UseRouting();

app.Use(async (ctx, next) =>
{
    await next();
    if (ctx.Response.ContentType?.StartsWith("text/html") == true)
    {
        ctx.Response.Headers["Cache-Control"] = "no-store, no-cache, must-revalidate";
        ctx.Response.Headers["Pragma"] = "no-cache";
        ctx.Response.Headers["Expires"] = "0";
    }
});

app.MapControllerRoute(name:"default", pattern:"{controller=Home}/{action=Index}/{id?}");

app.MapGet("/ping", () => Results.Ok("pong"));
app.MapGet("/health", () => Results.Ok(new { ok=true }));
app.MapGet("/ready", async (IConfiguration cfg) => {
    try {
        await using var con = new SqlConnection(cs);
        await con.OpenAsync();
        await using var cmd = new SqlCommand("SELECT 1", con);
        await cmd.ExecuteScalarAsync();
        return Results.Ok();
    } catch { return Results.StatusCode(503); }
});

app.Run();
