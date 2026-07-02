using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    // Represents a message sent in a PFMP chat
    [Table("Message")]
    public class Message
    {
        [Key]
        [Column("Id_Message")]
        public int Id_Message { get; set; }

        [Column("Id_PFMP")]
        public int Id_PFMP { get; set; }
   
        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

        [Column("RoleExpediteur")]
        [MaxLength(50)]
        public string RoleExpediteur { get; set; } = string.Empty;

        [Column("Contenu")]
        [MaxLength(250)]
        public string Contenu { get; set; } = string.Empty;


        [Column("DateEnvoi")]
        public DateTime? DateEnvoi { get; set; }


    }
}