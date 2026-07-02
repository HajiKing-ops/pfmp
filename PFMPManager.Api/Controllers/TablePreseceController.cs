using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;
using PFMPManager.Api.Data;
using PFMPManager.Api.Services;


namespace PFMPManager.Api.Controllers
{
    [ApiController]
    [Route("api/presence")]
    public class TablePreseceController : ControllerBase
    {
        private readonly AppDbContext _context;
        private const string Present = "PRESENT";
        private const string Absent = "ABSENT";
        private readonly ICurrentUserService _currentUserService;

        public TablePreseceController(AppDbContext context, ICurrentUserService currentUser)
        {
            _context = context;
            _currentUserService = currentUser;
        }

        [Authorize(Roles = "Administrateur")]

        [HttpPost("initialiser")]
        // Initializes today's presence records for students in active PFMPs
        public async Task<IActionResult> Presence()
        {
            // Default values for new presence records
            var justification = false;
            var todayDate = DateTime.Today;
            var currentUserResult = _currentUserService.GetCurrentUser(User);
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
                                  && pfmp.Id_Utilisateur == currentUserResult.UserId
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
                Etat = Present,
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
        // Updates a student's presence record for a specific day
        public async Task<IActionResult> UpdateTablePresence(int studentId, UpdateTablePresenceDto request)
        {

            var currentUserResult = _currentUserService.GetCurrentUser(User);
            if (!currentUserResult.Success)
            {
                return Unauthorized(currentUserResult.ErrorMessage);
            }
            
            if (request == null || string.IsNullOrWhiteSpace(request.Etat) || request.Retard < 0 || !request.DateJour.HasValue)
            {
                return BadRequest();
            }
            var etat = request.Etat.ToLower().Trim();
            if (etat != Present.ToLower().Trim()  && etat != Absent.ToLower().Trim())
            {
                return BadRequest();
            }
            // Ensure the connected user is allowed to update this student's presence

            if (currentUserResult.Role == "Enseignant")
            {
                var verify = await (from etud in _context.Etudiant
                                    join pfmp in _context.Pfmp
                                    on etud.Id_Utilisateur_1 equals pfmp.Id_Utilisateur_1
                                    where etud.Id_Utilisateur == currentUserResult.UserId
                                    && pfmp.Id_Utilisateur_1 == studentId && pfmp.DateDebut.HasValue
                                    && pfmp.DateFin.HasValue && pfmp.DateDebut.Value.Date <= request.DateJour.Value.Date
                                    && pfmp.DateFin.Value.Date >= request.DateJour.Value.Date
                                    select pfmp
                                    ).AsNoTracking().AnyAsync();
                if (!verify)
                {
                    return Forbid();
                }
            }

            if (currentUserResult.Role == "Administrateur")
            {
                var verify = await _context.Pfmp.AsNoTracking().Where(pfmp => pfmp.Id_Utilisateur == currentUserResult.UserId
                                                && pfmp.Id_Utilisateur_1 == studentId && pfmp.DateDebut.HasValue
                                                && pfmp.DateFin.HasValue && pfmp.DateDebut.Value.Date <= request.DateJour.Value.Date
                                                && pfmp.DateFin.Value.Date >= request.DateJour.Value.Date
                                                ).AnyAsync();
                if (!verify)
                {
                    return Forbid();
                }
            }
            var present = await _context.TablePresence.Where(p => p.DateJour.HasValue && p.DateJour.Value.Date == request.DateJour.Value.Date && p.Id_Utilisateur == studentId).FirstOrDefaultAsync();
            if (present == null)
            {
                return NotFound("Aucune presence trouvee pour cet etudiant a cette date.");
            }
            present.Etat = Present;
            present.Justification = request.Justification;

            if (etat == Absent.ToLower().Trim())
            {
                present.Retard = 0;
                present.Etat = Absent;
            }
            else
            {
                present.Retard = request.Retard;
            }

            await _context.SaveChangesAsync();

            return Ok();

        }
    }
}