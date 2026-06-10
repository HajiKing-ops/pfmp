using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.Models;
using PFMPManager.Api.DTOs;
using Microsoft.VisualBasic;
using System.Reflection.Metadata;


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


            foreach (var pfmp in pfmps)
            {
                var query = await _context.Etudiant.FirstOrDefaultAsync(f => f.Id_Utilisateur_1 == pfmp.IdEtudiant);
                var etudiant = new EtudiantDto
                {
                    Id_Utilisateur_1 = query.Id_Utilisateur_1,
                    Date_Naissance = query.Date_Naissance,
                    Adresse = query.Adresse,
                    CodePostal = query.CodePostal,
                    Ville = query.Ville,
                    NumTelephone = query.NumTelephone,
                    AdresseMail = query.AdresseMail,
                    Id_Utilisateur = query.Id_Utilisateur,

                }).ToListAsync();
                var IdEtudiant = etudiant.Id_Utilisateur_1;

                //etudiant -> utilisateur 
                var utSearch = await _context.Utilisateur.FirstOrDefaultAsync(ut => ut.Id_Utilisateur == IdEtudiant);


                //etudier -> groupeclasse
                var search = await (from etudier in _context.Etudier
                                    join gc in _context.GroupeClasse
                                    on etudier.Id_Etablissement == gc.Id_Etablissement 
                                    && etudier.Id_Classe == gc.Id_Classe
                                    where etudier.Id_Utilisateur == IdEtudiant 
                                    && pfmp.DateDebut.Value.Date <= etudier.AnneeSortie && pfmp.DateDebut.Value.Date >= etudier.AnneeRentree

                                    select gc).FirstOrDefaultAsync();
              

                // groupeclasse -> filieres
                var fil = await (from gc in _context.GroupeClasse
                                 join filiere in _context.Filiere
                                 on gc.Id_Filiere equals filiere.Id_Filiere
                                 where gc.Id_Classe == search.Id_Classe
                                 select filiere).FirstOrDefaultAsync();

               



                var siret = pfmp.SIRET;

                // organisation
                var orgSearch = await _context.Organisation.FirstOrDefaultAsync(o => o.SIRET == siret);

                // travailler
                var tSearch = await _context.Travailler.FirstOrDefaultAsync(t => t.SIRET == siret);
                var idProf = tsearch.Id_Utilisateur;

                //Professionnel
                var pSearch = await _context.Professionnel.FirstOrDefaultAsync(p => p.Id_Utilisateur == idProf);



                //Utilisateur
                var uSearch = await _context.Utilisateur.FirstOrDefaultAsync(u => u.Id_Utilisateur == idProf);




                //planning 
                var planSearch = await _context.Planning.FirstOrDefaultAsync(pl => pl.Id_Planning == pfmp.Id_Planning);
                var planjour = await _context.PlanningJours.ToListAsync(plan => plan.Id_Planning == plansearch.Id_Planning);

                var JourRestants = orgSearch.DateFin.HasValue ? Math.Max(0, (orgSearch.DateFin.Value.Date - DateTime.Today).Days) : 0,

                //TablePresence
                var tableSearch = await _context.TablePresence.ToListAsync(tp => tp.Id_Utilisateur == IdEtudiant && tp.DateJour >= pfmp.DateDebut.Value.Date && tp.DateJour <= pfmp.DateFin.Value.Date);

               



                var adminRowDto = new AdminStageRowDto
                {
                    Nom = utSearch.Nom,
                    Prenom = utSearch.Prenom,
                    LibelleFiliere = fil.LibelleFiliere,
                    Entreprise = orgSearch.RaisonSociale,
                    NomMaitreDeStage = uSearch.Nom,
                    PrenomMaitreDeStage = uSearch.Prenom,
                    DateDebut = etudiant.DateDebut,
                    DateFin = etudiant.DateFin,
                    Id_PFMP = pfmp.IdPFMP,

                }
            }

        }
    }
}