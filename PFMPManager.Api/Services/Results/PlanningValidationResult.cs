using PFMPManager.Api.DTOs;
namespace PFMPManager.Api.Services.Results
{
    // Stores the result of PFMP planning validation
     public class PlanningValidationResult
        {
            public string? ErrorMessage { get; set; }
            public int CalculatedWeeklyTotal { get; set; }
            public List<CreatePlanningJoursDto> ValidPlanningDays { get; set; } = new();
        }
}