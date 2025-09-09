using System.Text.Json;
namespace YourApp.Helpers
{
    public static class SeoJson
    {
        public static string NewsArticle(string title,string desc,string url,DateTime? pub)
        {
            var obj = new {
                @context = "https://schema.org",
                @type = "NewsArticle",
                headline = title,
                description = desc,
                mainEntityOfPage = url,
                datePublished = pub?.ToString("yyyy-MM-ddTHH:mm:sszzz")
            };
            return JsonSerializer.Serialize(obj);
        }
    }
    public class SeoVM{ public string Title{get;set;}=""; public string Description{get;set;}=""; public string Url{get;set;}=""; public DateTime? Published{get;set;} }
}