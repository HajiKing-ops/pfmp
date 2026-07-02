using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    // Represents a referent user profile linked to supervised students
    [Table("Referent")]
    public class Referent
    {
        [Key]
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }
   


        [Column("NumTelephone")]
        [MaxLength(10)]
        public string? NumTelephone { get; set; }
 


        [Column("AdresseMail")]
        [MaxLength(75)]
        public string? AdresseMail { get; set; }
    }
}