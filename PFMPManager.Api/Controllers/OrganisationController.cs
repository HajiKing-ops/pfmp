using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;
namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 

    [Route("api/entreprises")] // Base route for all endpoints in this controller

    public class OrganisationController : ControllerBase
    {
        private readonly AppDbContext _context; //Database context injected by DI

        // Dependencies are injected by the ASP.NET Core DI container

        public OrganisationController(AppDbContext context)
        {
            _context = context;
        }

        // Returns all organisations available to authenticated users
        [Authorize]
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var query = _context.Organisation.AsNoTracking();
            var result = await ToOrganisationDtoAsync(query);
            return Ok(result); // 200 ok with json array 
        }


        // Searches organisations using optional filters
        [Authorize]
        [HttpGet("recherche")]
        public async Task<IActionResult> Recherche (string? nom, string? codePostal, string? secteur)
        {
            var query = _context.Organisation.AsNoTracking().AsQueryable();


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
          
            var result = await ToOrganisationDtoAsync(query);

            if (!result.Any())
            {
                return NotFound();
            }
            return Ok(result);
        }
        
        // Maps organisation entities to DTOs
        private async Task<List<OrganisationDto>>  ToOrganisationDtoAsync(IQueryable<Organisation> query)
        {
            return await query.Select(o => new OrganisationDto
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
        }
    }

}