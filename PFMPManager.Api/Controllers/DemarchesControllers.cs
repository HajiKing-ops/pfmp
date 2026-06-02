using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;



namespace PFMPManager.Api.Controllers
{
    [ApiController]

    [Route("api/demarches")]

    public class DemarcheController : ControllerBase 
    {
        private readonly AppDbContext _context;

        public DemarcheController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost]

        public async Task<IActionResult> Create(CreateDemarchesDto request)
        {
            var idEtudiant = request.Id_Utilisateur;
            var nomEntreprise = request.SIRET;
            var dateRefus = request.dateRefus;
            var status = request.status;
            
            var query = new Demarches
            {
                SIRET = nomEntreprise,
                Id_Utilisateur = idEtudiant,
                dateRefus = dateRefus,
                status = status,
            };
            _context.Demarches.Add(query);
            await _context.SaveChangesAsync();


            return Ok();
        }

    }
}