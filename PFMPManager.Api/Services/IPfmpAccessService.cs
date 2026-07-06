namespace PFMPManager.Api.Services
{
    // Defines PFMP access validation rules for students and teachers
    public interface IPfmpAccessService
    {
       Task<string?> ValidateStudentPfmpAccessAsync(int currentUserId, int studentId, string role);
    }
}