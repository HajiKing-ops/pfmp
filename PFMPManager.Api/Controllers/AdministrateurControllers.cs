using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.Models;
using PFMPManager.Api.DTOs;
using Microsoft.VisualBasic;
using System.Reflection.Metadata;
using Microsoft.EntityFrameworkCore.Metadata.Internal;


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
        
       public async Task<IActionResult> GetALl()
        {
            var  pfmps = await _context.Pfmp.Select(p => new PfmpDto///p => p.DateDebut.HasValue && p.DateDebut.Value.Date <= DateTime.Today && p.DateFin.HasValue && p.DateFin.Value.Date >= DateTime.Today
            {
                DateDebut = p.DateDebut,
                DateFin = p.DateFin,
                IdAdministrateur = p.Id_Utilisateur,
                Id_Planning = p.Id_Planning,
                SIRET = p.SIRET,
                IdEtudiant = p.Id_Utilisateur_1,
                IdPfmp = p.Id_PFMP,
            }).ToListAsync();

            var adminRowDto = new List<AdminStageRowDto>();

            foreach (var pfmp in pfmps)
            {
                var IdEtudiant = pfmp.IdEtudiant;
                int? pfmpAnnee =null;
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
                int comptJour = 0;


                var utSearch = await _context.Utilisateur.FirstOrDefaultAsync(ut => ut.Id_Utilisateur == IdEtudiant);

                if (utSearch != null)
                {
                    nomEtudiant = utSearch.Nom;
                    prenomEtudiant = utSearch.Prenom;
                }

                if (pfmp.DateDebut.HasValue)
                {
                    pfmpAnnee = pfmp.DateDebut.Value.Date.Year;


                    //etudiant -> utilisateur 
                    


                    //etudier -> groupeclasse
                    var search = await (from etudier in _context.Etudier
                                        join gc in _context.GroupeClasse
                                        on new { etudier.Id_Etablissement, etudier.Id_Classe }
                                        equals new { gc.Id_Etablissement, gc.Id_Classe }
                                        where pfmpAnnee <= etudier.AnneeSortie
                                         && pfmpAnnee >= etudier.AnneeRentree
                                         && etudier.Id_Utilisateur == IdEtudiant

                                        select gc).FirstOrDefaultAsync();


                    if (search != null)
                    {

                        // groupeclasse -> filieres
                        var fil = await _context.Filiere.FirstOrDefaultAsync(fi => fi.Id_Filiere == search.Id_Filiere);

                       
                        if (fil != null)
                        {
                            libelleFiliere = fil.LibelleFiliere;
                        }
                    }
                }
                else
                {
                    libelleFiliere = "Non renseigné";
                }




                var siret = pfmp.SIRET;
              
                // organisation
                var orgSearch = await _context.Organisation.FirstOrDefaultAsync(o => o.SIRET == siret);

                if (orgSearch != null)
                {
                    nomEntreprise = orgSearch.RaisonSociale;
                }
                else {
                    nomEntreprise = "Non renseigné";
                } 


             //travailler
           

                var tSearch = await _context.Travailler.FirstOrDefaultAsync(t => t.SIRET == siret);


                if (tSearch != null)
                {
                    var idProf = tSearch.Id_Utilisateur;



                    //Professionnel
                    var pSearch = await _context.Professionnel.FirstOrDefaultAsync(p => p.Id_Utilisateur == idProf);

                    if (pSearch != null)
                    {
                        //Utilisateur
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



                    //planning 
                var planSearch = await _context.Planning.FirstOrDefaultAsync(pl => pl.Id_Planning == pfmp.Id_Planning);
              

               

                //TablePresence
                if (pfmp.DateDebut.HasValue && pfmp.DateFin.HasValue)
                {
                    if (planSearch != null)
                    {
                        var planjour = await _context.PlanningJours.Where(plan => plan.Id_Planning == planSearch.Id_Planning).ToListAsync();
                        if (planjour.Any())
                        {

                            for (var date = pfmp.DateDebut; date <= pfmp.DateFin; date++)
                            { 
                                var jourFrancais = Convert.date.DayOfWeek to French;


                            }

                            //totalJourStage = planjour.Count(c => c.Jour);
                        }
                    }

                    //totalJourStage = (pfmp.DateFin.Value.Date - pfmp.DateDebut.Value.Date).Days;
                    var tableSearch = await _context.TablePresence.Where(tp => tp.Id_Utilisateur == IdEtudiant && tp.DateJour.HasValue && tp.DateJour.Value.Date >= pfmp.DateDebut.Value.Date && tp.DateJour.Value.Date <= pfmp.DateFin.Value.Date).ToListAsync();
                    if (tableSearch.Any())
                    {
                        Absences = tableSearch.Count(a => a.Etat.Contains("Absent"));
                        Presences = tableSearch.Count(c => c.Etat.Contains("Présent"));

                        Restants = totalJourStage - Presences - Absences;

                        if (Restants == 0)
                        {
                            status = true;
                        }
                    }
                    
                }
                
                


                var dto = new AdminStageRowDto
                {
                    Nom = nomEtudiant,
                    Prenom = prenomEtudiant,
                    LibelleFiliere = libelleFiliere,
                    Entreprise = nomEntreprise,
                    NomMaitreDeStage = nom,
                    PrenomMaitreDeStage = prenom ,
                    DateDebut = pfmp.DateDebut,
                    DateFin = pfmp.DateFin,
                    Id_PFMP = pfmp.IdPfmp,
                    Presence = Presences ,
                    Absence = Absences ,
                    Status = status,
                    Restants = Restants,
                    NumTelephone = telephone,
                };
                adminRowDto.Add(dto);
            }
            return Ok(adminRowDto);
        }


    }
}