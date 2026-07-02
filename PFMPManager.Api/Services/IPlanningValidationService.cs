using PFMPManager.Api.DTOs;
using PFMPManager.Api.Services.Results;
namespace PFMPManager.Api.Services
{
     // Defines validation rules for PFMP weekly planning data
    public interface IPlanningValidationService
    {
        PlanningValidationResult ValidatePlanningDays(List<CreatePlanningJoursDto>? planningDays, int? requestedWeeklyTotal);
    }
}