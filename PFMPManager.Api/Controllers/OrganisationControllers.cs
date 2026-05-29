using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;

namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 

    [Route("api/organisation")] // Base route for all endpoints in this controller

    public class OrganisationController : ControllerBase
    {
        private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)

        //DI container injects AppDbContext registered om program.cs
        public OrganisationController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet] // GEt /api/organisation returns all organisations as JSON
        public async Task<IActionResult> GetAll()
        {
            var resutlt = await _context.Organisation.Select(o => new OrganisationDto // created object of the dto 
            {
                SIRET = o.SIRET ?? string.Empty, // ?? string.Empty -> if the database value exists use it, if its null, use empty text
                RaisonSociale = o.RaisonSociale ?? string.Empty,
                SecteurActivite = o.SecteurActivite ?? string.Empty,
                Activite = o.Activite ?? string.Empty,
                Adresse = o.Adresse ?? string.Empty,
                CodePostal = o.CodePostal ?? string.Empty,
                Ville = o.Ville ?? string.Empty,
                AdresseMail = o.AdresseMail ?? string.Empty,
                NumTelephone = o.NumTelephone ?? string.Empty, 
            }
                ).ToListAsync(); //Query all rows
            return Ok(resutlt); // 200 ok with json array 
        }
    }
}