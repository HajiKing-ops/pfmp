namespace PFMPManager.Api.DTOs
{
    // Represents basic user information returned by the API
    public class UtilisateurDto 
    {
        public int Id_Utilisateur { get; set; }
        public string Nom { get; set; } = string.Empty;
        public string Prenom { get; set; } = string.Empty;
        public string Login { get; set; } = string.Empty;

    }


}