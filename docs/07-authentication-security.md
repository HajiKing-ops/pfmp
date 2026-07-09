# 07 - Authentication and Security

## Summary

PFMP Manager uses JWT authentication with HttpOnly cookies:

- `AccessToken`: short-lived JWT access token;
- `RefreshToken`: long-lived token, stored raw only in the browser cookie and hashed in the database;
- `Fgp`: session fingerprint cookie.

The Flutter frontend does not read the JWT directly. It uses `BrowserClient()..withCredentials = true`, so the browser sends cookies automatically.

## Login Flow

Endpoint:

```text
POST /api/login
```

Flow:

1. The frontend sends `login` and `pwd`.
2. The API finds `Utilisateur.Login`.
3. `PasswordHelper.VerifyPassword` validates the PBKDF2 password hash.
4. `RoleService` resolves the application role.
5. `JwtHelper.CreateTokens` creates:
   - a JWT access token;
   - a raw refresh token;
   - a refresh token hash.
6. The API generates a fingerprint and stores only its hash.
7. The API sets HttpOnly cookies.
8. The API returns `LoginResponseDto`.

## Password Hashing

`PasswordHelper` uses:

- PBKDF2 with SHA-256;
- random 16-byte salt;
- 48-byte derived hash;
- 100,000 iterations;
- Base64 storage of salt plus hash.

## JWT Contents and Validation

`JwtHelper` adds these claims:

- `ClaimTypes.NameIdentifier`: user id;
- `ClaimTypes.Role`: application role;
- `ClaimTypes.Name`: login;
- `fingerprint_hash`: hash of the `Fgp` cookie.

Validation in `Program.cs` checks:

- issuer;
- audience;
- lifetime;
- signing key;
- zero clock skew;
- access token from the `AccessToken` cookie;
- fingerprint hash from the `Fgp` cookie against the JWT claim.

## Refresh Token Rotation

The refresh token:

- is generated randomly;
- is sent in an HttpOnly cookie;
- is stored hashed in the database;
- expires after 7 days in the current code;
- is rotated on refresh;
- belongs to a `TokenFamilyId`.

If a previously revoked refresh token is reused, the token family is revoked.

## Cookies

Current cookie settings:

| Cookie | HttpOnly | Secure currently | SameSite | Current lifetime |
| --- | --- | --- | --- | --- |
| `AccessToken` | Yes | `false` | `Strict` | 15 minutes |
| `RefreshToken` | Yes | `false` | `Strict` | 7 days |
| `Fgp` | Yes | `false` | `Strict` | 7 days |

`Secure = false` is suitable only for local HTTP development. A real HTTPS deployment should use secure cookies.

## Role-Based Access Control

The API uses `[Authorize]` and `[Authorize(Roles = "...")]`.

Examples:

- `Administrateur`: `/api/administrateur`, `/api/presence/initialiser`, `/api/utilisateur`;
- `Etudiant`: `/api/dashboard`, `/api/demarches`, `/api/journal`, `/api/pfmp/complete`;
- `Etudiant,Enseignant`: `/api/pfmp/recherche/{studentId}/{pfmpId?}`;
- `Enseignant,Administrateur`: `/api/presence/update/{studentId}`.

Some `[Authorize]` actions add their own business access checks, especially messaging.

## CORS

`Program.cs` defines the `AllowFlutterWeb` policy with:

```text
http://localhost:65427
```

and:

- `AllowAnyMethod`;
- `AllowAnyHeader`;
- `AllowCredentials`.

For credentialed browser requests, exact origins are required. Do not combine `AllowAnyOrigin()` with `AllowCredentials()`.

When Flutter is served through Docker/Nginx, `/api` calls are same-origin from the browser perspective, so CORS is less central for that mode.

## Nginx `/api` Proxy

`appli_pfmp/nginx.conf` proxies:

```text
/api/* -> http://api:8080/api/*
```

Benefits:

- the browser uses one origin;
- cookies are simpler to manage;
- the API does not need to be exposed directly in production-style mode;
- MySQL remains reachable only by the API.

## Secrets and `.env`

Rules:

- never commit `.env`;
- use `.env.example` only as a safe template;
- use a strong, random `JWT_SECRET`;
- do not document real local secrets.

`.env` is ignored by `.gitignore`.

## Security Risks and TODOs

| Topic | Risk | Recommendation |
| --- | --- | --- |
| Cookies with `Secure=false` | Acceptable for local HTTP only | Use `Secure=true` with HTTPS. |
| HTTPS | Not configured as production-ready in this repository | Add HTTPS before real deployment. |
| Forwarded headers | No `UseForwardedHeaders` middleware was confirmed | Add it if HTTPS is terminated by Nginx or another proxy. |
| API exposure | Development config exposes the API port | Keep API internal in production-style mode. |
| MySQL exposure | Development config exposes MySQL for local use | Never expose MySQL publicly. |
| Database user | API uses `${MYSQL_USER}`/`${MYSQL_PASSWORD}`, but MySQL user creation is not confirmed in Compose | Verify user creation for a fresh volume. |
| Internship supervisor account | Temporary password `test1234` is created in backend code | Replace before production. |
| Profile endpoint | Frontend expects profile routes, but backend routing is unclear | Complete and protect profile endpoints. |
| Automated tests | No backend security tests are visible | Add auth, role, and access-scope tests. |

## Production Security Guidance

- Enable HTTPS.
- Use strong secrets outside Git.
- Do not expose MySQL.
- Do not expose the API directly if Nginx can proxy `/api`.
- Use a limited MySQL application user instead of root.
- Implement tested backups and restore procedures.
- Add structured logs and monitoring.
- Test `401` and `403` behavior for every role-sensitive endpoint.
