using System.Security.Cryptography;

namespace PFMPManager.Api.Helpers
{
    // Provides password hashing and verification using PBKDF2
    public static class PasswordHelper
    {
        private const int SaltSize = 16;
        private const int HashSize = 48;
        private const int Iteration = 100000;

        public static string HashPassword(string pwd)
        {
            
            // Generate a random salt for this password
            byte[] salt  = new byte[SaltSize];
            RandomNumberGenerator.Fill(salt);

            // Derive the password hash using PBKDF2 with SHA-256
            var pbkdf2 = new Rfc2898DeriveBytes(pwd, salt, Iteration, HashAlgorithmName.SHA256);

            byte[] hash = pbkdf2.GetBytes(HashSize);
            
            // Store salt and hash together before converting to Base64
            byte[] hashBytes = new byte[64];

            Array.Copy(salt, 0, hashBytes, 0, SaltSize);
            Array.Copy(hash, 0, hashBytes, SaltSize, HashSize);

            string savedPasswordHash = Convert.ToBase64String(hashBytes);
                
            return savedPasswordHash;

        }

        public static bool VerifyPassword(string storedHash, string pwdFromFlutter)
        {

            string savedPassword = storedHash.ToString();

            // Decode the stored Base64 password hash
            byte[] hashBytes = Convert.FromBase64String(savedPassword);

            // Extract the original salt from the stored hash
            byte[] salt = new byte[SaltSize];
            Array.Copy(hashBytes, 0, salt, 0, SaltSize);

            // Hash the provided password using the original salt
            var pbkdf2 = new Rfc2898DeriveBytes(pwdFromFlutter, salt, Iteration, HashAlgorithmName.SHA256);

            byte[] hash = pbkdf2.GetBytes(HashSize);
            
            // Compare the stored hash with the newly generated hash
            bool ok = true;
            for (int i = 0; i< HashSize; i++)
                if (hashBytes[i + SaltSize] != hash[i])
                    ok = false;

            return ok;
        }
    }
    
}