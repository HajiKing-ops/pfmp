# Nginx Reverse Proxy (Flutter Web)

`appli_pfmp/nginx.conf` configures the Nginx container that serves the built
Flutter Web app in the `flutter_web` Docker service. It does two things.

## SPA fallback

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

Any path that isn't a static file falls back to `index.html`, so Flutter's
client-side router can handle it after a browser refresh. Safe to keep
regardless of whether the app uses hash-based or path-based routing.

## API reverse proxy

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

Proxies `/api/...` requests to the `api` service over the Docker Compose
network, so the browser can call `/api/...` on the same origin as the page
instead of a separate host and port. `api:8080` matches the internal Docker
hostname already referenced elsewhere in the project, and lines up with the
default internal port for .NET 8+ container images, so this target looks
correct.

## Current status: present, not yet wired in

The block is marked `# Optional` in the file, and nothing calls it yet: the
Flutter data layer still calls the hardcoded absolute host
(`http://10.123.33.116:5002`, see the main [README](../README.md#run-locally)),
not `/api/...`. The proxy config exists in the container, but no traffic
currently goes through it.

## Why it's worth finishing

Once the Flutter client is updated to call relative `/api/...` paths, this
resolves three recurring pain points already documented in
[`TROUBLESHOOTING.md`](TROUBLESHOOTING.md):

- **CORS** — same-origin requests don't need `Access-Control-Allow-Origin`
  at all, for the Dockerized frontend.
- **The hardcoded API host** — `/api/...` works from any machine that can
  reach the `flutter_web` container, with no rebuild per environment.
- **Cookie edge cases** — `AccessToken`, `RefreshToken`, and `Fgp` stay
  scoped to one origin instead of crossing from the API's host/port to the
  Flutter host/port, avoiding most `SameSite`/`Secure` friction.

This does **not** change the `flutter run -d chrome` local dev flow — that
still talks to the API directly and still needs the CORS origins and cookie
settings already documented in the main README.

## To activate it

1. Update the Flutter data layer (`appli_pfmp/lib/data`) to call
   `/api/...` instead of the hardcoded host, at least for the Dockerized
   `flutter_web` build.
2. Confirm the API container listens on port `8080` internally — the proxy
   assumes `http://api:8080`.
3. Add `ForwardedHeaders` middleware in `Program.cs` (handling
   `X-Forwarded-For` and `X-Forwarded-Proto`) if it isn't there already.
   Without it, the API can't see the real client IP or scheme once Nginx
   is in front of it — this affects the `Secure` cookie flag and
   `UseHttpsRedirection()`.
4. Re-run the [post-deploy checklist](TROUBLESHOOTING.md#post-deploy-verification-checklist)
   afterward — cookie behavior is exactly what this change touches.
