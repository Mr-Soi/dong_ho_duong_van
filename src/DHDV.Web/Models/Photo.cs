namespace DHDV.Web.Models
{
    public class Photo
    {
        public int Id { get; set; }
        public int AlbumId { get; set; }
        public string Url { get; set; } = "";
        public string? ThumbUrl { get; set; }
        public string? Caption { get; set; }
    }
}
