namespace DHDV.Web.Models
{
    public class PostVM
    {
        public string Title { get; set; } = "";
        public string Slug  { get; set; } = "";
        public string Content { get; set; } = "";
        public System.DateTime? PublishedAt { get; set; }
        public bool IsPinned { get; set; }
    }

    public class PaginationVM
    {
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public int TotalItems { get; set; }
        public int TotalPages => (int)System.Math.Ceiling(TotalItems / (double)PageSize);
        public bool HasPrev => Page > 1;
        public bool HasNext => Page < TotalPages;
    }

    public class NewsIndexVM
    {
        public System.Collections.Generic.IEnumerable<PostVM> Posts { get; set; } = System.Linq.Enumerable.Empty<PostVM>();
        public PaginationVM Pagination { get; set; } = new();
        public string? Query { get; set; }
        public string Sort { get; set; } = "newest";
        public bool HasMore => Pagination?.HasNext ?? false;
    }
}
