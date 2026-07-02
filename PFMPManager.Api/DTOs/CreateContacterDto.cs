namespace PFMPManager.Api.DTOs
{
    // Contains the data required for a student to create or update a contact request
    public class CreateContacterDto
    {
        public string TypeContact { get; set; } = string.Empty;
        public DateTime? DateDemande { get; set; }
        public string StatutDemande { get; set; } = string.Empty;
        

    }
}