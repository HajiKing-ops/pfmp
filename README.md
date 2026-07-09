# PFMP Manager

PFMP Manager is a web application for managing student internship periods called PFMP. The repository contains an ASP.NET Core Web API, a Flutter Web frontend, a MySQL database, and a Docker Compose setup with Nginx.

This documentation is based on the code currently present in the repository. Anything unclear or not confirmed in code is marked as `TODO`, `To verify`, or `Not confirmed in code`.

## Technology Stack

| Area | Technologies |
| --- | --- |
| Backend | ASP.NET Core Web API, .NET 9, Entity Framework Core, Pomelo MySQL, QuestPDF |
| Frontend | Flutter Web, Dart, flutter_bloc, http BrowserClient |
| Database | MySQL 8, persistent Docker volume |
| Authentication | JWT in HttpOnly cookies, refresh token rotation, fingerprint cookie |
| DevOps | Docker Compose, Nginx, `.env` configuration |

## Main Roles

| Role | Current status |
| --- | --- |
| Administrator | Has a Flutter admin area for supervision, class statistics, attendance, period management, and messaging. |
| Teacher / Referent | Exists in backend authorization for assigned-student access, attendance updates, and messaging. A dedicated Flutter teacher area is not currently wired in `main.dart`. |
| Student | Has a Flutter student area for dashboard, PFMP search, daily reports, messaging, profile, and PFMP list. |
| Professional / Internship supervisor | Exists in the business model and can be linked to an organisation during PFMP creation. This role does not log into the app in the current version. |

## Quick Architecture

```text
Browser
  |
  v
Flutter Web / Nginx
  |
  | /api/*
  v
ASP.NET Core API
  |
  | Entity Framework Core
  v
MySQL
```

PFMP Manager uses a separated architecture because each part has a clear responsibility:

- the Flutter frontend manages the user interface and browser experience;
- the ASP.NET Core API manages authentication, authorization, business rules, and API responses;
- MySQL stores persistent application data;
- Docker Compose runs the stack in a reproducible way;
- Nginx serves Flutter Web and forwards `/api/...` calls to the internal API container.

In production-style mode, only Nginx is exposed publicly. The API and MySQL containers stay internal, which reduces the public attack surface.

## Repository Structure

```text
.
|-- PFMPManager.Api/        # ASP.NET Core API
|   |-- Controllers/        # REST endpoints
|   |-- DTOs/               # Request/response contracts
|   |-- Data/               # EF Core AppDbContext
|   |-- Helpers/            # JWT, password, admin helper code
|   |-- Models/             # EF Core entities
|   |-- Services/           # Business/security services
|   `-- Dockerfile
|-- appli_pfmp/             # Flutter Web application
|   |-- lib/application/    # Screens
|   |-- lib/bloc/           # BLoC state management
|   |-- lib/data/           # API calls
|   |-- lib/model/          # Dart models
|   |-- nginx.conf          # Nginx static server + /api proxy
|   `-- Dockerfile
|-- docs/                   # Detailed documentation
|-- docker-compose.yml
|-- docker-compose.override.yml
|-- docker-compose.prod.yml
|-- .env.example
`-- README.md
```

## Environment Configuration

Do not commit the real `.env` file. It is ignored by `.gitignore`.

Create a local environment file from the safe template:

```powershell
Copy-Item .env.example .env
```

Variables shown in `.env.example`:

```env
MYSQL_ROOT_PASSWORD=change_me
MYSQL_DATABASE=pfmp_manager
MYSQL_USER=pfmp_user
MYSQL_PASSWORD=change_me
MYSQL_PORT=3307
API_PORT=5002
FLUTTER_PORT=65427
JWT_SECRET=change_me_long_secret_at_least_32_chars
```

Important: `docker-compose.yml` uses `${MYSQL_USER}` and `${MYSQL_PASSWORD}` for the API connection string. The MySQL service currently declares `MYSQL_ROOT_PASSWORD` and `MYSQL_DATABASE`, but not automatic user creation. For a fresh Docker volume, verify that the application database user exists or add a proper initialization process.

## Run with Docker for Development

Create the external MySQL volume if needed:

```bash
docker volume create docker-test_mysql_data
```

Start the full stack:

```bash
docker compose up --build
```

Default local URLs with `.env.example`:

| Service | URL |
| --- | --- |
| Flutter Web / Nginx | `http://localhost:65427` |
| API exposed for development | `http://localhost:5002` |
| MySQL exposed for development | `localhost:3307` |

Flutter calls relative `/api/...` URLs. In Docker, Nginx forwards those requests to the API container.

## Run in Production-Style Mode

Production-style mode exposes only Nginx on port 80. The API and MySQL remain internal to the Docker network.

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

Stop production-style mode:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
```

Useful logs:

```bash
docker logs pfmp_api
docker logs pfmp_flutter
docker logs pfmp_mysql
```

## Run Locally without Docker

Backend:

```bash
cd PFMPManager.Api
dotnet restore
dotnet run --launch-profile http
```

Frontend:

```bash
cd appli_pfmp
flutter pub get
flutter run -d chrome --web-port 65427
```

To verify: the current Flutter code calls relative `/api/...` URLs. When running Flutter directly with the development server, make sure those requests are proxied or routed to the ASP.NET Core API, because the Flutter development server does not automatically proxy `/api`.

## Detailed Documentation

- [01 - Project Overview](docs/01-project-overview.md)
- [02 - Architecture](docs/02-architecture.md)
- [03 - Roles and Permissions](docs/03-roles-and-permissions.md)
- [04 - Backend API](docs/04-backend-api.md)
- [05 - Frontend Guide](docs/05-frontend-guide.md)
- [06 - Database Model](docs/06-database-model.md)
- [07 - Authentication and Security](docs/07-authentication-security.md)
- [08 - Docker Deployment](docs/08-docker-deployment.md)
- [09 - Development Workflow](docs/09-development-workflow.md)
- [10 - Testing Checklist](docs/10-testing-checklist.md)
- [11 - Temporary Public Access](docs/11-temporary-public-access.md)
- [12 - TODO and Future Improvements](docs/12-todo-future-improvements.md)

Operational docs:

- [Windows Setup](docs/SETUP_WINDOWS.md)
- [macOS Setup](docs/SETUP_MACOS.md)
- [Linux Setup](docs/SETUP_LINUX.md)
- [Database Backup and Restore](docs/DATABASE_BACKUP.md)
- [Nginx Reverse Proxy](docs/NGINX_PROXY.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Project Status

Confirmed in code:

- cookie-based login and logout;
- JWT access token with refresh token rotation;
- fingerprint cookie validation;
- role-based access control;
- student area;
- administrator area;
- PFMP, schedule, attendance, daily report, organisation, messaging, and admin supervision endpoints;
- Docker Compose setup with MySQL, API, Flutter Web, and Nginx `/api` reverse proxy.

Not complete or to verify:

- no dedicated Flutter Teacher / Referent area is currently wired;
- `ProfileController` appears incomplete or not explicitly routed;
- the Flutter PFMP creation form appears to omit `siteWeb`, while the API requires it;
- the Flutter PFMP creation form currently uses hardcoded dates;
- `/api/presence/modify` and `/api/administrateur/classes/stats` are attempted by the frontend as fallbacks but are not backend routes confirmed in code;
- a fresh MySQL volume may need explicit creation of the non-root application user.

See [12 - TODO and Future Improvements](docs/12-todo-future-improvements.md) for the full roadmap.
