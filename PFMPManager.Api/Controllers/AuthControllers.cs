using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Mvc;


[ApiController]
[Route("api/login")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)

    //DI container injects AppDbContext registered om program.cs
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

        //verify the Role
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

        // created object of the  LoginResponseDto and passsed the info i want 
        var response = new LoginResponseDto
        {

            Id_Utilisateur = user.Id_Utilisateur,
            Nom = user.Nom ??  string.Empty,
            Prenom = user.Prenom ??  string.Empty ,
            Login = user.Login ?? string.Empty ,
            Role = role
        };

        return Ok(response);
        }
    }
