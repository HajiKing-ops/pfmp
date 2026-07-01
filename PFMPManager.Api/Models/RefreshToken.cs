using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("RefreshToken")]
    public class RefreshToken
    {
        [Key]
        [Column("Id_RefreshToken")]
        public int Id_RefreshToken { get; set; }


        [Column("TokenHash")]
        [MaxLength(256)]
        public string? TokenHash { get; set; }


        [Column("CreatedAt")]
        public DateTime? CreatedAt { get; set; }


        [Column("ExpiresAt")]
        public DateTime? ExpiresAt { get; set; }


        [Column("RevokedAt")]
        public DateTime? RevokedAt { get; set; }


        [Column("ReplacedByTokenHash")]
        [MaxLength(256)]
        public string? ReplacedByTokenHash { get; set; }

        [Column("Id_Utilisateur")]
        public int Id_Utilisateur { get; set; }

        [MaxLength(36)]
        public string TokenFamilyId { get; set; } = string.Empty;


    }
}