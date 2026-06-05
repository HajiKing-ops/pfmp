namespace PFMPManager.Api.DTOs
{
    public class CreatePlanningJoursDto
    {
        public string? Jour { get; set; }
        public TimeSpan? MatinDebut { get; set; }
        public TimeSpan? MatinFin { get; set; }
        public TimeSpan? ApresMidiDebut { get; set; }
        public TimeSpan? ApresMidiFin { get; set; }
        public int TotalHeures { get; set; }
    }
}