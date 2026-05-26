using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Models;

namespace PFMPManager.Api.Data
{
    public class AppDbContext : DbContext 
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        { 
        }
        public DbSet<Organisation> Organisation { get; set; }
    }
}
