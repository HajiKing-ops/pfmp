using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
     // Represents a PFMP internship linked to a student, an administrator, an organisation and a planning
    [Table("PFMP")]
    public class Pfmp
    {
        [Key]
        [Column("Id_PFMP")]
        public int Id_PFMP { get; set; } 
    

        [Column("DateDebut")]
        public DateTime? DateDebut { get; set; }
   
        [Column("DateFin")]
        public DateTime? DateFin { get; set; }

        // Administrator responsible for validating the PFMP
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

        [Column("Id_Planning")]
        public int Id_Planning { get; set; }

        [Column("SIRET")]
        [MaxLength(14)]
        public string SIRET { get; set; } = string.Empty;

        // Student linked to this PFMP
        [Column("Id_Utilisateur_1")]
        public int Id_Utilisateur_1 { get; set; }

    }
}