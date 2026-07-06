
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Services;
using PFMPManager.Api.Helpers;



namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 
    
    [Route("api/administrateur")] // Base route for all endpoints in this controller

    public class AdministrateurController : ControllerBase
    {
        private readonly AppDbContext _context; 
        private readonly ICurrentUserService _currentUserService;

       // Dependencies are injected by the ASP.NET Core DI container
        public AdministrateurController(AppDbContext context, ICurrentUserService currentUserService)
        {
            _context = context;
            _currentUserService = currentUserService;
        }

        // Returns PFMP dashboard data for the connected administrator
       [Authorize(Roles = "Administrateur")]
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
           
            var user = _currentUserService.GetCurrentUser(User);
            if (!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idAdmin = user.UserId;
            
            var admin = await _context.Administrer.Where(a => a.Id_Utilisateur == idAdmin).ToListAsync();
            if (!admin.Any())
            {
                return NotFound("l'Administrateur n'exite pas");
            }
            // Verify that the connected administrator manages at least one establishment
            var etablissementIds = admin.Select(a => a.Id_Etablissement).Distinct().ToList();

            if (!etablissementIds.Any())
            {
                return NotFound("L'Etablissement n'existe pas");
            }

            // Load students from the administrator's establishments
            var classes = await _context.GroupeClasse.Where(gc => etablissementIds.Contains(gc.Id_Etablissement)).ToListAsync();
            if (!classes.Any())
            {
                return NotFound("Aucune classe trouvee pour cet administrateur");
            }


            var etud = await (from e in _context.Etudier
                              join c in _context.GroupeClasse
                              on new { e.Id_Etablissement, e.Id_Classe }
                              equals new { c.Id_Etablissement, c.Id_Classe }
                              where etablissementIds.Contains(c.Id_Etablissement)
                              select e
                               ).ToListAsync();


            if (!etud.Any())
            {
                return NotFound();
            }
            var etudiantIds = etud.Select(e => e.Id_Utilisateur).Distinct().ToList(); // extract students ids



            // Load PFMPs for the selected students
            var pfmps = await _context.Pfmp.Where(pf => etudiantIds.Contains(pf.Id_Utilisateur_1)).Select(
            p => new PfmpDto
            {
                DateDebut = p.DateDebut,
                DateFin = p.DateFin,
                IdAdministrateur = p.Id_Utilisateur,
                Id_Planning = p.Id_Planning,
                SIRET = p.SIRET,
                IdEtudiant = p.Id_Utilisateur_1,
                IdPfmp = p.Id_PFMP,
            }).ToListAsync();

            if (!pfmps.Any())
            {
                return NotFound("Aucune PFMP trouvee pour cet administrateur");
            }

            var adminRowDto = await AdminListHelper.CreateList(_context, pfmps, etablissementIds);

            var stat = AdminListHelper.Calculation(adminRowDto);
                        
            return Ok(new { adminRowDto, stat });
        }



        // Returns filtered PFMP dashboard data for the connected administrator
        [Authorize(Roles = "Administrateur")]

        [HttpGet("recherche")]
        public async Task<IActionResult> GetAll(string? nomRecherche, string? entrepriseRecherche, string? status, int? idEtablissement, int? idClasse)
        {
            
            var user = _currentUserService.GetCurrentUser(User);
            if(!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idAdmin = user.UserId;
            // Verify that the connected administrator manages at least one establishment
            var admin = await _context.Administrer.Where(a => a.Id_Utilisateur == idAdmin).ToListAsync();
            if (!admin.Any())
            {
                return NotFound("l'Administrateur n'exite pas");
            }

            var etablissementIds = admin.Select(a => a.Id_Etablissement).Distinct().ToList();
            
            if (!etablissementIds.Any())
            {
                return NotFound("L'Etablissement n'existe pas");
            }
            
            // Verify that the connected administrator manages at least one establishment
            var classes = await _context.GroupeClasse.Where(gc => etablissementIds.Contains(gc.Id_Etablissement)).ToListAsync();
            if (!classes.Any())
            {
                return NotFound("Aucune classe trouvee pour cet administrateur");
            }

            var etud = await (from e in _context.Etudier
                              join c in _context.GroupeClasse
                              on new { e.Id_Etablissement, e.Id_Classe }
                              equals new { c.Id_Etablissement, c.Id_Classe }
                              where etablissementIds.Contains(c.Id_Etablissement)
                              select e
                               ).ToListAsync();


            if (!etud.Any())
            {
                return NotFound();
            }
            if (idEtablissement.HasValue != idClasse.HasValue)
                {
                    return BadRequest("Il faut fournir idEtablissement et idClasse ensemble ");
                }
            if(idEtablissement.HasValue && idClasse.HasValue)
            {
                if(!etablissementIds.Contains(idEtablissement.Value))
                {
                    return Forbid();
                }
                etud = etud.Where(e=> e.Id_Etablissement == idEtablissement.Value && e.Id_Classe == idClasse.Value).ToList();
                if(!etud.Any())
                {
                    return NotFound("Aucun étudiant trouvé pour cette classe ");
                }
            }

            var etudiantIds = etud.Select(e => e.Id_Utilisateur).Distinct().ToList(); // extract students ids



            // Load PFMPs for the selected students
            var pfmps = await _context.Pfmp.Where(pf => etudiantIds.Contains(pf.Id_Utilisateur_1)).Select(
            p => new PfmpDto
            {
                DateDebut = p.DateDebut,
                DateFin = p.DateFin,
                IdAdministrateur = p.Id_Utilisateur,
                Id_Planning = p.Id_Planning,
                SIRET = p.SIRET,
                IdEtudiant = p.Id_Utilisateur_1,
                IdPfmp = p.Id_PFMP,
            }).ToListAsync();

            if (!pfmps.Any())
            {
                return NotFound("Aucune PFMP trouvee pour cet administrateur");
            }

            var adminRowDto = await AdminListHelper.CreateList(_context, pfmps, etablissementIds);



            if (!string.IsNullOrWhiteSpace(nomRecherche))
            {
                var search = nomRecherche.Trim().ToLower();

                adminRowDto = adminRowDto.Where(r => r.Nom.ToLower().Contains(search) || r.Prenom.ToLower().Contains(search)).ToList();
            }

            if (!string.IsNullOrWhiteSpace(entrepriseRecherche))
            {
                var search = entrepriseRecherche.Trim().ToLower();

                adminRowDto = adminRowDto.Where(r => r.Entreprise.ToLower().Contains(search)).ToList();
            }
            
            if (!string.IsNullOrWhiteSpace(status))
            {
                var statutRecherche = status.Trim().ToLower();
                if(statutRecherche == "encours")
                {
                    adminRowDto = adminRowDto.Where(r => r.DateDebut.HasValue&& r.DateFin.HasValue &&r.DateDebut.Value.Date <= DateTime.Today.Date && r.DateFin.Value.Date >= DateTime.Today.Date).ToList();
                }
                else if(statutRecherche == "valide")
                {
                    adminRowDto = adminRowDto.Where(r => r.Status == true).ToList();
                }
                else if(statutRecherche == "incomplet")
                {
                    adminRowDto = adminRowDto.Where(r => r.Restants > 0).ToList();
                }else if(statutRecherche == "tous")
                {
                }
                else
                {
                    return BadRequest("Statut invalide. Valeurs acceptées : tous, encours, valide, incomplet.");
                }
            }

            var stat = AdminListHelper.Calculation(adminRowDto);

            return Ok(new { adminRowDto, stat });
        }

        // Returns PFMP statistics grouped by class for the connected administrator
        [Authorize (Roles =  "Administrateur")]
        [HttpGet("classes")]
        public async Task<IActionResult> Classes()
        {
            var user = _currentUserService.GetCurrentUser(User);
            if(!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idAdmin = user.UserId;
            var admin = await _context.Administrer.Where(a => a.Id_Utilisateur == idAdmin).ToListAsync();
            if (!admin.Any())
            {
                return NotFound("l'Administrateur n'exite pas");
            }

            var etablissementIds = admin.Select(a => a.Id_Etablissement).Distinct().ToList();

            if (!etablissementIds.Any())
            {
                return NotFound("L'Etablissement n'existe pas");
            }

            //Recuperer les etudiants appartenant aux etablissements de l'administrateur
            var classes = await _context.GroupeClasse.Where(gc => etablissementIds.Contains(gc.Id_Etablissement)).ToListAsync();
            if (!classes.Any())
            {
                return NotFound("Aucune classe trouvee pour cet administrateur");
            }

            var etud = await (from e in _context.Etudier
                              join c in _context.GroupeClasse
                              on new { e.Id_Etablissement, e.Id_Classe }
                              equals new { c.Id_Etablissement, c.Id_Classe }
                              where etablissementIds.Contains(c.Id_Etablissement)
                              select e
                               ).ToListAsync();


            if (!etud.Any())
            {
                return NotFound();
            }


            var etudiantIds = etud.Select(e => e.Id_Utilisateur).Distinct().ToList(); 



            //Recuperer les PFMP des etudiants trouves 
            var pfmps = await _context.Pfmp.Where(pf => etudiantIds.Contains(pf.Id_Utilisateur_1)).Select(
            p => new PfmpDto
            {
                DateDebut = p.DateDebut,
                DateFin = p.DateFin,
                IdAdministrateur = p.Id_Utilisateur,
                Id_Planning = p.Id_Planning,
                SIRET = p.SIRET,
                IdEtudiant = p.Id_Utilisateur_1,
                IdPfmp = p.Id_PFMP,
            }).ToListAsync();

            if (!pfmps.Any())
            {
                return NotFound("Aucune PFMP trouvee pour cet administrateur");
            }

            var adminRowDto = await AdminListHelper.CreateList(_context, pfmps, etablissementIds);
            var stat = AdminListHelper.Calculation(adminRowDto);
            var groupByClass = adminRowDto.GroupBy(gc => new { 
                gc.IdEtablissement,
                gc.IdClasse,
                gc.LibelleFiliere

            });

            var classStats = new List<AdminClassStatsDto>();


            foreach (var g in groupByClass)
            {
                var presences = g.Sum(r => r.Presence);
                var absences = g.Sum(ab => ab.Absence);
                var total = presences + absences;
                var tauxPresence = total == 0 ? 0 : Math.Round((double)presences / total * 100);

                var dto = new AdminClassStatsDto
                {
                    IdEtablissement = g.Key.IdEtablissement,
                    IdClasse = g.Key.IdClasse,
                    LibelleFiliere = g.Key.LibelleFiliere,

                    NombreEleves = g.Count(),

                    EnCours = g.Count(r =>
                    r.DateDebut.HasValue &&
                    r.DateFin.HasValue &&
                    r.DateDebut.Value.Date <= DateTime.Today.Date &&
                    r.DateFin.Value.Date >= DateTime.Today.Date),

                    Presence = presences,
                    Absence = absences,
                    TauxPresence = (int)tauxPresence,
                };
                classStats.Add(dto);
            }

            return Ok(classStats);

        }


    }
}
