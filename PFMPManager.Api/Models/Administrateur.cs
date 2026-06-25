using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("Administrateur")]
    public class Administrateur
    {
        [Key]
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }
        // { get; set; } � EF Core reads this to save to DB, writes this when fetching from DB
        // = string.Empty  � default value is "" instead of null (avoids null warnings)


    }
}