using System.Security.Claims;
using PFMPManager.Api.Services.Results;
namespace PFMPManager.Api.Services
{
     // Defines a service for extracting the connected user's context from JWT claims
    public interface ICurrentUserService
    {
        CurrentUserResult GetCurrentUser(ClaimsPrincipal user) ;
    }
}




