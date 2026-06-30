using System.Security.Claims;
namespace PFMPManager.Api.Services
{
    public interface ICurrentUserService
    {
        CurrentUserResult GetCurrentUser(ClaimsPrincipal user) ;
    }
}




