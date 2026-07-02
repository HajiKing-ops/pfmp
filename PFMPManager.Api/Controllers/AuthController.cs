using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PFMPManager.Api.Data;
using PFMPManager.Api.DTOs;
using PFMPManager.Api.Helpers;
using PFMPManager.Api.Models;




[ApiController]
[Route("api")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context; // Database context injected by DI
    private readonly IConfiguration _configuration;
    private readonly IRoleService _roleService; 
    private const string FingerprintCookieName = "Fgp";
    private const string AccessTokenCookieName = "AccessToken";
    private const string RefreshTokenCookieName = "RefreshToken";

    //Dependencies are injected by the ASP.NET Core DI container
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

        //Validate required login fileds
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


        //Resolve the user's application role 
        var role = await _roleService.GetUserRoleAsync(user.Id_Utilisateur);

        if (string.IsNullOrWhiteSpace(role))
        {
            return NotFound("Role not found");
        }


        var tokenFamilyId = Guid.NewGuid().ToString(); // create a new refresh token family identifier 
        
        var fingerprint = JwtHelper.GenerateSecureRandomString(); // Generate a session fingerprint

        var fingerprintHash = JwtHelper.HashFingerprint(fingerprint); // Store only the fingerprint hash in tokens/database


        var (refreshTokenHash, accessToken, refreshToken) = JwtHelper.CreateTokens(_configuration , user.Id_Utilisateur, role, user.Login!, fingerprintHash); // Create access and refresh tokens for the authenticated user

        // Store authentication values in HttpOnly cookies
        StoreFingerprintCookie(fingerprint);
        StoreAccessTokenCookie(accessToken);
        StoreRefreshTokenCookie(refreshToken);

        //Save only the hashed refresh token in the database
        var refreshTokenEntity = new RefreshToken()
        {
            TokenHash = refreshTokenHash,
            Id_Utilisateur = user.Id_Utilisateur,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            RevokedAt = null,
            ReplacedByTokenHash = null,
            TokenFamilyId = tokenFamilyId,
            FingerprintHash = fingerprintHash,

        };
         _context.RefreshToken.Add(refreshTokenEntity);
        await _context.SaveChangesAsync();

        var response = new LoginResponseDto
        {
            Id_Utilisateur = user.Id_Utilisateur,
            Nom = user.Nom ?? string.Empty,
            Prenom = user.Prenom ?? string.Empty,
            Role = role,
        };

        return Ok(response);
    }




    [HttpPost("login/refresh")]

    public async Task<IActionResult> Refresh()
    {
        // Read the refresh token from the HttpOnly cookie
        var refreshToken = Request.Cookies[RefreshTokenCookieName];

        if(string.IsNullOrWhiteSpace(refreshToken))
        {
            return BadRequest("RefreshToken n'existe pas");
        }
        
        var refreshTokenHash = JwtHelper.HashRefreshToken(refreshToken); // Hash before database lookup

        //Find the matching refresh token record
        var search = await _context.RefreshToken.FirstOrDefaultAsync(r => r.TokenHash == refreshTokenHash);
        
        if (search == null)
        {
            return Unauthorized("Le jeton n'existe pas.");
        }
        // Revoke the token family if a rotated token is reused
        if (search.RevokedAt != null)
        {
            if (!string.IsNullOrWhiteSpace(search.TokenFamilyId))
            {
               await RevokeFamilyAsync(search.TokenFamilyId);

            }
            return Unauthorized("Ce jeton a deja ete utilise ou vous etes deconnecte");
        }

        if (!search.ExpiresAt.HasValue || search.ExpiresAt.Value <= DateTime.UtcNow)
        {
            return Unauthorized("L'utilisateur doit se reconnecter.");
        }


        // Load the user linked to the refresh token 
        var utilisateur = await _context.Utilisateur.FirstOrDefaultAsync(u => u.Id_Utilisateur == search.Id_Utilisateur);
        if (utilisateur == null)
        {
            return Unauthorized("Utilisateur introuvable");
        }
        
        var role = await _roleService.GetUserRoleAsync(utilisateur.Id_Utilisateur);

        if (string.IsNullOrWhiteSpace(role))
        {
            return Unauthorized("Role introuvable.");
        }

        // Validate the Fgp cookie against the stored fingerprint hash
        var fingerprint = Request.Cookies[FingerprintCookieName]; 

        if (string.IsNullOrWhiteSpace(fingerprint))
        {
            return Unauthorized("Fingerprint manquant");
        }
        var fingerprintHash = JwtHelper.HashFingerprint(fingerprint);
        if (!string.Equals(fingerprintHash, search.FingerprintHash, StringComparison.Ordinal))
        {
           await RevokeFamilyAsync(search.TokenFamilyId);

            return Unauthorized("Fingerprint invalide");
        }
        // Rotate the refresh token and create a new access token 
        var (newRefreshTokenHash, accessToken, newRefreshToken) = JwtHelper.CreateTokens( _configuration, utilisateur.Id_Utilisateur, role, utilisateur.Login!, fingerprintHash);


        search.RevokedAt = DateTime.UtcNow;
        search.ReplacedByTokenHash = newRefreshTokenHash;

        //Replace authentication cookies with the new tokens 
        StoreAccessTokenCookie(accessToken);
        StoreRefreshTokenCookie(newRefreshToken);

        //Store the new refresh token hash in the same token family
        var newRefreshTokenEntity = new RefreshToken
        {
            Id_Utilisateur = utilisateur.Id_Utilisateur,
            TokenHash = newRefreshTokenHash,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            RevokedAt = null,
            ReplacedByTokenHash = null,
            TokenFamilyId = search.TokenFamilyId,
            FingerprintHash = search.FingerprintHash
        };

        _context.RefreshToken.Add(newRefreshTokenEntity);
        await _context.SaveChangesAsync();

        var response = new LoginResponseDto
        {
            Id_Utilisateur = utilisateur.Id_Utilisateur,
            Nom = utilisateur.Nom ?? string.Empty,
            Prenom = utilisateur.Prenom ?? string.Empty,
            Role = role,
        };

        return Ok(response);

    }

    [HttpPost("logout")]

    public async Task<IActionResult> Logout()
    {
        // Read the refresh token from the HttpOnly cookie
        var refreshToken = Request.Cookies[RefreshTokenCookieName];

        if (string.IsNullOrWhiteSpace(refreshToken))
        {
            return BadRequest("RefreshToken n'existe pas");
        }
        
        var refreshTokenHash = JwtHelper.HashRefreshToken(refreshToken); // Hash before database lookup

        // Find the active refresh token record
        var search = await _context.RefreshToken.FirstOrDefaultAsync(r => r.TokenHash == refreshTokenHash);

        if (search == null)
        {
            return Unauthorized("Le jeton n'existe pas.");
        }

        // Reject already revoked refresh tokens
        if (search.RevokedAt != null)
        {
            return Unauthorized("Ce jeton a deja ete utilise ou vous etes deconnecte");
        }

        // Revoke the refresh  token and clear authentication cookies
        search.RevokedAt = DateTime.UtcNow;
        Response.Cookies.Delete(FingerprintCookieName);
        Response.Cookies.Delete(AccessTokenCookieName);
        Response.Cookies.Delete(RefreshTokenCookieName);


        await _context.SaveChangesAsync();
        return Ok("Vous etes deconnecte");

    }

    // Revoke all active refresh tokens in the same token family
    private async Task<int> RevokeFamilyAsync(string tokenFamilyId)
    {
        if (string.IsNullOrWhiteSpace(tokenFamilyId))
        {
            return 0;
        }
        var now = DateTime.UtcNow;

        return await _context.RefreshToken.Where(r => r.RevokedAt == null 
        && r.TokenFamilyId == tokenFamilyId)
       .ExecuteUpdateAsync(setters => setters
       .SetProperty(r => r.RevokedAt, now));
    }
    // Store the raw refresh token in an HttpOnly cookie

    private void StoreRefreshTokenCookie(string RefreshToken)
    {
        Response.Cookies.Append(RefreshTokenCookieName, RefreshToken, new CookieOptions
        {
            HttpOnly = true,
            Secure = false,
            SameSite = SameSiteMode.Strict,
            Expires = DateTimeOffset.UtcNow.AddDays(7)
        });
    }
   // Store the access token in an HttpOnly cookie
    private void StoreAccessTokenCookie(string accessToken)
    {
        Response.Cookies.Append(AccessTokenCookieName, accessToken, new CookieOptions
        {
            HttpOnly = true,
            Secure = false,
            SameSite = SameSiteMode.Strict,
            Expires = DateTimeOffset.UtcNow.AddMinutes(15)
        });
    }
    //  Store the session fingerprint in an HttpOnly cookie
    private void StoreFingerprintCookie(string fingerprint)
    {
        Response.Cookies.Append(FingerprintCookieName, fingerprint, new CookieOptions
        {
            HttpOnly = true,
            Secure = false,
            SameSite = SameSiteMode.Strict,
            Expires = DateTimeOffset.UtcNow.AddDays(7)
        });
    }



}


