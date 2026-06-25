using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("Utilisateur")]
    public class Utilisateur
    {
        [Key]
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }
        // { get; set; }  EF Core reads this to save to DB, writes this when fetching from DB
        // = string.Empty   default value is "" instead of null (avoids null warnings)


        [Column("Nom")]
        [MaxLength(25)]
        public string? Nom { get; set; }
        // string? the ? means this column is nullable (optional, can be null)

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