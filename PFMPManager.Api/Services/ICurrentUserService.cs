using System.Security.Claims;
using PFMPManager.Api.Services.Results;
namespace PFMPManager.Api.Services
{
    public interface ICurrentUserService
    {
        CurrentUserResult GetCurrentUser(ClaimsPrincipal user) ;
    }
}




