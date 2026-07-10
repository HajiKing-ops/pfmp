# PFMP Manager

A web application for managing PFMP work-based training placements in a school context.

> **PFMP** stands for *Période de Formation en Milieu Professionnel*, a mandatory work-based training placement that French vocational students complete with a host company. The term is kept as-is throughout this documentation, matching the codebase (entities, routes, and variables are all named `Pfmp`).

PFMP Manager centralizes placement tracking: finding a host organization, contact applications, weekly schedules, the student logbook, attendance, and messaging.

- **Backend**: ASP.NET Core Web API + Entity Framework Core
- **Database**: MySQL
- **Frontend**: Flutter Web
- **Deployment**: Docker Compose + Nginx
- **Authentication**: JWT stored in HttpOnly cookies, with role-based access control

> **Project status**: active student project. Some parts (teacher interface, automated tests, production HTTPS) are still incomplete — see [12 - TODO and future improvements](docs/12-todo-future-improvements.md).

## Roles

| Role | Logs into the app | Summary |
| --- | --- | --- |
| Student | Yes | Manages their own PFMPs, applications, and logbook. |
| Administrator | Yes | Oversees PFMPs for the schools they are responsible for. |
| Teacher / Referent | Yes, backend only | Can follow assigned students through the API; no Flutter interface is wired up for this role yet. |
| Professional / Workplace supervisor | No | Exists in the data model but does not log into the app in the current version. |

Full breakdown and permission table: [03 - Roles and permissions](docs/03-roles-and-permissions.md).

## Project structure

```text
.
├── PFMPManager.Api/       # ASP.NET Core API
├── appli_pfmp/            # Flutter Web application
├── docker-compose.yml
├── docker-compose.override.yml
├── docker-compose.prod.yml
├── .env.example
├── README.md
└── docs/
```

## Prerequisites

- Git
- Docker Desktop or Docker Engine + Docker Compose (to run everything in containers)
- .NET 9 SDK and the Flutter SDK (only needed to run services outside Docker)

Detailed per-OS setup guides: [Windows](docs/SETUP_WINDOWS.md) · [macOS](docs/SETUP_MACOS.md) · [Linux](docs/SETUP_LINUX.md).

## Run With Docker

```bash
git clone <repository-url>
cd Projet-WebApp-PFMP
cp .env.example .env          # PowerShell: Copy-Item .env.example .env
docker volume create docker-test_mysql_data
docker compose up --build
```

Then open [http://localhost:65427](http://localhost:65427) (default port from `.env.example`).

Production-style mode, where only Nginx is exposed (see [08 - Docker and deployment](docs/08-docker-deployment.md)):

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

## Run Locally

Backend:

```bash
cd PFMPManager.Api
dotnet restore
dotnet run --launch-profile http
# http://localhost:5002
```

Frontend:

```bash
cd appli_pfmp
flutter pub get
flutter run -d chrome --web-port 65427
```

⚠️ The Flutter code calls the API with relative URLs (`/api/...`). In Docker, Nginx handles this automatically; outside Docker, you need a local proxy forwarding `/api` to `http://localhost:5002`, otherwise the calls will fail. Details: [05 - Flutter frontend guide](docs/05-frontend-guide.md#api-calls).

## Documentation

| Document | Content |
| --- | --- |
| [01 - Project overview](docs/01-project-overview.md) | Goals, users, main flows, current scope. |
| [02 - Architecture](docs/02-architecture.md) | Global diagram, backend / frontend / Docker architecture. |
| [03 - Roles and permissions](docs/03-roles-and-permissions.md) | Detailed permission table by role. |
| [04 - Backend API](docs/04-backend-api.md) | Full endpoint reference (method, route, role, rules, errors). |
| [05 - Flutter frontend guide](docs/05-frontend-guide.md) | Flutter app structure, screens, API calls. |
| [06 - Database model](docs/06-database-model.md) | EF Core entities, relationships, composite keys. |
| [07 - Authentication and security](docs/07-authentication-security.md) | JWT, cookies, CORS, refresh token rotation. |
| [08 - Docker and deployment](docs/08-docker-deployment.md) | Services, ports, volumes, deployment commands. |
| [09 - Development workflow](docs/09-development-workflow.md) | Setup, dev cycle, Git conventions. |
| [10 - Testing checklist](docs/10-testing-checklist.md) | Manual checks before shipping. |
| [11 - Temporary public access](docs/11-temporary-public-access.md) | Procedure for a short public test from a local machine. |
| [12 - TODO and future improvements](docs/12-todo-future-improvements.md) | Backend, frontend, DevOps, and security follow-ups. |
| [MySQL backup & restore](docs/DATABASE_BACKUP.md) | Backing up and restoring the MySQL volume. |
| [Nginx reverse proxy](docs/NGINX_PROXY.md) | Details of `nginx.conf` and the `/api` proxy. |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Post-deploy checklist and common problems. |
| Setup guides: [Windows](docs/SETUP_WINDOWS.md) / [macOS](docs/SETUP_MACOS.md) / [Linux](docs/SETUP_LINUX.md) | Installing the toolchain per operating system. |

## Security

Authentication relies on HttpOnly cookies and role-based access control. Several current settings (`Secure=false` cookies, no HTTPS) are suited to local development only and **are not appropriate for a real public deployment**. See [07 - Authentication and security](docs/07-authentication-security.md) before putting this online, even temporarily, and [11 - Temporary public access](docs/11-temporary-public-access.md) if a short public test is genuinely needed.

Never commit `.env`: use `.env.example` as a template and replace the default values (especially `JWT_SECRET`) before any real use.

## Contributing

See [09 - Development workflow](docs/09-development-workflow.md) for Git conventions, build/test commands, and the checklist to run through before proposing a change.
