using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("demarches")]
    public class Demarches
    {

        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

        [Column("SIRET")]
        [MaxLength(14)]
        public string SIRET { get; set; }
        
        [Column("dateRefus")]
        public DateTime? dateRefus { get; set; }

        [Column("entreprise")]
        [MaxLength(50)]
        public string? entreprise { get; set; }

        [Column("contact")]
        [MaxLength(80)]
        public string? contact { get; set; }

        [Column("Adresse")]
        [MaxLength(75)]
        public string? Adresse { get; set; }

    }
}