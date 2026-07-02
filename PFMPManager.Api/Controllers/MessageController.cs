using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;
using PFMPManager.Api.Services;


namespace PFMPManager.Api.Controllers
{
    [ApiController]

    [Route("api/messages")]

    public class MessageController : ControllerBase
    {
        private readonly AppDbContext _context;
        //private readonly IRoleService _roleService;
        private readonly ICurrentUserService _currentUserService;
        public MessageController(AppDbContext context, ICurrentUserService currentUserService)
        {
            _context = context;
            //_roleService = roleService;
            _currentUserService = currentUserService;
        }


        [Authorize]

        [HttpGet("{idPfmp}")]
        //Retrieves the message history for an authorized pfmp participant 
        public async Task<IActionResult> GetHistory(int idPfmp)
        {
            var user = _currentUserService.GetCurrentUser(User);
            if (!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
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
            bool canAccessPfmp = await CanAccessPfmpAsync(user.UserId, user.Role, idPfmp);

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
        //Sends a message to the pfmp chat if the user is authorized 
        public async Task<IActionResult> SendMessage(MessageRequestDto request, int idPfmp)
        {
            var user = _currentUserService.GetCurrentUser(User);
            if (!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            if (request == null || string.IsNullOrWhiteSpace(request.Contenu))
            {
                return BadRequest("Le contenu du message est obligatoire");
            }

            var existPfmp = await PfmpExistsAsync(idPfmp);
            if (!existPfmp)
            {
                return NotFound("la PFMP n'existe pas");

            }
            var activePfmp = await IsPfmpActiveAsync(idPfmp);

            if (!activePfmp)
            {
                return BadRequest("La PFMP n'est pas active.");
            }

            bool canAccessPfmp = await CanAccessPfmpAsync(user.UserId, user.Role, idPfmp);

            if (!canAccessPfmp)
            {
                return Forbid();
            }

            var newMsg = new Message
            {
                Id_Utilisateur = user.UserId,
                Id_PFMP = idPfmp,
                RoleExpediteur = user.Role,
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

        //check whether the PFMP exists
        private async Task<bool> PfmpExistsAsync(int idPfmp)
        {
            return await _context.Pfmp.AsNoTracking().AnyAsync(p => p.Id_PFMP == idPfmp);
        }



        // check whether the pfmp is currently active
        private async Task<bool> IsPfmpActiveAsync(int idPfmp)
        {
            var activePfmp = await _context.Pfmp.AsNoTracking().AnyAsync(pfmp => pfmp.Id_PFMP == idPfmp && pfmp.DateDebut.HasValue
                                           && pfmp.DateFin.HasValue && pfmp.DateFin.Value.Date >= DateTime.Today.Date
                                           && pfmp.DateDebut.Value.Date <= DateTime.Today.Date);
            return activePfmp;
        }


        // Check whether the user can access the pfmp chat
        private async Task<bool> CanAccessPfmpAsync(int idUtilisateur, string role, int idPfmp)
        {
            if (role == "Etudiant")
            {
                return await _context.Pfmp.AsNoTracking().AnyAsync(pf => pf.Id_Utilisateur_1 == idUtilisateur && pf.Id_PFMP == idPfmp);
            }
            else if (role == "Enseignant")
            {
                return await (from e in _context.Etudiant
                              join pfmp in _context.Pfmp
                                  on e.Id_Utilisateur_1 equals pfmp.Id_Utilisateur_1
                              where e.Id_Utilisateur == idUtilisateur
                                  && pfmp.Id_PFMP == idPfmp
                              select pfmp
                                        ).AsNoTracking().AnyAsync();

            }
            else if (role == "Administrateur")
            {
                return await (from admin in _context.Administrer
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
                                       ).AsNoTracking().AnyAsync();



            }
            return false;
        }
    }
}



