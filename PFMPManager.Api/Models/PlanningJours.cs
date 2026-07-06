using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    // Represents one working day in a weekly PFMP planning
    [Table("PlanningJours")]
    public class PlanningJours
    {
        [Key]
        [Column("Id_planningJour")]
        public int Id_planningJour { get; set; }
    

        [Column("Jour")]
        [MaxLength(20)]
        public string? Jour { get; set; }
      

        [Column("MatinDebut")]
        public TimeSpan? MatinDebut { get; set; }

        [Column("MatinFin")]
        public TimeSpan? MatinFin { get; set; }

        [Column("ApresMidiDebut")]
        public TimeSpan? ApresMidiDebut { get; set; }

        [Column("ApresMidiFin")]
        public TimeSpan? ApresMidiFin { get; set; }

        [Column("totalMinutes")]
        public int TotalMinutes  { get; set; }

        [Column("Id_Planning")]
        public int Id_Planning { get; set; }
    }
}