using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("etudier")]
    public class Etudier
    {

        [Column("Id_Utilisateur_1")]
        public int Id_Utilisateur_1 { get; set; }
      


        [Column("Id_Etablissement")]
        public int Id_Etablissement{ get; set; }


        [Column("Id_Classe")]
        public int Id_Classe { get; set; }

        [Column("AnneeRentree")]
        public int AnneeRentree { get; set; }

        [Column("AnneeSortie")]
        public int AnneeSortie { get; set; }



    }
}