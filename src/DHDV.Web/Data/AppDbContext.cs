using System.Linq;                    // cần cho Any()
using DHDV.Web.Models;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) {}

        public DbSet<Person> Persons => Set<Person>();
        public DbSet<Category> Categories => Set<Category>();
        public DbSet<Post> Posts => Set<Post>();
        public DbSet<Album> Albums => Set<Album>();
        public DbSet<Photo> Photos => Set<Photo>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Person: Father 1-n Children
            modelBuilder.Entity<Person>()
                .HasOne(p => p.Father)
                .WithMany(f => f.Children)
                .HasForeignKey(p => p.FatherId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Person>()
                .HasOne(p => p.Father)
                .WithMany(f => f.Children)
                .HasForeignKey(p => p.FatherId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Person>()
                .HasOne(p => p.Mother)
                .WithMany()
                .HasForeignKey(p => p.MotherId)
                .OnDelete(DeleteBehavior.NoAction);

        }
    }

    public static class DbInitializer
    {
        public static void Seed(AppDbContext db)
        {
            if (db.Persons.Any()) return;

            var ancestor = new Person { FullName = "Dương Văn Tổ", Generation = 1, BirthPlace = "Nam Định" };
            var child1 = new Person { FullName = "Dương Văn A", Generation = 2, Father = ancestor };
            var child2 = new Person { FullName = "Dương Văn B", Generation = 2, Father = ancestor };
            var grand1 = new Person { FullName = "Dương Văn C", Generation = 3, Father = child1 };
            db.Persons.AddRange(ancestor, child1, child2, grand1);

            var cateGiaPha = new Category { Name = "Gia phả" };
            var cateBanTin = new Category { Name = "Bản tin" };
            db.Categories.AddRange(cateGiaPha, cateBanTin);

            db.Posts.Add(new Post {
                Title = "Giới thiệu Dòng họ Dương Văn",
                Category = cateGiaPha,
                Content = "Dòng họ Dương Văn có lịch sử lâu đời...",
                IsPublished = true,
                IsDeleted = false,
                CreatedAt = System.DateTime.UtcNow,
                PublishedAt = System.DateTime.UtcNow
            });

            var alb = new Album { Name = "Hình ảnh truyền thống", Description = "Ảnh lưu niệm" };
            alb.Photos.Add(new Photo { Path = "/img/sample1.jpg", Caption = "Ảnh 1" });
            alb.Photos.Add(new Photo { Path = "/img/sample2.jpg", Caption = "Ảnh 2" });
            db.Albums.Add(alb);

            db.SaveChanges();
        }
    }
}
