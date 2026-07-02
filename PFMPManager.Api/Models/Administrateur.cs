using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    // Represents an administrator user profile
    [Table("Administrateur")]
    public class Administrateur
    {
        [Key]
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }
    

    }
}