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
         // Maps to the tables
        public DbSet<Utilisateur> Utilisateur { get; set; }
        public DbSet<Referent> Referent { get; set; }
        public DbSet<Etudiant> Etudiant { get; set; }
        public DbSet<Administrateur> Administrateur { get; set; }
        public DbSet<Pfmp> Pfmp { get; set; }
        public DbSet<Organisation> Organisation { get; set; }
    }
}
