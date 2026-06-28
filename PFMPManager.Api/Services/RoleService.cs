using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;

public class RoleService : IRoleService
{
    private readonly AppDbContext _context;

    public RoleService(AppDbContext context)
    {
        _context = context;
    } 

    public async Task<string?> GetUserRoleAsync(int idUtilisateur)
    {
        var isEtudiant = await _context.Etudiant
           .AnyAsync(e => e.Id_Utilisateur_1 == idUtilisateur);

        if (isEtudiant)
            return "Etudiant";

        var isReferent = await _context.Referent
            .AnyAsync(r => r.Id_Utilisateur == idUtilisateur);

        if (isReferent)
            return "Enseignant";

        var isAdmin = await _context.Administrateur
            .AnyAsync(a => a.Id_Utilisateur == idUtilisateur);

        if (isAdmin)
            return "Administrateur";

        return null;

    }
}