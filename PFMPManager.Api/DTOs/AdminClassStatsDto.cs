namespace PFMPManager.Api.DTOs
{
    // Represents PFMP attendance statistics for an administrator's class
    public class AdminClassStatsDto
    {
        public int IdEtablissement { get; set; }
        public int IdClasse { get; set; }
        public string? LibelleFiliere { get; set; }
        public int NombreEleves { get; set; }
        public int EnCours { get; set; }
        public int Presence { get; set; }
        public int Absence { get; set; }
        public int TauxPresence { get; set; }
        
    }
}