namespace PFMPManager.Api.DTOs
{
    // Contains the fields that can be updated in a daily PFMP report
    public class UpdateRapportJournalierDto
    {
        
        public DateTime? DateRapport { get; set; }
        public string? LienVersFichier { get; set; }
        
    }
}

