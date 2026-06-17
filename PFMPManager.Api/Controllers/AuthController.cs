using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Models;
using Microsoft.AspNetCore.Mvc;
using PFMPManager.Api.Helpers;
using Microsoft.EntityFrameworkCore;




[ApiController]
[Route("api")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context; // Database context injected via DI (Dependency Injection)
    private readonly IConfiguration _configuration;
    private readonly IRoleService _roleService;

    //DI container injects AppDbContext registered om program.cs
    public AuthController(AppDbContext context, IConfiguration configuration, IRoleService roleService)
    {
        _context = context;
        _configuration = configuration;
        _roleService = roleService;
    }


    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequestDto request)
    {

        var loginFromFlutter = request.Login;
        var pwdFromFlutter = request.Pwd;

        if (string.IsNullOrWhiteSpace(loginFromFlutter) || string.IsNullOrWhiteSpace(pwdFromFlutter))
        {
            return BadRequest();
        }

        var user = await _context.Utilisateur
            .FirstOrDefaultAsync(u => u.Login == loginFromFlutter);

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
        var role = await _roleService.GetUserRoleAsync(user.Id_Utilisateur);



        if (string.IsNullOrWhiteSpace(role))
        {
            return NotFound("Role not found");
        }


        var (refreshTokenHash, accessToken, refreshToken) = JwtHelper.CreateTokens(_configuration , user.Id_Utilisateur, role, user.Login);

        var refreshTokenEntity = new RefreshToken()
        {
            TokenHash = refreshTokenHash,
            Id_Utilisateur = user.Id_Utilisateur,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            RevokedAt = null,
            ReplacedByTokenHash = null
        };
         _context.RefreshToken.Add(refreshTokenEntity);
        await _context.SaveChangesAsync();

      
          
        var response = new LoginResponseDto
        {
            RefreshToken = refreshToken,
            AccessToken = accessToken,
            Id_Utilisateur = user.Id_Utilisateur,
            Nom = user.Nom ?? string.Empty,
            Prenom = user.Prenom ?? string.Empty,
            Role = role,
        };

        return Ok(response);
    }




    [HttpPost("login/refresh")]

    public async Task<IActionResult> Refresh(RefreshRequestDto request)
    { 
        if(string.IsNullOrWhiteSpace(request.RefreshTokenHash))
        {
            return BadRequest("RefreshToken n'existe pas");
        }
        var refreshTokenHash = JwtHelper.HashRefreshToken(request.RefreshTokenHash);

        var search = await _context.RefreshToken.FirstOrDefaultAsync(r => r.TokenHash == refreshTokenHash);

        if (search == null)
        {
            return Unauthorized("Le jeton n'existe pas.");
        }
        if (search.RevokedAt != null)
        {
            return Unauthorized("Ce jeton a d�j� �t� utilis� ou vous �tes d�connect�");
        }
        if (!search.ExpiresAt.HasValue || search.ExpiresAt.Value <= DateTime.UtcNow)
        {
            return Unauthorized("L'utilisateur doit se reconnecter.");
        }



        var utilisateur = await _context.Utilisateur.FirstOrDefaultAsync(u => u.Id_Utilisateur == search.Id_Utilisateur);
        if (utilisateur == null)
        {
            return Unauthorized("Utilisateur introuvable");
        }

        var role = await _roleService.GetUserRoleAsync(utilisateur.Id_Utilisateur);

        if (string.IsNullOrWhiteSpace(role))
        {
            return Unauthorized("R�le introuvable.");
        }

        var (newRefreshTokenHash, accessToken, newRefreshToken) = JwtHelper.CreateTokens( _configuration, utilisateur.Id_Utilisateur, role, utilisateur.Login);


        search.RevokedAt = DateTime.UtcNow;
        search.ReplacedByTokenHash = newRefreshTokenHash;


        var newRefreshTokenEntity = new RefreshToken
        {
            Id_Utilisateur = utilisateur.Id_Utilisateur,
            TokenHash = newRefreshTokenHash,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            RevokedAt = null,
            ReplacedByTokenHash = null
        };

        _context.RefreshToken.Add(newRefreshTokenEntity);
        await _context.SaveChangesAsync();

        var response = new LoginResponseDto
        {
            RefreshToken = newRefreshToken,
            AccessToken = accessToken,
            Id_Utilisateur = utilisateur.Id_Utilisateur,
            Nom = utilisateur.Nom ?? string.Empty,
            Prenom = utilisateur.Prenom ?? string.Empty,
            Role = role,
        };

        return Ok(response);

    }

    [HttpPost("logout")]

    public async Task<IActionResult> Logout(RefreshRequestDto request)
    {
        if (string.IsNullOrWhiteSpace(request.RefreshTokenHash))
        {
            return BadRequest("RefreshToken n'existe pas");
        }
        var refreshTokenHash = JwtHelper.HashRefreshToken(request.RefreshTokenHash);

        var search = await _context.RefreshToken.FirstOrDefaultAsync(r => r.TokenHash == refreshTokenHash);

        if (search == null)
        {
            return Unauthorized("Le jeton n'existe pas.");
        }
        if (search.RevokedAt != null)
        {
            return Unauthorized("Ce jeton a d�j� �t� utilis� ou vous �tes d�connect�");
        }

        search.RevokedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return Ok("Vous �tes d�connect�");

    }


}
