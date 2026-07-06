
namespace PFMPManager.Api.DTOs
{
    // Represents professional profile information returned by the API
    public class ProfileMeDto
    {
        public string Prenom { get; set; } = string.Empty;
       public string Nom { get; set; } = string.Empty;
        public string Niveau { get; set; } = string.Empty;
        public DateTime? DateNaissance { get; set; }
        public string Filiere { get; set; } = string.Empty;
        public string Etablissement { get; set; } = string.Empty;


    }
}