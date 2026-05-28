using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;


namespace PFMPManager.Api.Controllers
{
    [ApiController] // Enables model validation and smart binding 

    [Route("api/etudiant")] // Base route for all endpoints in this controller

    public class EtudiantController : ControllerBase
    {
        private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)

        //DI container injects AppDbContext registered om program.cs
        public EtudiantController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet] // GEt /api/organisation returns all organisations as JSON
        public async Task<IActionResult> GetAll()
        {
            var etudiant = await _context.Etudiant.ToListAsync(); //Query all rows
            return Ok(etudiant); // 200 ok with json array 
        }
    }
}