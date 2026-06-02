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

    public class DemarcheController : ControllersBase 
    {
        private readonly AppDbContext _context;

        public DemarcheController(AppDbContext context)
        {
            _context = context;
        }

        [HttpPost]

    }
}