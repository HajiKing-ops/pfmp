# 09 - Development workflow

## Prerequisites

To run everything with Docker:

- Git;
- Docker Desktop or Docker Engine;
- Docker Compose;
- a local `.env` file.

To run outside Docker:

- .NET 9 SDK;
- Flutter SDK compatible with Dart `^3.11.5`;
- MySQL 8;
- a Chrome/Edge browser for Flutter Web.

Existing setup guides:

- [Windows setup](SETUP_WINDOWS.md)
- [macOS setup](SETUP_MACOS.md)
- [Linux setup](SETUP_LINUX.md)

## Clone the project

```bash
git clone <repository-url>
cd Projet-WebApp-PFMP
```

## Create `.env`

```powershell
Copy-Item .env.example .env
```

Then edit `.env` with local values.

Do not commit `.env`.

## First Docker run

Create the volume:

```bash
docker volume create docker-test_mysql_data
```

Start:

```bash
docker compose up --build
```

Check:

```bash
docker compose ps
```

Open:

```text
http://localhost:65427
```

## Rebuilding after a change

Full rebuild:

```bash
docker compose up --build
```

Production-style rebuild:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

Stop:

```bash
docker compose down
```

## Running the API outside Docker

```bash
cd PFMPManager.Api
dotnet restore
dotnet run --launch-profile http
```

URL:

```text
http://localhost:5002
```

OpenAPI JSON in development:

```text
http://localhost:5002/openapi/v1.json
```

## Running Flutter outside Docker

```bash
cd appli_pfmp
flutter pub get
flutter run -d chrome --web-port 65427
```

Note: the Flutter code uses `/api/...`. If Flutter is served by its own dev server, you need to check how `/api` is proxied to the API. In Docker, Nginx already handles this.

## Testing changes

Backend:

```bash
cd PFMPManager.Api
dotnet build
```

Frontend:

```bash
cd appli_pfmp
flutter analyze
flutter test
```

Recommended manual tests:

- login;
- logout;
- student role access;
- administrator role access;
- `403` rejection on unauthorized endpoints;
- application creation/edit;
- PFMP creation;
- logbook;
- messaging;
- attendance;
- production-style with Nginx `/api`.

See [10 - Testing checklist](10-testing-checklist.md).

## Recommended Git workflow

Before starting work:

```bash
git status
git pull
```

Create a branch:

```bash
git checkout -b docs/documentation-improvements
```

Small, clear commits:

```bash
git add README.md docs/
git commit -m "docs: add project documentation"
```

Example commit messages:

- `docs: document backend api routes`
- `docs: add docker deployment guide`
- `fix(api): restrict pfmp access for referent`
- `feat(frontend): add teacher dashboard`
- `test(api): add auth role tests`

## Contribution rules

- Never commit `.env`.
- Never commit secrets in `appsettings.json`, the documentation, or screenshots.
- Keep `.env.example` filled with dummy values.
- Document any API route changes.
- Add or update the testing checklist whenever a flow changes.
- Take a MySQL backup before any change that risks affecting the data.

## Backing up before sensitive changes

See [MySQL backup & restore](DATABASE_BACKUP.md).

Example:

```bash
docker exec pfmp_mysql mysqldump -uroot -pYOUR_PASSWORD pfmp_manager > backups/pfmp_manager_before_changes.sql
```

## If you get stuck

See [Troubleshooting](TROUBLESHOOTING.md) for common problems: CORS errors, rejected cookies, MySQL connection issues, a missing Docker volume, and more.

## Things to check regularly

- The Docker volume exists.
- Containers are healthy/up.
- The Nginx `/api` proxy works.
- Cookies are set after login.
- The API rejects unauthorized access.
- The documentation stays aligned with the controllers and services.
