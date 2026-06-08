using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt; // create/writes JWT
using System.Security.Claims; // creates  claims 
using Microsoft.IdentityModel.Tokens; // signing key and credentials
using System.Text; //converts secret key text to bytes
using PFMPManager.Api.Helpers;



[ApiController]
[Route("api/login")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)
    private readonly IConfiguration _configuration;

    //DI container injects AppDbContext registered om program.cs
    public AuthController(AppDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
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

        bool ok = PasswordHelper.VerifyPassword(hashpwd, pwdFromFlutter);
        if (!ok)
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
            return NotFound("Role not found");
        }

        var jwtKey = _configuration["Jwt:Key"];
        var jwtIssuer = _configuration["Jwt:Issuer"];
        var jwtAudience = _configuration["Jwt:Audience"];
        var jwtExpiration = int.Parse(_configuration["Jwt:ExpireMinutes"]!); // ! promis this is not null

        var expires = DateTime.UtcNow.AddMinutes(jwtExpiration);

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id_Utilisateur.ToString()), // inside the token, store the user ID
            new Claim(ClaimTypes.Role, role),
            new Claim(ClaimTypes.Name, user.Login!),
        };

        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtKey!)); //convert the secret key string into bytes and ! -> promis this value is not null

        var credentials = new SigningCredentials( // use the HMAC ShA-256 algoritm to sign the token 
            key,
            SecurityAlgorithms.HmacSha256
        );

        var token = new JwtSecurityToken // crea5te token object
        (
            issuer: jwtIssuer,
            audience: jwtAudience,
            claims: claims,
            expires: expires,
            signingCredentials: credentials
        );

        var tokenString = new JwtSecurityTokenHandler().WriteToken(token); // take my token and transform it into the final token text 

        // created object of the  LoginResponseDto and passsed the info i want 
        var response = new LoginResponseDto
        {

            Token = tokenString,
            Id_Utilisateur = user.Id_Utilisateur,
            Nom = user.Nom ?? string.Empty,
            Prenom = user.Prenom ?? string.Empty,
            Role = role,
        };

        return Ok(response);
    }
}
