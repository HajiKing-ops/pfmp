using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Helpers;
using PFMPManager.Api.Models;
using Microsoft.AspNetCore.Authorization;



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

        //[Authorize(Roles = Admini)]
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






        [HttpPost("complete")]

        public async Task<IActionResult> CompletePfmp(CreateCompletePfmpDto request)
        {
            //entreprise 
            var RaisonSociale = request.RaisonSociale;
            var SecteurActivite = request.SecteurActivite;
            var SIRET = request.SIRET;
            var Adresse = request.Adresse;
            var NumTelephone = request.NumTelephone;

            //planning 
            var TotalHebdo = request.TotalHebdo;


            //PFMP
            var DateDebut = request.DateDebut;
            var DateFin = request.DateFin;
            var IdEtudiant = request.IdEtudiant;

            // in here is the problem i have to solve it the admin id 
            var IdAdministrateur = 10;

            //maître de stage fields
            var PrenomMaitreStage = request.PrenomMaitreStage;
            var NomMaitreStage = request.NomMaitreStage;
            var FonctionMaitreStage = request.FonctionMaitreStage;
            var TelephoneMaitreStage = request.TelephoneMaitreStage;
            var EmailMaitreStage = request.EmailMaitreStage;


            if (TotalHebdo > 35 || TotalHebdo <= 0)
            {
                return BadRequest();
            }

            if (string.IsNullOrWhiteSpace(RaisonSociale) || string.IsNullOrWhiteSpace(SecteurActivite) || string.IsNullOrWhiteSpace(SIRET)
                || string.IsNullOrWhiteSpace(Adresse) || string.IsNullOrWhiteSpace(NumTelephone)
                || IdEtudiant <= 0 || IdAdministrateur <= 0 || string.IsNullOrWhiteSpace(PrenomMaitreStage)
                || string.IsNullOrWhiteSpace(NomMaitreStage) || string.IsNullOrWhiteSpace(FonctionMaitreStage) || string.IsNullOrWhiteSpace(TelephoneMaitreStage)
                || string.IsNullOrWhiteSpace(EmailMaitreStage) ||!DateDebut.HasValue || !DateFin.HasValue || DateFin.Value.Date < DateDebut.Value.Date)
            {
                return BadRequest();
            }

            if (request.PlanningJours == null || !request.PlanningJours.Any())
            {
                return BadRequest();
            }

            foreach (var pj in request.PlanningJours)
            {
                if (pj.TotalHeures <= 0 || string.IsNullOrWhiteSpace(pj.Jour))
                    {
                    return BadRequest();
                    }
                bool matinVide = pj.MatinDebut == null && pj.MatinFin == null;
                bool matinComplete = pj.MatinDebut != null && pj.MatinFin != null;

                bool midiVide = pj.ApresMidiDebut == null && pj.ApresMidiFin == null;
                bool midiComplete = pj.ApresMidiDebut != null && pj.ApresMidiFin != null;

                if (!matinVide && !matinComplete)
                {
                    return BadRequest($"le matin du jour {pj.Jour} est incomplet");
                }
               
                if (matinComplete && pj.MatinDebut >= pj.MatinFin)
                {
                    return BadRequest($"pour {pj.Jour} l'heure de debut du matin doit etre avant l'heure de fin ");
                }
                if (midiComplete && pj.ApresMidiDebut >= pj.ApresMidiFin)
                {
                    return BadRequest($"pour {pj.Jour} l'heure de debut de l'apres-midi doit etre avant l'heure de fin ");
                }
                if (matinComplete && midiComplete && pj.MatinFin >= pj.ApresMidiDebut)
                {
                    return BadRequest($"Pour {pj.Jour}, le matin ne peut pas finir apres le debut de l'apres-midi");
                }

                var totalFromDay = request.PlanningJours.Sum(p => p.TotalHeures);
                if (totalFromDay != request.TotalHebdo)
                {
                    return BadRequest();
                }

            }
            var searchContacter = await _context.Contacter.AnyAsync(c => c.SIRET == SIRET && c.Id_Utilisateur == IdEtudiant && c.StatutDemande.Trim().ToLower() == "accepte");
            if (!searchContacter)
            {
                return BadRequest("Vous devez d'abord contacter l'organisation");
            }
            //search 
            var dejaEnStage = await _context.Pfmp.AnyAsync(pf=> pf.Id_Utilisateur_1 == IdEtudiant &&
                                                    pf.DateDebut.HasValue && pf.DateFin.HasValue &&
                                                    pf.DateFin.Value.Date >= DateDebut.Value.Date && pf.DateDebut.Value.Date <= DateFin.Value.Date );
            if (dejaEnStage)
            {
                return BadRequest("Vous êtes deja en stage sur cette periode ");
            }


            //search the organisation with the SIRET
            var checkOrg = await _context.Organisation.FirstOrDefaultAsync(p => p.SIRET == SIRET);

            if (checkOrg == null)
            {
                checkOrg = new Organisation
                {
                    RaisonSociale = request.RaisonSociale,
                    SecteurActivite = request.SecteurActivite,
                    Adresse = request.Adresse,
                    NumTelephone = request.NumTelephone,
                    SIRET = request.SIRET,
                };
                _context.Organisation.Add(checkOrg);
                await _context.SaveChangesAsync();
            }

            //search the user with his login 
            var userExist = await _context.Utilisateur.FirstOrDefaultAsync(p => p.Login == EmailMaitreStage);

            var user = new Utilisateur();

            if (userExist == null)
            {

                var pwd = "test1234";

                string savedPasswordHash = PasswordHelper.HashPassword(pwd);

                user.Nom = request.NomMaitreStage;
                user.Prenom = request.PrenomMaitreStage;
                user.Login = EmailMaitreStage;
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
                    prf.Fonction = FonctionMaitreStage;
                    prf.AdresseMail = user.Login;
                    prf.NumTelephone = TelephoneMaitreStage;

                    _context.Professionnel.Add(prf);
                    await _context.SaveChangesAsync();
                }
                else
                {

                prf = userprf;

                }


            var checkTravail = await _context.Travailler.FirstOrDefaultAsync(o => o.Id_Utilisateur == prf.Id_Utilisateur && o.SIRET == SIRET);

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
                TotalHebdo = request.TotalHebdo,
            };
            _context.Planning.Add(plan);
            await _context.SaveChangesAsync();
             
            var idPlanning = plan.Id_Planning;

            
            foreach (var pj in request.PlanningJours)
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
                Id_Utilisateur_1 = request.IdEtudiant,
                Id_Utilisateur =  request.IdAdministrateur,

            };
            _context.Pfmp.Add(createPfmp);
            await _context.SaveChangesAsync();

            var createPfmpDto = new PfmpDto
            {
                DateDebut = createPfmp.DateDebut,
                DateFin = createPfmp.DateFin,
                Id_Planning = createPfmp.Id_Planning,
                SIRET = createPfmp.SIRET,
                IdEtudiant = createPfmp.Id_Utilisateur_1,
                IdAdministrateur = createPfmp.Id_Utilisateur,
                IdPfmp = createPfmp.Id_PFMP,

                JourRestants = createPfmp.DateFin.HasValue ? Math.Max(0, (createPfmp.DateFin.Value.Date - DateTime.Today).Days) : 0,
            };

            return Ok(createPfmpDto);
        }



        // Update

        [HttpPut("{id}")]

        public async Task<IActionResult> Update(CreatePfmpDto request, int id)
        {
            if (string.IsNullOrWhiteSpace(request.Siret))
            {
                return BadRequest();
            }
            if (request.IdEtudiant <= 0 || request.IdPlanning <= 0 || request.IdAdministrateur <= 0)
            {
                return BadRequest();
            }
            if (request.DateFin < request.DateDebut)
            {
                return BadRequest();
            }

            var search = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == id);

            if (search == null)
            {
                return NotFound();
            }


            search.DateDebut = request.DateDebut;
            search.DateFin = request.DateFin;
            search.Id_Utilisateur = request.IdAdministrateur;
            search.Id_Planning = request.IdPlanning;
            search.SIRET = request.Siret;
            search.Id_Utilisateur_1 = request.IdEtudiant;


            await _context.SaveChangesAsync();

            var update = new PfmpDto
            {
                IdPfmp = search.Id_PFMP,
                IdAdministrateur = search.Id_Utilisateur,
                Id_Planning = search.Id_Planning,
                DateFin = search.DateFin,
                DateDebut = search.DateDebut,
                SIRET = search.SIRET,
                IdEtudiant = search.Id_Utilisateur_1,

            };
            return Ok(update);

        }



        //Delete 

        [HttpDelete("{id}")]

        public async Task<IActionResult> Delete(int id)
        {
            var del = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == id);
            if (del == null)
            {
                return NotFound();
            }
            var id_plan = del.Id_Planning;

            _context.Pfmp.Remove(del);

            var delplanjour = await _context.PlanningJours.Where(p => p.Id_Planning == id_plan).ToListAsync();
           
            _context.PlanningJours.RemoveRange(delplanjour);

            var delplan = await _context.Planning.FirstOrDefaultAsync(p => p.Id_Planning == id_plan);
            if (delplan != null)
            {
                _context.Planning.Remove(delplan);
            }
            
            await _context.SaveChangesAsync();

            return NoContent();
        }


    }
}
