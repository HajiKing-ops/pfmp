using System.Security.Cryptography;

namespace PFMPManager.Api.Helpers
{
    public static class PasswordHelper
    {
        private const int SaltSize = 16;
        private const int HashSize = 48;
        private const int Iteration = 100000;

        public static string HashPassword(string pwd)
        {
            
                
            // hashing  and stuff 
            //make a new byte array  
            byte[] salt  = new byte[SaltSize];
            //generate salt 
            RandomNumberGenerator.Fill(salt);

            //hash and salt it using PBKDF2
            var pbkdf2 = new Rfc2898DeriveBytes(pwd, salt, Iteration, HashAlgorithmName.SHA256);

            //place the string in the byte array (thats what getbytes does)
            byte[] hash = pbkdf2.GetBytes(HashSize);

            //make new byte array where to store the hashed password+salt
            //why 64? cause 48 are for the hash and 16 for the salt 
            byte[] hashBytes = new byte[64];

            //place the hash and salt in their  respective places 
            Array.Copy(salt, 0, hashBytes, 0, SaltSize);
            Array.Copy(hash, 0, hashBytes, SaltSize, HashSize);

            //now, convert our fancy byte array to a string 
            string savedPasswordHash = Convert.ToBase64String(hashBytes);
                
            return savedPasswordHash;

        }

        public static bool VerifyPassword(string storedHash, string pwdFromFlutter)
        {

            //get the saved string 
            string savedPassword = storedHash.ToString();

            //turn it into bytes
            byte[] hashBytes = Convert.FromBase64String(savedPassword);

            //take the salt out of the string 
            byte[] salt = new byte[SaltSize];
            Array.Copy(hashBytes, 0, salt, 0, SaltSize);

            //hash teh user inputted PW with the salt 
            var pbkdf2 = new Rfc2898DeriveBytes(pwdFromFlutter, salt, Iteration, HashAlgorithmName.SHA256);

            //put the hashed input in a byte array so we can compare it byte-by-byte
            byte[] hash = pbkdf2.GetBytes(HashSize);


            //compare redults! byte-by-byte
            //starting from 16 in the stored array cause 0-15 are the salt there
            bool ok = true;
            for (int i = 0; i< HashSize; i++)
                if (hashBytes[i + SaltSize] != hash[i])
                    ok = false;

            return ok;
        }
    }
    
}