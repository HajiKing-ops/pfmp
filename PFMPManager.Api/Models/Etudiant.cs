using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("Etudiant")]
    public class Etudiant
    {
        [Key]
        [Column("Id_Utilisateur_1")]
        public int Id_Utilisateur_1 { get; set; }  // ? -> can be null 
  

        [Column("Date_Naissance")]
        public DateTime? Date_Naissance { get; set; }
     
        [Column("Adresse")]
        [MaxLength(100)]
        public string? Adresse { get; set; }

        [Column("CodePostal")]
        public string? CodePostal { get; set; }

        [Column("Ville")]
        [MaxLength(50)]
        public string? Ville { get; set; }
         
        [Column("NumTelephone")]
        [MaxLength(10)]
        public string? NumTelephone { get; set; }

        [Column("AdresseMail")]
        [MaxLength(75)]
        public string? AdresseMail { get; set; }

        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }




    }
}