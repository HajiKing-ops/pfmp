using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Helpers;
using PFMPManager.Api.Models;
using PFMPManager.Api.Services;
namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 
    [Route("api/pfmp")] // Base route for all endpoints in this controller
    public class PfmpController : ControllerBase
    {
        private readonly AppDbContext _context; 
        private readonly ICurrentUserService _currentUserService;
        private readonly IPfmpAccessService _pfmpAccessService;
        private readonly IPlanningValidationService _planningValidationService;

        //Dependencies are injected by the ASP.NET Core DI container
        public PfmpController(AppDbContext context, ICurrentUserService currentUserService, IPfmpAccessService pfmpAccessService ,IPlanningValidationService planningValidationService)
        {
            _context = context;
            _currentUserService = currentUserService;
            _pfmpAccessService = pfmpAccessService;
            _planningValidationService = planningValidationService;
        }

        // Retrieves PFMP details for an authorized student or teacher

        [Authorize(Roles = "Etudiant,Enseignant")]
        [HttpGet("recherche/{studentId}/{pfmpId?}")] 
        public async Task<IActionResult> GetStudentPfmps(int studentId, int? pfmpId)
        {

            var currentUserResult = _currentUserService.GetCurrentUser(User);
            if (!currentUserResult.Success)
            {
                return Unauthorized(currentUserResult.ErrorMessage);
            }
            var pfmpAccessError = await _pfmpAccessService.ValidateStudentPfmpAccessAsync(currentUserResult.UserId, studentId, currentUserResult.Role);
            if (pfmpAccessError != null)
            {
                return StatusCode(403, pfmpAccessError);
            }



            var pfmps = await GetStudentPfmpsAsync(studentId, pfmpId);
            if (!pfmps.Any())
            {
                return NotFound();
            }

            var lookupData = await BuildPfmpDetailLookupDataAsync(pfmps);

            var result = pfmps
                .Select(pfmp => BuildPfmpDetailDto(pfmp, lookupData))
                .ToList();
                
            return Ok(result);
        }




        //Create a complete PFMP request with organisation, supervisor, planning and PFMP data
        [Authorize(Roles = "Etudiant")]
        [HttpPost("complete")]
        public async Task<IActionResult> CompletePfmp(CreateCompletePfmpDto request)
        {
         
            var siret = request.SIRET;
           
            var requestedWeeklyTotal = request.TotalHebdo;

            var currentYear = DateTime.Today.Year;


            //Get the connected student from the JWT claims
            var currentUserResult = _currentUserService.GetCurrentUser(User);
            if (!currentUserResult.Success)
            {
                return Unauthorized(currentUserResult.ErrorMessage);
            }
          
           var currentStudentId = currentUserResult.UserId;
           

            //Checks whether the request contains all required PFMP fields
            if (IsBasicCompletePfmpRequestInvalid(request))
            {
                return BadRequest();
            }

            var planningValidation = _planningValidationService.ValidatePlanningDays(request.PlanningJours, requestedWeeklyTotal);
            if (planningValidation.ErrorMessage != null)
            {
                return BadRequest(planningValidation.ErrorMessage);
            }
            var calculatedWeeklyTotal = planningValidation.CalculatedWeeklyTotal;
            var validPlanningDays = planningValidation.ValidPlanningDays;

            //Find the administrator responsible for the student's establishment 
            var administratorId = await FindAdministratorIdForStudentAsync(currentStudentId, currentYear);

            if (administratorId <= 0)
            {
                return NotFound("L’administrateur n’existe pas.");
            }

            // Check whether the student has an accepted contact request with the organisation 
            var hasAcceptedContactRequest = await HasAcceptedContactRequestAsync(currentStudentId, siret);

            if (!hasAcceptedContactRequest)
            {
                return BadRequest("Vous devez d'abord contacter l'organisation");
            }
            //Prevent overlapping PFMP periods for the same student

            var startDate = request.DateDebut!.Value.Date;
            var endDate = request.DateFin!.Value.Date;

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

            //Create or update related PFMP entities inside a transaction
            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {


                await UpdateOrganisationWebsiteAsync(organisation, request.SiteWeb!);

                // Creates the supervisor user account if it does not already exist
                var user = await GetOrCreateSupervisorUserAsync(request.NomMaitreStage!, request.PrenomMaitreStage!, request.EmailMaitreStage!);

                var prf = await GetOrCreateProfessionalProfileAsync(user.Id_Utilisateur, request.FonctionMaitreStage!, request.EmailMaitreStage!, request.TelephoneMaitreStage!);


                await EnsureWorkRelationExistsAsync(prf.Id_Utilisateur, siret);


                //Create a planning and its validated planning days 
                var idPlanning = await CreatePlanningWithDaysAsync(calculatedWeeklyTotal, validPlanningDays);


                // Create the PFMP linked to the student, planning, organisation and administrator
                var createdPfmp = await CreatePfmpAsync(request, idPlanning, currentStudentId, administratorId);

                var responseDto = BuildCompletePfmpResponse(createdPfmp, currentStudentId, administratorId);

                await transaction.CommitAsync();

                return Ok(responseDto);
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }



        }
      

       

        private bool IsBasicCompletePfmpRequestInvalid(CreateCompletePfmpDto request)
        {

            return string.IsNullOrWhiteSpace(request.RaisonSociale) || string.IsNullOrWhiteSpace(request.SecteurActivite) || string.IsNullOrWhiteSpace(request.SIRET)
                 || string.IsNullOrWhiteSpace(request.Adresse) || string.IsNullOrWhiteSpace(request.NumTelephone) || string.IsNullOrWhiteSpace(request.SiteWeb)
                 || string.IsNullOrWhiteSpace(request.PrenomMaitreStage) || string.IsNullOrWhiteSpace(request.TelephoneMaitreStage)
                 || string.IsNullOrWhiteSpace(request.NomMaitreStage) || string.IsNullOrWhiteSpace(request.FonctionMaitreStage)
                 || string.IsNullOrWhiteSpace(request.EmailMaitreStage) || !request.DateDebut.HasValue || !request.DateFin.HasValue
                 || request.DateFin.Value.Date < request.DateDebut.Value.Date;
        }

       
     

            
        
       
        private async Task<Utilisateur> GetOrCreateSupervisorUserAsync(string supervisorLastName, string supervisorFirstName, string supervisorEmail)
        {
            var userExist = await _context.Utilisateur.FirstOrDefaultAsync(p => p.Login == supervisorEmail);
            var user = new Utilisateur();
            if (userExist == null)
            {
                var pwd = "test1234"; // Temporary default password for development only
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

        //Creates the professional profile linked to the supervisor user
        private async Task<Professionnel> GetOrCreateProfessionalProfileAsync(int supervisorUserId, string fonctionMaitreStage, string supervisorEmail, string telephoneMaitreStage)
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

        // Ensure the supervisor is linked to the organisation 
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

        private async Task<Pfmp> CreatePfmpAsync(CreateCompletePfmpDto request, int idPlanning, int currentStudentId, int administratorId)
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
            return new PfmpDto
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
            return await _context.Contacter.AnyAsync(c => c.SIRET == siret && c.Id_Utilisateur == currentStudentId && c.StatutDemande!.Trim().ToLower() == "accepte");
        }
        // Checks whether the student already has a PFMP during the requested period
        private async Task<bool> HasOverlappingPfmpAsync(int currentStudentId, DateTime startDate, DateTime endDate)
        {
            return await _context.Pfmp.AnyAsync(pf => pf.Id_Utilisateur_1 == currentStudentId &&
                                                   pf.DateDebut.HasValue && pf.DateFin.HasValue &&
                                                   pf.DateFin.Value.Date >= startDate && pf.DateDebut.Value.Date <= endDate);
        }
        private async Task<Organisation?> FindOrganisationBySiretAsync(string siret)
        {
            return await _context.Organisation.FirstOrDefaultAsync(o => o.SIRET == siret);
        }

        private async Task<Dictionary<string,string>> GetOrganisationRaisonSocialesBySiretsAsync(List<string> sirets)
        {
            return await _context.Organisation
                .AsNoTracking()
                .Where(o => sirets.Contains(o.SIRET))
                .ToDictionaryAsync(o => o.SIRET,
                o => o.RaisonSociale ?? string.Empty);
        }

        private async Task UpdateOrganisationWebsiteAsync(Organisation organisation, string siteWeb)
        {
            organisation.SiteWeb = siteWeb;
            await _context.SaveChangesAsync();
        }


        private PfmpDetailDto BuildPfmpDetailDto(Pfmp pfmp, PfmpDetailLookupData lookupData)
        {
            var dto = new PfmpDetailDto
            {
                DateDebut = pfmp.DateDebut,
                DateFin = pfmp.DateFin,
                Id_Planning = pfmp.Id_Planning,
                SIRET = pfmp.SIRET,
                IdEtudiant = pfmp.Id_Utilisateur_1,
                IdPfmp = pfmp.Id_PFMP,
            };
            if (lookupData.OrganisationNamesBySiret.TryGetValue(pfmp.SIRET, out var raisonSociale))
            {
                dto.RaisonSociale = raisonSociale;
            }
            else
            {
                dto.RaisonSociale = string.Empty;
            }
            if (lookupData.SupervisorDetailsBySiret.TryGetValue(pfmp.SIRET, out var supervisorDetails))
            {
                dto.PrenomMaitreStage = supervisorDetails.PrenomMaitreStage;
                dto.NomMaitreStage = supervisorDetails.NomMaitreStage;
                dto.FonctionMaitreStage = supervisorDetails.FonctionMaitreStage;
                dto.TelephoneMaitreStage = supervisorDetails.TelephoneMaitreStage;
                dto.EmailMaitreStage = supervisorDetails.EmailMaitreStage;
            }

            dto.JourRestants = CalculateRemainingDays(pfmp.DateFin);
            dto.Semaine = CalculateWeekCount(pfmp.DateDebut, pfmp.DateFin);

           

            if (lookupData.PlanningDaysByPlanningId.TryGetValue(pfmp.Id_Planning, out var planningDays))
            {
                dto.PlanningJours = planningDays;
            }
            else 
            {
                dto.PlanningJours = new List<CreatePlanningJoursDto>();
            }


                return dto;
        }

        private int CalculateRemainingDays(DateTime? end)
        {
            if (!end.HasValue)
            {
                return 0;
            }
            return Math.Max(0, (end.Value.Date - DateTime.Today).Days);
        }

        private int CalculateWeekCount(DateTime? start, DateTime? end)
        {

            if (!start.HasValue || !end.HasValue)
            {
                return 0;
            }
            var duration = end.Value.Date - start.Value.Date;
            var total = duration.TotalDays / 7;
            return (int)total;
        }

        private async Task<Dictionary<string,SupervisorDetailsDto>> GetSupervisorDetailsBySiretsAsync(List<string> sirets)
        {
            var workRelations = await _context.Travailler
                .AsNoTracking()
                .Where(w=> sirets
                .Contains(w.SIRET!))
                .ToListAsync();

            
            var supervisorUserIds = workRelations.Select(wR => wR.Id_Utilisateur).Distinct().ToList();

            var supervisorUsers = await _context.Utilisateur
                .AsNoTracking().Where(u => supervisorUserIds.Contains(u.Id_Utilisateur))
                .ToListAsync();

            var professionalProfiles = await _context.Professionnel.AsNoTracking().Where(p => supervisorUserIds.Contains(p.Id_Utilisateur))
                .ToListAsync();


            var supervisorUsersById = supervisorUsers.ToDictionary(user => user.Id_Utilisateur);
            var professionalProfilesByUserId = professionalProfiles.ToDictionary(profile => profile.Id_Utilisateur);

            var supervisorDetailsBySiret = new Dictionary<string, SupervisorDetailsDto>();

            foreach (var workRelation in workRelations)
            {
                var userId = workRelation.Id_Utilisateur;

                if (!supervisorUsersById.TryGetValue(userId, out var supervisorUser))
                {
                    continue;
                }
                if (!professionalProfilesByUserId.TryGetValue(userId, out var professionalProfile))
                {
                    continue;
                }
                var dto = new SupervisorDetailsDto
                {
                    PrenomMaitreStage = supervisorUser.Prenom!,
                    NomMaitreStage = supervisorUser.Nom!,
                    FonctionMaitreStage = professionalProfile.Fonction!,
                    TelephoneMaitreStage = professionalProfile.NumTelephone!,
                    EmailMaitreStage  = professionalProfile.AdresseMail!,
                };
                if (!supervisorDetailsBySiret.ContainsKey(workRelation.SIRET!))
                {
                    supervisorDetailsBySiret.Add(workRelation.SIRET!, dto);
                }
            }
            return supervisorDetailsBySiret;
        }

        private async Task<Dictionary<int, List<CreatePlanningJoursDto>>> GetPlanningDaysByPlanningIdsAsync(List<int> planningIds)
        { 
            var rawPlanningDays = await _context.PlanningJours
                .AsNoTracking()
                .Where(j => planningIds.Contains(j.Id_Planning))
                .Select(j => new
                {
                    j.Id_Planning,
                    Day = new CreatePlanningJoursDto
                    {
                        Jour = j.Jour,
                        MatinDebut = j.MatinDebut,
                        MatinFin = j.MatinFin,
                        ApresMidiDebut = j.ApresMidiDebut,
                        ApresMidiFin = j.ApresMidiFin,
                        TotalHeures = j.TotalHeures
                    }
                })
                .ToListAsync();

            var planningDaysByPlanningId = rawPlanningDays
                .GroupBy(x => x.Id_Planning)
                .ToDictionary(group => group.Key,
                              group=> group.Select(x => x.Day).ToList());
            return planningDaysByPlanningId;
        }

        private class PfmpDetailLookupData
        {
            public Dictionary<int,List<CreatePlanningJoursDto>> PlanningDaysByPlanningId {get; set;} = new ();
            public Dictionary<string, string> OrganisationNamesBySiret { get; set; } = new();
            public Dictionary<string, SupervisorDetailsDto> SupervisorDetailsBySiret { get; set; } = new();
        }

        //Builds lookup dictionaries used to avoid repeated database queries 
        private async Task<PfmpDetailLookupData> BuildPfmpDetailLookupDataAsync(List<Pfmp> pfmps)
        {
            var planningIds = pfmps.Select(pfmp => pfmp.Id_Planning).Distinct().ToList();
            var sirets = pfmps.Select(pfmp => pfmp.SIRET).Distinct().ToList();

            var organisationNamesBySiret = await GetOrganisationRaisonSocialesBySiretsAsync(sirets);
            var planningDaysByPlanningId = await GetPlanningDaysByPlanningIdsAsync(planningIds);
            var supervisorDetailsBySiret = await GetSupervisorDetailsBySiretsAsync(sirets);

          return new PfmpDetailLookupData
          {
            PlanningDaysByPlanningId = planningDaysByPlanningId,
            OrganisationNamesBySiret = organisationNamesBySiret,
            SupervisorDetailsBySiret = supervisorDetailsBySiret
          };
        }

        private async Task<List<Pfmp>> GetStudentPfmpsAsync(int studentId, int? pfmpId)
        {
            var query = _context.Pfmp.AsNoTracking();
            query = query.Where(pfmp => pfmp.Id_Utilisateur_1 == studentId);
            if (pfmpId != null)
            {
                query = query.Where(pfmp => pfmp.Id_PFMP == pfmpId);
            }

            return await query.ToListAsync();
           
        }


    }
}

