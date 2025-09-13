using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace DHDV.Web.Models
{
    [Table("Albums")]
    public class Album
    {
        public int Id { get; set; }

        // nếu DB dùng "Title" và "Description" giữ nguyên;
        // nếu DB dùng tên khác, đổi bằng [Column("TenCotThucTe")]
        public string Title { get; set; } = "";
        public string? Description { get; set; }

        // hay gặp lệch tên CoverUrl vs CoverImage → map an toàn:
        [Column("CoverImage")] public string? CoverUrl { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
