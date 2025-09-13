namespace DHDV.Web.Models
{
    public class Post
    {
        public int Id { get; set; }
        public string? Title { get; set; }
        public string? Content { get; set; }
        public System.DateTime? PublishedAt { get; set; }
        public bool IsDeleted { get; set; }

        // bổ sung để khớp Admin/Views
        public string? Summary { get; set; }
        public string? CoverImage { get; set; }
        public string? Slug { get; set; }
        public bool? IsPublished { get; set; }
        public System.DateTime? CreatedAt { get; set; }
        public int? CategoryId { get; set; }
        public Category? Category { get; set; }
    }
}
