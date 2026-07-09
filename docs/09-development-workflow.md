# 09 - Development Workflow

## Prerequisites

To run everything with Docker:

- Git;
- Docker Desktop or Docker Engine;
- Docker Compose;
- a local `.env` file.

To run services locally without Docker:

- .NET 9 SDK;
- Flutter SDK compatible with Dart `^3.11.5`;
- MySQL 8;
- Chrome or Edge for Flutter Web.

Setup guides:

- [SETUP_WINDOWS.md](SETUP_WINDOWS.md)
- [SETUP_MACOS.md](SETUP_MACOS.md)
- [SETUP_LINUX.md](SETUP_LINUX.md)

## Clone the Repository

```bash
git clone <repository-url>
cd Projet-WebApp-PFMP
```

## Create `.env`

```powershell
Copy-Item .env.example .env
```

Edit `.env` with local values.

Do not commit `.env`.

## First Docker Run

Create the external volume:

```bash
docker volume create docker-test_mysql_data
```

Start the stack:

```bash
docker compose up --build
```

Check containers:

```bash
docker compose ps
```

Open:

```text
http://localhost:65427
```

## Rebuild After Changes

Full development rebuild:

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

## Run the API Locally

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

## Run Flutter Locally

```bash
cd appli_pfmp
flutter pub get
flutter run -d chrome --web-port 65427
```

To verify: the current Flutter code uses `/api/...`. If Flutter is served by its development server, make sure `/api` requests are routed or proxied to the API.

## Test Changes

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

Manual checks:

- login;
- logout;
- student access;
- administrator access;
- `403` responses for forbidden endpoints;
- contact request creation/update;
- PFMP creation;
- daily reports;
- messaging;
- attendance;
- production-style Nginx `/api` proxy.

See [10 - Testing Checklist](10-testing-checklist.md).

## Recommended Git Workflow

Before working:

```bash
git status
git pull
```

Create a branch:

```bash
git checkout -b docs/improve-documentation
```

Use small, clear commits:

```bash
git add README.md docs/
git commit -m "docs: improve project documentation"
```

Commit message examples:

- `docs: document backend api routes`
- `docs: add docker deployment guide`
- `fix(api): restrict pfmp access for referent`
- `feat(frontend): add teacher dashboard`
- `test(api): add auth role tests`

## Contribution Rules

- Do not commit `.env`.
- Do not commit real secrets in docs, configuration, or screenshots.
- Keep `.env.example` safe and generic.
- Document route changes when API endpoints change.
- Update the testing checklist when a user flow changes.
- Back up MySQL before risky data changes.

## Backup Before Risky Changes

See [DATABASE_BACKUP.md](DATABASE_BACKUP.md).

Example:

```bash
docker exec pfmp_mysql mysqldump -uroot -pYOUR_PASSWORD pfmp_manager > backups/pfmp_manager_before_changes.sql
```

## Regular Checks

- Docker volume exists.
- Containers are running.
- Nginx `/api` proxy works.
- Cookies are set after login.
- Protected endpoints reject unauthorized users.
- Documentation remains aligned with controllers and services.
