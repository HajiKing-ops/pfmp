using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    // Represents the base user account shared by all application roles
    [Table("Utilisateur")]
    public class Utilisateur
    {
        [Key]
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }
        

        [Column("Nom")]
        [MaxLength(25)]
        public string? Nom { get; set; }
        

        [Column("Prenom")]
        [MaxLength(25)]
        public string? Prenom { get; set; }

        [Column("Login")]
        [MaxLength(50)]
        public string? Login { get; set; }

        [Column("Pwd")]
        [MaxLength(256)]
        public string? Pwd { get; set; }

    }
}