namespace PFMPManager.Api.DTOs 
{
    public class DemarchesDto
    {
        public int Id_Utilisateur { get; set; }
        public string SIRET { get; set; } = string.Empty;
        public DateTime? dateRefus { get; set; }
        public string status { get; set; } = string.Empty

    }