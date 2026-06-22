
using System.Security.Claims; // creates  claims
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;


namespace PFMPManager.Api.Controllers
{
    [ApiController]

    [Route("api/messages")]

    public class MessageController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IRoleService _roleService;

        public MessageController(AppDbContext context, IRoleService roleService)
        {
            _context = context;
            _roleService = roleService;
        }


        [Authorize]

        [HttpGet("{idPfmp}")]

        public async Task<IActionResult> GetHistory(int idPfmp)
        {
            var id = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(id, out int idUtilisateur))
            {
                return Unauthorized("Token invalide : identifiant utilisateur manquant.");
            }



            var role = await _roleService.GetUserRoleAsync(idUtilisateur);

            if (string.IsNullOrWhiteSpace(role))
            {
                return Unauthorized("Role introuvable.");
            }

            bool existPfmp = await PfmpExistsAsync(idPfmp);
            if (!existPfmp)
            {
                return NotFound("PFMP n'existe pas");

            }
            var activePfmp = await IsPfmpActiveAsync(idPfmp);

            if (!activePfmp)
            {
                return BadRequest("PFMP est deactive");
            }
            bool canAccessPfmp = await CanAccessPfmpAsync(idUtilisateur, role, idPfmp);

            if (!canAccessPfmp)
            {
                return Forbid();
            }



            var getMsg = await _context.Message.Where(ms => ms.Id_PFMP == idPfmp).OrderBy(ms => ms.DateEnvoi).Select(ms => new MessageResponseDto
            {
                IdUtilisateur = ms.Id_Utilisateur,
                IdPfmp = ms.Id_PFMP,
                RoleExpediteur = ms.RoleExpediteur,
                Contenu = ms.Contenu,
                DateEnvoi = ms.DateEnvoi,
                IdMessage = ms.Id_Message,
            }).ToListAsync();


            return Ok(getMsg);

        }

        [Authorize]

        [HttpPost("{idPfmp}")]

        public async Task<IActionResult> SendMessage(MessageRequestDto request, int idPfmp)
        {

            var id = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(id, out int idUtilisateur))
            {
                return Unauthorized("Token invalide : identifiant utilisateur manquant.");
            }

            if (request == null || string.IsNullOrWhiteSpace(request.Contenu))
            {
                return BadRequest("Contenu est vide");
            }

            var role = await _roleService.GetUserRoleAsync(idUtilisateur);

            if (string.IsNullOrWhiteSpace(role))
            {
                return Unauthorized("Role introuvable.");
            }

            var existPfmp = await PfmpExistsAsync(idPfmp);
            if (!existPfmp)
            {
                return NotFound("PFMP n'existe pas");

            }
            var activePfmp = await IsPfmpActiveAsync(idPfmp);

            if (!activePfmp)
            {
                return BadRequest("PFMP est deactive");
            }

            bool canAccessPfmp = await CanAccessPfmpAsync(idUtilisateur, role, idPfmp);

            if (!canAccessPfmp)
            {
                return Forbid();
            }

            var newMsg = new Message
            {
                Id_Utilisateur = idUtilisateur,
                Id_PFMP = idPfmp,
                RoleExpediteur = role,
                Contenu = request.Contenu,
                DateEnvoi = DateTime.UtcNow,
            };

            _context.Message.Add(newMsg);
            await _context.SaveChangesAsync();

            var dto = new MessageResponseDto
            {
                IdUtilisateur = newMsg.Id_Utilisateur,
                IdPfmp = newMsg.Id_PFMP,
                RoleExpediteur = newMsg.RoleExpediteur,
                Contenu = newMsg.Contenu,
                DateEnvoi = newMsg.DateEnvoi,
                IdMessage = newMsg.Id_Message,
            };

            return Ok(dto);

        }

        //check if PFMP exist or not
        private async Task<bool> PfmpExistsAsync(int idPfmp)
        {
            return await _context.Pfmp.AnyAsync(p => p.Id_PFMP == idPfmp);
        }



        // check if the pfmp is active or not
        private async Task<bool> IsPfmpActiveAsync(int idPfmp)
        {
            var activePfmp = await _context.Pfmp.AnyAsync(pfmp => pfmp.Id_PFMP == idPfmp && pfmp.DateDebut.HasValue
                                           && pfmp.DateFin.HasValue && pfmp.DateFin.Value.Date >= DateTime.Today.Date
                                           && pfmp.DateDebut.Value.Date <= DateTime.Today.Date);
            return activePfmp;
        }


        // Can this user access this active PFMP chat?
        private async Task<bool> CanAccessPfmpAsync(int idUtilisateur, string role, int idPfmp)
        {
            bool canAccess = false;
            if (role == "Etudiant")
            {
                canAccess = await _context.Pfmp.AnyAsync(pf => pf.Id_Utilisateur_1 == idUtilisateur && pf.Id_PFMP == idPfmp);
            }
            else if (role == "Enseignant")
            {
                canAccess = await (from e in _context.Etudiant
                                  join pfmp in _context.Pfmp
                                      on e.Id_Utilisateur_1 equals pfmp.Id_Utilisateur_1
                                  where e.Id_Utilisateur == idUtilisateur
                                      && pfmp.Id_PFMP == idPfmp
                                  select pfmp
                                        ).AnyAsync();

            }
            else if (role == "Administrateur")
            {
                canAccess = await (from admin in _context.Administrer
                                  join gc in _context.GroupeClasse
                                      on admin.Id_Etablissement equals gc.Id_Etablissement
                                  join e in _context.Etudier
                                      on new { gc.Id_Etablissement, gc.Id_Classe }
                                      equals new { e.Id_Etablissement, e.Id_Classe }
                                  join etud in _context.Etudiant
                                      on e.Id_Utilisateur equals etud.Id_Utilisateur_1
                                  join p in _context.Pfmp
                                      on etud.Id_Utilisateur_1 equals p.Id_Utilisateur_1
                                  where admin.Id_Utilisateur == idUtilisateur
                                      && p.Id_PFMP == idPfmp
                                  select p
                                       ).AnyAsync();



            }
            return canAccess;
        }
    }
}



