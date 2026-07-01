using PFMPManager.Api.DTOs;
using PFMPManager.Api.Services.Results;
namespace PFMPManager.Api.Services
{
    public class PlanningValidationService : IPlanningValidationService
    {
        public PlanningValidationResult ValidatePlanningDays(List<CreatePlanningJoursDto>? planningDays, int? requestedWeeklyTotal)
        {
            var result = new PlanningValidationResult();
            if (planningDays == null || !planningDays.Any())
            {
                result.ErrorMessage = "Le planning est obligatoire";
                return result;
            }
            foreach (var planningDay in planningDays)
            {

                var planningDayError = GetPlanningDayValidationError(planningDay);
                if (planningDayError != null)
                {
                    result.ErrorMessage = planningDayError;
                    return result;
                }
                if (IsPlanningDayEmpty(planningDay))
                {
                    continue;
                }
                int dayMinutes = CalculatePlanningDayMinutes(planningDay);
                if (dayMinutes != planningDay.TotalHeures)
                {
                    result.ErrorMessage = "Le total des heures du jour ne correspond pas au planning";
                    return result;
                }
                result.CalculatedWeeklyTotal += dayMinutes;
                result.ValidPlanningDays.Add(CreateValidatedPlanningDay(planningDay));
            }

            if (IsWeeklyTotalInvalid(result.CalculatedWeeklyTotal, requestedWeeklyTotal))
            {
                result.ErrorMessage = "Le total hebdomadaire du planning est invalide";
                return result;
            }
            if (!result.ValidPlanningDays.Any())
            {
                result.ErrorMessage = "Le planning doit contenir au moins un jour valide";
                return result;
            }
            return result;
        }

       

        private string? GetPlanningDayValidationError(CreatePlanningJoursDto planningDay)
        {
            if (string.IsNullOrWhiteSpace(planningDay.Jour))
            {
                return "Le jour est obligatoire.";
            }

            bool matinIncomplete = IsTimeSlotIncomplete(planningDay.MatinDebut, planningDay.MatinFin);
            bool midiIncomplete = IsTimeSlotIncomplete(planningDay.ApresMidiDebut, planningDay.ApresMidiFin);

            if (IsPlanningDayEmpty(planningDay))
            {
                return null;
            }

            if (matinIncomplete)
            {
                return $"le matin du jour {planningDay.Jour} est incomplet";
            }
            if (midiIncomplete)
            {
                return $"le apres-midi du jour {planningDay.Jour} est incomplet";
            }

            if (IsTimeSlotOrderInvalid(planningDay.MatinDebut, planningDay.MatinFin))
            {
                return $"pour {planningDay.Jour} l'heure de debut du matin doit etre avant l'heure de fin ";
            }
            if (IsTimeSlotOrderInvalid(planningDay.ApresMidiDebut, planningDay.ApresMidiFin))
            {
                return $"pour {planningDay.Jour} l'heure de debut de l'apres-midi doit etre avant l'heure de fin ";
            }
            if (IsMorningOverlappingAfternoon(planningDay.MatinFin, planningDay.ApresMidiDebut))
            {
                return $"Pour {planningDay.Jour}, le matin ne peut pas finir apres le debut de l'apres-midi";
            }
            return null;
        }
        private bool IsTimeSlotComplete(TimeSpan? start, TimeSpan? end)
        {
            return start != null && end != null;
        }
        private bool IsTimeSlotEmpty(TimeSpan? start, TimeSpan? end)
        {
            return start == null && end == null;
        }
        private bool IsTimeSlotIncomplete(TimeSpan? start, TimeSpan? end)
        {
            return !IsTimeSlotEmpty(start, end) && !IsTimeSlotComplete(start, end);
        }

        private int CalculateTimeSlotMinutes(TimeSpan? start, TimeSpan? end)
        {
            if (!start.HasValue || !end.HasValue)
            {
                return 0;
            }
            var duration = end.Value - start.Value;
            return (int)duration.TotalMinutes;
        }

        private bool IsTimeSlotOrderInvalid(TimeSpan? start, TimeSpan? end)
        {
            if (!IsTimeSlotComplete(start, end))
            {
                return false;
            }
            return start!.Value >= end!.Value;
        }
        private int CalculatePlanningDayMinutes(CreatePlanningJoursDto planningDay)
        {
            return CalculateTimeSlotMinutes(planningDay.MatinDebut, planningDay.MatinFin) + CalculateTimeSlotMinutes(planningDay.ApresMidiDebut, planningDay.ApresMidiFin);
        }

        private bool IsMorningOverlappingAfternoon(TimeSpan? morningEnd, TimeSpan? afternoonStart)
        {
            if (!morningEnd.HasValue || !afternoonStart.HasValue)
            {
                return false;
            }
            return morningEnd.Value >= afternoonStart.Value;
        }
          private bool IsWeeklyTotalInvalid(int calculatedWeeklyTotal, int? requestedWeeklyTotal)
        {
            return calculatedWeeklyTotal != requestedWeeklyTotal || calculatedWeeklyTotal <= 0 || calculatedWeeklyTotal > 2100;
        }

        private bool IsPlanningDayEmpty(CreatePlanningJoursDto planningDay) {
            return IsTimeSlotEmpty(planningDay.MatinDebut, planningDay.MatinFin) && IsTimeSlotEmpty(planningDay.ApresMidiDebut, planningDay.ApresMidiFin);

        }
                private CreatePlanningJoursDto CreateValidatedPlanningDay(CreatePlanningJoursDto planningDay)
        {

            return new CreatePlanningJoursDto
            {
                Jour = planningDay.Jour,
                MatinDebut = planningDay.MatinDebut,
                MatinFin = planningDay.MatinFin,
                ApresMidiDebut = planningDay.ApresMidiDebut,
                ApresMidiFin = planningDay.ApresMidiFin,
                TotalHeures = planningDay.TotalHeures
            };
        }

   }
}