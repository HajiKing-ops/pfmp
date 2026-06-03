using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("demarches")]

    public class Contacter 
    {

        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

        [Column("SIRET")]
        [MaxLength(14)]
        public string? SIRET { get; set; }

        [Column("TypeContact")]
        [MaxLength(10)]
        public string? TypeContact { get; set; }

        [Column("DateDemande")]
        public DateTime? DateDemande { get; set; }

        [Column("StatutDemande")]
        [MaxLength(12)]
        public string? StatutDemande { get; set; }

    }
}