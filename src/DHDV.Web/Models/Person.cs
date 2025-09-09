using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace DHDV.Web.Models
{
    public class Person
    {
        public int Id { get; set; }
        public string? FullName { get; set; }
        public string? Alias { get; set; }
        public System.DateTime? BirthDate { get; set; }
        public System.DateTime? DeathDate { get; set; }
        public int? Generation { get; set; }
        public string? Branch { get; set; }
        public string? BirthPlace { get; set; }   // thêm để khớp DbInitializer.Seed
        public bool IsDeleted { get; set; }

        public int? FatherId { get; set; }
        public int? MotherId { get; set; }

        public Person? Father { get; set; }

        [ForeignKey(nameof(MotherId))]
        public Person? Mother { get; set; }

        public List<Person> Children { get; set; } = new(); // theo quan hệ Father
    }
}
