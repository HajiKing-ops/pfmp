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
        public DbSet<Remplir> Remplir { get; set; }
        public DbSet<Planning> Planning { get; set; }
        public DbSet<Contacter> Contacter { get; set; }
        public DbSet<RapportJournalier> RapportJournalier { get; set; }
        public DbSet<PlanningJours> PlanningJours { get; set; }
        public DbSet<Professionnel> Professionnel { get; set; }
        public DbSet<Travailler> Travailler { get; set; }
        public DbSet<Etudier> Etudier { get; set; }
        public DbSet<GroupeClasse> GroupeClasse { get; set; }
        public DbSet<Filiere> Filiere { get; set; }
        public DbSet<TablePresence> TablePresence { get; set; }
        public DbSet<Administrer> Administrer { get; set; }
        public DbSet<Etablissement> Etablissement { get; set; }
        public DbSet<RefreshToken> RefreshToken { get; set; }
        public DbSet<Message> Message { get; set; }



        protected override void OnModelCreating(ModelBuilder modelBuilder) // table rule/configuration
        {
            modelBuilder.Entity<Remplir>()
                .HasKey(r => new {r.Id_Utilisateur, r.Id_RapportJournalier});

            modelBuilder.Entity<Contacter>()
               .HasKey(r => new { r.Id_Utilisateur, r.SIRET });

            modelBuilder.Entity<Travailler>()
              .HasKey(c => new { c.Id_Utilisateur, c.SIRET });

           modelBuilder.Entity<Etudier>()
              .HasKey(c => new { c.Id_Utilisateur, c.Id_Etablissement, c.Id_Classe });

            modelBuilder.Entity<GroupeClasse>()
              .HasKey(c => new { c.Id_Etablissement, c.Id_Classe });

            modelBuilder.Entity<Administrer>()
              .HasKey(c => new { c.Id_Utilisateur, c.Id_Etablissement });

            modelBuilder.Entity<Etablissement>()
              .HasKey(c => new { c.Id_Etablissement, c.Id_Classe });
        }

    }
}
