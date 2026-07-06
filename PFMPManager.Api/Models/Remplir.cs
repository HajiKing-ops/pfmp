using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
	// Represents the relationship between a student and a daily report
	[Table("Remplir")]
	public class Remplir
	{

		[Column("Id_Utilisateur")]
		public int Id_Utilisateur { get; set; }
	
		[Column("Id_RapportJournalier")]
		public int Id_RapportJournalier { get; set; }
		

	}
}