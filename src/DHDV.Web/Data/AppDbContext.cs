using Microsoft.EntityFrameworkCore;
using DHDV.Web.Models;

namespace DHDV.Web.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Person> Persons => Set<Person>();
        public DbSet<Post> Posts => Set<Post>();
        public DbSet<Category> Categories => Set<Category>();
        public DbSet<Album> Albums => Set<Album>();
        public DbSet<DHDV.Web.Models.Photo> Photos { get; set; } = default!;



        protected override void OnModelCreating(ModelBuilder mb)
        {
        mb.Entity<Person>().Ignore(p => p.Father)
                            .Ignore(p => p.Mother)
                            .Ignore(p => p.Children)
                            .Ignore(p => p.FullName);
        mb.Entity<Album>().Property(a => a.CoverUrl).HasColumnName("CoverImage"); // nếu DB dùng CoverImage
        }

    }
}
