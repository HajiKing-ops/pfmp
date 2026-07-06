namespace PFMPManager.Api.DTOs
{
    // Contains user information returned after successful login
    public class LoginResponseDto
    {
        public int Id_Utilisateur { get; set; }
        public string Nom { get; set; } = string.Empty;
        public string Prenom { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
    }
}
