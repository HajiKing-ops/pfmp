using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    // Represents the relationship between an administrator and an establishment
    [Table("Administrer")]
    public class Administrer
    {
        
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

        [Column("Id_Etablissement")]
        public int Id_Etablissement { get; set; }



    }
}