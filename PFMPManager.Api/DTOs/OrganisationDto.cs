namespace PFMPManager.Api.DTOs
{
    // Represents organisation information returned by the API
    public class OrganisationDto
    {
        public string SIRET { get; set; } = string.Empty;
        public string RaisonSociale { get; set; } = string.Empty;
        public string SecteurActivite { get; set; } = string.Empty;
        public string Activite { get; set; } = string.Empty;
        public string Adresse { get; set; } = string.Empty;
        public string CodePostal { get; set; } = string.Empty;
        public string Ville { get; set; } = string.Empty;
        public string AdresseMail { get; set; } = string.Empty;
        public string NumTelephone { get; set; } = string.Empty;
        public string SiteWeb { get; set; } = string.Empty;


    }
}