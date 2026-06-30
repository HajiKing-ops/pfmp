using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Helpers;
using PFMPManager.Api.Models;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.VisualBasic; // creates  claims 


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

      
        [Authorize(Roles = "Administrateur")]

        [HttpPost("initialiser")]

        public async Task<IActionResult> Presence()
        {
            //value by default
            var etat = "PRESENT";
            var justification = false;
            var todayDate = DateTime.Today;
            var currentUserResult = TryGetCurrentUserContext();
            if (!currentUserResult.Success)
            {
                return Unauthorized(currentUserResult.ErrorMessage);
            }
            var todayDay = DateTime.Today.DayOfWeek switch
            {
                DayOfWeek.Monday => "Lundi",
                DayOfWeek.Tuesday => "Mardi",
                DayOfWeek.Wednesday => "Mercredi",
                DayOfWeek.Thursday => "Jeudi",
                DayOfWeek.Friday => "Vendredi",
                DayOfWeek.Saturday => "Samedi",
                DayOfWeek.Sunday => "Dimanche",
                _ => ""
            };

            if (DateTime.Today.DayOfWeek == DayOfWeek.Saturday ||
                DateTime.Today.DayOfWeek == DayOfWeek.Sunday)
            { 
                return Ok("Pas de presence a initialiser le week-end");
            }
            

            var studentIds = await (from etud in _context.Etudiant
                                  join pfmp in _context.Pfmp
                                  on etud.Id_Utilisateur_1 equals pfmp.Id_Utilisateur_1
                                  join plan in _context.PlanningJours
                                  on pfmp.Id_Planning equals plan.Id_Planning
                                   where pfmp.DateDebut.HasValue
                                  && pfmp.DateFin.HasValue
                                  && pfmp.DateDebut.Value.Date <= todayDate
                                  && pfmp.DateFin.Value.Date >= todayDate
                                  && plan.Jour == todayDay
                                  && pfmp.Id_Utilisateur == currentUserResult.User!.UserId
                                    select pfmp.Id_Utilisateur_1 
                                  
                                  ).Distinct().ToListAsync();


            if (studentIds.Count == 0)
            {
                return Ok("aucune PFMP active aujourdhui");            
            }
                var existingPresences = await _context.TablePresence.Where(o => studentIds.Contains(o.Id_Utilisateur) && o.DateJour == todayDate).Select(o=>o.Id_Utilisateur).ToListAsync();
            var existingKeys = existingPresences.ToHashSet();
            var newPresences = studentIds.Where(s => !existingKeys.Contains(s)).Select(s => new TablePresence
            {
                Id_Utilisateur = s,
                Etat = etat,
                DateJour = todayDate,
                Justification = justification,
                Retard = 0

            }).ToList();
            if (newPresences.Count == 0)
            {
                return Ok("deja initialise");
            }
            
            _context.TablePresence.AddRange(newPresences);
            await _context.SaveChangesAsync();
            
            
            return Ok();
        }



        [Authorize(Roles = "Enseignant,Administrateur")]
        [HttpPut("update/{studentId}")]
        public async Task<IActionResult> UpdateTablePresence(int studentId, UpdateTablePresenceDto request)
        {

            var currentUserResult = TryGetCurrentUserContext();
            if (!currentUserResult.Success)
            {
                return Unauthorized(currentUserResult.ErrorMessage);
            }
            if (string.IsNullOrWhiteSpace(request.Etat) || request.Retard < 0 || !request.DateJour.HasValue)
            {
                return BadRequest();
            }
            var etat = request.Etat.ToLower().Trim();
            if (etat != "present"  && etat != "absent")
            {
                return BadRequest();
            }
            if (currentUserResult.User!.Role == "Enseignant")
            {
                var verify = await (from etud in _context.Etudiant
                                    join pfmp in _context.Pfmp
                                    on etud.Id_Utilisateur_1 equals pfmp.Id_Utilisateur_1
                                    where etud.Id_Utilisateur == currentUserResult.User!.UserId
                                    && pfmp.Id_Utilisateur_1 == studentId && pfmp.DateDebut.HasValue
                                    && pfmp.DateFin.HasValue && pfmp.DateDebut.Value.Date <= request.DateJour.Value.Date
                                    && pfmp.DateFin.Value.Date >= request.DateJour.Value.Date
                                    select pfmp
                                    ).AsNoTracking().AnyAsync();
                if (!verify)
                {
                    return BadRequest();
                }
            }

            if (currentUserResult.User!.Role == "Administrateur")
            {
                var verify = await _context.Pfmp.AsNoTracking().Where(pfmp => pfmp.Id_Utilisateur == currentUserResult.User!.UserId
                                                && pfmp.Id_Utilisateur_1 == studentId && pfmp.DateDebut.HasValue
                                                && pfmp.DateFin.HasValue && pfmp.DateDebut.Value.Date <= request.DateJour.Value.Date
                                                && pfmp.DateFin.Value.Date >= request.DateJour.Value.Date
                                                ).AnyAsync();
                if (!verify)
                {
                    return BadRequest();
                }
            }
            var present = await _context.TablePresence.Where(p => p.DateJour.HasValue && p.DateJour.Value.Date == request.DateJour.Value.Date && p.Id_Utilisateur == studentId).FirstOrDefaultAsync();
            if (present == null)
            {
                return BadRequest();
            }
            present.Etat = "PRESENT";
            present.Justification = request.Justification;
            
            if (etat == "absent")
            {
                present.Retard = 0;
                present.Etat = "ABSENT";
            }
            else
            {
                present.Retard = request.Retard;
            }

            await _context.SaveChangesAsync();

            return Ok();

        }
        private bool TryGetCurrentUserId(out int currentStudentId)
        {

            var id = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(id, out currentStudentId);
        }

        private string? TryGetCurrentUserRole()
        {

            return User.FindFirstValue(ClaimTypes.Role);

        }

        private class CurrentUserContext
        {
            public int UserId { get; set; }
            public string Role { get; set; } = string.Empty;
        }
        private class CurrentUserContextResult
        {
            public bool Success { get; set; }
            public string? ErrorMessage { get; set; }
            public CurrentUserContext? User { get; set; }
        }
        private CurrentUserContextResult TryGetCurrentUserContext()
        {
            var result = new CurrentUserContextResult();

            if (!TryGetCurrentUserId(out int currentUserId))
            {
                result.Success = false;
                result.ErrorMessage = "Token invalide : identifiant utilisateur manquant";
                return result;
            }
            var role = TryGetCurrentUserRole();
            if (role == null || string.IsNullOrWhiteSpace(role))
            {
                result.Success = false;
                result.ErrorMessage = "Token invalide : role utilisateur manquant";
                return result;
            }
            result.Success = true;
            result.User = new CurrentUserContext
            {
                UserId = currentUserId,
                Role = role
            };
            return result;
        }
    }
}