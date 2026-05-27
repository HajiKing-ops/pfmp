using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Models;

namespace PFMPManager.Api.Data
{
    //Bridge between the application and the database, all queries go through here 
    public class AppDbContext : DbContext 
    {
        //Receives DB configuration from program.cs (connection string, provider, etc)
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        { 
        }
        public DbSet<Organisation> Organisation { get; set; } // Maps to the Organisation table
    }
}
