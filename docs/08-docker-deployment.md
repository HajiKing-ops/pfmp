# 08 - Docker and Deployment

## Docker Files

| File | Purpose |
| --- | --- |
| `docker-compose.yml` | Shared service configuration for MySQL, API, and Flutter/Nginx. |
| `docker-compose.override.yml` | Development configuration: exposed ports and `Development` environment. |
| `docker-compose.prod.yml` | Production-style configuration: only Nginx is exposed on port 80. |
| `PFMPManager.Api/Dockerfile` | Builds and publishes the .NET API, then runs it with the ASP.NET runtime. |
| `appli_pfmp/Dockerfile` | Builds Flutter Web, then serves it with Nginx. |
| `appli_pfmp/nginx.conf` | Serves Flutter and proxies `/api`. |
| `.env.example` | Safe template for environment variables. |

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
- `mysqladmin ping` healthcheck.

To verify: `docker-compose.yml` does not currently declare `MYSQL_USER` and `MYSQL_PASSWORD` in the MySQL service environment, even though the API connection string uses them. A fresh volume may need explicit application user creation.

### `api`

Container:

```text
pfmp_api
```

Build context:

```text
./PFMPManager.Api
```

Important environment variables:

- `ASPNETCORE_URLS=http://+:8080`;
- `ConnectionStrings__DefaultConnection`;
- `Jwt__Key`;
- `Jwt__Issuer`;
- `Jwt__Audience`;
- `Jwt__ExpireMinutes`.

The API waits for MySQL to be healthy.

### `flutter_web`

Container:

```text
pfmp_flutter
```

Build context:

```text
./appli_pfmp
```

The container serves the compiled Flutter Web application with Nginx on internal port 80.

## MySQL Volume

The MySQL volume is external:

```text
docker-test_mysql_data
```

Create it before the first run:

```bash
docker volume create docker-test_mysql_data
```

Do not run this unless you intentionally want to delete local database data:

```bash
docker compose down -v
```

## Development Mode

Create `.env` from the template:

```powershell
Copy-Item .env.example .env
```

Create the volume:

```bash
docker volume create docker-test_mysql_data
```

Start the stack:

```bash
docker compose up --build
```

With `.env.example`, expected ports are:

| Service | Host port | Container port |
| --- | --- | --- |
| Flutter / Nginx | `65427` | `80` |
| API | `5002` | `8080` |
| MySQL | `3307` | `3306` |

Development URLs:

```text
http://localhost:65427
http://localhost:5002
localhost:3307
```

Development mode exposes more ports because it is useful for debugging, API testing, and database inspection.

## Production-Style Mode

Start:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

In this mode:

- Nginx is exposed on `http://localhost`;
- the API remains internal;
- MySQL remains internal;
- the frontend calls `/api` through Nginx.

Stop:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
```

This mode is safer for temporary public testing because only the frontend/Nginx entry point is public.

## Logs and Debug Commands

Required log commands:

```bash
docker logs pfmp_api
docker logs pfmp_flutter
docker logs pfmp_mysql
```

Useful alternatives:

```bash
docker compose ps
docker compose logs -f api
docker compose logs -f flutter_web
docker compose logs -f mysql
```

## Backup and Restore

Detailed instructions already exist in:

- [DATABASE_BACKUP.md](DATABASE_BACKUP.md)

Example backup:

```bash
mkdir -p backups
docker exec pfmp_mysql mysqldump -uroot -pYOUR_PASSWORD pfmp_manager > backups/pfmp_manager_backup.sql
```

Example restore on macOS/Linux:

```bash
docker exec -i pfmp_mysql mysql -uroot -pYOUR_PASSWORD pfmp_manager < backups/pfmp_manager_backup.sql
```

Use placeholder values in documentation. Do not write real passwords in docs.

## Nginx

`appli_pfmp/nginx.conf` provides:

- short caching for Flutter bootstrap files;
- longer caching for assets and CanvasKit files;
- SPA fallback to `index.html`;
- `/api/` reverse proxy to `http://api:8080/api/`.

## Network Exposure

Development:

- Flutter/Nginx is exposed;
- API is exposed;
- MySQL is exposed.

Production-style:

- only Nginx on port 80 is exposed;
- API and MySQL stay inside the Docker network.

This reduces the public attack surface and keeps database access behind the API.

## Before Real Deployment

- Replace all development secrets.
- Enable HTTPS.
- Use `Secure=true` cookies under HTTPS.
- Use a limited MySQL application user.
- Do not expose MySQL publicly.
- Do not expose the API directly if Nginx can proxy `/api`.
- Add CI/CD.
- Add automated backups.
- Add monitoring and logs.
- Verify forwarded headers if HTTPS is terminated before the API.
