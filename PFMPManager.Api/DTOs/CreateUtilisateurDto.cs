namespace PFMPManager.Api.DTOs
{
    public class CreateUtilisateurDto
    {
        // Contains the data required to create a user account
        public string Nom { get; set; } = string.Empty;
        public string Prenom { get; set; } = string.Empty;
        public string Login { get; set; } = string.Empty;
        public string Pwd { get; set; } = string.Empty;

    }


}