namespace PFMPManager.Api.DTOs
{
    public class CreateContacterDto
    {
        public int Id_Utilisateur { get; set; }
        public string SIRET { get; set; } = string.Empty;
        public string TypeContact { get; set; } = string.Empty;
        public DateTime? DateDemande { get; set; }
        public string StatutDemande { get; set; } = string.Empty;

    }
}