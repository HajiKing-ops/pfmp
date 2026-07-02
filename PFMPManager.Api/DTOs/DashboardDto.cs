namespace PFMPManager.Api.DTOs
{
    // Represents dashboard data for the connected student's active PFMP
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
        public int JoursRenseignes { get; set; }
        public int MinutesTotales  { get; set; }
        public int MinutesParJour  { get; set; }
    }
}