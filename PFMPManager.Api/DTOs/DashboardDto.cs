namespace PFMPManager.Api.DTOs
{
    public class DashboardDto
    {
        public DateTime? DateDebut { get; set; }
        public DateTime? DateFin { get; set; }
        public int Id_Planning { get; set; }
        public string SIRET { get; set; } = string.Empty;
        public int IdAdministrateur { get; set; }
        public int IdEtudiant { get; set; }
        public int IdPfmp { get; set; }
        public int JourRestants { get; set; }



    }
}