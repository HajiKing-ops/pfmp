namespace PFMPManager.Api.DTOs
{
    // Represents detailed PFMP information returned to the frontend
    public class PfmpDetailDto
    {
        public DateTime? DateDebut { get; set; }
        public DateTime? DateFin { get; set; }
        public int Id_Planning { get; set; }
        public string SIRET { get; set; } = string.Empty;
        
        public int IdEtudiant { get; set; }
        public int IdPfmp { get; set; }
        public int JourRestants { get; set; }
        public string RaisonSociale { get; set; } = string.Empty;
        public int Semaine { get; set; }

        public string? PrenomMaitreStage { get; set; }
        public string? NomMaitreStage { get; set; }
        public string? FonctionMaitreStage { get; set; }
        public string? TelephoneMaitreStage { get; set; }
        public string? EmailMaitreStage { get; set; }

        // Planning days
        public List<CreatePlanningJoursDto> PlanningJours { get; set; } = new();

    }
}