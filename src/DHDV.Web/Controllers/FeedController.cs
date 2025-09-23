using System.Text;
using System.Xml;
using DHDV.Web.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DHDV.Web.Controllers;
public class FeedController : Controller
{
    private readonly AppDbContext _db;
    public FeedController(AppDbContext db)=>_db=db;

    [HttpGet("feed.xml")]
    public async Task<IActionResult> Index()
    {
        var baseUrl=$"{Request.Scheme}://{Request.Host}";
        var posts=await _db.Set<Post>()
            .AsNoTracking()
            .OrderByDescending(x=>x.PublishedAt??x.CreatedAt)
            .Take(100)
            .Select(x=>new{ x.Title,x.Slug,x.Summary,x.CoverImage,x.PublishedAt,x.CreatedAt })
            .ToListAsync();

        var sb=new StringBuilder();
        using var xw=XmlWriter.Create(sb,new XmlWriterSettings{Encoding=new UTF8Encoding(false),Indent=false});
        xw.WriteStartDocument();
        xw.WriteStartElement("rss"); xw.WriteAttributeString("version","2.0");
        xw.WriteStartElement("channel");
        xw.WriteElementString("title","Dòng họ Dương Văn");
        xw.WriteElementString("link",baseUrl);
        xw.WriteElementString("description","Bài viết mới nhất");
        xw.WriteElementString("lastBuildDate",DateTime.UtcNow.ToString("r"));

        foreach(var p in posts){
            var link=$"{baseUrl}/Posts/{p.Slug}";
            xw.WriteStartElement("item");
            xw.WriteElementString("title",p.Title??"Bài viết");
            xw.WriteElementString("link",link);
            xw.WriteElementString("guid",link);
            if(p.PublishedAt!=null || p.CreatedAt!=null)
                xw.WriteElementString("pubDate",((p.PublishedAt??p.CreatedAt)??DateTime.UtcNow).ToUniversalTime().ToString("r"));
            if(!string.IsNullOrWhiteSpace(p.Summary))
                xw.WriteElementString("description",p.Summary);
            xw.WriteEndElement();
        }
        xw.WriteEndElement(); xw.WriteEndElement(); xw.WriteEndDocument(); xw.Flush();
        return Content(sb.ToString(),"application/rss+xml",Encoding.UTF8);
    }

    private class Post{ public string Title{get;set;}=""; public string Slug{get;set;}=""; public string? Summary{get;set;} public string? CoverImage{get;set;} public DateTime? PublishedAt{get;set;} public DateTime? CreatedAt{get;set;} }
}
