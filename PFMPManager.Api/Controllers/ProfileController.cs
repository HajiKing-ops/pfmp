using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using Microsoft.AspNetCore.Authorization;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Services;
using Microsoft.AspNetCore.Identity;
using PFMPManager.Api.Models;
using System.Net;



[ApiController]
[Route("api/profile")]
public class ProfileController : ControllerBase
{
    private readonly AppDbContext _context; // Database context injected by DI
     private readonly ICurrentUserService _currentUserService;

    //Dependencies are injected by the ASP.NET Core DI container
    public ProfileController(AppDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }
    public async Task<IActionResult> ProfileMe()
    {
        var user = _currentUserService.GetCurrentUser(User);
        if(!user.Success)
        {
            return Unauthorized(user.ErrorMessage);
        }
        var userId = user.UserId;

        var userInfo = await _context.Utilisateur.AsNoTracking().FirstOrDefaultAsync(u=> u.Id_Utilisateur == userId);
        if (userInfo == null)
        return NotFound();

        var studentInfo = await _context.Etudiant.AsNoTracking().FirstOrDefaultAsync(s=> s.Id_Utilisateur_1 == userId);
        var today = DateTime.Today.Year;
        var etablissement = await (from e in _context.Etudier
                              join c in _context.GroupeClasse
                              on new { e.Id_Etablissement, e.Id_Classe }
                              equals new { c.Id_Etablissement, c.Id_Classe }
                              join et in _context.Etablissement
                              on c.Id_Etablissement equals et.Id_Etablissement
                              join  f in _context.Filiere 
                              on c.Id_Filiere equals f.Id_Filiere
                              where e.Id_Utilisateur == userId && e.AnneeRentree <= today && e.AnneeSortie >= today
                              select new {f.LibelleFiliere, et.NomEtablissement})
                              .FirstOrDefaultAsync();
        var dto = new ProfileMeDto
        {
            Prenom = userInfo.Prenom,
            Nom = userInfo.Nom,
            DateNaissance = studentInfo.Date_Naissance,
            Niveau = etablissement.LibelleFiliere,
            Filiere = etablissement.LibelleFiliere,
            Etablissement = etablissement.NomEtablissement,
        };
        return Ok(dto);
    }

    
}