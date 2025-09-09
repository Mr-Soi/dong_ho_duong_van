using System.ComponentModel.DataAnnotations;

namespace DHDV.Web.Models
{
    public class Album
    {
        public int Id { get; set; }
        [Required, MaxLength(150)]
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<Photo> Photos { get; set; } = new();
    }

    public class Photo
    {
        public int Id { get; set; }
        [Required]
        public string Path { get; set; } = string.Empty;
        public string? Caption { get; set; }
        public int AlbumId { get; set; }
        public Album? Album { get; set; }
    }
}
