using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Authorization;
namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 

    [Route("api/entreprises")] // Base route for all endpoints in this controller

    public class OrganisationController : ControllerBase
    {
        private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)

        //DI container injects AppDbContext registered om program.cs
        public OrganisationController(AppDbContext context)
        {
            _context = context;
        }

        [Authorize]

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _context.Organisation.Select(o => new OrganisationDto // created object of the dto 
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
                SiteWeb = o.SiteWeb ?? string.Empty,
            }).ToListAsync(); //Query all rows
            return Ok(result); // 200 ok with json array 
        }


        [HttpGet("recherche")]

        public async Task<IActionResult> Recherche (string? nom, string? codePostal, string? secteur)
        {
            var query = _context.Organisation.AsQueryable();


            if (!string.IsNullOrWhiteSpace(nom))
            {
                query = query.Where(o => o.RaisonSociale.Contains(nom));

            }
             if (!string.IsNullOrWhiteSpace(codePostal))
             {
                query = query.Where(o => o.CodePostal == codePostal);
             }
             if (!string.IsNullOrWhiteSpace(secteur))
             {
                query = query.Where(o => o.SecteurActivite.Contains(secteur));
             }
          
            var result = await query.Select(o => new OrganisationDto
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
                SiteWeb = o.SiteWeb ?? string.Empty,
            }).ToListAsync();

            if (!result.Any())
            {
                return NotFound();
            }
            return Ok(result);
            

        }
    }

}