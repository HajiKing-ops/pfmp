using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Helpers;
using PFMPManager.Api.Models;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
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



        [Authorize(Roles = "Etudiant,Enseignant")]
        [HttpGet("recherche/{idEtudiant}/{idPfmp?}")] //address of the method
        public async Task<IActionResult> GetPfmpById(int idEtudiant, int? idPfmp)
        {
            if (!TryGetCurrentUserId(out int currentUserId))
            {
                return Unauthorized("Token invalide : identifiant utilisateur manquant");
            }
            var role = TryGetCurrentUserRole();
            if (role == null || string.IsNullOrWhiteSpace(role))
            {
                return Unauthorized("Token invalide : role utilisateur manquant");
            }
            var pfmpAccessError = await ValidatePfmpAccessAsync(currentUserId, idEtudiant, role);
            if (pfmpAccessError != null)
            {
                return StatusCode(403, pfmpAccessError);    
            }
            
            

            var query = _context.Pfmp.AsQueryable();
            if (idPfmp != null)
            {
                if (role == "Etudiant")
                {
                    query = query.Where(o => o.Id_Utilisateur_1 == idEtudiant && o.Id_PFMP == idPfmp);
                }
                else if(role == "Enseignant")
                {
                    query = from etudiant in _context.Etudiant
                            join pfmp in _context.Pfmp
                            on etudiant.Id_Utilisateur_1 equals pfmp.Id_Utilisateur_1
                            where etudiant.Id_Utilisateur == currentUserId
                            && pfmp.Id_Utilisateur_1 == idEtudiant
                            && pfmp.Id_PFMP == idPfmp
                            select pfmp;
                }
                
            }
            else
            {
                if (role == "Etudiant")
                {
                    query = query.Where(o => o.Id_Utilisateur_1 == idEtudiant);    
                }
                else if (role == "Enseignant")
                {
                    query = from etudiant in _context.Etudiant
                            join pfmp in _context.Pfmp
                            on etudiant.Id_Utilisateur_1 equals pfmp.Id_Utilisateur_1
                            where etudiant.Id_Utilisateur == currentUserId
                            && pfmp.Id_Utilisateur_1 == idEtudiant
                            select pfmp;
                }
            }
            var pfmps = await query.ToListAsync();
            if (!pfmps.Any())
            {
                return NotFound();
            }
            var result = new List<PfmpDetailDto>();
            foreach (var p in pfmps)
            {
                var organisation = await _context.Organisation.FirstOrDefaultAsync(o => o.SIRET == p.SIRET);
                var dto = new PfmpDetailDto
                {
                    DateDebut = p.DateDebut,
                    DateFin = p.DateFin,
                    Id_Planning = p.Id_Planning,
                    SIRET = p.SIRET,
                    IdEtudiant = p.Id_Utilisateur_1,
                    IdPfmp = p.Id_PFMP,
                    JourRestants = p.DateFin.HasValue ? Math.Max(0, (p.DateFin.Value.Date - DateTime.Today).Days) : 0,
                    RaisonSociale = organisation?.RaisonSociale ?? string.Empty
                };
                if (p.DateDebut != null && p.DateFin != null)
                {
                    var semaine = p.DateFin.Value.Date - p.DateDebut.Value.Date;
                    var total = semaine.TotalDays / 7;
                    dto.Semaine = (int)total;
                }
                var search = await _context.Travailler.FirstOrDefaultAsync(t => t.SIRET == p.SIRET);
                if (search != null)
                {
                    var maitreDeStage = await _context.Utilisateur.FirstOrDefaultAsync(u => u.Id_Utilisateur == search.Id_Utilisateur);
                    if (maitreDeStage != null)
                    {
                        dto.PrenomMaitreStage = maitreDeStage.Prenom;
                        dto.NomMaitreStage = maitreDeStage.Nom;
                        var prof = await _context.Professionnel.FirstOrDefaultAsync(r => r.Id_Utilisateur == search.Id_Utilisateur);
                        if (prof != null)
                        {
                            dto.FonctionMaitreStage = prof.Fonction;
                            dto.TelephoneMaitreStage = prof.NumTelephone;
                            dto.EmailMaitreStage = prof.AdresseMail;
                        }
                    }
                }
                dto.PlanningJours = await _context.PlanningJours
                    .Where(j => j.Id_Planning == p.Id_Planning)
                    .Select(j => new CreatePlanningJoursDto
                    {
                        Jour = j.Jour,
                        MatinDebut = j.MatinDebut,
                        MatinFin = j.MatinFin,
                        ApresMidiDebut = j.ApresMidiDebut,
                        ApresMidiFin = j.ApresMidiFin,
                        TotalHeures = j.TotalHeures
                    })
                    .ToListAsync();
                result.Add(dto);
            }
            return Ok(result);
        }





        [Authorize(Roles = "Etudiant")]
        [HttpPost("complete")]
        public async Task<IActionResult> CompletePfmp(CreateCompletePfmpDto request)
        {
            //entreprise
            var siret = request.SIRET;
            //planning
            var requestedWeeklyTotal = request.TotalHebdo;

            var currentYear = DateTime.Today.Year;
            

            //Get current student id
            if (!TryGetCurrentUserId(out int currentStudentId))
            {
                return Unauthorized("Token invalide : identifiant utilisateur manquant");
            }

            //Validate basic request fields
            if (IsBasicCompletePfmpRequestInvalid(request))
            {
                return BadRequest();
            }

            var planningValidation = ValidatePlanningDays(request.PlanningJours, requestedWeeklyTotal);
            if (planningValidation.ErrorMessage != null)
            {
               return BadRequest(planningValidation.ErrorMessage);
            }
            var calculatedWeeklyTotal = planningValidation.CalculatedWeeklyTotal;
            var validPlanningDays = planningValidation.ValidPlanningDays;

            //Find administrator
            var administratorId = await FindAdministratorIdForStudentAsync(currentStudentId, currentYear);

            if (administratorId <= 0)
            {
                return NotFound("Adminstrateur n'existe pas");
            }
            
            //check business rules
            var hasAcceptedContactRequest = await HasAcceptedContactRequestAsync(currentStudentId, siret);

            if (!hasAcceptedContactRequest)
            {
                return BadRequest("Vous devez d'abord contacter l'organisation");
            }
            //search
            var startDate = request.DateDebut.Value.Date;
            var endDate = request.DateFin.Value.Date;

            var alreadyInInternship = await HasOverlappingPfmpAsync(currentStudentId, startDate, endDate);
            if (alreadyInInternship)
            {
                return BadRequest("Vous êtes deja en stage sur cette periode");
            }

            
            var organisation = await FindOrganisationBySiretAsync(siret);
            if (organisation == null)
            {
                return NotFound("L’organisation est introuvable");
            }
            
            //Create/Update database entities inside transaction 
            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                

                await UpdateOrganisationWebsiteAsync(organisation,request.SiteWeb!);

                
                var user = await GetOrCreateSupervisorUserAsync(request.NomMaitreStage!, request.PrenomMaitreStage!, request.EmailMaitreStage!);

                var prf = await GetOrCreateProfessionalProfileAsync(user.Id_Utilisateur, request.FonctionMaitreStage!, request.EmailMaitreStage!, request.TelephoneMaitreStage!);
                

                await EnsureWorkRelationExistsAsync(prf.Id_Utilisateur, siret);
                
                

                var idPlanning = await CreatePlanningWithDaysAsync(calculatedWeeklyTotal, validPlanningDays);


                
                var createdPfmp = await CreatePfmpAsync(request, idPlanning, currentStudentId, administratorId);

                var responseDto = BuildCompletePfmpResponse(createdPfmp,currentStudentId,administratorId);

                await transaction.CommitAsync();
                
                return Ok(responseDto);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }

           

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

        private async Task<string?> ValidatePfmpAccessAsync(int currentUserId, int idEtudiant, string role)
        {
            if (role == "Etudiant" && currentUserId == idEtudiant)
            {
                return null;
            }
            else if(role == "Enseignant")
            {
                var hasStudentAccess = await _context.Etudiant.AnyAsync(o=> o.Id_Utilisateur == currentUserId && o.Id_Utilisateur_1 == idEtudiant);
                if(hasStudentAccess)
                {
                    return null;
                }
            }
            return "Vous n’avez pas le droit d’accéder à cette PFMP.";
            
        }
        
        private bool IsBasicCompletePfmpRequestInvalid(CreateCompletePfmpDto request)
        {
            
            return string.IsNullOrWhiteSpace(request.RaisonSociale) || string.IsNullOrWhiteSpace(request.SecteurActivite) || string.IsNullOrWhiteSpace(request.SIRET) 
                 || string.IsNullOrWhiteSpace(request.Adresse)      || string.IsNullOrWhiteSpace(request.NumTelephone)    || string.IsNullOrWhiteSpace(request.SiteWeb)
                 || string.IsNullOrWhiteSpace(request.PrenomMaitreStage) || string.IsNullOrWhiteSpace(request.TelephoneMaitreStage)
                 || string.IsNullOrWhiteSpace(request.NomMaitreStage)    || string.IsNullOrWhiteSpace(request.FonctionMaitreStage) 
                 || string.IsNullOrWhiteSpace(request.EmailMaitreStage)  || !request.DateDebut.HasValue || !request.DateFin.HasValue 
                 || request.DateFin.Value.Date < request.DateDebut.Value.Date;
        }

        private bool IsTimeSlotComplete(TimeSpan? start, TimeSpan? end)
        {
            return start != null && end != null;
        }
        private bool IsTimeSlotEmpty(TimeSpan? start, TimeSpan? end)
        { 
            return start == null && end == null;
        }
        private bool IsTimeSlotIncomplete(TimeSpan? start, TimeSpan? end)
        {
            return !IsTimeSlotEmpty(start, end) && !IsTimeSlotComplete(start, end);
        }

        private int CalculateTimeSlotMinutes(TimeSpan? start, TimeSpan? end)
        {
            if (!start.HasValue || !end.HasValue)
            {
                return 0;
            }
            var duration = end.Value - start.Value;
            return (int)duration.TotalMinutes;
        }

        private bool IsTimeSlotOrderInvalid(TimeSpan? start, TimeSpan? end)
        {
            if (!IsTimeSlotComplete(start, end))
            {
                return false;
            }
            return  start.Value >= end.Value;
        }
        private int CalculatePlanningDayMinutes(CreatePlanningJoursDto planningDay)
        { 
            return CalculateTimeSlotMinutes(planningDay.MatinDebut, planningDay.MatinFin) + CalculateTimeSlotMinutes(planningDay.ApresMidiDebut, planningDay.ApresMidiFin);
        }

        private bool IsMorningOverlappingAfternoon(TimeSpan? morningEnd, TimeSpan? afternoonStart)
        {
            if (!morningEnd.HasValue || !afternoonStart.HasValue)
            {
                return false;
            }
            return morningEnd.Value >= afternoonStart.Value;
        }

        private CreatePlanningJoursDto CreateValidatedPlanningDay(CreatePlanningJoursDto planningDay)
        {

            return new CreatePlanningJoursDto
             {
                Jour = planningDay.Jour,
                MatinDebut = planningDay.MatinDebut,
                MatinFin = planningDay.MatinFin,
                ApresMidiDebut = planningDay.ApresMidiDebut,
                ApresMidiFin = planningDay.ApresMidiFin,
                TotalHeures = planningDay.TotalHeures
            };
        }

        private bool IsWeeklyTotalInvalid(int calculatedWeeklyTotal, int? requestedWeeklyTotal)
        {
            return calculatedWeeklyTotal != requestedWeeklyTotal || calculatedWeeklyTotal <= 0 || calculatedWeeklyTotal > 2100;
        }

        private bool IsPlanningDayEmpty(CreatePlanningJoursDto planningDay) {
            return IsTimeSlotEmpty(planningDay.MatinDebut, planningDay.MatinFin) && IsTimeSlotEmpty(planningDay.ApresMidiDebut, planningDay.ApresMidiFin);
            
        }

        private string? GetPlanningDayValidationError(CreatePlanningJoursDto planningDay)
        {
            if (string.IsNullOrWhiteSpace(planningDay.Jour))
            {
                return "Le jour est obligatoire.";
            }

            bool matinIncomplete = IsTimeSlotIncomplete(planningDay.MatinDebut, planningDay.MatinFin);
            bool midiIncomplete = IsTimeSlotIncomplete(planningDay.ApresMidiDebut, planningDay.ApresMidiFin);

            if (IsPlanningDayEmpty(planningDay))
            {
                return null; 
            }

            if (matinIncomplete)
            {
                return  $"le matin du jour {planningDay.Jour} est incomplet";
            }
            if (midiIncomplete)
            {
                return  $"le apres-midi du jour {planningDay.Jour} est incomplet";
            }

            if (IsTimeSlotOrderInvalid(planningDay.MatinDebut, planningDay.MatinFin))
            {
                return $"pour {planningDay.Jour} l'heure de debut du matin doit etre avant l'heure de fin ";
            }
            if (IsTimeSlotOrderInvalid(planningDay.ApresMidiDebut, planningDay.ApresMidiFin))
            {
                return  $"pour {planningDay.Jour} l'heure de debut de l'apres-midi doit etre avant l'heure de fin ";
            }
            if (IsMorningOverlappingAfternoon(planningDay.MatinFin, planningDay.ApresMidiDebut))
            {
                return  $"Pour {planningDay.Jour}, le matin ne peut pas finir apres le debut de l'apres-midi";
            }
            return null;
        }
        private PlanningValidationResult ValidatePlanningDays(List<CreatePlanningJoursDto>? planningDays, int? requestedWeeklyTotal)
        {
            var result = new PlanningValidationResult();
            if (planningDays == null || !planningDays.Any())
            {
                result.ErrorMessage = "Le planning est obligatoire";
                return result;
            }
            foreach (var planningDay in planningDays)
            {
                
                var planningDayError = GetPlanningDayValidationError(planningDay);
                if (planningDayError != null)
                {
                    result.ErrorMessage = planningDayError;
                    return result;
                }
                if (IsPlanningDayEmpty(planningDay))
                {
                    continue;
                }
                int dayMinutes = CalculatePlanningDayMinutes(planningDay);
                if (dayMinutes != planningDay.TotalHeures)
                {
                    result.ErrorMessage = "Le total des heures du jour ne correspond pas au planning";
                    return result;
                }
                result.CalculatedWeeklyTotal += dayMinutes;
                result.ValidPlanningDays.Add(CreateValidatedPlanningDay(planningDay));
            }

            if (IsWeeklyTotalInvalid(result.CalculatedWeeklyTotal, requestedWeeklyTotal))
            {
                result.ErrorMessage = "Le total hebdomadaire du planning est invalide";
                return result;
            }
            if (!result.ValidPlanningDays.Any())
            {
                result.ErrorMessage = "Le planning doit contenir au moins un jour valide";
                return result;
            }
            return result;
        }
        private class PlanningValidationResult
        { 
            public string? ErrorMessage { get; set; }
            public int CalculatedWeeklyTotal { get; set; }
            public List<CreatePlanningJoursDto> ValidPlanningDays { get; set; } = new();
        }
        private async Task<Utilisateur> GetOrCreateSupervisorUserAsync(string supervisorLastName, string supervisorFirstName, string supervisorEmail)
        {
            var userExist = await _context.Utilisateur.FirstOrDefaultAsync(p => p.Login == supervisorEmail);
            var user = new Utilisateur();
            if (userExist == null)
            {
                var pwd = "test1234";
                string savedPasswordHash = PasswordHelper.HashPassword(pwd);
                user.Nom = supervisorLastName;
                user.Prenom = supervisorFirstName;
                user.Login = supervisorEmail;
                user.Pwd = savedPasswordHash;
                _context.Utilisateur.Add(user);
                await _context.SaveChangesAsync();
            }
            else
            {
                user = userExist;
            }
            return user;
        }

        private async Task<Professionnel> GetOrCreateProfessionalProfileAsync(int supervisorUserId, string fonctionMaitreStage, string supervisorEmail,  string telephoneMaitreStage)
        {
            var prf = new Professionnel();
            var userprf = await _context.Professionnel.FirstOrDefaultAsync(p => p.Id_Utilisateur == supervisorUserId);
            if (userprf == null)
            {
                prf.Id_Utilisateur = supervisorUserId;
                prf.Fonction = fonctionMaitreStage;
                prf.AdresseMail = supervisorEmail;
                prf.NumTelephone = telephoneMaitreStage;
                _context.Professionnel.Add(prf);
                await _context.SaveChangesAsync();
                return prf;
            }
            else
            {
                prf = userprf;
            }
            return prf;
        }

        private async Task EnsureWorkRelationExistsAsync(int supervisorUserId, string siret)
        {
            var checkTravail = await _context.Travailler.FirstOrDefaultAsync(o => o.Id_Utilisateur == supervisorUserId && o.SIRET == siret);
            var travail = new Travailler();
            if (checkTravail == null)
            {
                travail.Id_Utilisateur = supervisorUserId;
                travail.SIRET = siret;
                _context.Travailler.Add(travail);
                await _context.SaveChangesAsync();
            }
        }
        private async Task<int> CreatePlanningWithDaysAsync(int calculatedWeeklyTotal, List<CreatePlanningJoursDto> validPlanningDays)
        {
            var plan = new Planning
            {
                TotalHebdo = calculatedWeeklyTotal,
            };
            _context.Planning.Add(plan);
            await _context.SaveChangesAsync();

            var idPlanning = plan.Id_Planning;

            foreach (var pj in validPlanningDays)
            {
                var planjour = new PlanningJours
                {
                    Jour = pj.Jour,
                    MatinDebut = pj.MatinDebut,
                    MatinFin = pj.MatinFin,
                    ApresMidiDebut = pj.ApresMidiDebut,
                    ApresMidiFin = pj.ApresMidiFin,
                    TotalHeures = pj.TotalHeures,
                    Id_Planning = idPlanning,
                };
                _context.PlanningJours.Add(planjour);
            }
            await _context.SaveChangesAsync();
            return idPlanning;
        }

        private async Task<Pfmp>  CreatePfmpAsync(CreateCompletePfmpDto request, int idPlanning, int currentStudentId, int administratorId)
        {
            var createdPfmp = new Pfmp
            {
                DateDebut = request.DateDebut,
                DateFin = request.DateFin,
                Id_Planning = idPlanning,
                SIRET = request.SIRET,
                Id_Utilisateur_1 = currentStudentId,
                Id_Utilisateur = administratorId,
            };
            _context.Pfmp.Add(createdPfmp);
            await _context.SaveChangesAsync();
            return createdPfmp;
        }
        private PfmpDto BuildCompletePfmpResponse(Pfmp createdPfmp, int currentStudentId, int administratorId)
        {
           return  new PfmpDto
           {
                DateDebut = createdPfmp.DateDebut,
                DateFin = createdPfmp.DateFin,
                Id_Planning = createdPfmp.Id_Planning,
                SIRET = createdPfmp.SIRET,
                IdEtudiant = currentStudentId,
                IdAdministrateur = administratorId,
                IdPfmp = createdPfmp.Id_PFMP,
           };
            
        }

        private async Task<int> FindAdministratorIdForStudentAsync(int currentStudentId, int currentYear)
        {
            return await (from e in _context.Etudier
                                          join gc in _context.GroupeClasse
                                          on new { e.Id_Etablissement, e.Id_Classe }
                                          equals new { gc.Id_Etablissement, gc.Id_Classe }
                                          join admin in _context.Administrer
                                          on gc.Id_Etablissement equals admin.Id_Etablissement
                                          where e.Id_Utilisateur == currentStudentId && e.AnneeRentree <= currentYear
                                          && e.AnneeSortie >= currentYear
                                          select admin.Id_Utilisateur).FirstOrDefaultAsync();
        }

        private async Task<bool> HasAcceptedContactRequestAsync(int currentStudentId, string siret)
        {
            return await _context.Contacter.AnyAsync(c => c.SIRET == siret && c.Id_Utilisateur == currentStudentId && c.StatutDemande.Trim().ToLower() == "accepte");
        }
        private async Task<bool> HasOverlappingPfmpAsync(int currentStudentId, DateTime startDate , DateTime endDate )
        {
             return await _context.Pfmp.AnyAsync(pf => pf.Id_Utilisateur_1 == currentStudentId &&
                                                    pf.DateDebut.HasValue && pf.DateFin.HasValue &&
                                                    pf.DateFin.Value.Date >= startDate && pf.DateDebut.Value.Date <= endDate);
        }
        private async Task<Organisation?> FindOrganisationBySiretAsync(string siret)
        {
            return await _context.Organisation.FirstOrDefaultAsync(o=> o.SIRET == siret);
        }

        private async Task UpdateOrganisationWebsiteAsync(Organisation organisation,string siteWeb)
        {
                organisation.SiteWeb = siteWeb;
                await _context.SaveChangesAsync();
        }
    }
}

