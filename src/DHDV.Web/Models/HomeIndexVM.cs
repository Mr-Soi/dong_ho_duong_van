using System.Collections.Generic;

namespace DHDV.Web.Models
{
    public class HomeIndexVM
    {
        public List<Post> Posts { get; set; } = new();
        public List<Person> People { get; set; } = new();
    }
}
