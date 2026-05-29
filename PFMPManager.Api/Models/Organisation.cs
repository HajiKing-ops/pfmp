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
        public string SIRET { get; set; } = string.Empty;
        // { get; set; } — EF Core reads this to save to DB, writes this when fetching from DB
        // = string.Empty  — default value is "" instead of null (avoids null warnings)


        [Column("RaisonSociale")]
        [MaxLength(50)]
        public string? RaisonSociale { get; set; }
        // string? — the ? means this column is nullable (optional, can be null)


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