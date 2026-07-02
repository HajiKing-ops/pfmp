using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
     // Represents a student's daily presence record during a PFMP
    [Table("TablePresence")]
    public class TablePresence
    {
        [Key]
        [Column("Id_TablePresence")]
        public int Id_TablePresence { get; set; }

        [Column("DateJour")]
        public DateTime? DateJour { get; set; }
        
        [Column("Etat")]
        [MaxLength(50)]
        public string? Etat { get; set; }

        [Column("Retard")]
        public int Retard { get; set; }

        [Column("Justification")]
        public bool Justification { get; set; }
        
        // Student linked to this presence record
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

    }
}