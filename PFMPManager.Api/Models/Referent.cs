using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("Referent")]
    public class Referent
    {
        [Key]
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }
        // { get; set; } � EF Core reads this to save to DB, writes this when fetching from DB
        // = string.Empty  � default value is "" instead of null (avoids null warnings)


        [Column("NumTelephone")]
        [MaxLength(10)]
        public string? NumTelephone { get; set; }
        // string? � the ? means this column is nullable (optional, can be null)


        [Column("AdresseMail")]
        [MaxLength(75)]
        public string? AdresseMail { get; set; }
    }
}