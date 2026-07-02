using System.Security.Claims;
using PFMPManager.Api.Services.Results;
namespace PFMPManager.Api.Services
{
    // Extracts the connected user's information from JWT claims
    public class CurrentUserService :ICurrentUserService
    {
        public CurrentUserResult GetCurrentUser(ClaimsPrincipal user)
        {
            
            var result = new CurrentUserResult();
            // Extract the user ID from the JWT claims
            if (!TryGetCurrentUserId(out int currentUserId ,user))
            {
                result.Success  = false;
                result.ErrorMessage = "Token invalide : identifiant utilisateur manquant";
                return result;
            }
            // Extract the user role from the JWT claims
            var role = TryGetCurrentUserRole(user);
            if (role == null || string.IsNullOrWhiteSpace(role))
            {
                result.Success = false;
                result.ErrorMessage = "Token invalide : role utilisateur manquant";
                return result;
            }
            // build the current user result
            result.Success = true;
            result.Role = role;
            result.UserId = currentUserId;
            return result;
        }

        //Try to read and parse the user ID claims
        private bool TryGetCurrentUserId(out int currentUserId, ClaimsPrincipal user)
        {

            var id = user.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(id, out currentUserId);
        }

        //Read the user role claim
        private string? TryGetCurrentUserRole(ClaimsPrincipal user)
        {

            return user.FindFirstValue(ClaimTypes.Role);

        }
    }


}