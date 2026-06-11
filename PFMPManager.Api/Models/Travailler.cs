using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    public class Travailler
    {
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

        [Column("SIRET")]
        [MaxLength(14)]
        public string? SIRET { get; set; }

    }
}