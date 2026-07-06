using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;

//Resolves the application role of a user from role-specific tables
public class RoleService : IRoleService
{
    private readonly AppDbContext _context;

    public RoleService(AppDbContext context)
    {
        _context = context;
    } 

    // Returns the first matching role for the given user, or null if no role is found    
    public async Task<string?> GetUserRoleAsync(int idUtilisateur)
    {
        var isEtudiant = await _context.Etudiant.AsNoTracking()
           .AnyAsync(e => e.Id_Utilisateur_1 == idUtilisateur);

        if (isEtudiant)
            return "Etudiant";

        var isReferent = await _context.Referent.AsNoTracking()
            .AnyAsync(r => r.Id_Utilisateur == idUtilisateur);

        if (isReferent)
            return "Enseignant"; // Referent users are exposed as Enseignant in API authorization 

        var isAdmin = await _context.Administrateur.AsNoTracking()
            .AnyAsync(a => a.Id_Utilisateur == idUtilisateur);

        if (isAdmin)
            return "Administrateur";

        return null;

    }
}