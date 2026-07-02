

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Services;
using PFMPManager.Api.Models;
using Microsoft.AspNetCore.Authorization;
using QuestPDF.Fluent; // lets you build the PDF layout
using QuestPDF.Helpers; //  gives PageSizes, colors, units, etc.
using QuestPDF.Infrastructure; // needed for PDF generation types/settings





namespace PFMPManager.Api.Controllers
{
    [ApiController]

    [Route("api/journal")]

    //Manages daily PFMP reports and PDF export
    [Authorize(Roles = "Etudiant")]
    public class RapportJournalierController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly ICurrentUserService _currentUserService;

        public RapportJournalierController(AppDbContext context, ICurrentUserService currentUserService)
        {
            _context = context;
            _currentUserService = currentUserService;
        }

        //Retrieves  daily reports for a given student 
        [Authorize(Roles = "Etudiant")]
        [HttpGet] 
        public async Task<IActionResult> RapportById() 
        {
            var user = _currentUserService.GetCurrentUser(User);
            if (!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idEtudiant = user.UserId;

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
                                    }).AsNoTracking().ToListAsync();
            if (!search.Any())
            {
                return NotFound();
            }
            return Ok(search);

        }

        //Creates a daily report for the connected student
        [Authorize(Roles = "Etudiant")]
        [HttpPost]
        public async Task<IActionResult> Create(CreateJournalDto  request) 
        {
            var user = _currentUserService.GetCurrentUser(User);
            if (!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idEtudiant = user.UserId;


            if (string.IsNullOrWhiteSpace(request.LienVersFichier))
            {
                return BadRequest("Le lien vers le fichier est obligatoire");
            }
            if (!request.DateRapport.HasValue)
            {
                return BadRequest("DateRapport obligatoire");
            }
            // Find the active PFMP matching the report date
            var query = await _context.Pfmp.AsNoTracking().FirstOrDefaultAsync(p => p.Id_Utilisateur_1 == idEtudiant&& p.DateDebut.HasValue && p.DateFin.HasValue && p.DateDebut.Value.Date <= request.DateRapport && p.DateFin.Value.Date >= request.DateRapport);
            if (query == null)
            {
                return NotFound("Aucune PFMP trouvee pour cette date ou id etudiant introuvable");
            }
            
            //prevent creating more than one report for the same day
            var search = await (from remplir in _context.Remplir
                                join repport in _context.RapportJournalier
                                on remplir.Id_RapportJournalier equals repport.Id_RapportJournalier
                                where remplir.Id_Utilisateur == idEtudiant
                                && repport.DateRapport.HasValue &&
                                repport.DateRapport.Value.Date == request.DateRapport.Value.Date && repport.Id_PFMP == query.Id_PFMP
                                select repport
                                ).AsNoTracking().AnyAsync();
            if (search)
            {
                return Conflict("UN journal existe deja pour cette date");
            }
            //Create the daily report and link it to the student
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
                Id_Utilisateur = idEtudiant,
            };
            _context.Remplir.Add(rem);
            await _context.SaveChangesAsync();

            var journal = new JournalDto
            {
                IdRapportJournalier = rapport.Id_RapportJournalier,
                IdEtudiant = idEtudiant,
                DateRapport = request.DateRapport,
                LienVersFichier = request.LienVersFichier,
                Id_PFMP = query.Id_PFMP,
            };
            
            return Ok(journal);
        }

        //update a daily report if the new date stays within the PFMP period
        [Authorize(Roles = "Etudiant")]
        [HttpPut("update/{id}")]

        public async Task<IActionResult> UpdateJournal(UpdateRapportJournalierDto request, int id)
        {
            var user = _currentUserService.GetCurrentUser(User);
            if (!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var studentId = user.UserId;

            if (id <= 0)
                return BadRequest("ID est invalide");

            if (string.IsNullOrWhiteSpace(request.LienVersFichier))
            {
                return BadRequest("LienVersFichier est vide");
            }
            if (!request.DateRapport.HasValue)
            {
                return BadRequest("DateRapport est invalide");
            }
            
           
            // Find the daily report to update

            var search = await ( from p in _context.Pfmp
                                join r in _context.RapportJournalier
                                on p.Id_PFMP equals r.Id_PFMP
                                where p.Id_Utilisateur_1 == studentId
                                && r.Id_RapportJournalier == id
                                select r ).FirstOrDefaultAsync();


            if(search == null)
            {
                return NotFound("Aucune journal trouvee");
            }

            var pfmp = await _context.Pfmp.AsNoTracking().FirstOrDefaultAsync(p => p.Id_PFMP == search.Id_PFMP);

            if (pfmp == null)
            {
                return BadRequest("la PFMP n'existe pas");
            }
            if (!pfmp.DateDebut.HasValue || !pfmp.DateFin.HasValue)
            {
                return BadRequest("Impossible de modifier ce rapport car les dates de la PFMP sont manquantes");
            }
            // Ensure the report date remains inside the PFMP period
            if (request.DateRapport.Value.Date < pfmp.DateDebut.Value.Date || request.DateRapport.Value.Date > pfmp.DateFin.Value.Date)
            {
                return BadRequest("La date du rapport doit etre comprise entre la date de debut et la date de fin de la PFMP");
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

        //Checks whether the student already submitted today's report
        [Authorize(Roles = "Etudiant")]
        [HttpGet("alerte")]
        public async Task<IActionResult> JournalExists()
        {
            var user = _currentUserService.GetCurrentUser(User);
            if (!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idEtudiant = user.UserId;
            var search = await (from remplir in _context.Remplir
                                join rapport in _context.RapportJournalier 
                                on remplir.Id_RapportJournalier equals rapport.Id_RapportJournalier
                                where remplir.Id_Utilisateur == idEtudiant 
                                && rapport.DateRapport.HasValue 
                                && rapport.DateRapport.Value.Date== DateTime.Today
                                select rapport
                               ).AsNoTracking().AnyAsync();
             return Ok(new { idEtudiant = idEtudiant, journalExiste = search });
        }



        // Exports all daily reports linked to a PFMP
        [Authorize(Roles = "Etudiant")]
        [HttpGet("export/{idPfmp}")]
        public async Task<IActionResult> ExportJournal(int idPfmp)
        {
            var user = _currentUserService.GetCurrentUser(User);
            if (!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }

            if (idPfmp <= 0)
                return BadRequest("Id PFMP est invalide");

            var query = await _context.Pfmp.AsNoTracking().FirstOrDefaultAsync(p => p.Id_PFMP == idPfmp && p.Id_Utilisateur_1 == user.UserId );



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
            // Retrieve reports within the PFMP date range
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
                                }).AsNoTracking().ToListAsync();
            
               
            return Ok(new { pfmp,  journal});
                  

        }

        // Generates a PDF summary of the PFMP daily reports
        [Authorize]
        [HttpGet("pdf/{idPfmp}")]
        public async Task<IActionResult> CreatePdf( int idPfmp)
        {
            if (idPfmp <= 0)
            {
                return BadRequest("id PFMP est invalide");
            }
            var user = _currentUserService.GetCurrentUser(User);
            if (!user.Success)
            {
                return Unauthorized(user.ErrorMessage);
            }
            var idEtudiant = user.UserId;
            var userRole = user.Role;
            
            // Ensure the connected student owns this PFMP

                var pfmp = await _context.Pfmp.AsNoTracking().FirstOrDefaultAsync(p => p.Id_PFMP == idPfmp && p.Id_Utilisateur_1 == idEtudiant);
                if (pfmp == null)
                {
                    return Forbid("C'est interdit");
                }
            
                var dateDebut = pfmp.DateDebut;
                var dateFin = pfmp.DateFin;
                if (!dateDebut.HasValue || !dateFin.HasValue)
                {
                return BadRequest("Les dates de la PFMP sont manquantes. ");
                }

                // Load student and organisation information for the PDF header
                var etudiant = await _context.Utilisateur.AsNoTracking().FirstOrDefaultAsync(e => e.Id_Utilisateur == idEtudiant);
                if (etudiant == null)
                {
                    return NotFound();
                }
                var etudiantNom = etudiant.Nom;
                var etudiantPrenom = etudiant.Prenom;


                var siret = pfmp.SIRET;
                var infoOrg = await _context.Organisation.AsNoTracking().FirstOrDefaultAsync(o => o.SIRET == siret);
                if (infoOrg == null)
                {
                    return NotFound();
                }
                var entreprise = infoOrg.RaisonSociale;

                // Load daily reports to include in the PDF
                var journaux = await _context.RapportJournalier.AsNoTracking().Where(r => r.Id_PFMP == idPfmp && r.DateRapport.HasValue).OrderBy(r => r.DateRapport).ToListAsync();
                if (!journaux.Any())
                {
                    return NotFound("Aucune PFMP");
                }
            
            //Build the PDF document  with  QuestPDF
            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(2, Unit.Centimetre);

                    page.Header()
                        .Text("Journal de bord PFMP")
                        .FontSize(20)
                        .Bold();

                    page.Content().Column(column =>
                    {
                        column.Item().Text($"etudiant : {etudiantPrenom} {etudiantNom}");
                        column.Item().Text($"Entreprise : {entreprise}");
                        column.Item().Text($"Periode : {dateDebut.Value:dd/MM/yyyy} - {dateFin.Value:dd/MM/yyyy}");
                        column.Item().PaddingTop(15).Text("Rapports journaliers").Bold();

                        foreach (var r in journaux)
                        {
                            var dateRapport = r.DateRapport;
                            if (!dateRapport.HasValue)
                            {
                                continue;
                            }
                            column.Item().Text($"{r.DateRapport.Value:dd/MM/yyyy} - {r.LienVersFichier}");
                        }
                    });
                    page.Footer().AlignCenter().Text(text =>
                    {
                        text.Span("Page");
                        text.CurrentPageNumber();
                    });
                });
            });

            var pdfBytes = document.GeneratePdf();
            return File(pdfBytes, "application/pdf", $"journal_pfmp_{idPfmp}.pdf");
        }
    }
}