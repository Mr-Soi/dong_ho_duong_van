using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace DHDV.Web.Models
{
    [Table("Persons")]
    public class Person
    {
        public int Id { get; set; }

        public string? DisplayName { get; set; }
        public string? Alias { get; set; }
        public DateTime? BirthDate { get; set; }
        public DateTime? DeathDate { get; set; }
        public int? Generation { get; set; }
        public string? Branch { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string? CreatedBy { get; set; }
        public string? UpdatedBy { get; set; }
        public string? FullNameNorm { get; set; }
        public string? AliasNorm { get; set; }
        public int? BirthYear { get; set; }
        public int? DeathYear { get; set; }
        public int? LegacyId { get; set; }
        public string? DisplayNameNorm { get; set; }
        public int? YearOfBirth { get; set; }
        public int? YearOfDeath { get; set; }
        public bool IsDeleted { get; set; }
        public string? NameNorm { get; set; }

        // scalar FK dùng trong controller
        public int? FatherId { get; set; }
        public int? MotherId { get; set; }

        // alias cho code cũ gọi FullName
        [NotMapped]
        public string? FullName { get => DisplayName; set => DisplayName = value; }

        // chặn EF cố map quan hệ tự tham chiếu
        [NotMapped] public Person? Father { get; set; }
        [NotMapped] public Person? Mother { get; set; }
        [NotMapped] public List<Person> Children { get; set; } = new();
    }
}
