using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("professionnel")]
    public class Professionnel
    {
        [Key]
        [Column("Id_Utilisateur")]
        
        public int Id_Utilisateur { get; set; } 
        


        [Column("Fonction")]
        [MaxLength(50)]
        public string? Fonction { get; set; }
        // string? � the ? means this column is nullable (optional, can be null)


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