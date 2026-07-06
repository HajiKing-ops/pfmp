# PFMP Manager

PFMP Manager is a web application for managing PFMP internships, also known as
"Période de Formation en Milieu Professionnel" (school-supervised work
placements). The repository contains a .NET 9 REST API, a Flutter web/mobile
client, and a Docker Compose environment with MySQL.

## Roles

| Role | Purpose |
| --- | --- |
| `Etudiant` | Searches organisations, tracks contact requests, creates PFMPs, fills the daily journal, exchanges messages. |
| `Enseignant` (referent) | Accesses assigned student PFMP information and updates presence when authorized. |
| `Administrateur` | Supervises PFMPs for managed establishments, tracks class-level statistics, initializes presence records, creates users. |
| `Professionnel` | Internship supervisor, linked to an organisation. Exists as a data entity today; **not confirmed as an application login role** — see [Known Issues](#known-issues). |

## Contents

- [Features](#features)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Repository Structure](#repository-structure)
- [Environment Variables](#environment-variables)
- [Run With Docker](#run-with-docker)
- [Run Locally](#run-locally)
- [API Overview](#api-overview)
- [Database Model](#database-model)
- [Security Notes](#security-notes)
- [Testing And Quality](#testing-and-quality)
- [Further Documentation](#further-documentation)

## Features

- Cookie-based login with JWT access tokens, refresh-token rotation, and a
  fingerprint cookie.
- Role detection from database profile tables: student, teacher/referent, and
  administrator.
- Student dashboard with current PFMP information and progress indicators.
- Organisation directory and search by name, postal code, or activity sector.
- Contact request tracking for internship search workflows.
- Complete PFMP creation flow including organisation, supervisor, planning, and
  overlap validation.
- Daily journal creation, update, export data endpoint, and PDF generation with
  QuestPDF.
- PFMP-scoped messaging with role-based access checks.
- Presence initialization and updates for active PFMP days.
- Administrator dashboard with PFMP rows, global statistics, filters, and
  class-level statistics.
- CERT-FR RSS news endpoint for cybersecurity news.
- Flutter UI using BLoC state management, French localization, custom widgets,
  and responsive desktop/mobile layouts.

## Architecture

```text
Flutter client
  |
  | HTTP requests with browser credentials
  v
.NET 9 API
  |
  | Entity Framework Core / Pomelo MySQL
  v
MySQL 8 database
```

The backend exposes REST endpoints under `/api/*`. Authentication is handled
with HttpOnly cookies:

- `AccessToken`: short-lived JWT access token.
- `RefreshToken`: long-lived refresh token, stored hashed in the database.
- `Fgp`: session fingerprint used to bind the access token to the browser
  session.

The Flutter app is located in `appli_pfmp` and communicates with the API through
the files in `appli_pfmp/lib/data`.

## Technology Stack

### Backend

- .NET 9 / ASP.NET Core Web API
- Entity Framework Core with `Pomelo.EntityFrameworkCore.MySql`
- MySQL 8
- JWT bearer authentication
- QuestPDF for PDF export
- OpenAPI JSON generation in development

### Frontend

- Flutter / Dart
- `flutter_bloc` for state management
- `http` with `BrowserClient` and `withCredentials`
- `intl` and Flutter localization for French dates
- `url_launcher` for external map links
- Custom Syne font and local image assets

### Infrastructure

- Docker Compose
- API Dockerfile with multi-stage .NET build
- Flutter Web Dockerfile with multi-stage build and Nginx runtime,
  including an optional reverse proxy for `/api/` (see
  [`docs/NGINX_PROXY.md`](docs/NGINX_PROXY.md))
- MySQL Docker image with a named external volume

## Repository Structure

```text
.
|-- PFMPManager.Api/
|   |-- Controllers/          # REST API endpoints
|   |-- Data/                 # EF Core DbContext
|   |-- DTOs/                 # API request/response contracts
|   |-- Helpers/              # JWT, passwords, admin statistics helpers
|   |-- Models/               # Database table mappings
|   |-- Services/             # Current user, roles, access checks, planning validation
|   |-- Dockerfile
|   |-- PFMPManager.Api.csproj
|   `-- Program.cs
|-- appli_pfmp/
|   |-- lib/
|   |   |-- application/      # UI screens
|   |   |-- bloc/             # BLoC events, states, and logic
|   |   |-- custom/           # Custom widgets, colors, functions
|   |   |-- data/             # API calls
|   |   |-- model/            # Flutter data models
|   |   `-- main.dart
|   |-- images/
|   |-- test/
|   |-- Dockerfile
|   |-- nginx.conf            # Nginx SPA fallback + optional /api/ proxy
|   `-- pubspec.yaml
|-- docs/
|   |-- SETUP_WINDOWS.md      # Windows installer walkthrough
|   |-- SETUP_MACOS.md        # macOS installer walkthrough
|   |-- SETUP_LINUX.md        # Linux installer walkthrough
|   |-- DATABASE_BACKUP.md    # MySQL volume, backup, restore
|   |-- TROUBLESHOOTING.md    # Common problems and verification checklist
|   |-- NGINX_PROXY.md        # Flutter Web reverse proxy explained
|-- docker-compose.yml
|-- .gitignore
`-- README.md
```

## Environment Variables

Docker Compose reads configuration from a root `.env` file. Keep real values out
of version control.

Example:

```env
MYSQL_ROOT_PASSWORD=change_me
MYSQL_DATABASE=pfmp_manager
MYSQL_PORT=3307
API_PORT=5002
FLUTTER_PORT=8080
```

The API also reads JWT/security settings from `PFMPManager.Api/appsettings.json`
for local development — override these through environment variables or a
secret manager in production. The keys currently expected are:

```text
Jwt:Key
Jwt:Issuer
Jwt:Audience
Jwt:AccessTokenExpirationMinutes
Jwt:RefreshTokenExpirationDays
```

## Run With Docker

The root `docker-compose.yml` starts three services:

- `mysql`: MySQL 8 database on `${MYSQL_PORT}`.
- `api`: .NET API on `${API_PORT}`.
- `flutter_web`: Flutter Web build served by Nginx on `${FLUTTER_PORT}`.

The MySQL volume is configured as an external volume named
`docker-test_mysql_data`. Create it before the first run if it does not already
exist:

```bash
docker volume create docker-test_mysql_data
```

Start the full stack:

```bash
docker compose up --build
```

Stop the stack:

```bash
docker compose down
```

When running with Docker, the API container connects to MySQL through the Docker
network using this connection string pattern:

```text
server=mysql;port=3306;database=${MYSQL_DATABASE};user=root;password=${MYSQL_ROOT_PASSWORD};
```

For volume creation, backup, and restore procedures, see
[`docs/DATABASE_BACKUP.md`](docs/DATABASE_BACKUP.md).

The `flutter_web` service's Nginx config also includes an optional reverse
proxy for `/api/...` requests to the `api` service — see
[`docs/NGINX_PROXY.md`](docs/NGINX_PROXY.md) for what it does and what's
left to wire it up.

## Run Locally

### Backend API

Requirements:

- .NET 9 SDK
- MySQL 8 with the PFMP database schema/data available

Commands:

```bash
cd PFMPManager.Api
dotnet restore
dotnet run --launch-profile http
```

Default local API URL:

```text
http://localhost:5002
```

In development, OpenAPI JSON is mapped by ASP.NET Core at:

```text
http://localhost:5002/openapi/v1.json
```

The default local connection string in `appsettings.json` points to MySQL on
`localhost:3307`, database `pfmp_manager`.

### Flutter App

Requirements:

- Flutter SDK compatible with Dart `^3.11.5`
- A running API reachable from the browser

Commands:

```bash
cd appli_pfmp
flutter pub get
flutter run -d chrome --web-port 65427
```

The API CORS policy currently allows these development origins:

```text
http://localhost:65427
http://192.168.1.103:65427
```

The current Flutter data layer contains a hard-coded API host:

```text
http://10.123.33.116:5002
```

Before running in another environment, make sure the Flutter API URLs, the API
CORS origins, and the cookie settings all point to compatible hosts.

New to one of these tools? Pick your OS:
[`docs/SETUP_WINDOWS.md`](docs/SETUP_WINDOWS.md),
[`docs/SETUP_MACOS.md`](docs/SETUP_MACOS.md), or
[`docs/SETUP_LINUX.md`](docs/SETUP_LINUX.md) — each walks through installing
every tool above with copy-paste commands for that platform.

## API Overview

### Authentication

| Method | Endpoint | Roles | Purpose |
| --- | --- | --- | --- |
| `POST` | `/api/login` | Public | Authenticate a user and set auth cookies. |
| `POST` | `/api/login/refresh` | Cookie session | Rotate refresh token and issue a new access token. |
| `POST` | `/api/logout` | Cookie session | Revoke the current refresh token and clear cookies. |

### Student And PFMP

| Method | Endpoint | Roles | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/dashboard` | Etudiant | Get active PFMP dashboard data. |
| `GET` | `/api/pfmp/recherche/{studentId}/{pfmpId?}` | Etudiant, Enseignant | Get PFMP details for an authorized student. |
| `POST` | `/api/pfmp/complete` | Etudiant | Create a complete PFMP with planning and supervisor information. |

### Organisations And Demarches

| Method | Endpoint | Roles | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/entreprises` | Authenticated | List organisations. |
| `GET` | `/api/entreprises/recherche` | Authenticated | Search organisations by optional filters. |
| `GET` | `/api/demarches` | Etudiant | List the connected student's contact requests. |
| `POST` | `/api/demarches/{siret}` | Etudiant | Create a contact request for an organisation. |
| `PUT` | `/api/demarches/modify/{siret}` | Etudiant | Update an existing contact request. |

### Journal

| Method | Endpoint | Roles | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/journal` | Etudiant | List the connected student's daily reports. |
| `POST` | `/api/journal` | Etudiant | Create a daily report for the active PFMP date. |
| `PUT` | `/api/journal/update/{id}` | Etudiant | Update a daily report. |
| `GET` | `/api/journal/alerte` | Etudiant | Check whether today's report exists. |
| `GET` | `/api/journal/export/{idPfmp}` | Etudiant | Return PFMP and journal data for export. |
| `GET` | `/api/journal/pdf/{idPfmp}` | Authenticated | Generate a PDF journal summary. |

### Messaging

| Method | Endpoint | Roles | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/messages/{idPfmp}` | Authenticated | Get message history for an active PFMP. |
| `POST` | `/api/messages/{idPfmp}` | Authenticated | Send a message in an active PFMP conversation. |

### Administration And Presence

| Method | Endpoint | Roles | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/administrateur` | Administrateur | Get administrator PFMP dashboard rows and statistics. |
| `GET` | `/api/administrateur/recherche` | Administrateur | Filter administrator dashboard data. |
| `GET` | `/api/administrateur/classes` | Administrateur | Get PFMP statistics grouped by class. |
| `POST` | `/api/presence/initialiser` | Administrateur | Initialize today's presence rows for active PFMPs. |
| `PUT` | `/api/presence/update/{studentId}` | Enseignant, Administrateur | Update a student's presence for a date. |
| `POST` | `/api/utilisateur` | Administrateur | Create a new base user account. |

### News

| Method | Endpoint | Roles | Purpose |
| --- | --- | --- | --- |
| `GET` | `/api/news` | Authenticated | Fetch and parse the CERT-FR RSS feed. |

## Database Model

The API maps to an existing relational schema through EF Core models:

- `Utilisateur`: base identity table.
- `Etudiant`, `Referent`, `Administrateur`: role/profile tables.
- `PFMP`: internship periods linked to a student, administrator,
  organisation, and planning.
- `Organisation`, `Professionnel`, `Travailler`: host organisation and
  supervisor relationships.
- `Planning`, `PlanningJours`: weekly schedule and day-level time slots.
- `Contacter`: student contact requests with organisations.
- `RapportJournalier`, `Remplir`: daily journal entries and student links.
- `TablePresence`: daily presence, absence, delay, and justification data.
- `Message`: PFMP chat messages.
- `Etablissement`, `GroupeClasse`, `Filiere`, `Etudier`, `Administrer`: school,
  class, program, student enrollment, and administrator assignment data.
- `RefreshToken`: hashed refresh tokens, rotation metadata, and fingerprint
  hashes.

Composite keys are configured in `AppDbContext` for join/link tables such as
`Remplir`, `Contacter`, `Travailler`, `Etudier`, `GroupeClasse`, and
`Administrer`.

## Security Notes

- Passwords are hashed with PBKDF2-SHA256, random salt, and 100,000 iterations.
- Refresh tokens are stored hashed in the database.
- Refresh-token reuse revokes the token family.
- JWT validation checks issuer, audience, lifetime, signing key, and the
  fingerprint hash.
- Authentication cookies are HttpOnly.
- Development cookie options currently use `Secure = false`; production
  deployments should use HTTPS and secure cookies.
- The JWT key in local configuration is a development value. Replace it outside
  local development.
- Never combine `AllowAnyOrigin()` with `AllowCredentials()` in CORS
  configuration — it's invalid for credentialed requests. List exact frontend
  origins instead.
- Persist ASP.NET Core's DataProtection key ring outside the container in
  production. Without it, every container restart invalidates existing
  cookies and tokens for all logged-in users.

## Testing And Quality

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

The repository currently contains a Flutter widget test scaffold under
`appli_pfmp/test`. No dedicated backend test project is present.

## Further Documentation

- [`docs/SETUP_WINDOWS.md`](docs/SETUP_WINDOWS.md) — Windows installer
  walkthrough (Git, Docker Desktop, .NET SDK, Flutter SDK).
- [`docs/SETUP_MACOS.md`](docs/SETUP_MACOS.md) — macOS installer walkthrough
  (Homebrew, Docker Desktop, .NET SDK, Flutter SDK).
- [`docs/SETUP_LINUX.md`](docs/SETUP_LINUX.md) — Linux installer walkthrough
  (apt-based, Docker Engine, .NET SDK, Flutter SDK).
- [`docs/DATABASE_BACKUP.md`](docs/DATABASE_BACKUP.md) — MySQL volume
  management, backup, and restore commands.
- [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) — common CORS/cookie/
  connection problems and a post-deploy verification checklist.
- [`docs/NGINX_PROXY.md`](docs/NGINX_PROXY.md) — what the Flutter Web
  reverse proxy does today and what's needed to finish wiring it up.
