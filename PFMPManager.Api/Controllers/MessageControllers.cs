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

            var existPfmp = await _context.Pfmp.AnyAsync(p => p.Id_PFMP == idPfmp);
            if (!existPfmp)
            {
                return NotFound("PFMP n'existe pas");

            }
            var activePfmp = await _context.Pfmp.AnyAsync(pfmp => pfmp.Id_PFMP == idPfmp && pfmp.DateDebut.HasValue
                                            && pfmp.DateFin.HasValue && pfmp.DateFin.Value.Date >= DateTime.Today.Date
                                            && pfmp.DateDebut.Value.Date <= DateTime.Today.Date);
            if (!activePfmp)
            {
                return BadRequest("PFMP est deactive");
            }
            if (role == "Etudiant")
            {
                var verifyPfmp = await _context.Pfmp.AnyAsync(pf => pf.Id_Utilisateur_1 == idUtilisateur && pf.Id_PFMP == idPfmp);

                if (!verifyPfmp)
                {
                    return Forbid();

                }
            }
            else if (role == "Enseignant")
            {
                var verifyPfmp = await (from e in _context.Etudiant
                                        join pfmp in _context.Pfmp
                                            on e.Id_Utilisateur_1 equals pfmp.Id_Utilisateur_1
                                        where e.Id_Utilisateur == idUtilisateur
                                            && pfmp.Id_PFMP == idPfmp
                                        select pfmp
                                         ).AnyAsync();
                if (!verifyPfmp)
                {
                    return Forbid();

                }

            }
            else if (role == "Administrateur")
            {
                var verifyPfmp = await (from admin in _context.Administrer
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



                if (!verifyPfmp)
                {
                    return Forbid();

                }
            }
            else
            {
                return Forbid();
            }

            var getMsg = await _context.Message.Where(ms => ms.Id_PFMP == idPfmp).OrderBy(ms => ms.DateEnvoi).Select(ms => new MessageResponseDto {
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

            var existPfmp = await _context.Pfmp.AnyAsync(p=> p.Id_PFMP == idPfmp);
            if (!existPfmp)
            {
                return NotFound("PFMP n'existe pas");

            }
            var activePfmp = await _context.Pfmp.AnyAsync(pfmp => pfmp.Id_PFMP == idPfmp && pfmp.DateDebut.HasValue
                                            && pfmp.DateFin.HasValue && pfmp.DateFin.Value.Date >= DateTime.Today.Date
                                            && pfmp.DateDebut.Value.Date <= DateTime.Today.Date);
            if (!activePfmp)
            {
                return BadRequest("PFMP est deactive");
            }
            if (role == "Etudiant")
            {
                var verifyPfmp = await _context.Pfmp.AnyAsync(pf => pf.Id_Utilisateur_1 == idUtilisateur && pf.Id_PFMP == idPfmp );

                if (!verifyPfmp)
                {
                    return Forbid();

                }
            }
            else if (role == "Enseignant")
            {
                var verifyPfmp = await (from e in _context.Etudiant
                                        join pfmp in _context.Pfmp
                                            on e.Id_Utilisateur_1 equals pfmp.Id_Utilisateur_1
                                        where e.Id_Utilisateur == idUtilisateur 
                                            && pfmp.Id_PFMP == idPfmp 
                                        select pfmp
                                         ).AnyAsync();
                if (!verifyPfmp)
                {
                    return Forbid();

                }

            } else if (role == "Administrateur")
            {
                var verifyPfmp = await (from admin in _context.Administrer
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



                if (!verifyPfmp)
                {
                    return Forbid();

                }
            } else {
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
        
    }
}
