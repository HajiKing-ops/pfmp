using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("Organisation")]
    public class Organisation
    {
        [Key]
        [Column("SIRET")]
        [MaxLength(14)]
        public string Siret { get; set; } = string.Empty;

        [Column("RaisonSociale")]
        [MaxLength(50)]
        public string? RaisonSociale { get; set; }

        [Column("SecteurActivite")]
        [MaxLength(50)]
        public string? SecteurActivite { get; set; }

        [Column("Activite")]
        [MaxLength(50)]
        public string? Activite { get; set; }

        [Column("Adresse")]
        [MaxLength(100)]
        public string? Adresse { get; set; }

        [Column("CodePostal")]
        [MaxLength(7)]
        public string? CodePostal { get; set; }

        [Column("Ville")]
        [MaxLength(50)]
        public string? Ville { get; set; }

        [Column("AdresseMail")]
        [MaxLength(75)]
        public string? AdresseMail { get; set; }

        [Column("NumTelephone")]
        [MaxLength(10)]
        public string? NumTelephone { get; set; }


    }
}