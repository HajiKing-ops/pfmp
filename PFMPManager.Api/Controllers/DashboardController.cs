using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using Microsoft.AspNetCore.Authorization;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Services;

namespace PFMPManager.Api.Controllers
{
    // Provides dashboard data for the connected student
        [ApiController]
        [Route("api/dashboard")]
        public class DashboardController : ControllerBase
        {
            private readonly AppDbContext _context;
            private readonly ICurrentUserService _currentUserService;

            public DashboardController(AppDbContext context, ICurrentUserService currentUserService)
            {
                _context = context;
                _currentUserService = currentUserService;
            }

        // Returns dashboard information for the connected student's active PFMP
        [Authorize(Roles = "Etudiant")]
        [HttpGet]
        public async Task<IActionResult> GetCurrentStudentDashboard()
        {
            var user = _currentUserService.GetCurrentUser(User);
            if(!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var studentUserId = user.UserId;
            // Find the connected student's active PFMP
            var activePfmp = await _context.Pfmp.AsNoTracking().FirstOrDefaultAsync(p => p.DateDebut.HasValue && p.DateDebut.Value.Date <= DateTime.Today
            && p.DateFin.HasValue && p.DateFin.Value.Date >= DateTime.Today
            && p.Id_Utilisateur_1 == studentUserId);
            if (activePfmp == null)
            {
                return NotFound("Aucune PFMP active trouvee pour cet etudiant");
            }
            // Count daily reports submitted during the active PFMP period
            var joursRenseignes = await
                (
                    from remplir in _context.Remplir
                    join rapport in _context.RapportJournalier
                    on remplir.Id_RapportJournalier equals rapport.Id_RapportJournalier
                    where remplir.Id_Utilisateur == studentUserId
                    && rapport.DateRapport.HasValue && activePfmp.DateDebut.HasValue
                    && activePfmp.DateFin.HasValue
                    && rapport.DateRapport.Value.Date >= activePfmp.DateDebut.Value.Date
                    && rapport.DateRapport.Value.Date <= activePfmp.DateFin.Value.Date
                    select rapport
                ).CountAsync();
                

            // Load the planning linked to the active PFMP
            var plan = await _context.Planning.AsNoTracking().FirstOrDefaultAsync(p => p.Id_Planning == activePfmp.Id_Planning);

            if (plan == null)
            {
                return NotFound("Le planning lie a cette PFMP est introuvable");
            }


            var minTotales = plan.TotalHebdo;
     
            // Build the dashboard response
            var dash = new DashboardDto
            {
                DateDebut = activePfmp.DateDebut,
                DateFin = activePfmp.DateFin,
                IdAdministrateur = activePfmp.Id_Utilisateur,
                Id_Planning = activePfmp.Id_Planning,
                SIRET = activePfmp.SIRET,
                IdEtudiant = activePfmp.Id_Utilisateur_1,
                IdPfmp = activePfmp.Id_PFMP,
                JourRestants = activePfmp.DateFin.HasValue ? Math.Max(0, (activePfmp.DateFin.Value.Date - DateTime.Today).Days) : 0,
                MinutesTotales  =  minTotales,
                JoursRenseignes = joursRenseignes
            };

                return Ok(dash);
            }

        }  
}