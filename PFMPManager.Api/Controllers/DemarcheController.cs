using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims; // creates  claims 
using PFMPManager.Api.Models;



namespace PFMPManager.Api.Controllers
{
    [ApiController]

    [Route("api/demarches")]
    [Authorize]

    public class DemarcheController : ControllerBase
    {
        private readonly AppDbContext _context;

        public DemarcheController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost("{siret}")]
        [Authorize(Roles = "Etudiant")]

        public async Task<IActionResult> Create(CreateContacterDto request, string siret)
        {
            var userIdTest = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdTest, out int idEtudiant))
            {
                return Unauthorized("Token invalide : identifiant utilisateur manquant.");
            }

            var DateDemande = request.DateDemande;
            var SIRET = siret;
            var TypeContact = request.TypeContact;
            var statutDemande = request.StatutDemande.Trim().ToLower();
            var enAttente = "En attente";
            var refuse = "Refuse";
            var accepte = "Accepte";
     


            if (string.IsNullOrWhiteSpace(SIRET) || string.IsNullOrWhiteSpace(TypeContact) || string.IsNullOrWhiteSpace(statutDemande))
            {
                return BadRequest();
            }
            if (!DateDemande.HasValue)
            {
                return BadRequest();
            }

            if (statutDemande != enAttente.Trim().ToLower() && statutDemande != refuse.Trim().ToLower() && statutDemande != accepte.Trim().ToLower())
            {
                return BadRequest("il faut entre en attend, refuse ou accepte");
            }
            if (statutDemande == enAttente.Trim().ToLower())
            {
                statutDemande = enAttente;
            }
            else if (statutDemande == refuse.Trim().ToLower())
            {
                statutDemande = refuse;
            }
            else if (statutDemande == accepte.Trim().ToLower())
            {
                statutDemande = accepte;
            }

            var searchOrg = await _context.Organisation.AnyAsync(o => o.SIRET == SIRET);
            if (!searchOrg)
            {
                return NotFound("l'organisation n'existe pas");
            }

            var check = await _context.Contacter.AnyAsync(d => d.Id_Utilisateur == idEtudiant && d.SIRET == SIRET);
            if (check)
            {
                return Conflict();
            }
            var query = new Contacter
            {

                Id_Utilisateur = idEtudiant,
                SIRET = SIRET,
                TypeContact = TypeContact,
                DateDemande = DateDemande,
                StatutDemande = statutDemande,
            };
            _context.Contacter.Add(query);
            await _context.SaveChangesAsync();

            var result = new ContacterDto
            {
                Id_Utilisateur = query.Id_Utilisateur,
                SIRET = query.SIRET,
                TypeContact = query.TypeContact,
                DateDemande = query.DateDemande,
                StatutDemande = query.StatutDemande,
            };
            return Ok(result);
        }


        [Authorize(Roles = "Etudiant")]
        [HttpPut("modify/{siret}")]

        public async Task<IActionResult> Update(CreateContacterDto request, string siret)
        {

            var DateDemande = request.DateDemande;
         
            var TypeContact = request.TypeContact;
            var statutDemande = request.StatutDemande.Trim().ToLower();
            var enAttente = "En attente";
            var refuse = "Refuse";
            var accepte = "Accepte";


            var userIdTest = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdTest, out int idEtudiant)) 
            {
                return Unauthorized("Token invalide : identifiant utilisateur manquant.");
            }

           

            if (string.IsNullOrWhiteSpace(siret) || string.IsNullOrWhiteSpace(TypeContact) || string.IsNullOrWhiteSpace(statutDemande))
            {
                return BadRequest();
            }
            if (!DateDemande.HasValue)
            {
                return BadRequest();
            }

            if (statutDemande != enAttente.Trim().ToLower() && statutDemande != refuse.Trim().ToLower() && statutDemande != accepte.Trim().ToLower())
            {
                return BadRequest("il faut entre en attend, refuse ou accepte");
            }
            if (statutDemande == enAttente.Trim().ToLower())
            {
                statutDemande = enAttente;
            }
            else if (statutDemande == refuse.Trim().ToLower())
            {
                statutDemande = refuse;
            }
            else if (statutDemande == accepte.Trim().ToLower())
            {
                statutDemande = accepte;
            }


            var searchOrg = await _context.Organisation.AnyAsync(o => o.SIRET == siret);
            if (!searchOrg)
            {
                return NotFound("l'organisation n'existe pas");
            }

            var update = await _context.Contacter.FirstOrDefaultAsync(d => d.Id_Utilisateur == idEtudiant && d.SIRET == siret);
            if (update == null)
            {
                return NotFound("contacter c'existe pas");
            }

            update.TypeContact = request.TypeContact;
            update.DateDemande = request.DateDemande;
            update.StatutDemande = statutDemande;


            await _context.SaveChangesAsync();

            var dto = new ContacterDto
            {
                Id_Utilisateur = update.Id_Utilisateur,
                SIRET = update.SIRET,
                TypeContact = update.TypeContact,
                DateDemande = update.DateDemande,
                StatutDemande = update.StatutDemande
            };
            return Ok(dto);

        }


    }
}