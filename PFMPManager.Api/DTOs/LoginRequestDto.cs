namespace PFMPManager.Api.DTOs
{
     // Contains login credentials sent by the client
    public class LoginRequestDto
    {
        public string Login { get; set; } = string.Empty;
        public string Pwd { get; set; } = string.Empty;
    }
}
