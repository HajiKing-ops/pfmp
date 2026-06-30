namespace PFMPManager.Api.Services
{
    public interface IPfmpAccessService
    {
       Task<string?> ValidateStudentPfmpAccessAsync(int currentUserId, int studentId, string role);
    }
}