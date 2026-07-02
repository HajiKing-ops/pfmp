namespace PFMPManager.Api.DTOs
{
    // Represents a student's contact request with an organisation
    public class ContacterDto
    {
        public int Id_Utilisateur { get; set; }
        public string SIRET { get; set; } = string.Empty;
        public string TypeContact { get; set; } = string.Empty;
        public DateTime? DateDemande { get; set; }
        public string StatutDemande { get; set; } = string.Empty;
        public string RaisonSociale { get; set; } = string.Empty;
    }
}