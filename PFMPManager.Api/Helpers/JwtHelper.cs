using System.Security.Claims; // creates  claims 
using System.IdentityModel.Tokens.Jwt; // create/writes JWT
using System.Text; //converts secret key text to bytes
using Microsoft.IdentityModel.Tokens;
using System.Security.Cryptography;


namespace PFMPManager.Api.Helpers
{
    public static class JwtHelper
    {

        public static (string refreshTokenHash, string accessToken, string refreshToken) CreateTokens(IConfiguration configuration, int id_Utilisateur, string role, string login,string fingerprintHash)
        {
            var claims = new List<Claim>
            {
            new Claim(ClaimTypes.NameIdentifier, id_Utilisateur.ToString()), // inside the token, store the user ID
            new Claim(ClaimTypes.Role, role),
            new Claim(ClaimTypes.Name, login!),
            new Claim("fingerprint_hash", fingerprintHash)
            };

            var accessToken = GenerateAccessToken(configuration , claims); // creates the JWT access token. 

            var refreshToken = GenerateRefreshToken(); // creates a random secret string

            var refreshTokenHash = HashRefreshToken(refreshToken); // hashes the refresh token before saving it in database

            return (refreshTokenHash, accessToken, refreshToken);

        }

        public static string GenerateAccessToken(IConfiguration configuration ,List<Claim> claims)
        {
            var jwtKey = configuration["Jwt:Key"];
            var jwtIssuer = configuration["Jwt:Issuer"];
            var jwtAudience = configuration["Jwt:Audience"];
            var jwtExpiration = int.Parse(configuration["Jwt:ExpireMinutes"]!);

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey!));

            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: jwtIssuer,
                audience: jwtAudience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(jwtExpiration),
                signingCredentials: credentials
                );
            return new JwtSecurityTokenHandler().WriteToken(token); // turns it into text
        }

        // creates a random long secret string.
        public static string GenerateRefreshToken()
        {
            var randomBytes = new byte[64];

            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);

            return Convert.ToBase64String(randomBytes);
        }

        public static string GenerateFingerprint()
        {
            var randomBytes = new byte[64];

            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);

            return Convert.ToBase64String(randomBytes);
        }

        public static string HashRefreshToken(string refreshToken)
        {
            using var sha256 = SHA256.Create();

            var tokenBytes = Encoding.UTF8.GetBytes(refreshToken);
            var hashBytes = sha256.ComputeHash(tokenBytes);

            return Convert.ToBase64String(hashBytes);
        }

        public static string HashFingerprint(string fingerprint)
        {
            using var sha256 = SHA256.Create();

            var tokenBytes = Encoding.UTF8.GetBytes(fingerprint);
            var hashBytes = sha256.ComputeHash(tokenBytes);

            return Convert.ToBase64String(hashBytes);
        }

    }

}