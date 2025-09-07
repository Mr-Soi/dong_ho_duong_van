using System;
using System.Collections.Generic;

namespace DHDV.Web.Models
{
    public class Category
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public string? Slug { get; set; }
        public DateTime CreatedAt { get; set; }

        // quan hệ ngược (tùy chọn)
        public ICollection<Post>? Posts { get; set; }
    }
}
