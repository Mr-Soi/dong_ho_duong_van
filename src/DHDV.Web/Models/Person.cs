namespace DHDV.Web.Models
{
    public class Person
    {
        public int Id { get; set; }

        // Đồng bộ với controllers/views
        public string? DisplayName { get; set; }
        public string? Alias { get; set; }

        public int? Generation { get; set; }
        public string? Branch { get; set; }

        public int? FatherId { get; set; }
        public int? MotherId { get; set; }

        public System.DateTime? BirthDate { get; set; }
        public System.DateTime? DeathDate { get; set; }

        public bool IsDeleted { get; set; }
    }
}
