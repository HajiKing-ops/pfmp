using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("TablePresence")]
    public class TablePresence
    {
        [Key]
        [Column("Id_TablePresence")]
        public int Id_TablePresence { get; set; }
        // { get; set; } � EF Core reads this to save to DB, writes this when fetching from DB
        // = string.Empty  � default value is "" instead of null (avoids null warnings)


        [Column("DateJour")]
        public DateTime? DateJour { get; set; }
        // string? � the ? means this column is nullable (optional, can be null)


        [Column("Etat")]
        [MaxLength(50)]
        public string? Etat { get; set; }

        [Column("Retard")]
        public int Retard { get; set; }

        [Column("Justification")]
        public bool Justification { get; set; }

        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

    }
}