public interface IRoleService
{
     // Defines a service for resolving the application role of a user
    Task<string?> GetUserRoleAsync(int idUtilisateur);
}

