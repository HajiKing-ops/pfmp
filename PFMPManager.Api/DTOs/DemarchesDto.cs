namespace PFMPManager.Api.DTOs 
{
    public class DemarchesDto
    {
        public int Id_Utilisateur { get; set; }
        public string SIRET { get; set; } = string.Empty;
        public DateTime? DateRefus { get; set; }
        public string Entreprise { get; set; } = string.Empty;
        public string Contact { get; set; } = string.Empty;
        public string Adresse { get; set; } = string.Empty;

    }
}