using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using System.Security.Claims; // creates  claims 


namespace PFMPManager.Api.Helpers
{
    public static class adminListHelper
    {


        public static async Task<List<AdminStageRowDto>> CreateList(AppDbContext _context, pfmps, etablissementIds)
        {
            var adminRowDto = new List<AdminStageRowDto>();

            foreach (var pfmp in pfmps)
            {
                var IdEtudiant = pfmp.IdEtudiant;

                string libelleFiliere = "Non renseign�";
                string nomEtudiant = "Non renseign�";
                string prenomEtudiant = "Non renseign�";
                int totalJourStage = 0;
                bool status = false;
                int Absences = 0;
                int Presences = 0;
                int Restants = 0;
                string nom = "Non renseign�";
                string prenom = "Non renseign�";
                string telephone = "Non renseign�";
                string nomEntreprise = "Non renseign�";
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
                    nomEtudiant = utSearch.Nom!;
                    prenomEtudiant = utSearch.Prenom;
                }




                var orgSearch = await _context.Organisation.FirstOrDefaultAsync(o => o.SIRET == siret);

                if (orgSearch != null)
                {
                    nomEntreprise = orgSearch.RaisonSociale;
                }
                else
                {
                    nomEntreprise = "Non renseign�";
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
                    nom = "Non renseign�";
                    prenom = "Non renseign�";
                    telephone = "Non renseign�";

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

            return adminRowDto;
        }

            public static List<AdminStageRowDto> Calculation(List<AdminStageRowDto> adminRowDto)
            {
                var stat = new List<AdminStageStatsDto>();
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
            }

        
    }

}