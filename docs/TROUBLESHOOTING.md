# Troubleshooting

This guide lists common issues when setting up or running PFMP Manager.

## Post-Deploy Verification Checklist

Run this after starting the full stack for the first time, or after any authentication or proxy change.

1. API container starts.
2. MySQL container is healthy (`docker compose ps`).
3. OpenAPI JSON responds at `/openapi/v1.json` in `Development`.
4. Login succeeds.
5. Cookies are set: `AccessToken`, `RefreshToken`, `Fgp`.
6. A protected endpoint works with cookies and no `Authorization` header.
7. The same endpoint fails without cookies.
8. A missing or incorrect `Fgp` cookie is rejected.
9. `/api/login/refresh` rotates the refresh token.
10. Logout clears or invalidates the authentication cookies.
11. A student cannot read another student's data.
12. Admin-only endpoints reject a student session.
13. Attendance updates validate both role and PFMP date.
14. Messages only work for users tied to the same active PFMP.
15. Flutter Web can call the API with credentials from a real browser.

## Common Problems

### CORS error: "No 'Access-Control-Allow-Origin' header"

- Add the frontend's exact origin to the API CORS policy.
- Make sure `.AllowCredentials()` is set.
- Do not combine `AllowCredentials()` with `AllowAnyOrigin()`.

### Login succeeds, but the next request returns 401

- Confirm the frontend uses `BrowserClient()..withCredentials = true`.
- Check cookie `SameSite` and `Secure` settings.
- Check that the frontend origin is allowed by CORS when not using the Nginx same-origin `/api` proxy.
- Make sure the frontend and API are reached through the expected hostnames.

### Cookies are rejected

Check:

- `SameSite`;
- `Secure`;
- HTTP vs HTTPS;
- cookie domain;
- host and port;
- frontend origin.

Local HTTP development usually needs `Secure=false`. HTTPS production should use `Secure=true`.

### MySQL data disappeared

Most likely cause: `docker compose down -v`, which deletes volumes.

Restore from a backup or recreate the external volume:

```bash
docker volume create docker-test_mysql_data
```

See [DATABASE_BACKUP.md](DATABASE_BACKUP.md).

### API cannot connect to MySQL

- API running inside Docker: use `server=mysql;port=3306;...`.
- API running locally outside Docker: use `server=localhost;port=3307;...` or the configured `MYSQL_PORT`.
- To verify: ensure the application MySQL user exists if using `${MYSQL_USER}` and `${MYSQL_PASSWORD}`.

### Docker says the volume does not exist

```bash
docker volume create docker-test_mysql_data
```

### `/api` calls fail when using `flutter run`

The Docker Nginx proxy handles `/api` calls, but the Flutter development server does not automatically proxy them.

Options:

- run the Docker frontend;
- add a local development proxy;
- temporarily adjust frontend/API routing for local development.
