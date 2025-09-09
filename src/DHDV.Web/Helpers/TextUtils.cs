using System.Net;
using System.Text.RegularExpressions;
namespace YourApp.Helpers
{
    public static class TextUtils
    {
        static readonly Regex RxBlocks = new(@"<(script|style|iframe)[\s\S]*?<\/\1>", RegexOptions.IgnoreCase|RegexOptions.Compiled);
        static readonly Regex RxImg    = new(@"<img[^>]*>", RegexOptions.IgnoreCase|RegexOptions.Compiled);
        static readonly Regex RxTags   = new(@"<[^>]+>", RegexOptions.Compiled);
        static readonly Regex RxSpace  = new(@"\s{2,}", RegexOptions.Compiled);
        static readonly Regex RxDataImg= new(@"data:image\/[a-zA-Z]+;base64,[A-Za-z0-9+\/=]+", RegexOptions.Compiled);

        public static string StripHtml(string? html)
        {
            if (string.IsNullOrWhiteSpace(html)) return string.Empty;
            html = RxBlocks.Replace(html, " ");
            html = RxImg.Replace(html, " ");
            html = RxTags.Replace(html, " ");
            html = WebUtility.HtmlDecode(html);
            html = RxDataImg.Replace(html, "");
            html = RxSpace.Replace(html, " ").Trim();
            return html;
        }
        public static string Excerpt(string? text, int max = 160)
        {
            if (string.IsNullOrWhiteSpace(text)) return string.Empty;
            var t = text.Trim();
            if (t.Length <= max) return t;
            t = t[..max];
            var cut = t.LastIndexOf(' ');
            if (cut > 0) t = t[..cut];
            return t + "…";
        }
        public static int WordCount(string? text)
        {
            if (string.IsNullOrWhiteSpace(text)) return 0;
            return Regex.Matches(text.Trim(), @"[\p{L}\p{N}]+").Count;
        }
        public static int ReadMinutes(string? text, int wpm = 220)
        {
            var words = WordCount(text);
            if (words == 0) return 1;
            return Math.Max(1, (int)Math.Ceiling(words / (double)wpm));
        }
    }
}