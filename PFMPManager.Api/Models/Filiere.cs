using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("Filiere")]
    public class Filiere
    {
        [Key]
        [Column("Id_Filiere")]
        public int Id_Filiere { get; set; }

        [Column("LibelleFiliere")]
        [MaxLength(50)]
        public string LibelleFiliere { get; set; } = string.Empty;


    }
}