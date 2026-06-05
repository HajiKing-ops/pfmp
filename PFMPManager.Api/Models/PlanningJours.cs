using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("planningjours")]
    public class PlanningJours
    {
        [Key]
        [Column("Id_planningJour")]
        public int Id_planningJour { get; set; }
        // { get; set; } — EF Core reads this to save to DB, writes this when fetching from DB
        // = string.Empty  — default value is "" instead of null (avoids null warnings)


        [Column("Jour")]
        [MaxLength(20)]
        public string? Jour { get; set; }
        // string? — the ? means this column is nullable (optional, can be null)


        [Column("MatinDebut")]
        public TimeSpan? MatinDebut { get; set; }

        [Column("MatinFin")]
        public TimeSpan? MatinFin { get; set; }

        [Column("ApresMidiDebut")]
        public TimeSpan? ApresMidiDebut { get; set; }

        [Column("ApresMidiFin")]
        public TimeSpan? ApresMidiFin { get; set; }

        [Column("TotalHeures")]
        public int TotalHeures { get; set; }

        [Column("Id_Planning")]
        public int Id_Planning { get; set; }
    }
}