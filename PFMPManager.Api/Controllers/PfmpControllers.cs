using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Server.HttpSys;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;


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

        [HttpGet] // GEt /api/Pfmp returns all PFMPs
        public async Task<IActionResult> GetAll()
        {
            var pfmps = await _context.Pfmp.Select(p => new PfmpDto
            { 
               
                DateDebut =  p.DateDebut,
                DateFin = p.DateFin,
                IdAdministrateur = p.Id_Utilisateur,
                Id_Planning = p.Id_Planning,
                SIRET = p.SIRET,
                IdEtudiant = p.Id_Utilisateur_1,
                IdPfmp = p.Id_PFMP,
              
            }).ToListAsync(); //Query all rows
            return Ok(pfmps); // 200 ok with json array 
        }

        [HttpGet("{id}")] //address of the method
        public async Task<IActionResult> GetPfmpById(int id)
        {
            var pfmp = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == id);

            if (pfmp == null)
            {
                return NotFound();
            }
            var pfmpById = new PfmpDto
            {
                DateDebut = pfmp.DateDebut,
                DateFin = pfmp.DateFin,
                IdAdministrateur = pfmp.Id_Utilisateur,
                Id_Planning = pfmp.Id_Planning,
                SIRET = pfmp.SIRET,
                IdEtudiant = pfmp.Id_Utilisateur_1,
                IdPfmp = pfmp.Id_PFMP,
                JourRestants = pfmp.DateFin.HasValue ? Math.Max(0, (pfmp.DateFin.Value.Date - DateTime.Today).Days) : 0,
                
            };



            return Ok(pfmpById);
        }
        
        [HttpPost]

        public async Task<IActionResult> Create(CreatePfmpDto request)
        {

            if(string.IsNullOrWhiteSpace(request.Siret))
            {
                return BadRequest();
            }
            if(request.IdAdministrateur <= 0 || request.IdPlanning <= 0 || request.IdEtudiant <= 0)
            {
                return BadRequest();
            }
            if(request.DateFin < request.DateDebut)
            {
                return BadRequest();
            }




            var pfmp = new Pfmp
            {
                DateDebut = request.DateDebut,
                DateFin = request.DateFin,
                Id_Planning = request.IdPlanning,
                SIRET = request.Siret,
                Id_Utilisateur_1 = request.IdEtudiant,
               
            };
            _context.Pfmp.Add(pfmp);
            await _context.SaveChangesAsync();
            
            var pfmpDto = new PfmpDto
            {
                 IdPfmp = pfmp.Id_PFMP,
                 IdAdministrateur = pfmp.Id_Utilisateur,
                 Id_Planning = pfmp.Id_Planning,
                 DateFin = pfmp.DateFin,
                 DateDebut = pfmp.DateDebut,
                 SIRET = pfmp.SIRET,
                 IdEtudiant = pfmp.Id_Utilisateur_1,
               
            };

            return Ok(pfmpDto);

        }

        [HttpPost("complete")]

        public async Task<IActionResult> CompletePfmp(CreateCompletePfmpDto request)
        {
            //entreprise 
            var RaisonSociale =request.RaisonSociale;
            var SecteurActivite = request.SecteurActivite;
            var SIRET = request.SIRET;
            var Adresse = request.Adresse;
            var NumTelephone = request.NumTelephone;

            //Planning 
            var Jour = request.Jour;
            var HoraireDebut = request.HoraireDebut;
            var HoraireFin = request.HoraireFin;
            
            //PFMP
            var DateDebut = request.DateDebut;
            var DateFin = request.DateFin;
            var IdEtudiant = request.IdEtudiant;
            var IdAdministrateur = request.IdAdministrateur;

            //maître de stage fields
            var PrenomMaitreStage = request.PrenomMaitreStage;
            var NomMaitreStage = request.NomMaitreStage;
            var FonctionMaitreStage = request.FonctionMaitreStage;
            var TelephoneMaitreStage = request.TelephoneMaitreStage;
            var EmailMaitreStage = request.EmailMaitreStage;
            
            if (string.IsNullOrWhiteSpace(RaisonSociale) ||  string.IsNullOrWhiteSpace(SecteurActivite) ||  string.IsNullOrWhiteSpace(SIRET)
                ||  string.IsNullOrWhiteSpace(Adresse) ||  string.IsNullOrWhiteSpace(NumTelephone)  ||  string.IsNullOrWhiteSpace(Jour) 
                ||  HoraireDebut <= 0 ||  HoraireFin <= 0 ||  !DateDebut.HasValue                                 
                ||  !DateFin.HasValue || IdEtudiant <=0 || IdAdministrateur <=0 || string.IsNullOrWhiteSpace(PrenomMaitreStage)
                || string.IsNullOrWhiteSpace(NomMaitreStage) || string.IsNullOrWhiteSpace(FonctionMaitreStage) || string.IsNullOrWhiteSpace(TelephoneMaitreStage)
                || string.IsNullOrWhiteSpace(EmailMaitreStage) || HoraireFin <= HoraireDebut || DateFin.Value.Date < DateDebut.Value.Date)
            {
                return BadRequest();
            }

            var checkOrg = await _context.Organisation.FirstOrDefaultAsync(p=> p.SIRET == SIRET);
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

            var user =  new Utilisateur
            {
                Nom = request.NomMaitreStage,
                Prenom = request.PrenomMaitreStage,
                Login = EmailMaitreStage,
                Pwd = "pwd",
            };
            _context.Utilisateur.Add(user);
            await _context.SaveChangesAsync();

            

            var prf = new Professionnel
            {
                Id_Utilisateur = user.Id_Utilisateur,
                Fonction = request.FonctionMaitreStage,
                AdresseMail = request.EmailMaitreStage,
                NumTelephone = request.TelephoneMaitreStage,

            };
            _context.Professionnel.Add(prf);
            await _context.SaveChangesAsync();


        }

        [HttpPut("{id}")]

         public async Task<IActionResult> Update(CreatePfmpDto request, int id)
        {
            if(string.IsNullOrWhiteSpace(request.Siret))
            {
                return BadRequest();
            }
            if(request.IdEtudiant <= 0 || request.IdPlanning <= 0 || request.IdAdministrateur <= 0)
            {
                return BadRequest();
            }
            if(request.DateFin < request.DateDebut)
            {
                return BadRequest();
            }

            var search = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == id);

            if(search == null)
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

            [HttpDelete("{id}")]

            public async Task<IActionResult> Delete(int id)
        {
            var del = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == id) ;
            
            if (del== null)
            {
                return NotFound();
            }
            _context.Pfmp.Remove(del);
            await _context.SaveChangesAsync();

            return NoContent();
        }

            
    }
}
