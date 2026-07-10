# 08 - Docker and deployment

## Docker files

| File | Role |
| --- | --- |
| `docker-compose.yml` | Shared configuration for the MySQL, API, and Flutter/Nginx services. |
| `docker-compose.override.yml` | Development configuration: exposed ports and the Development environment. |
| `docker-compose.prod.yml` | Production-style configuration: only Nginx exposes port 80. |
| `PFMPManager.Api/Dockerfile` | Builds/publishes .NET 9, then runs it on the ASP.NET runtime image. |
| `appli_pfmp/Dockerfile` | Builds Flutter Web, then serves it via the Nginx runtime image. |
| `appli_pfmp/nginx.conf` | Serves Flutter and proxies `/api`. |
| `.env.example` | Example variables, with no real secrets. |

## Services

### `mysql`

Container:

```text
pfmp_mysql
```

Image:

```text
mysql:8.0
```

Configuration:

- `MYSQL_ROOT_PASSWORD`;
- `MYSQL_DATABASE`;
- external volume `docker-test_mysql_data`;
- healthcheck via `mysqladmin ping`.

Watch out: the current compose file does not declare `MYSQL_USER` and `MYSQL_PASSWORD` in the MySQL service's environment, even though the API uses them to connect. To verify for a fresh install.

### `api`

Container:

```text
pfmp_api
```

Build:

```text
./PFMPManager.Api/Dockerfile
```

Variables:

- `ASPNETCORE_URLS=http://+:8080`;
- `ConnectionStrings__DefaultConnection`;
- `Jwt__Key`;
- `Jwt__Issuer`;
- `Jwt__Audience`;
- `Jwt__ExpireMinutes`.

Depends on MySQL being healthy.

### `flutter_web`

Container:

```text
pfmp_flutter
```

Build:

```text
./appli_pfmp/Dockerfile
```

The Flutter build is served by Nginx on internal port 80.

## MySQL volume

The volume is external:

```text
docker-test_mysql_data
```

Creation:

```bash
docker volume create docker-test_mysql_data
```

Do not delete it with:

```bash
docker compose down -v
```

unless deleting local data is intentional.

## Starting Docker development

Copy the example environment file:

```powershell
Copy-Item .env.example .env
```

Create the volume:

```bash
docker volume create docker-test_mysql_data
```

Start:

```bash
docker compose up --build
```

With `.env.example`, expected ports:

| Service | Host port | Container port |
| --- | --- | --- |
| Flutter / Nginx | `65427` | `80` |
| API | `5002` | `8080` |
| MySQL | `3307` | `3306` |

URLs:

```text
http://localhost:65427
http://localhost:5002
localhost:3307
```

## Starting production-style

Required command:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

In this mode:

- Nginx is exposed on `http://localhost`;
- the API stays internal;
- MySQL stays internal;
- the frontend calls `/api` on Nginx.

Stop:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
```

## Logs

Required commands:

```bash
docker logs pfmp_api
docker logs pfmp_flutter
docker logs pfmp_mysql
```

Useful commands:

```bash
docker compose ps
docker compose logs -f api
docker compose logs -f flutter_web
docker compose logs -f mysql
```

## Backup and restore

Documentation already exists: [MySQL backup & restore](DATABASE_BACKUP.md).

Generic backup example:

```bash
mkdir -p backups
docker exec pfmp_mysql mysqldump -uroot -pYOUR_PASSWORD pfmp_manager > backups/pfmp_manager_backup.sql
```

macOS/Linux restore example:

```bash
docker exec -i pfmp_mysql mysql -uroot -pYOUR_PASSWORD pfmp_manager < backups/pfmp_manager_backup.sql
```

On Windows, see [MySQL backup & restore](DATABASE_BACKUP.md) for the CMD and PowerShell variants.

## Nginx

`appli_pfmp/nginx.conf` includes:

- short-lived caching for the main Flutter files;
- long-lived caching for assets/canvaskit/icons;
- an SPA fallback to `index.html`;
- a proxy from `/api/` to `http://api:8080/api/`.

Full details: [Nginx reverse proxy](NGINX_PROXY.md).

## Network exposure

Development:

- API exposed on the host;
- MySQL exposed on the host;
- Flutter exposed on the host.

Production-style:

- only Nginx's port 80 is exposed;
- the API and MySQL are not exposed.

This model is safer for a temporary public test.

## Checklist before a real deployment

- Replace every secret in `.env`.
- Use HTTPS.
- Switch cookies to `Secure=true`.
- Create an application-level MySQL user with limited privileges.
- Do not expose MySQL publicly.
- Do not expose the API directly.
- Add a CI/CD pipeline.
- Add automated backups.
- Add monitoring/logs.
- Check `UseForwardedHeaders` behind Nginx if HTTPS is terminated before reaching the API.
