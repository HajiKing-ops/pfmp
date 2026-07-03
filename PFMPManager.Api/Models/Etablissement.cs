using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    // Represents an establishment where class groups are managed
    [Table("Etablissement")]
    public class Etablissement
    {
        [Key]
        [Column("Id_Etablissement")]
        public int Id_Etablissement { get; set; } 

        [Column("NomEtablissement")]
        [MaxLength(50)]
        public string NomEtablissement { get; set; } =string.Empty;
       
        [Column("Adresse")]
        [MaxLength(50)]
        public string Adresse { get; set; } = string.Empty;


        [Column("CodePostal")]
        [MaxLength(7)]
        public string? CodePostal { get; set; }

        [Column("Ville")]
        [MaxLength(50)]
        public string? Ville { get; set; }

        [Column("NumTelephone")]
        [MaxLength(10)]
        public string? NumTelephone { get; set; }

        [Column("AdresseMail")]
        [MaxLength(50)]
        public string AdresseMail { get; set; } = string.Empty;


    }
}