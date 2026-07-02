namespace PFMPManager.Api.DTOs
{
    // Contains the data required to create or update a daily PFMP report
    public class CreateJournalDto
    {
        public DateTime? DateRapport { get; set; }
        public string LienVersFichier { get; set; } = string.Empty;

    }
}