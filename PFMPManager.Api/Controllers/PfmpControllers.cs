using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;


namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 

    [Route("api/pfmp")] // Base route for all endpoints in this controller

    public class PfmpController : ControllerBase
    {
        private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)

        //DI container injects AppDbContext registered om program.cs
        public PfmpController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet] // GEt /api/Pfmp returns all PFMPs
        public async Task<IActionResult> GetAll()
        {
            var pfmps = await _context.Pfmp.Select(p => new PfmpDto
            { 
               
                DateDebut =  p.DateDebut,
                DateFin = p.DateFin,
                IdAdministrateur = p.Id_Utilisateur,
                Id_Planning = p.Id_Planning,
                SIRET = p.SIRET,
                IdEtudiant = p.Id_Utilisateur_1,
                IdPfmp = p.Id_PFMP,
            }).ToListAsync(); //Query all rows
            return Ok(pfmps); // 200 ok with json array 
        }

        [HttpGet("{id}")] //address of the method
        public async Task<IActionResult> GetPfmpById(int id)
        {
            var pfmp = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == id);

            if (pfmp == null)
            {
                return NotFound();
            }
            var pfmpById = new PfmpDto
            {
                DateDebut = pfmp.DateDebut,
                DateFin = pfmp.DateFin,
                IdAdministrateur = pfmp.Id_Utilisateur,
                Id_Planning = pfmp.Id_Planning,
                SIRET = pfmp.SIRET,
                IdEtudiant = pfmp.Id_Utilisateur_1,
                IdPfmp = pfmp.Id_PFMP,
                JourRestants = pfmp.DateFin.HasValue ? Math.Max(0, (pfmp.DateFin.Value.Date - DateTime.Today).Days) : 0,
            };



            return Ok(pfmpById);
        }
        
        [HttpPost]

        public async Task<IActionResult> Create(CreatePfmpDto request)
        {

            if(string.IsNullOrWhiteSpace(request.Siret))
            {
                return BadRequest();
            }
            if(request.IdAdministrateur <= 0 || request.IdPlanning <= 0 || request.IdEtudiant <= 0)
            {
                return BadRequest();
            }
            if(request.DateFin < request.DateDebut)
            {
                return BadRequest();
            }
            

            var pfmp = new Pfmp
            {
                DateDebut = request.DateDebut,
                DateFin = request.DateFin,
                Id_Utilisateur = request.IdAdministrateur,
                Id_Planning = request.IdPlanning,
                SIRET = request.Siret,
                Id_Utilisateur_1 = request.IdEtudiant,
            };
            _context.Pfmp.Add(pfmp);
            await _context.SaveChangesAsync();
            
            var pfmpDto = new PfmpDto
            {
                 IdPfmp = pfmp.Id_PFMP,
                 IdAdministrateur = pfmp.Id_Utilisateur,
                 Id_Planning = pfmp.Id_Planning,
                 DateFin = pfmp.DateFin,
                 DateDebut = pfmp.DateDebut,
                 SIRET = pfmp.SIRET,
                 IdEtudiant = pfmp.Id_Utilisateur_1,
            };

            return Ok(pfmpDto);

        }

        [HttpPut("{id}")]

         public async Task<IActionResult> Update(CreatePfmpDto request, int id)
        {
            if(string.IsNullOrWhiteSpace(request.Siret))
            {
                return BadRequest();
            }
            if(request.IdEtudiant <= 0 || request.IdPlanning <= 0 || request.IdAdministrateur <= 0)
            {
                return BadRequest();
            }
            if(request.DateFin < request.DateDebut)
            {
                return BadRequest();
            }

            var search = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == id);

            if(search == null)
            {
                return NotFound();
            }
            

                search.DateDebut = request.DateDebut;
                search.DateFin = request.DateFin;
                search.Id_Utilisateur = request.IdAdministrateur;
                search.Id_Planning = request.IdPlanning;
                search.SIRET = request.Siret;
                search.Id_Utilisateur_1 = request.IdEtudiant;

                await _context.SaveChangesAsync();

            var update = new PfmpDto
            {
                IdPfmp = search.Id_PFMP,
                IdAdministrateur = search.Id_Utilisateur,
                Id_Planning = search.Id_Planning,
                DateFin = search.DateFin,
                DateDebut = search.DateDebut,
                SIRET = search.SIRET,
                IdEtudiant = search.Id_Utilisateur_1,
            };
                return Ok(update);
                
            }

            [HttpDelete("{id}")]

            public async Task<IActionResult> Delete(int id)
        {
            var del = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == id) ;
            
            if (del== null)
            {
                return NotFound();
            }
            _context.Pfmp.Remove(del);
            await _context.SaveChangesAsync();

            return NoContent();
        }

            
    }
}
