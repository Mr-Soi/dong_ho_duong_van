using Microsoft.EntityFrameworkCore;
using DHDV.Web.Models;

namespace DHDV.Web.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> o) : base(o) {}

        public DbSet<Person>   Persons    { get; set; } = default!;
        public DbSet<Album>    Albums     { get; set; } = default!;
        public DbSet<Photo>    Photos     { get; set; } = default!;
        public DbSet<Post>     Posts      { get; set; } = default!;
        public DbSet<Category> Categories { get; set; } = default!;

        protected override void OnModelCreating(ModelBuilder b)
        {
            b.Entity<Person>().ToTable("Persons");
            b.Entity<Album>().ToTable("Albums");
            b.Entity<Photo>().ToTable("Photos");
            b.Entity<Post>().ToTable("Posts");
            b.Entity<Category>().ToTable("Categories");
        }
    }
}
