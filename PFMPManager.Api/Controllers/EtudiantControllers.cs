using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Authorization;

namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 

    [Route("api/etudiant")] // Base route for all endpoints in this controller

    public class EtudiantController : ControllerBase
    {
        private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)

        //DI container injects AppDbContext registered om program.cs
        public EtudiantController(AppDbContext context)
        {
            _context = context;
        }
        [Authorize]

        [HttpGet] // GEt /api/organisation returns all organisations as JSON
        public async Task<IActionResult> GetAll()
        {
            var etudiant = await _context.Etudiant.ToListAsync(); //Query all rows
            return Ok(etudiant); // 200 ok with json array 
        }

        [HttpGet("{id}/pfmp")]
        
        public async Task<IActionResult> GetByID(int id)
        {
            var etudiantById = await _context.Pfmp.Where( p => p.Id_Utilisateur_1 == id).Select( p => new PfmpDto {
                DateDebut =  p.DateDebut,
                DateFin = p.DateFin,
                IdAdministrateur = p.Id_Utilisateur,
                Id_Planning = p.Id_Planning,
                SIRET = p.SIRET,
                IdEtudiant = p.Id_Utilisateur_1,
                IdPfmp = p.Id_PFMP,
            }).ToListAsync(); // 
            if (etudiantById != null && !etudiantById.Any()) 
            {
                return NotFound();
            }
            return Ok(etudiantById);

        }
        

    }
}