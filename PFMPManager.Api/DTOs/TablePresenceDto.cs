
namespace PFMPManager.Api.DTOs
{
    public class TablePresenceDto
    {
        public DateTime? DateJour { get; set; }
        public string Etat { get; set; } = string.Empty;
        public int Retard { get; set; } 
        public bool Justification { get; set; }
        public int Id_Utilisateur { get; set; } 
    }
}