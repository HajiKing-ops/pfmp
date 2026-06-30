
namespace PFMPManager.Api.DTOs
{
    public class UpdateTablePresenceDto
    {
        public string Etat { get; set; } = string.Empty;
        public int Retard { get; set; }
        public DateTime? DateJour { get; set; }
        public bool Justification { get; set; }    
    }
}