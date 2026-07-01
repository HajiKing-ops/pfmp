using System.Security.Claims;
using PFMPManager.Api.Services.Results;
namespace PFMPManager.Api.Services
{
    public class CurrentUserService :ICurrentUserService
    {
        public CurrentUserResult GetCurrentUser(ClaimsPrincipal user)
        {
             var result = new CurrentUserResult();

            if (!TryGetCurrentUserId(out int currentUserId ,user))
            {
                result.Success  = false;
                result.ErrorMessage = "Token invalide : identifiant utilisateur manquant";
                return result;
            }
            var role = TryGetCurrentUserRole(user);
            if (role == null || string.IsNullOrWhiteSpace(role))
            {
                result.Success = false;
                result.ErrorMessage = "Token invalide : role utilisateur manquant";
                return result;
            }
            result.Success = true;
            result.Role = role;
            result.UserId = currentUserId;
            return result;
        }
        
        private bool TryGetCurrentUserId(out int currentUserId, ClaimsPrincipal user)
        {

            var id = user.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(id, out currentUserId);
        }

        private string? TryGetCurrentUserRole(ClaimsPrincipal user)
        {

            return user.FindFirstValue(ClaimTypes.Role);

        }
    }
  

}