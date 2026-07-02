using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;

namespace PFMPManager.Api.Services
{
    
    public class PfmpAccessService : IPfmpAccessService
    {
       private readonly AppDbContext _context;

       public PfmpAccessService(AppDbContext context)
        {
            _context = context;
        }
        public async Task<string?> ValidateStudentPfmpAccessAsync(int currentUserId, int studentId, string role )
        {
            if (role == "Etudiant" && currentUserId == studentId)
            {
                return null;
            }
            else if (role == "Enseignant")
            {
                var hasStudentAccess = await _context.Etudiant.AsNoTracking().AnyAsync(o => o.Id_Utilisateur == currentUserId && o.Id_Utilisateur_1 == studentId);
                if (hasStudentAccess)
                {
                    return null;
                }
            }
            return "Vous n’avez pas le droit d’acceder à cette PFMP.";

        }
    }
}