namespace PFMPManager.Api.DTOs
{
    // Contains all data required to create a complete PFMP request
    public class CreateCompletePfmpDto
    {
        //Entreprise
        public string? RaisonSociale {get; set;}
        public string? SecteurActivite {get; set;}
        public string SIRET { get; set; } = string.Empty;
        public string? Adresse {get; set;}
        public string? NumTelephone {get; set;}
        public string? SiteWeb { get; set; }

        //Planning 

        public int TotalHebdo { get; set; }

        //PlanningJour
        public List<CreatePlanningJoursDto> PlanningJours { get; set; } = new();


        //PFMP
        public DateTime? DateDebut { get; set; }
        public DateTime? DateFin { get; set; }
        
        
        public string? PrenomMaitreStage {get; set;}
        public string? NomMaitreStage {get; set;}
        public string? FonctionMaitreStage {get; set;}
        public string? TelephoneMaitreStage {get; set;}
        public string? EmailMaitreStage {get; set;}
        
    }
}