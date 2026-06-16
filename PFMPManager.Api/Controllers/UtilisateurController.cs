using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Helpers;
using PFMPManager.Api.Models;


namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 

    [Route("api/utilisateur")] // Base route for all endpoints in this controller

    public class UtilisateurController : ControllerBase
    {
        private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)

        //DI container injects AppDbContext registered om program.cs
        public UtilisateurController(AppDbContext context)
        {
            _context = context;
        }
        
        [Authorize(Roles = "Administrateur")]
        [HttpGet] // GEt /api/organisation returns all organisations as JSON
        public async Task<IActionResult> GetAll()
        {
            var utilisateur = await _context.Utilisateur.ToListAsync(); //Query all rows
            return Ok(utilisateur); // 200 ok with json array 
        }


        [HttpPost]

        public async Task<IActionResult> CreateUtilisateur(CreateUtilisateurDto request)
        {
            var nom = request.Nom;
            var prenom = request.Prenom;
            var login = request.Login;
            var pwd = request.Pwd;

            if (string.IsNullOrWhiteSpace(nom) || string.IsNullOrWhiteSpace(prenom) || string.IsNullOrWhiteSpace(login) || string.IsNullOrWhiteSpace(pwd))
            {
                return BadRequest();

            }

            var Pwd = PasswordHelper.HashPassword(request.Pwd);

            var query = new Utilisateur
            {
                Nom = nom,
                Prenom = prenom,
                Login = login,
                Pwd = Pwd,
            };
            _context.Utilisateur.Add(query);
            await _context.SaveChangesAsync();

            var create = new CreateUtilisateurDto
            {
                Nom = query.Nom,
                Prenom = query.Prenom,
                Login = query.Login,

            };
            return Ok(create);
        }

    }
}