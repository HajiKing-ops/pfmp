using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("planning")]
    public class Planning
    {
        [Key]
        [Column("Id_Planning")]
        public int Id_Planning { get; set; }
        // { get; set; } — EF Core reads this to save to DB, writes this when fetching from DB
        // = string.Empty  — default value is "" instead of null (avoids null warnings)


        [Column("Jour")]
        [MaxLength(10)]
        public string? Jour { get; set; }
        // string? — the ? means this column is nullable (optional, can be null)


        [Column("HoraireDebut")]
        public int HoraireDebut { get; set; }

        [Column("HoraireFin")]
        public int HoraireFin { get; set; }
    }
}