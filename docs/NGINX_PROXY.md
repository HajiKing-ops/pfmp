# Nginx Reverse Proxy for Flutter Web

`appli_pfmp/nginx.conf` configures the Nginx container used by the `flutter_web` service. It serves the compiled Flutter Web application and forwards relative API calls to the internal API container.

## SPA Fallback

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

Flutter Web is a single-page application. If a user refreshes a Flutter route, Nginx returns `index.html` so Flutter can handle the route client-side.

## API Proxy

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

The Flutter data layer currently uses relative URLs such as:

```text
/api/login
/api/dashboard
/api/messages/{idPfmp}
```

When the app runs in Docker, those requests arrive at Nginx first. Nginx forwards them to the Compose service named `api` on internal port `8080`.

## Why This Proxy Matters

- The browser talks to a single origin.
- `AccessToken`, `RefreshToken`, and `Fgp` cookies stay scoped to the frontend origin.
- The API does not need to be directly exposed in production-style mode.
- CORS is simpler for Dockerized frontend traffic.

## Ports by Mode

Development Docker:

```text
Browser -> http://localhost:${FLUTTER_PORT}
Nginx   -> http://api:8080/api/
```

Production-style local mode:

```text
Browser -> http://localhost
Nginx   -> http://api:8080/api/
```

## Important Note for Flutter without Docker

If the application is launched with:

```bash
flutter run -d chrome --web-port 65427
```

the Flutter development server does not automatically proxy `/api` to the ASP.NET Core API. A local proxy or another routing approach must be verified for that workflow.

## Production TODOs

- Add or verify `ForwardedHeaders` in the API if Nginx or another reverse proxy terminates HTTPS.
- Use `Secure=true` cookies under HTTPS.
- Do not expose `pfmp_api` directly in production-style mode.
- Do not expose MySQL publicly.
- Test login, refresh, logout, and protected routes after any Nginx change.
