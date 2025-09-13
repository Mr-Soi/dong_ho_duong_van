using Microsoft.EntityFrameworkCore;
using DHDV.Web.Models;

namespace DHDV.Web.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Person> Persons { get; set; } = default!;
        public DbSet<Album>  Albums  { get; set; } = default!;
        public DbSet<Photo>  Photos  { get; set; } = default!;
        public DbSet<Post>   Posts   { get; set; } = default!;

        protected override void OnModelCreating(ModelBuilder b)
        {
            // map mặc định dbo.<plural> đủ dùng với seed hiện tại
            b.Entity<Person>().ToTable("Persons");
            b.Entity<Album>().ToTable("Albums");
            b.Entity<Photo>().ToTable("Photos");
            b.Entity<Post>().ToTable("Posts");
        }
    }
}
