namespace PFMPManager.Api.DTOs
{
    // Represents a cybersecurity news item returned from the CERT-FR RSS feed
    public class NewsDto
    {
        public string? Title {get; set;} = string.Empty;
        public string? Link {get; set;} = string.Empty;
        
        public string? Description {get; set;} = string.Empty;
        public string? PublishedDate {get; set;} = string.Empty;

    }
}
