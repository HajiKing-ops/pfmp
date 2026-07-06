
namespace PFMPManager.Api.DTOs
{
    // Represents professional profile information returned by the API
    public class CreateTablePresenceDto
    {
        public DateTime? DateJour { get; set; } 
       public string Etat { get; set; } = string.Empty;
        public int Retard { get; set; } 
        public bool Justification { get; set; } 


    }
}