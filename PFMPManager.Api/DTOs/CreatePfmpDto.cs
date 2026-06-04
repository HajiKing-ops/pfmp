namespace PFMPManager.Api.DTOs
{
    public class CreatePfmpDto
    {
        public DateTime? DateDebut { get; set; }
        public DateTime? DateFin { get; set; }
        public int IdAdministrateur { get; set; } 
        public int IdPlanning  { get; set; }
        public string Siret { get; set; } = string.Empty;
        public int IdEtudiant {get; set;}
        public int JourRestants { get; set; }

    }
}