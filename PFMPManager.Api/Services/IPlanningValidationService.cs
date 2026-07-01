using PFMPManager.Api.DTOs;
using PFMPManager.Api.Services.Results;
namespace PFMPManager.Api.Services
{
    public interface IPlanningValidationService
    {
        PlanningValidationResult ValidatePlanningDays(List<CreatePlanningJoursDto>? planningDays, int? requestedWeeklyTotal);
    }
}