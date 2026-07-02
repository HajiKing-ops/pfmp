namespace PFMPManager.Api.DTOs
{
    // Represents one day of a weekly PFMP planning
    public class CreatePlanningJoursDto
    {
        public string? Jour { get; set; }
        public TimeSpan? MatinDebut { get; set; }
        public TimeSpan? MatinFin { get; set; }
        public TimeSpan? ApresMidiDebut { get; set; }
        public TimeSpan? ApresMidiFin { get; set; }
        public int TotalMinutes  { get; set; }
    }
}