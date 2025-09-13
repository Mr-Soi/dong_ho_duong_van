namespace DHDV.Web.Models
{
    public class Post
    {
        public int Id { get; set; }
        public string? Title { get; set; }
        public string? Content { get; set; }
        public System.DateTime? PublishedAt { get; set; }
        public bool IsDeleted { get; set; }
    }
}
