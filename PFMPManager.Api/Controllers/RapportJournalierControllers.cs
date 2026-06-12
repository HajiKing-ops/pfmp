using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Microsoft.OpenApi.Validations;
using Microsoft.VisualBasic;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;



namespace PFMPManager.Api.Controllers
{
    [ApiController]

    [Route("api/journal")]

    public class RapportJournalierController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RapportJournalierController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("{idEtudiant}")] 

        public async Task<IActionResult> RapportById(int idEtudiant) 
        {
            var search = await ( from remplir in _context.Remplir 
                                 join rapport in _context.RapportJournalier 
                                    on remplir.Id_RapportJournalier equals  rapport.Id_RapportJournalier 
                                    where remplir.Id_Utilisateur ==  idEtudiant 
                                    orderby rapport.Id_RapportJournalier descending
                                    select new JournalDto
                                    {
                                        IdEtudiant = remplir.Id_Utilisateur,
                                        IdRapportJournalier = rapport.Id_RapportJournalier,
                                        DateRapport = rapport.DateRapport,
                                        LienVersFichier = rapport.LienVersFichier,
                                        Id_PFMP = rapport.Id_PFMP,
                                    }) .ToListAsync();
            if (!search.Any())
            {
                return NotFound();
            }
            return Ok(search);


        }


        [HttpPost]

        public async Task<IActionResult> Create(CreateJournalDto  request) 
        {
            if (request.IdEtudiant ==  null)
            {
                return BadRequest("IdEtudiant invalide");
            }
            if (string.IsNullOrWhiteSpace(request.LienVersFichier))
            {
                return BadRequest("Le lien vers le fichier est obligatoire");
            }
            if (!request.DateRapport.HasValue)
            {
                return BadRequest("DateRapport obligatoire");
            }
            var query = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_Utilisateur_1 == request.IdEtudiant&& p.DateDebut.HasValue && p.DateFin.HasValue && p.DateDebut.Value.Date <= request.DateRapport && p.DateFin.Value.Date >= request.DateRapport);
            if (query == null)
            {
                return NotFound("Aucune PFMP trouvee pour cette date");
            }
            var search = await (from remplir in _context.Remplir
                                join repport in _context.RapportJournalier
                                on remplir.Id_RapportJournalier equals repport.Id_RapportJournalier
                                where remplir.Id_Utilisateur == request.IdEtudiant
                                && repport.DateRapport.HasValue &&
                                repport.DateRapport.Value.Date == request.DateRapport.Value.Date && repport.Id_PFMP == query.Id_PFMP
                                select repport
                                ).AnyAsync();
            if (search)
            {
                return Conflict("UN journal existe deja pour cette date");
            }
            var rapport = new RapportJournalier
            {
                DateRapport = request.DateRapport,
                LienVersFichier = request.LienVersFichier,
                Id_PFMP = query.Id_PFMP,
            };
            _context.RapportJournalier.Add(rapport);
            await _context.SaveChangesAsync();

            var rem = new Remplir
            {
                Id_RapportJournalier = rapport.Id_RapportJournalier,
                Id_Utilisateur = request.IdEtudiant,
            };
            _context.Remplir.Add(rem);
            await _context.SaveChangesAsync();

            var journal = new JournalDto
            {
                IdRapportJournalier = rapport.Id_RapportJournalier,
                IdEtudiant = request.IdEtudiant,
                DateRapport = request.DateRapport,
                LienVersFichier = request.LienVersFichier,
                Id_PFMP = query.Id_PFMP,
            };
            
            return Ok(journal);
        }

        //update 
        [HttpPut("update/{id}")]

        public async Task<IActionResult> UpdateJournal(UpdateRapportJournalierDto request, int id)
        {
            if (string.IsNullOrWhiteSpace(request.LienVersFichier))
            {
                return BadRequest("LienVersFichier est vide");
            }
            if (!request.DateRapport.HasValue)
            {
                return BadRequest("DateRapport est invalide");
            }
           
            

            var search = await _context.RapportJournalier.FirstOrDefaultAsync(r => r.Id_RapportJournalier == id);
            if(search == null)
            {
                return NotFound("Aucune journal trouvée");
            }

            var pfmp = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == search.Id_PFMP);

            if (pfmp == null)
            {
                return BadRequest("la PFMP n'existe pas");
            }
            if (!pfmp.DateDebut.HasValue || !pfmp.DateFin.HasValue)
            {
                return BadRequest("Impossible de modifier ce rapport car les dates de la PFMP sont manquantes");
            }
            if (request.DateRapport.Value.Date < pfmp.DateDebut.Value.Date || request.DateRapport.Value.Date > pfmp.DateFin.Value.Date)
            {
                return BadRequest("La date du rapport doit être comprise entre la date de début et la date de fin de la PFMP");
            }


            search.DateRapport = request.DateRapport;
            search.LienVersFichier = request.LienVersFichier;

          await _context.SaveChangesAsync();

            var update = new JournalDto
            {
                IdRapportJournalier = search.Id_RapportJournalier,
                DateRapport = search.DateRapport,
                LienVersFichier = search.LienVersFichier,
                Id_PFMP = search.Id_PFMP,
            };
            return Ok(update);
        }

        
        [HttpGet("alerte/{idEtudiant}")]

        public async Task<IActionResult> JournalExists(int idEtudiant)
        {
            var search = await (from remplir in _context.Remplir
                                join rapport in _context.RapportJournalier 
                                on remplir.Id_RapportJournalier equals rapport.Id_RapportJournalier
                                where remplir.Id_Utilisateur == idEtudiant 
                                && rapport.DateRapport.HasValue 
                                && rapport.DateRapport.Value.Date== DateTime.Today
                                select rapport
                               ).AnyAsync();
             return Ok(new { idEtudiant = idEtudiant, journalExiste = search });
        }




        [HttpGet("export/{idPfmp}")]

        public async Task<IActionResult> ExportJournal(int idPfmp)
        { 
            var query = await _context.Pfmp.FirstOrDefaultAsync(p => p.Id_PFMP == idPfmp);



            if (query == null)
            {
                return NotFound();
            }

            var pfmp = new PfmpDto
            {
                IdEtudiant = query.Id_Utilisateur_1,
                DateDebut = query.DateDebut,
                DateFin = query.DateFin,
                IdPfmp = query.Id_PFMP,

            };
            var dateDebut = query.DateDebut;
            var dateFin = query.DateFin;
            var idEtudiant = query.Id_Utilisateur_1;
            if(!dateDebut.HasValue || !dateFin.HasValue)
            {
                return BadRequest();
            }
            var journal = await (from remplir in _context.Remplir
                                join rapport in _context.RapportJournalier
                                on remplir.Id_RapportJournalier equals rapport.Id_RapportJournalier
                                where remplir.Id_Utilisateur == idEtudiant && rapport.DateRapport.HasValue 
                                && rapport.DateRapport.Value.Date >= dateDebut.Value.Date && rapport.DateRapport.Value.Date <= dateFin.Value.Date
                                orderby rapport.DateRapport
                                 select  new JournalDto
                                {
                                    IdEtudiant = remplir.Id_Utilisateur,
                                    IdRapportJournalier = rapport.Id_RapportJournalier,
                                    DateRapport = rapport.DateRapport,
                                    LienVersFichier = rapport.LienVersFichier
                                }).ToListAsync();
            
               
            return Ok(new { pfmp,  journal});
                  

        }
        
       
    }
}