namespace PFMPManager.Api.DTOs
{
    public class EtudiantDto
    {
        public DateTime? Date_Naissance { get; set; }
        public string Adresse {get; set;} = string.Empty;
        public string CodePostal {get; set;} = string.Empty;
        public string Ville {get; set;} = string.Empty;
        public string NumTelephone {get; set;} = string.Empty;
        public string  AdresseMail {get; set;} = string.Empty;
        public int IdEtudiant {get; set;}
        public int IdReferent {get; set;}

    }
}