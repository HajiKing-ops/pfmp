using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
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
                                    select new JournalDto
                                    {
                                        IdEtudiant = remplir.Id_Utilisateur,
                                        IdRapportJournalier = rapport.Id_RapportJournalier,
                                        DateRapport = rapport.DateRapport,
                                        LienVersFichier = rapport.LienVersFichier
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
            if (request.IdEtudiant <= 0)
            {
                return BadRequest();
            }
            if (string.IsNullOrWhiteSpace(request.LienVersFichier))
            {
                return BadRequest();
            }
            if (!request.DateRapport.HasValue)
            {
                return BadRequest();
            }

            var rapport = new RapportJournalier
            {
                DateRapport = request.DateRapport,
                LienVersFichier = request.LienVersFichier,
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
            };
            return Ok(journal);
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