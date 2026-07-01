namespace PFMPManager.Api.Services.Results
{
    public class CurrentUserResult
    {
        public bool Success {get; set;}
        public string ErrorMessage {get; set;} = string.Empty;
        public string Role {get; set;} = string.Empty;
        public int UserId {get; set;}

    }
}