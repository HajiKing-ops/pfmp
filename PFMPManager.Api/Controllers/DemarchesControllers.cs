using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;



namespace PFMPManager.Api.Controllers
{
    [ApiController]

    [Route("api/demarches")]

    public class DemarcheController : ControllerBase 
    {
        private readonly AppDbContext _context;

        public DemarcheController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost]

        public async Task<IActionResult> Create(CreateDemarchesDto request)
        {
            var idEtudiant = request.Id_Utilisateur;
            var nomEntreprise = request.Entreprise;
            var dateRefus = request.DateRefus;
            var status = request.Status;
            var contact = request.Contact;
            var Adresse = request.Adresse;
            var SIRET = request.SIRET;

            if (idEtudiant <= 0)
            {
                return BadRequest();
            }
            if (string.IsNullOrWhiteSpace(nomEntreprise) || string.IsNullOrWhiteSpace(status) || string.IsNullOrWhiteSpace(contact) || string.IsNullOrWhiteSpace(Adresse) || string.IsNullOrWhiteSpace(SIRET))
            {
                return BadRequest();
            }
            if (!dateRefus.HasValue)
            {
                return BadRequest();
            }
            var check = await _context.Demarches.FirstOrDefaultAsync(d => d.Id_Utilisateur == idEtudiant && d.SIRET == SIRET);
            if (check != null)
            {
                return Conflict();
            }
            var query = new Demarches
            {

                Id_Utilisateur = idEtudiant,
                SIRET = SIRET,
                dateRefus = dateRefus,
                entreprise = nomEntreprise,
                contact = contact,
                status = status,
                Adresse = Adresse,
            };
            _context.Demarches.Add(query);
            await _context.SaveChangesAsync();

            var result = new DemarchesDto
            {
                Id_Utilisateur = query.Id_Utilisateur,
                SIRET = query.SIRET,
                DateRefus = query.dateRefus,
                Entreprise = query.entreprise,
                Contact = query.contact,
                Status = query.status,
                Adresse = query.Adresse,
            };
            return Ok(result);
        }



        [HttpPut("{idEtudiant}/{siret}")]

        public async Task<IActionResult> Update(CreateDemarchesDto request, int idEtudiant, string siret)
        {
            if (idEtudiant <= 0)
            {
                return BadRequest();
            }
            if(string.IsNullOrWhiteSpace(siret))
            {
                return BadRequest();
            }

            var check = await _context.Demarches.FirstOrDefaultAsync(d => d.Id_Utilisateur == idEtudiant && d.SIRET == siret);
            if (check == null)
            {
                return NotFound();
            }

            check.Id_Utilisateur = request.Id_Utilisateur;
            check.SIRET = request.SIRET;
            check.dateRefus = request.DateRefus;
            check.status = request.Status;
            check.entreprise = request.Entreprise;
            check.contact = request.Contact;
            check.Adresse = request.Adresse;

            await _context.SaveChangesAsync();
            var update = new DemarchesDto
            {
                Id_Utilisateur = check.Id_Utilisateur,
                SIRET = check.SIRET,
                DateRefus = check.dateRefus,
                Status = check.status,
                Entreprise = check.entreprise,
                Contact = check.contact,
                Adresse = check.Adresse,
            };
            return Ok(update);

        }



        
        [HttpDelete("{idEtudiant}/{siret}")]

        public async Task<IActionResult> Delete(int idEtudiant, string siret)
        { 
            var del = await _context.Demarches.FirstOrDefaultAsync(d => d.Id_Utilisateur == idEtudiant && d.SIRET == siret);

            if (del == null)
            {
                return NotFound();
            }
            _context.Demarches.Remove(del);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        

    }
}