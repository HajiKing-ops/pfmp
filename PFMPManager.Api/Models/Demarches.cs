using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("demarches")]
    public class Demarches
    {
        
        [Column("SIRET")]
        [MaxLength(14)]
        public string SIRET { get; set; } = string.Empty;
        // { get; set; } — EF Core reads this to save to DB, writes this when fetching from DB
        // = string.Empty  — default value is "" instead of null (avoids null warnings)


        [Column("Id_Utilisateur")]
        public string? Id_Utilisateur { get; set; } = string.Empty;
        // string? — the ? means this column is nullable (optional, can be null)


        [Column("dateRefus")]
        public Datetime? dateRefus { get; set; }


        [Column("status")]
        [MaxLength(50)]
        public string? status { get; set; }

       

    }
}