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

        
        [Authorize]
        [HttpGet] // GEt /api/Pfmp returns all PFMPs
        public async Task<IActionResult> GetAll()
        {
            var pfmps = await _context.Pfmp.Select(p => new PfmpDto
            {
                DateDebut = p.DateDebut,
                DateFin = p.DateFin,
                IdAdministrateur = p.Id_Utilisateur,
                Id_Planning = p.Id_Planning,
                SIRET = p.SIRET,
                IdEtudiant = p.Id_Utilisateur_1,
                IdPfmp = p.Id_PFMP,
            }).ToListAsync(); //Query all rows
            return Ok(pfmps); // 200 ok with json array
        }

        [Authorize]
        [HttpGet("recherche/{idEtudiant}/{idPfmp?}")] //address of the method
        public async Task<IActionResult> GetPfmpById(int idEtudiant, int? idPfmp)
        {
            var query = _context.Pfmp.AsQueryable();
            if (idPfmp != null)
            {
                query = query.Where(o => o.Id_Utilisateur_1 == idEtudiant && o.Id_PFMP == idPfmp);
            }
            else
            {
                query = query.Where(o => o.Id_Utilisateur_1 == idEtudiant);
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
            var siteWeb = request.SiteWeb;

            //planning
            var totalHebdo = request.TotalHebdo;

            //date for today and time
            var today = DateTime.Today.Year;
            int totalHebdoBackend = 0;
            //PFMP

            var dateDebut = request.DateDebut;
            var dateFin = request.DateFin;

            //empty list for valid days
            var validePlanning = new List<CreatePlanningJoursDto>();

            //List to return every information that is created
            var completePfmpdto = new PfmpDto();

            //maître de stage fields
            
            var fonctionMaitreStage = request.FonctionMaitreStage;
            var telephoneMaitreStage = request.TelephoneMaitreStage;
            var emailMaitreStage = request.EmailMaitreStage;

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

            if (request.PlanningJours == null || !request.PlanningJours.Any())
            {
                return BadRequest();
            }

            //Validate planning days
            foreach (var pj in request.PlanningJours)
            {
                int dayMinutes = 0;
                if (string.IsNullOrWhiteSpace(pj.Jour))
                {
                    return BadRequest();
                }

                bool matinVide = IsTimeSlotEmpty(pj.MatinDebut, pj.MatinFin);
                bool matinComplete = IsTimeSlotComplete(pj.MatinDebut, pj.MatinFin);
                bool midiVide = IsTimeSlotEmpty(pj.ApresMidiDebut, pj.ApresMidiFin);
                bool midiComplete = IsTimeSlotComplete(pj.ApresMidiDebut, pj.ApresMidiFin);
                bool matinIncomplete = IsTimeSlotIncomplete(pj.MatinDebut, pj.MatinFin);
                bool midiIncomplete = IsTimeSlotIncomplete(pj.ApresMidiDebut, pj.ApresMidiFin);

                if (matinVide && midiVide)
                {
                    continue;
                }
                if (matinIncomplete)
                {
                    return BadRequest($"le matin du jour {pj.Jour} est incomplet");
                }
                if (midiIncomplete)
                {
                    return BadRequest($"le apres-midi du jour {pj.Jour} est incomplet");
                }

                if (IsTimeSlotOrderInvalid(pj.MatinDebut,pj.MatinFin))
                {
                    return BadRequest($"pour {pj.Jour} l'heure de debut du matin doit etre avant l'heure de fin ");
                }
                if (IsTimeSlotOrderInvalid(pj.ApresMidiDebut, pj.ApresMidiFin))
                {
                    return BadRequest($"pour {pj.Jour} l'heure de debut de l'apres-midi doit etre avant l'heure de fin ");
                }
                if (IsMorningOverlappingAfternoon(pj.MatinFin, pj.ApresMidiDebut))
                {
                    return BadRequest($"Pour {pj.Jour}, le matin ne peut pas finir apres le debut de l'apres-midi");
                }

                if (matinComplete)
                {
                    dayMinutes += CalculateTimeSlotMinutes(pj.MatinDebut, pj.MatinFin);
                }
                if (midiComplete)
                {
                    dayMinutes += CalculateTimeSlotMinutes(pj.ApresMidiDebut, pj.ApresMidiFin);
                }


                if (dayMinutes != pj.TotalHeures)
                {
                    return BadRequest();
                }
                else
                {
                    totalHebdoBackend += dayMinutes;
                    var planning = new CreatePlanningJoursDto
                    {
                        Jour = pj.Jour,
                        MatinDebut = pj.MatinDebut,
                        MatinFin = pj.MatinFin,
                        ApresMidiDebut = pj.ApresMidiDebut,
                        ApresMidiFin = pj.ApresMidiFin,
                        TotalHeures = pj.TotalHeures
                    };
                    validePlanning.Add(planning);
                }

            }
            if (totalHebdoBackend != totalHebdo || totalHebdoBackend <= 0 || totalHebdoBackend > 2100)
            {
                return BadRequest();
            }
            if (!validePlanning.Any())
            {
                return BadRequest();
            }

            //Find administrator
            var idAdministrateur = await (from e in _context.Etudier
                                          join gc in _context.GroupeClasse
                                          on new { e.Id_Etablissement, e.Id_Classe }
                                          equals new { gc.Id_Etablissement, gc.Id_Classe }
                                          join admin in _context.Administrer
                                          on gc.Id_Etablissement equals admin.Id_Etablissement
                                          where e.Id_Utilisateur == currentStudentId && e.AnneeRentree <= today
                                          && e.AnneeSortie >= today
                                          select admin.Id_Utilisateur).FirstOrDefaultAsync();

            if (idAdministrateur <= 0)
            {
                return NotFound("Adminstrateur n'existe pas");
            }
            
            //check business rules
            var searchContacter = await _context.Contacter.AnyAsync(c => c.SIRET == siret && c.Id_Utilisateur == currentStudentId && c.StatutDemande.Trim().ToLower() == "accepte");
            if (!searchContacter)
            {
                return BadRequest("Vous devez d'abord contacter l'organisation");
            }
            //search
            var dejaEnStage = await _context.Pfmp.AnyAsync(pf => pf.Id_Utilisateur_1 == currentStudentId &&
                                                    pf.DateDebut.HasValue && pf.DateFin.HasValue &&
                                                    pf.DateFin.Value.Date >= dateDebut.Value.Date && pf.DateDebut.Value.Date <= dateFin.Value.Date);
            if (dejaEnStage)
            {
                return BadRequest("Vous êtes deja en stage sur cette periode ");
            }

            
            var checkOrg = await _context.Organisation.FirstOrDefaultAsync(p => p.SIRET == siret);
            if (checkOrg == null)
            {
                return NotFound("L'Organisation untrovable");
            }
            //Create/Update database entities inside transaction 
            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                

                checkOrg.SiteWeb = siteWeb;
            
                await _context.SaveChangesAsync();

                //search the user with his login
                var userExist = await _context.Utilisateur.FirstOrDefaultAsync(p => p.Login == emailMaitreStage);
                var user = new Utilisateur();
                if (userExist == null)
                {
                    var pwd = "test1234";
                    string savedPasswordHash = PasswordHelper.HashPassword(pwd);
                    user.Nom = request.NomMaitreStage;
                    user.Prenom = request.PrenomMaitreStage;
                    user.Login = emailMaitreStage;
                    user.Pwd = savedPasswordHash;
                    _context.Utilisateur.Add(user);
                    await _context.SaveChangesAsync();
                }
                else
                {
                    user = userExist;
                }
                var prf = new Professionnel();
                var userprf = await _context.Professionnel.FirstOrDefaultAsync(p => p.Id_Utilisateur == user.Id_Utilisateur);
                if (userprf == null)
                {
                    prf.Id_Utilisateur = user.Id_Utilisateur;
                    prf.Fonction = fonctionMaitreStage;
                    prf.AdresseMail = user.Login;
                    prf.NumTelephone = telephoneMaitreStage;
                    _context.Professionnel.Add(prf);
                    await _context.SaveChangesAsync();
                }
                else
                {
                    prf = userprf;
                }
                var checkTravail = await _context.Travailler.FirstOrDefaultAsync(o => o.Id_Utilisateur == prf.Id_Utilisateur && o.SIRET == siret);
                var travail = new Travailler();
                if (checkTravail == null)
                {
                    travail.Id_Utilisateur = prf.Id_Utilisateur;
                    travail.SIRET = request.SIRET;
                    _context.Travailler.Add(travail);
                    await _context.SaveChangesAsync();
                }
                var plan = new Planning
                {
                    TotalHebdo = totalHebdoBackend,
                };
                _context.Planning.Add(plan);
                await _context.SaveChangesAsync();

                var idPlanning = plan.Id_Planning;

                foreach (var pj in validePlanning)
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
                var createPfmp = new Pfmp
                {
                    DateDebut = request.DateDebut,
                    DateFin = request.DateFin,
                    Id_Planning = idPlanning,
                    SIRET = request.SIRET,
                    Id_Utilisateur_1 = currentStudentId,
                    Id_Utilisateur = idAdministrateur,
                };
                _context.Pfmp.Add(createPfmp);
                await _context.SaveChangesAsync();

                completePfmpdto.DateDebut = createPfmp.DateDebut;
                completePfmpdto.DateFin = createPfmp.DateFin;
                completePfmpdto.Id_Planning = createPfmp.Id_Planning;
                completePfmpdto.SIRET = createPfmp.SIRET;
                completePfmpdto.IdEtudiant = currentStudentId;
                completePfmpdto.IdAdministrateur = idAdministrateur;
                completePfmpdto.IdPfmp = createPfmp.Id_PFMP;


                await transaction.CommitAsync();
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }

            return Ok(completePfmpdto);

        }
        private bool TryGetCurrentUserId(out int currentStudentId)
        {

            var id = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(id, out currentStudentId);
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
        private bool IsMorningOverlappingAfternoon(TimeSpan? morningEnd, TimeSpan? afternoonStart)
        {
            if (!morningEnd.HasValue || !afternoonStart.HasValue)
            {
                return false;
            }
            return morningEnd.Value >= afternoonStart.Value;
        }

    }
}

