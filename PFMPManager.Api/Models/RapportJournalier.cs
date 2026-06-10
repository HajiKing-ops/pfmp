using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
	[Table("RapportJournalier")]
	public class RapportJournalier
	{
		[Key]
		[Column("Id_RapportJournalier")]
		public int Id_RapportJournalier { get; set; }
		// { get; set; } � EF Core reads this to save to DB, writes this when fetching from DB
		// = string.Empty  � default value is "" instead of null (avoids null warnings)
		// = string.Empty  � default value is "" instead of null (avoids null warnings)[]

		[Column("DateRapport")]
		public DateTime? DateRapport { get; set; }

		[Column("LienVersFichier")]
		public string LienVersFichier { get; set; } = string.Empty;
        public int Id_PFMP { get; set; } 


    }
}