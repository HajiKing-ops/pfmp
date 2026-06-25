using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("PFMP")]
    public class Pfmp
    {
        [Key]
        [Column("Id_PFMP")]
        public int Id_PFMP { get; set; } 
        // { get; set; } � EF Core reads this to save to DB, writes this when fetching from DB
        // = string.Empty  � default value is "" instead of null (avoids null warnings)


        [Column("DateDebut")]
        public DateTime? DateDebut { get; set; }
        // string? � the ? means this column is nullable (optional, can be null)


        [Column("DateFin")]
        public DateTime? DateFin { get; set; }

        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

        [Column("Id_Planning")]
        public int Id_Planning { get; set; }

        [Column("SIRET")]
        [MaxLength(14)]
        public string SIRET { get; set; } = string.Empty;

        [Column("Id_Utilisateur_1")]
        public int Id_Utilisateur_1 { get; set; }

    }
}