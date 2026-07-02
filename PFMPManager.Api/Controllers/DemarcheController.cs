using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
using PFMPManager.Api.Models;
using PFMPManager.Api.Services;



namespace PFMPManager.Api.Controllers
{
    

    // Manages student contact requests with organisations
    [Route("api/demarches")]
    [ApiController]
    [Authorize]
    public class DemarcheController : ControllerBase
    {
        private readonly AppDbContext _context;
        private const string EnAttente = "En attente";
        private const string Refuse = "Refuse";
        private const string Accepte = "Accepte";
        private readonly ICurrentUserService _currentUserService;

        public DemarcheController(AppDbContext context, ICurrentUserService currentUserService)
        {
            _context = context;
            _currentUserService = currentUserService;
        }

        // Retrieves contact requests for the connected student
        [HttpGet]
        [Authorize(Roles = "Etudiant")]
        public async Task<IActionResult> Get()
        {
            var user = _currentUserService.GetCurrentUser(User);
            if(!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idEtudiant = user.UserId;
            
            // Load contact requests owned by the connected student
            var getAllDemarches = await _context.Contacter.AsNoTracking().Where(c => c.Id_Utilisateur == idEtudiant).ToListAsync();
            if (!getAllDemarches.Any())
            {
                return NotFound("Aucune Demarche");
            }
            
            var dtos = new List<ContacterDto>();

            foreach (var d in getAllDemarches)
            {
                var checkOrg = await _context.Organisation.AsNoTracking().Where(o => o.SIRET == d.SIRET).Select(o => o.RaisonSociale).FirstOrDefaultAsync();

                if (checkOrg == null)
                {
                    return NotFound("L'Organisation introuvable");
                }
                var dto = new ContacterDto
                {
                    Id_Utilisateur = d.Id_Utilisateur,
                    SIRET = d.SIRET,
                    TypeContact = d.TypeContact,
                    DateDemande = d.DateDemande,
                    StatutDemande = d.StatutDemande,
                    RaisonSociale = checkOrg,
                };
                dtos.Add(dto);
            }

            return Ok(dtos);
        }


        // Creates a contact request for the connected student and selected organisation
        [HttpPost("{siret}")]
        [Authorize(Roles = "Etudiant")]
        public async Task<IActionResult> Create(CreateContacterDto request, string siret)
        {
            var user = _currentUserService.GetCurrentUser(User);
            if(!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idEtudiant = user.UserId;
            var SIRET = siret;
            if(request == null)
            {
                return BadRequest();
            }
            
     

            // Validate required contact request fields
            if (string.IsNullOrWhiteSpace(SIRET) || string.IsNullOrWhiteSpace(request.TypeContact) || string.IsNullOrWhiteSpace(request.StatutDemande))
            {
                return BadRequest();
            }
            var dateDemande = request.DateDemande;
            var typeContact = request.TypeContact;
            var statutDemande = request.StatutDemande.Trim().ToLower();
            if (!dateDemande.HasValue)
            {
                return BadRequest();
            }

            if (statutDemande != EnAttente.Trim().ToLower())
            {
                return BadRequest("il faut entre en attend");
            }
            if (statutDemande == EnAttente.Trim().ToLower())
            {
                statutDemande = EnAttente;
            }
            // Ensure the organisation exists before creating the contact request

            var searchOrg = await _context.Organisation.AsNoTracking().Where(o => o.SIRET == SIRET).Select(o=> o.RaisonSociale).FirstOrDefaultAsync();
            if (searchOrg == null)
            {
                return NotFound("l'organisation n'existe pas");
            }
            // Prevent duplicate contact requests for the same organisation
            var check = await _context.Contacter.AsNoTracking().AnyAsync(d => d.Id_Utilisateur == idEtudiant && d.SIRET == SIRET);
            if (check)
            {
                return Conflict();
            }
            var query = new Contacter
            {

                Id_Utilisateur = idEtudiant,
                SIRET = SIRET,
                TypeContact = typeContact,
                DateDemande = dateDemande,
                StatutDemande = EnAttente,
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
                RaisonSociale = searchOrg,
            };
            return Ok(result);
        }


        // Updates an existing contact request owned by the connected student
        [Authorize(Roles = "Etudiant")]
        [HttpPut("modify/{siret}")]
        public async Task<IActionResult> Update(CreateContacterDto request, string siret)
        {
            var user = _currentUserService.GetCurrentUser(User);
            if(!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idEtudiant = user.UserId;
            if(request == null)
            {
                return BadRequest();
            }
           
            // Validate required contact request fields
            if (string.IsNullOrWhiteSpace(siret) || string.IsNullOrWhiteSpace(request.TypeContact) || string.IsNullOrWhiteSpace(request.StatutDemande))
            {
                return BadRequest();
            }
            var dateDemande = request.DateDemande;
            var typeContact = request.TypeContact;
            var statutDemande = request.StatutDemande.Trim().ToLower();
            if (!dateDemande.HasValue)
            {
                return BadRequest();
            }

            if (statutDemande != EnAttente.Trim().ToLower() && statutDemande != Refuse.Trim().ToLower() && statutDemande != Accepte.Trim().ToLower())
            {
                return BadRequest("il faut entre en attend, refuse ou accepte");
            }
            if (statutDemande == EnAttente.Trim().ToLower())
            {
                statutDemande = EnAttente;
            }
            else if (statutDemande == Refuse.Trim().ToLower())
            {
                statutDemande = Refuse;
            }
            else if (statutDemande == Accepte.Trim().ToLower())
            {
                statutDemande = Accepte;
            }


            var searchOrg = await _context.Organisation.AsNoTracking().Where(o => o.SIRET == siret).Select(o=> o.RaisonSociale).FirstOrDefaultAsync();
            if (searchOrg == null)
            {
                return NotFound("l'organisation n'existe pas");
            }
            // Find the contact request owned by the connected student
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
                StatutDemande = update.StatutDemande,
                RaisonSociale = searchOrg,
            };
            return Ok(dto);

        }


    }
}