namespace PFMPManager.Api.DTOs
{
	// Represents global PFMP statistics for the administrator dashboard
	public class AdminStageStatsDto
	{
		public int? StageTotal { get; set; }
		public int? Encours { get; set; }
		public int? Valide { get; set; }
		public int? AbsencesTotal { get; set; }

	}
}