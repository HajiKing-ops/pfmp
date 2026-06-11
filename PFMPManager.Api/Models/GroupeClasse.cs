using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("groupeclasse")]
    public class GroupeClasse
    {
        [Column("Id_Etablissement")]
        public int Id_Etablissement { get; set; }

        [Column("Id_Classe")]
        public int Id_Classe { get; set; }


        [Column("LibelleClasse")]
        [MaxLength(50)]
        public string? LibelleClasse { get; set; }

        [Column("Grade")]
        [MaxLength(15)]
        public string? Grade { get; set; }

        [Column("Id_Filiere")]
        public int Id_Filiere { get; set; }



    }
}