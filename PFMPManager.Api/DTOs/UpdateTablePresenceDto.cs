
namespace PFMPManager.Api.DTOs
{
    // Contains the fields required to update a student's presence record
    public class UpdateTablePresenceDto
    {
        public string Etat { get; set; } = string.Empty;
        public int Retard { get; set; }
        public DateTime? DateJour { get; set; }
        public bool Justification { get; set; }    
    }
}