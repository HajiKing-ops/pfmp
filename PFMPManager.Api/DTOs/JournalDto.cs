namespace PFMPManager.Api.DTOs
{
    // Represents a daily PFMP report returned by the API
    public class JournalDto 
    { 
        public int IdRapportJournalier { get; set; }
        public int? IdEtudiant { get; set; }
        public DateTime? DateRapport { get; set; }
        public string? LienVersFichier { get; set; }
        public int Id_PFMP { get; set; }

    }
}
