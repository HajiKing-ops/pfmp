using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Helpers;
using PFMPManager.Api.Models;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims; // creates  claims 


namespace PFMPManager.Api.Controllers 
{
    [ApiController]
    [Route("api/presence")]
    public class TablePreseceController : ControllerBase
    {
        private readonly AppDbContext _context;

        public TablePreseceController(AppDbContext context)
        {
            _context = context;
        }

        [Authorize(Roles = "Enseignant,Administrateur")]

        [HttpPost("{idEtudiant}")]
        public async Task<IActionResult> Presence(TablePresenceDto request, int idEtudiant)
        {
            var EtudiantExiste = await _context.Etudiant.AnyAsync(t => t.Id_Utilisateur_1 == idEtudiant);
            if (!EtudiantExiste)
            {
                return NotFound("Etudiant n'existe pas");
            }
            if (!request.DateJour.HasValue)
            {
                return BadRequest();
            }
            var jour = request.DateJour.Value.Date;
            var EtudiantPfmp = await _context.Pfmp.FirstOrDefaultAsync(pf => pf.Id_Utilisateur_1 == idEtudiant && pf.DateDebut.HasValue&& pf.DateFin.HasValue && pf.DateDebut.Value.Date <= jour && pf.DateFin.Value.Date >= jour);
            if (EtudiantPfmp == null)
            {
                return BadRequest("pfmp n'existe pas");
            }
 
            var TablePresence = await _context.TablePresence.FirstOrDefaultAsync(tp => tp.Id_Utilisateur == idEtudiant && tp.DateJour.HasValue &&tp.DateJour.Value.Date == jour);
            if (TablePresence != null)
            {
                return BadRequest("c'est deja existe");
            }

            TablePresence = new TablePresence
                {
                    DateJour = request.DateJour,
                    Etat = request.Etat,
                    Retard = request.Retard,
                    Justification = request.Justification,
                    Id_Utilisateur = idEtudiant,
                };
                _context.TablePresence.Add(TablePresence);
                await _context.SaveChangesAsync();
            
            

            var dto = new TablePresenceDto
            {
                DateJour = TablePresence.DateJour,
                Etat = TablePresence.Etat,
                Retard = TablePresence.Retard,
                Justification = TablePresence.Justification,
                Id_Utilisateur = TablePresence.Id_Utilisateur,
            };
            return Ok(dto);
        }

    }
}