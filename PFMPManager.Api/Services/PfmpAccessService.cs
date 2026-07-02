using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;

namespace PFMPManager.Api.Services
{
    // PfmpAccessService Checks whether the connected user can access a student's pfmp data
    public class PfmpAccessService : IPfmpAccessService
    {
       private readonly AppDbContext _context;

       public PfmpAccessService(AppDbContext context)
        {
            _context = context;
        }
        
        public async Task<string?> ValidateStudentPfmpAccessAsync(int currentUserId, int studentId, string role)
        {
            if (role == "Etudiant" && currentUserId == studentId)
            {
                return null; //Return null when access id allowed, otherwise returns an error message
            }
            else if (role == "Enseignant")
            {
                // Check whether the teacher is linked to the requested student
                var hasStudentAccess = await _context.Etudiant.AsNoTracking().AnyAsync(o => o.Id_Utilisateur == currentUserId && o.Id_Utilisateur_1 == studentId);
                if (hasStudentAccess)
                {
                    return null;
                }
            }
            return "Vous n’avez pas le droit d’accéder à cette PFMP.";

        }
    }
}