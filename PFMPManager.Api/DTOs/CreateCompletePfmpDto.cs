namespace PFMPManager.Api.DTOs
{
    public class CreateCompletePfmpDto
    {
        //Entreprise
        public string? RaisonSociale {get; set;}
        public string? SecteurActivite {get; set;}
        public string SIRET { get; set; } = string.Empty;
        public string? Adresse {get; set;}
        public string? NumTelephone {get; set;}

        //Planning
        
        public string? Jour {get; set;}
        public int HoraireDebut {get; set; }
        public int HoraireFin {get; set; }

        //PFMP
        public DateTime? DateDebut { get; set; }
        public DateTime? DateFin { get; set; }
        public int IdEtudiant { get; set; }
        public int IdAdministrateur { get; set;}
        
        //maître de stage fields
        public string? PrenomMaitreStage {get; set;}
        public string? NomMaitreStage {get; set;}
        public string? FonctionMaitreStage {get; set;}
        public string? TelephoneMaitreStage {get; set;}
        public string? EmailMaitreStage {get; set;}
        
    }
}