using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
     // Represents a student's enrolment in a class for a school year
    [Table("Etudier")]
    public class Etudier
    {

        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }
      

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