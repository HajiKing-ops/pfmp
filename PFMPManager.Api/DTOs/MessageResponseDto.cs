namespace PFMPManager.Api.DTOs
{
    public class MessageResponseDto
    {
        public int IdUtilisateur { get; set; }
        public int IdPfmp { get; set; }
        public string RoleExpediteur { get; set; }
        public string Contenu { get; set; } = string.Empty;
        public DateTime? DateEnvoi { get; set; }
        public int IdMessage { get; set; }

    }
}