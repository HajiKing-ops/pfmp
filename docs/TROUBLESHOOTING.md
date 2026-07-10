# Troubleshooting

Common problems when setting up or running PFMP Manager, plus a checklist for
verifying a deployment end-to-end.

## Post-deploy verification checklist

Run through this after starting the full stack for the first time, or after
any change to authentication:

1. API container starts.
2. MySQL container reports healthy (`docker compose ps`).
3. OpenAPI JSON responds at `/openapi/v1.json`.
4. Login succeeds.
5. Cookies are set: `AccessToken`, `RefreshToken`, `Fgp`.
6. A protected endpoint works with cookies and no `Authorization` header.
7. The same endpoint fails without cookies.
8. A missing or incorrect `Fgp` cookie is rejected.
9. `/api/login/refresh` rotates the refresh token.
10. Logout clears all three auth cookies.
11. A student cannot read another student's data.
12. Admin-only endpoints reject a student session.
13. Attendance updates validate both role and date.
14. Messages only work between users tied to the same PFMP.
15. Flutter Web can call the API with credentials from an actual browser, not
    just from inside the Docker network.

## Common problems

### CORS error: "No 'Access-Control-Allow-Origin' header"

- Add the frontend's exact origin to the API's CORS policy.
- Make sure `.AllowCredentials()` is set.
- Never combine `AllowCredentials()` with `AllowAnyOrigin()` — it's invalid
  for credentialed requests and the browser will reject it.

### Login succeeds, but the next request returns 401

- Flutter Web isn't using a credentialed client — confirm
  `BrowserClient()..withCredentials = true`.
- Cookies are being blocked by `SameSite`/`Secure` settings.
- The frontend's origin isn't in the API's allowed CORS origins.
- The frontend and API are being reached through different hosts than
  expected (e.g. one via `localhost`, the other via a LAN IP).

### Cookies are rejected

Check, in order: `SameSite`, `Secure`, HTTP vs HTTPS, cookie domain, port, and
frontend origin. Local HTTP development typically needs `Secure=false`;
production over HTTPS needs `Secure=true`.

### MySQL data disappeared

Most likely cause: `docker compose down -v`, which deletes volumes. Restore
from a backup or recreate the external volume — see
[MySQL backup & restore](DATABASE_BACKUP.md).

### API can't connect to MySQL

- API running **inside** Docker → use `server=mysql;port=3306;...`.
- API running **locally** (outside Docker) → use
  `server=localhost;port=3307;...` (or whatever `MYSQL_PORT` is set to).

### Docker says the volume doesn't exist

```bash
docker volume create docker-test_mysql_data
```

### `flutter run -d chrome` can't reach `/api`

The Flutter dev server does not proxy `/api` to the backend automatically —
only the Dockerized Nginx setup does that. Either run the full stack with
Docker, or set up a local reverse proxy for `/api` while developing with
`flutter run`. See [05 - Flutter frontend guide](05-frontend-guide.md).

### `PUT /api/presence/modify` returns 404 or 405

This endpoint doesn't exist on the backend. The frontend's attendance service
is expected to fall back to `PUT /api/presence/update/{idEtudiant}` after
this call fails — if it doesn't, that fallback logic itself may be broken.
See [04 - Backend API](04-backend-api.md).

## See also

- [09 - Development workflow](09-development-workflow.md)
- [10 - Testing checklist](10-testing-checklist.md)
- [07 - Authentication and security](07-authentication-security.md)
