using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PFMPManager.Api.Models
{
    [Table("Planning")]
    public class Planning
    {
        [Key]
        [Column("Id_Planning")]
        public int Id_Planning { get; set; }
       

        [Column("TotalHebdo")] 
        public int TotalHebdo { get; set; }
       


    }
}