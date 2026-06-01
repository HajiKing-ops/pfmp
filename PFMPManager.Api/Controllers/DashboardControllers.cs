using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;

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
            [HttpGet("{idEtudiant}")]

            public async Task<IActionResult> GetById(int idEtudiant)
            {
            var search = await _context.Pfmp.FirstOrDefaultAsync(p => p.DateDebut <= DateTime.Today && p.DateFin >= DateTime.Today && p.Id_Utilisateur_1 == idEtudiant);
                if (search == null)
                {
                    return NotFound();
                }
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
            };

                return Ok(dash);


            }
            
        }  
}