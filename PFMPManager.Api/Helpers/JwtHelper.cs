using System.IdentityModel.Tokens.Jwt; // Creates and writes JWT tokens 
using System.Security.Claims; // Provides JWT cliams
using System.Security.Cryptography;
using System.Text; //converts secret key text to bytes
using Microsoft.IdentityModel.Tokens;


namespace PFMPManager.Api.Helpers
{
    //Helper methods for creating JWTs, refresh tokens and session fingerprints
    public static class JwtHelper
    {

        //Create the access token, raw refresh token and hashed refresh token
        public static (string refreshTokenHash, string accessToken, string refreshToken) CreateTokens(IConfiguration configuration, int id_Utilisateur, string role, string login,string fingerprintHash)
        {
            //Create claims stored inside the access token 
            var claims = new List<Claim>
            {
            new Claim(ClaimTypes.NameIdentifier, id_Utilisateur.ToString()), // store the user id
            new Claim(ClaimTypes.Role, role), // Store the user role for authorization 
            new Claim(ClaimTypes.Name, login!), // Store the user login
            new Claim("fingerprint_hash", fingerprintHash) // bind the JWT to the Fgp cookie
            };

            var accessToken = GenerateAccessToken(configuration , claims); // Create the JWT access

            var refreshToken = GenerateSecureRandomString(); // Generate the raw refresh token 

            var refreshTokenHash = HashRefreshToken(refreshToken); // Hash before saving in the database

            return (refreshTokenHash, accessToken, refreshToken); // return the hash for storage and the raw token for the HttpOnly cookie

        }

        public static string GenerateAccessToken(IConfiguration configuration ,List<Claim> claims)
        {
            //Read JWT settings from configuration
            var jwtKey = configuration["Jwt:Key"];
            var jwtIssuer = configuration["Jwt:Issuer"];
            var jwtAudience = configuration["Jwt:Audience"];
            var jwtExpiration = int.Parse(configuration["Jwt:ExpireMinutes"]!);

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(jwtKey!));

            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256); //Sign the token with HMAC-SHA256

            var token = new JwtSecurityToken(
                issuer: jwtIssuer,
                audience: jwtAudience,
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(jwtExpiration),
                signingCredentials: credentials
                );
            return new JwtSecurityTokenHandler().WriteToken(token); // Serialize the JWT to a string
        }

        // Generate a cryptographically secure 
  
        public static string GenerateSecureRandomString()
        {
            var randomBytes = new byte[64];

            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomBytes);

            return Convert.ToBase64String(randomBytes);
        }
        // Hash the refresh token before database comparison or storage
        public static string HashRefreshToken(string refreshToken)
        {
            using var sha256 = SHA256.Create();

            var tokenBytes = Encoding.UTF8.GetBytes(refreshToken);
            var hashBytes = sha256.ComputeHash(tokenBytes);

            return Convert.ToBase64String(hashBytes);
        }
        //Hash the fingerprint before comparing it with the JWT claim
        public static string HashFingerprint(string fingerprint)
        {
            using var sha256 = SHA256.Create();

            var tokenBytes = Encoding.UTF8.GetBytes(fingerprint);
            var hashBytes = sha256.ComputeHash(tokenBytes);

            return Convert.ToBase64String(hashBytes);
        }


    }

}