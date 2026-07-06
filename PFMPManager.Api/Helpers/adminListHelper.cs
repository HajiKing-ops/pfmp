using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;


namespace PFMPManager.Api.Helpers
{
    // Builds administrator dashboard rows and statistics from PFMP data
    public static class AdminListHelper
    {

        // Builds dashboard rows for PFMPs managed by the connected administrator
        public static async Task<List<AdminStageRowDto>> CreateList(AppDbContext _context, List<PfmpDto> pfmps, List<int> etablissementIds)
        {
            var adminRowDto = new List<AdminStageRowDto>();

            foreach (var pfmp in pfmps)
            {
                var idEtudiant = pfmp.IdEtudiant;

                string libelleFiliere = "Non renseigne";
                string nomEtudiant = "Non renseigne";
                string prenomEtudiant = "Non renseigne";
                int totalJourStage = 0;
                bool status = false;
                int absences = 0;
                int presences = 0;
                int restants = 0;
                string nom = "Non renseigne";
                string prenom = "Non renseigne";
                string telephone = "Non renseigne";
                string nomEntreprise = "Non renseigne";
                var siret = pfmp.SIRET;
                int idEtablissement = 0;
                int idClasse = 0;
                string libelleClasse = "";





                if (pfmp.DateDebut.HasValue)
                {
                    var pfmpAnnee = pfmp.DateDebut.Value.Date.Year;

                    // Ensure the student belonged to one of the administrator's establishments during the PFMP year
                    var search = await (from etudier in _context.Etudier
                                        join gc in _context.GroupeClasse
                                        on new { etudier.Id_Etablissement, etudier.Id_Classe }
                                        equals new { gc.Id_Etablissement, gc.Id_Classe }
                                        where pfmpAnnee <= etudier.AnneeSortie
                                         && pfmpAnnee >= etudier.AnneeRentree
                                         && etudier.Id_Utilisateur == idEtudiant

                                        select gc).FirstOrDefaultAsync();


                    if (search == null || !etablissementIds.Contains(search.Id_Etablissement))
                    {
                        continue;
                    }
                    // Store class and filiere information used in the dashboard row
                    idEtablissement = search.Id_Etablissement;
                    idClasse = search.Id_Classe;
                    libelleClasse = search.LibelleClasse;
                    var fil = await _context.Filiere.FirstOrDefaultAsync(fi => fi.Id_Filiere == search.Id_Filiere);

                    if (fil != null)
                    {
                        libelleFiliere = fil.LibelleFiliere;
                    }

                }
                else { continue; }

                // Load student identity information
                var utSearch = await _context.Utilisateur.FirstOrDefaultAsync(ut => ut.Id_Utilisateur == idEtudiant);

                if (utSearch != null)
                {
                    nomEtudiant = utSearch.Nom!;
                    prenomEtudiant = utSearch.Prenom;
                }



                // Load organisation information linked to the PFMP
                var orgSearch = await _context.Organisation.FirstOrDefaultAsync(o => o.SIRET == siret);

                if (orgSearch != null)
                {
                    nomEntreprise = orgSearch.RaisonSociale;
                }
                else
                {
                    nomEntreprise = "Non renseigne";
                }

                // Load internship supervisor information from the organisation work relation
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
                    nom = "Non renseigne";
                    prenom = "Non renseigne";
                    telephone = "Non renseigne";

                }


                var dto = new AdminStageRowDto();
                var planSearch = await _context.Planning.FirstOrDefaultAsync(pl => pl.Id_Planning == pfmp.Id_Planning);



                // Calculate the expected number of internship days from the planning
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

                    
                   // Load presences and absences recorded during the PFMP period
                    var tableSearch = await _context.TablePresence.Where(tp => tp.Id_Utilisateur == idEtudiant && tp.DateJour.HasValue && tp.DateJour.Value.Date >= pfmp.DateDebut.Value.Date && tp.DateJour.Value.Date <= pfmp.DateFin.Value.Date).ToListAsync();
                    if (tableSearch.Any())
                    {
                        absences = tableSearch.Count(a => a.Etat.Contains("ABSENT"));
                        presences = tableSearch.Count(c => c.Etat.Contains("PRESENT"));
                        
                        foreach(var tp in tableSearch)
                        {
                            var tablePresence = new CreateTablePresenceDto
                            {
                                DateJour = tp.DateJour,
                                Etat = tp.Etat,
                                Retard = tp.Retard,
                                Justification =tp.Justification,
                            };
                            
                            dto.TablePresence.Add(tablePresence) ;
                        }
                    }
                }
                // Calculate remaining days and completion status
                restants = Math.Max(0, totalJourStage - presences - absences);

                if (totalJourStage > 0 && restants == 0)
                {
                    status = true;
                }


                // Build the dashboard row returned to the frontend
                

                    dto.Nom  = nomEtudiant;
                    dto.Prenom = prenomEtudiant;
                    dto.LibelleFiliere = libelleFiliere;
                    dto.Entreprise = nomEntreprise;
                    dto.NomMaitreDeStage = nom;
                    dto.PrenomMaitreDeStage = prenom;
                    dto.NumTelephone = telephone;
                    dto.DateDebut = pfmp.DateDebut;
                    dto.DateFin = pfmp.DateFin;
                    dto.Id_PFMP = pfmp.IdPfmp;
                    dto.Presence = presences;
                    dto.Absence = absences;
                    dto.Status = status;
                    dto.Restants = restants;
                    dto.IdEtablissement = idEtablissement;
                    dto.IdClasse = idClasse;
                    dto.LibelleClasse = libelleClasse;
                    dto.StudentId = idEtudiant;


                adminRowDto.Add(dto);
            }

            return adminRowDto;
        }
            // Calculates global dashboard statistics from administrator dashboard rows            
            public static AdminStageStatsDto Calculation(List<AdminStageRowDto> adminRowDto)
            {
                int stageTotal = adminRowDto.Count;

                int enCours = adminRowDto.Count(r =>
                    r.DateDebut.HasValue &&
                    r.DateFin.HasValue &&
                    r.DateDebut.Value.Date <= DateTime.Today.Date &&
                    r.DateFin.Value.Date >= DateTime.Today.Date
                );
                int valides = adminRowDto.Count(r => r.Status);

                int absencesTotal = adminRowDto.Sum(r => r.Absence);

                var stat = new AdminStageStatsDto
                {
                    StageTotal = stageTotal,
                    Encours = enCours,
                    Valide = valides,
                    AbsencesTotal = absencesTotal,
                };
                return stat;

            }

        
    }

}