# Nginx Reverse Proxy (Flutter Web)

`appli_pfmp/nginx.conf` configures the Nginx container for the `flutter_web` service. It serves the Flutter Web build and proxies relative API calls.

## SPA fallback

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

Flutter Web is a single-page app. If the user refreshes a route, Nginx serves `index.html`.

## API proxy

```nginx
location /api/ {
    proxy_pass http://api:8080/api/;
    proxy_http_version 1.1;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

The Flutter frontend currently uses relative URLs such as:

```text
/api/login
/api/dashboard
/api/messages/{idPfmp}
```

In Docker, these calls reach Nginx first, and are then forwarded to the `api` Compose service on internal port `8080`.

## Why this proxy is useful

- The browser calls the same origin as the Flutter application.
- The `AccessToken`, `RefreshToken`, and `Fgp` cookies stay scoped to that single origin.
- The API does not need to be exposed directly in production-style mode.
- CORS issues are reduced for the Dockerized frontend.

## Ports by mode

Docker development:

```text
Browser -> http://localhost:${FLUTTER_PORT}
Nginx   -> http://api:8080/api/
```

Local production-style:

```text
Browser -> http://localhost
Nginx   -> http://api:8080/api/
```

## Important note for Flutter outside Docker

If the application is launched with:

```bash
flutter run -d chrome --web-port 65427
```

then the Flutter dev server does not automatically proxy `/api` to ASP.NET Core. You therefore need to set up a local proxy or adapt the development configuration.

## Production TODO

- Add/verify `ForwardedHeaders` in the API if Nginx or another reverse proxy terminates HTTPS.
- Switch cookies to `Secure=true` under HTTPS.
- Do not expose `pfmp_api` directly in production-style mode.
- Do not expose MySQL publicly.
- Test login, refresh token, logout, and protected routes after any Nginx change.

## See also

- [02 - Architecture](02-architecture.md) for how Nginx fits into the overall system.
- [07 - Authentication and security](07-authentication-security.md) for CORS and cookie details.
- [08 - Docker and deployment](08-docker-deployment.md) for the full Docker service list.
