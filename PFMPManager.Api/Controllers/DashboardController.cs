using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using Microsoft.AspNetCore.Authorization;
using PFMPManager.Api.DTOs;

namespace PFMPManager.Api.Controllers 
{
    [ApiController]

    [Route("api/dashboard")]

        public class DashboardController : ControllerBase
        {
            private readonly AppDbContext _context;

            public DashboardController(AppDbContext context)
            {
                _context = context;
            }

        [Authorize]

        [HttpGet("{idEtudiant}")]

        public async Task<IActionResult> GetById(int idEtudiant)
        {
            var search = await _context.Pfmp.FirstOrDefaultAsync(p => p.DateDebut.HasValue && p.DateDebut.Value.Date <= DateTime.Today 
            && p.DateFin.HasValue && p.DateFin.Value.Date >= DateTime.Today 
            && p.Id_Utilisateur_1 == idEtudiant);
            if (search == null)
            {
                return NotFound();
            }
            var joursRenseignes = await
                (
                    from remplir in _context.Remplir
                    join rapport in _context.RapportJournalier
                    on remplir.Id_RapportJournalier equals rapport.Id_RapportJournalier
                    where remplir.Id_Utilisateur == idEtudiant
                    && rapport.DateRapport.HasValue && search.DateDebut.HasValue
                    && search.DateFin.HasValue
                    && rapport.DateRapport.Value.Date >= search.DateDebut.Value.Date
                    && rapport.DateRapport.Value.Date <= search.DateFin.Value.Date
                    select rapport
                ).CountAsync();
                


            var plan = await _context.Planning.FirstOrDefaultAsync(p => p.Id_Planning == search.Id_Planning);

            if (plan == null)
            {
                return NotFound();
            }


            var heuresTotales = plan.TotalHebdo;
     

            var dash = new DashboardDto
            {
                DateDebut = search.DateDebut,
                DateFin = search.DateFin,
                IdAdministrateur = search.Id_Utilisateur,
                Id_Planning = search.Id_Planning,
                SIRET = search.SIRET,
                IdEtudiant = search.Id_Utilisateur_1,
                IdPfmp = search.Id_PFMP,
                JourRestants = search.DateFin.HasValue ? Math.Max(0, (search.DateFin.Value.Date - DateTime.Today).Days) : 0,
                HeuresTotales =  heuresTotales,
                JoursRenseignes = joursRenseignes
            };

                return Ok(dash);
            }

        }  
}