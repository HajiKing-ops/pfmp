namespace PFMPManager.Api.DTOs
{
    public class CreateJournalDto
    {
        public int IdEtudiant { get; set; }
        public DateTime? DateRapport { get; set; }
        public string LienVersFichier { get; set; } = string.Empty;

    }
}