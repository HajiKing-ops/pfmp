
namespace PFMPManager.Api.DTOs
{
    public class ProfessionnelDto
    {
        public int Id_Utilisateur { get; set; } 
       public string Fonction { get; set; } = string.Empty;
        public string Adresse { get; set; } = string.Empty;
        public string CodePostal { get; set; } = string.Empty;
        public string Ville { get; set; } = string.Empty;
        public string AdresseMail { get; set; } = string.Empty;
        public string NumTelephone { get; set; } = string.Empty;


    }
}