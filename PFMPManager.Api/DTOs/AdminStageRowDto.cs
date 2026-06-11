namespace PFMPManager.Api.DTOs
{
    public class AdminStageRowDto
    {
        public string? Nom { get; set; }
        public string? Prenom { get; set; }
        public string? LibelleFiliere  { get; set; }
        public string? Entreprise { get; set; }
        public string? NomMaitreDeStage { get; set; }
        public string? PrenomMaitreDeStage { get; set; }
        public DateTime? DateDebut { get; set; }
        public DateTime? DateFin { get; set; }
        public int Presence { get; set; }
        public int Absence { get; set; }
        public int Restants { get; set; }
        public bool? Status { get; set; }
        public int Id_PFMP { get; set; }
        public string? NumTelephone { get; set; }


    }
}