using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Identity;
using System.Security.Cryptography;

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
            .FirstOrDefault(u => u.Login == loginFromFlutter);

        if (user == null)
        {
            return Unauthorized();
        }

        var hashpwd = user.Pwd;
        if (string.IsNullOrWhiteSpace(hashpwd))
        {
            return BadRequest();
        }

        //get the saved string 
        string savedPassword = hashpwd.ToString();

        //turn it into bytes
        byte[] hashBytes = Convert.FromBase64String(savedPassword);

        //take the salt out of the string 
        byte[] salt = new byte[16];
        Array.Copy(hashBytes, 0, salt, 0, 16);

        //hash teh user inputted PW with the salt 
        var pbkdf2 = new Rfc2898DeriveBytes(pwdFromFlutter, salt, 10000);

        //put the hashed input in a byte array so we can compare it byte-by-byte
        byte[] hash = pbkdf2.GetBytes(20);


        //compare redults! byte-by-byte
        //starting from 16 in the stored array cause 0-15 are the salt there
        int ok =  1;
        for (int i = 0; i < 20; i++)
        {
            if (hashBytes[i + 16] != hash[i])
            {
                ok = 0;
            }
            //if there are no diffreneces between the strings, grant access 
        }
        if (ok == 0)
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
        if (string.IsNullOrWhiteSpace(role))
        {
            return NotFound();
        }

        // created object of the  LoginResponseDto and passsed the info i want 
        var response = new LoginResponseDto
        {

            Id_Utilisateur = user.Id_Utilisateur,
            Nom = user.Nom ?? string.Empty,
            Prenom = user.Prenom ?? string.Empty,
            Role = role,
        };

        return Ok(response);
    }
}
