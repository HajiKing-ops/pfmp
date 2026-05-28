using PFMPManager.Api.Data;
using PFMPManager.Api.Models;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Mvc;


[ApiController]
[Route("api/login")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;

    public AuthController(AppDbContext context)
    {
        _context = context;
    }

    [HttpPost]
    public IActionResult Login(LoginRequestDto request)
    {

        var loginFromFlutter = request.Login;
        var pwdFromFlutter = request.Pwd;



        if (string.IsNullOrWhiteSpace(loginFromFlutter) || string.IsNullOrWhiteSpace(pwdFromFlutter))
        {
            return BadRequest();
        }

        var user = _context.Utilisateur
            .FirstOrDefault(u => u.Login == loginFromFlutter && u.Pwd == pwdFromFlutter);

        if (user == null)
        {
            return Unauthorized();
        }
        string role = "";

        var student = _context.Etudiant
            .FirstOrDefault(u => u.Id_Utilisateur_1 == user.Id_Utilisateur);

        if (student != null)
        {
            role = "Etudiant";
        }
        else
        {
            var referent = _context.Referent
                .FirstOrDefault(u => u.Id_Utilisateur == user.Id_Utilisateur);
            if (referent != null)
            {
                role = "Enseignant";
            }
            else 
            {
                var administrateur = _context.Administrateur
                    .FirstOrDefault(u => u.Id_Utilisateur == user.Id_Utilisateur);
                if (administrateur != null)
                {
                    role = "Administrateur";
                }
                
            }


        }

        var response = new LoginResponseDto
        {

            Id_Utilisateur = user.Id_Utilisateur,
            Nom = user.Nom,
            Prenom = user.Prenom,
            Login = user.Login,
            Role = role
        };

        return Ok(response);
        }
    }
