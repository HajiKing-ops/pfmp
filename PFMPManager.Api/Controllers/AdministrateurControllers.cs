using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.Models;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Authorization;



namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 

    [Route("api/administrateur")] // Base route for all endpoints in this controller

    public class AdministrateurController : ControllerBase
    {
        private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)

        //DI container injects AppDbContext registered om program.cs
        public AdministrateurController(AppDbContext context)
        {
            _context = context;
        }
        [Authorize(Roles = "Administrateur")]

        [HttpGet("{id}")]
        public async Task<IActionResult> GetAll(int id)
        {
            //Verifie que l'administrateur gere au moins un etablissement 
            var admin = await _context.Administrer.Where(a => a.Id_Utilisateur == id).ToListAsync();
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
                return NotFound("Aucune classe trouvée pour cet administrateur");
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
                return NotFound("Aucune PFMP trouvée pour cet administrateur");
            }


            var adminRowDto = new List<AdminStageRowDto>();

            foreach (var pfmp in pfmps)
            {
                var IdEtudiant = pfmp.IdEtudiant;
              
                string libelleFiliere = "Non renseigné";
                string nomEtudiant = "Non renseigné";
                string prenomEtudiant = "Non renseigné";
                int totalJourStage = 0;
                bool status = false;
                int Absences = 0;
                int Presences = 0;
                int Restants = 0;
                string nom = "Non renseigné";
                string prenom = "Non renseigné";
                string telephone = "Non renseigné";
                string nomEntreprise = "Non renseigné";
                var siret = pfmp.SIRET;
                





                if (pfmp.DateDebut.HasValue)
                {
                    var pfmpAnnee = pfmp.DateDebut.Value.Date.Year;

                    //varifier que l'etudiant appartenait bien a l'etablissement de l'admin pendant l'annee de la PFMP
                    var search = await (from etudier in _context.Etudier
                                        join gc in _context.GroupeClasse
                                        on new { etudier.Id_Etablissement, etudier.Id_Classe }
                                        equals new { gc.Id_Etablissement, gc.Id_Classe }
                                        where pfmpAnnee <= etudier.AnneeSortie
                                         && pfmpAnnee >= etudier.AnneeRentree
                                         && etudier.Id_Utilisateur == IdEtudiant

                                        select gc).FirstOrDefaultAsync();


                    if (search == null || !etablissementIds.Contains(search.Id_Etablissement))
                    {
                        continue;


                    }
                    // Recuperer les informations d'affichage : eleve, filier, entreprise, maitre de stage
                    
                    var fil = await _context.Filiere.FirstOrDefaultAsync(fi => fi.Id_Filiere == search.Id_Filiere);


                    if (fil != null)
                    {
                        libelleFiliere = fil.LibelleFiliere;
                    }

                }
                else { continue; }

                    var utSearch = await _context.Utilisateur.FirstOrDefaultAsync(ut => ut.Id_Utilisateur == IdEtudiant);

                if (utSearch != null)
                {
                    nomEtudiant = utSearch.Nom;
                    prenomEtudiant = utSearch.Prenom;
                }
              



                var orgSearch = await _context.Organisation.FirstOrDefaultAsync(o => o.SIRET == siret);

                if (orgSearch != null)
                {
                    nomEntreprise = orgSearch.RaisonSociale;
                }
                else {
                    nomEntreprise = "Non renseigné";
                }


                var tSearch = await _context.Travailler.FirstOrDefaultAsync(t => t.SIRET == siret);


                if (tSearch != null)
                {
                    var idProf = tSearch.Id_Utilisateur;



                    var pSearch = await _context.Professionnel.FirstOrDefaultAsync(p => p.Id_Utilisateur == idProf);

                    if (pSearch != null)
                    {

                        var uSearch = await _context.Utilisateur.FirstOrDefaultAsync(u => u.Id_Utilisateur == idProf);
                        if (uSearch != null)
                        {
                            nom = uSearch.Nom;
                            prenom = uSearch.Prenom;
                            telephone = pSearch.NumTelephone;
                        }
                    }

                }
                else
                {
                    nom = "Non renseigné";
                    prenom = "Non renseigné";
                    telephone = "Non renseigné";

                }



                var planSearch = await _context.Planning.FirstOrDefaultAsync(pl => pl.Id_Planning == pfmp.Id_Planning);




                //Calculer le nombre de jours prevus selon le planning
                if (pfmp.DateDebut.HasValue && pfmp.DateFin.HasValue)
                {
                    if (planSearch != null)
                    {
                        var planjour = await _context.PlanningJours.Where(plan => plan.Id_Planning == planSearch.Id_Planning).ToListAsync();
                        if (planjour.Any())
                        {
                            var jourPlanning = planjour.Select(pj => pj.Jour).ToList();

                            for (var date = pfmp.DateDebut.Value.Date; date <= pfmp.DateFin.Value.Date; date = date.AddDays(1))
                            {
                                string jourFrancais = date.DayOfWeek switch
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

                                if (jourPlanning.Contains(jourFrancais))
                                {
                                    totalJourStage++;
                                }

                            }
                        }
                    }


                    // Calculer les presences, absences, jours restants et statut
                    var tableSearch = await _context.TablePresence.Where(tp => tp.Id_Utilisateur == IdEtudiant && tp.DateJour.HasValue && tp.DateJour.Value.Date >= pfmp.DateDebut.Value.Date && tp.DateJour.Value.Date <= pfmp.DateFin.Value.Date).ToListAsync();
                    if (tableSearch.Any())
                    {
                        Absences = tableSearch.Count(a => a.Etat.Contains("ABSENT"));
                        Presences = tableSearch.Count(c => c.Etat.Contains("PRESENT"));
                    }
                }

                Restants = Math.Max(0, totalJourStage - Presences - Absences);

                if (totalJourStage > 0 && Restants == 0)
                {
                    status = true;
                }

               
                // Construire le DTO retourne auy frontend
                var dto = new AdminStageRowDto
                {
                    Nom = nomEtudiant,
                    Prenom = prenomEtudiant,
                    LibelleFiliere = libelleFiliere,
                    Entreprise = nomEntreprise,
                    NomMaitreDeStage = nom,
                    PrenomMaitreDeStage = prenom,
                    NumTelephone = telephone,
                    DateDebut = pfmp.DateDebut,
                    DateFin = pfmp.DateFin,
                    Id_PFMP = pfmp.IdPfmp,
                    Presence = Presences,
                    Absence = Absences,
                    Status = status,
                    Restants = Restants,

                };
                adminRowDto.Add(dto);

            }
            
            int enCours =0;
            int valides =0;
            int absencesTotal = 0;
            int stageTotal = adminRowDto.Count;

            foreach (var pf in adminRowDto)
            {
                
                if (pf.DateDebut.HasValue && pf.DateFin.HasValue)
                {
                    if (pf.DateDebut.Value.Date <= DateTime.Today.Date && DateTime.Today.Date <= pf.DateFin.Value.Date)
                    {
                        enCours += 1;
                    }
                }
                if (pf.Status)
                {
                    valides += 1;
                }
                absencesTotal += pf.Absence;
            }
            var stat = new AdminStageStatsDto
            {
                StageTotal = stageTotal,
                Encours = enCours,
                Valide = valides,
                AbsencesTotal = absencesTotal,
            };
            return Ok(new { adminRowDto, stat });
        }
    }
    
}