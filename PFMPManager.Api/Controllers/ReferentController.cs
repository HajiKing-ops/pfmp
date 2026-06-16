using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Authorization;


namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 

    [Route("api/referent")] // Base route for all endpoints in this controller

    public class ReferentController : ControllerBase
    {
        private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)

        //DI container injects AppDbContext registered om program.cs
        public ReferentController(AppDbContext context)
        {
            _context = context;
        }

        [Authorize]
        [HttpGet] // GEt /api/organisation returns all organisations as JSON
        public async Task<IActionResult> GetAll()
        {
            var referent = await _context.Referent.ToListAsync(); //Query all rows
            return Ok(referent); // 200 ok with json array 
        }

        [HttpGet("{id}/etudiants")]

        public async Task<IActionResult> EtudiantsById(int id)
        {
            var ById = await _context.Etudiant.Where(e=> e.Id_Utilisateur == id).Select(p=> new EtudiantDto
            {
                Date_Naissance = p.Date_Naissance,
                Adresse = p.Adresse ?? string.Empty,
                CodePostal = p.CodePostal ?? string.Empty,
                Ville = p.Ville ?? string.Empty,
                NumTelephone = p.NumTelephone ?? string.Empty,
                AdresseMail = p.AdresseMail ?? string.Empty,
                IdEtudiant = p.Id_Utilisateur_1,
                IdReferent = id,

            }).ToListAsync();


            if( ById != null && !ById.Any())
            {  
                return NotFound();
            }
            return Ok(ById);
        }
    }
}