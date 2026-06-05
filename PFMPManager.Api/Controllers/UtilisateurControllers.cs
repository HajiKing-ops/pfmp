using System.ComponentModel.DataAnnotations.Schema;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
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
            // hashing  and stuff 
            //make a new byte array  
            byte[] salt;
            //generate salt 
            new RNGCryptoServiceProvider().GetBytes(salt = new byte[16]);

            //hash and salt it using PBKDF2
            var pbkdf2 = new Rfc2898DeriveBytes(pwd, salt, 10000);

            //place the string in the byte array (thats what getbytes does)
            byte[] hash = pbkdf2.GetBytes(20);

            //make new byte array where to store the hashed password+salt
            //why 36? cause 20 are for the hash and 16 for the salt 
            byte[] hashBytes = new byte[36];

            //place the hash and salt in their  respective places 
            Array.Copy(salt, 0, hashBytes, 0, 16);
            Array.Copy(hash, 0, hashBytes, 16, 20);

            //now, convert our fancy byte array to a string 
            string savedPasswordHash = Convert.ToBase64String(hashBytes);

            var query = new Utilisateur
            {
                Nom = nom,
                Prenom = prenom,
                Login = login,
                Pwd = savedPasswordHash,
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