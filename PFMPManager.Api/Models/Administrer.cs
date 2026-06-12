using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("administrer")]
    public class Administrer
    {
        
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

        [Column("Id_Etablissement")]
        public int Id_Etablissement { get; set; }



    }
}