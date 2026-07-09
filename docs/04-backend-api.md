# 04 - Backend API

The backend API is implemented in `PFMPManager.Api` with ASP.NET Core controllers. Routes are exposed under `/api`. Authentication uses HttpOnly cookies and role-based authorization.

This document lists only endpoints confirmed in the current controllers. Missing Teacher / Referent endpoints are documented as future TODOs, not as existing routes.

## Authentication

### `POST /api/login`

| Item | Details |
| --- | --- |
| Controller | `AuthController` |
| Required role | Public |
| Request body | `LoginRequestDto` |
| Response | `LoginResponseDto` and auth cookies |

Request:

```json
{
  "login": "username",
  "pwd": "password"
}
```

Response shape:

```json
{
  "id_Utilisateur": 1,
  "nom": "LastName",
  "prenom": "FirstName",
  "role": "Etudiant"
}
```

Business rules:

- validates the login and password;
- verifies the password with `PasswordHelper`;
- resolves the role with `RoleService`;
- creates a JWT access token;
- creates a refresh token and stores only its hash;
- creates a fingerprint and stores only its hash in the token/database;
- sets `AccessToken`, `RefreshToken`, and `Fgp` HttpOnly cookies.

Error cases:

- `400`: missing login/password or invalid stored password hash;
- `401`: user not found or invalid password;
- `404`: role not found;
- `500`: unhandled server error.

### `POST /api/login/refresh`

| Item | Details |
| --- | --- |
| Controller | `AuthController` |
| Required role | Existing cookie session |
| Request body | None |
| Response | `LoginResponseDto` and rotated cookies |

Business rules:

- reads `RefreshToken` from cookies;
- hashes it before database lookup;
- rejects missing, unknown, revoked, or expired tokens;
- revokes the token family if a rotated token is reused;
- validates the `Fgp` cookie against the stored fingerprint hash;
- rotates the refresh token and issues a new access token.

Error cases:

- `400`: missing `RefreshToken` cookie;
- `401`: invalid token, expired token, revoked token, missing role/user, or invalid fingerprint;
- `500`: unhandled server error.

### `POST /api/logout`

| Item | Details |
| --- | --- |
| Controller | `AuthController` |
| Required role | Existing cookie session |
| Request body | None |
| Response | Text confirmation |

Business rules:

- reads the refresh token from cookies;
- revokes the matching refresh token in the database;
- deletes `AccessToken`, `RefreshToken`, and `Fgp`.

Error cases:

- `400`: missing refresh token cookie;
- `401`: token not found or already revoked;
- `500`: unhandled server error.

## Student Dashboard

### `GET /api/dashboard`

| Item | Details |
| --- | --- |
| Controller | `DashboardController` |
| Required role | `Etudiant` |
| Response | `DashboardDto` |

Purpose: returns dashboard data for the connected student's active PFMP.

Business rules:

- finds the active PFMP where `DateDebut <= today <= DateFin`;
- counts daily reports inside the active PFMP period;
- loads the linked `Planning`.

Error cases:

- `401`: invalid token;
- `403`: user is not `Etudiant`;
- `404`: no active PFMP or missing planning;
- `500`: unhandled server error.

## PFMP

### `GET /api/pfmp/recherche/{studentId}/{pfmpId?}`

| Item | Details |
| --- | --- |
| Controller | `PfmpController` |
| Required role | `Etudiant`, `Enseignant` |
| Response | List of `PfmpDetailDto` |

Purpose: returns PFMP details for a student, optionally limited to one PFMP.

Access rules:

- a Student can read only their own PFMPs;
- a Teacher / Referent can read only assigned students' PFMPs through `PfmpAccessService`.

Response includes:

- PFMP dates and identifiers;
- organisation name;
- internship supervisor details when found;
- remaining days and week count;
- schedule days.

Error cases:

- `401`: invalid token;
- `403`: access denied;
- `404`: no PFMP found;
- `500`: unhandled server error.

### `POST /api/pfmp/complete`

| Item | Details |
| --- | --- |
| Controller | `PfmpController` |
| Required role | `Etudiant` |
| Request body | `CreateCompletePfmpDto` |
| Response | `PfmpDto` |

Purpose: creates a complete PFMP with organisation, internship supervisor, schedule, attendance rows, and PFMP record.

Important request fields:

```json
{
  "raisonSociale": "Company",
  "secteurActivite": "IT",
  "siret": "12345678900000",
  "adresse": "Address",
  "numTelephone": "0000000000",
  "siteWeb": "https://example.test",
  "totalHebdo": 2100,
  "planningJours": [],
  "dateDebut": "2026-08-20",
  "dateFin": "2026-09-20",
  "prenomMaitreStage": "FirstName",
  "nomMaitreStage": "LastName",
  "fonctionMaitreStage": "Supervisor",
  "telephoneMaitreStage": "0000000000",
  "emailMaitreStage": "mail@example.test"
}
```

Business rules:

- required fields must be present, including `siteWeb`;
- `DateFin` must be greater than or equal to `DateDebut`;
- schedule days are validated by `PlanningValidationService`;
- the calculated weekly total must match `TotalHebdo`;
- weekly total must be greater than 0 and not exceed 2100 minutes;
- an administrator must be found for the student's establishment in the current school year;
- the student must have an accepted contact request for the organisation;
- the requested period must not overlap another PFMP for the same student;
- the organisation must exist;
- the supervisor user/profile and `Travailler` relation are created or reused;
- the planning, planning days, PFMP, and attendance rows are created in a transaction.

Known risks:

- the backend creates a supervisor user with temporary password `test1234`;
- the current Flutter form appears not to send `siteWeb`;
- the current Flutter form appears to use hardcoded PFMP dates.

Error cases:

- `400`: invalid request, invalid schedule, missing accepted contact request, or overlapping PFMP;
- `401`: invalid token;
- `403`: user is not `Etudiant`;
- `404`: administrator or organisation not found;
- `500`: unhandled server error.

## Contact Requests

### `GET /api/demarches`

| Item | Details |
| --- | --- |
| Controller | `DemarcheController` |
| Required role | `Etudiant` |
| Response | List of `ContacterDto` |

Purpose: returns contact requests for the connected student.

Error cases:

- `401`: invalid token;
- `403`: user is not `Etudiant`;
- `404`: no contact request or organisation not found.

### `POST /api/demarches/{siret}`

| Item | Details |
| --- | --- |
| Controller | `DemarcheController` |
| Required role | `Etudiant` |
| Request body | `CreateContacterDto` |
| Response | `ContacterDto` |

Request:

```json
{
  "typeContact": "Email",
  "dateDemande": "2026-07-07",
  "statutDemande": "En attente"
}
```

Business rules:

- the organisation must exist;
- the initial status must be `En attente`;
- duplicate contact requests for the same student and SIRET are rejected.

Error cases:

- `400`: invalid fields or invalid initial status;
- `401` / `403`: authentication or role problem;
- `404`: organisation not found;
- `409`: contact request already exists.

### `PUT /api/demarches/modify/{siret}`

| Item | Details |
| --- | --- |
| Controller | `DemarcheController` |
| Required role | `Etudiant` |
| Request body | `CreateContacterDto` |
| Response | `ContacterDto` |

Accepted statuses:

- `En attente`;
- `Refuse`;
- `Accepte`.

Error cases:

- `400`: invalid fields or invalid status;
- `401` / `403`: authentication or role problem;
- `404`: organisation or contact request not found.

## Organisations

### `GET /api/entreprises`

| Item | Details |
| --- | --- |
| Controller | `OrganisationController` |
| Required role | Authenticated |
| Response | List of `OrganisationDto` |

Purpose: returns all organisations. No pagination is currently visible.

### `GET /api/entreprises/recherche`

| Item | Details |
| --- | --- |
| Controller | `OrganisationController` |
| Required role | Authenticated |
| Query parameters | `nom`, `codePostal`, `secteur` |
| Response | List of `OrganisationDto` |

Filtering rules:

- `nom` uses `Contains`;
- `codePostal` uses exact match;
- `secteur` uses `Contains`.

Error cases:

- `401`: not authenticated;
- `404`: no result.

## Daily Reports

### `GET /api/journal`

| Item | Details |
| --- | --- |
| Controller | `RapportJournalierController` |
| Required role | `Etudiant` |
| Response | List of `JournalDto` |

Purpose: returns daily reports for the connected student.

Error cases:

- `401` / `403`: authentication or role problem;
- `404`: no daily report found.

### `POST /api/journal`

| Item | Details |
| --- | --- |
| Controller | `RapportJournalierController` |
| Required role | `Etudiant` |
| Request body | `CreateJournalDto` |
| Response | `JournalDto` |

Request:

```json
{
  "dateRapport": "2026-08-21",
  "lienVersFichier": "Daily report content or link"
}
```

Business rules:

- `LienVersFichier` is required;
- `DateRapport` is required;
- a PFMP belonging to the student must cover the report date;
- only one report per day and PFMP is allowed.

Error cases:

- `400`: required field missing;
- `404`: no PFMP found for the date;
- `409`: daily report already exists for that day.

### `PUT /api/journal/update/{id}`

| Item | Details |
| --- | --- |
| Controller | `RapportJournalierController` |
| Required role | `Etudiant` |
| Request body | `UpdateRapportJournalierDto` |
| Response | `JournalDto` |

Business rules:

- the report must belong to a PFMP owned by the connected student;
- the updated report date must remain inside the PFMP period.

Error cases:

- `400`: invalid id, link, date, or date outside PFMP period;
- `404`: daily report not found.

### `GET /api/journal/alerte`

| Item | Details |
| --- | --- |
| Controller | `RapportJournalierController` |
| Required role | `Etudiant` |
| Response | `{ idEtudiant, journalExiste }` |

Purpose: checks whether the connected student already has a daily report for today.

### `GET /api/journal/export/{idPfmp}`

| Item | Details |
| --- | --- |
| Controller | `RapportJournalierController` |
| Required role | `Etudiant` |
| Response | Object containing `pfmp` and `journal` |

Business rules:

- the PFMP must belong to the connected student;
- PFMP dates must be present;
- reports are returned for the PFMP date range.

### `GET /api/journal/pdf/{idPfmp}`

| Item | Details |
| --- | --- |
| Controller | `RapportJournalierController` |
| Required role | Authenticated, but effective access is student owner only |
| Response | PDF file |

Important note: the action has `[Authorize]`, but the implementation uses the connected user id as the student id and requires the PFMP to belong to that user. Administrator or Teacher / Referent PDF access is therefore not confirmed in code.

Error cases:

- `400`: invalid PFMP id or missing PFMP dates;
- `401`: invalid token;
- `403`: PFMP not owned by the connected user;
- `404`: student, organisation, or reports not found.

## Messages

### `GET /api/messages/{idPfmp}`

| Item | Details |
| --- | --- |
| Controller | `MessageController` |
| Required role | Authenticated |
| Response | List of `MessageResponseDto` |

Business rules:

- the PFMP must exist;
- the PFMP must be active;
- the connected user must be allowed to access it:
  - student owner;
  - assigned teacher/referent;
  - administrator in the student establishment/class scope.

Error cases:

- `400`: PFMP inactive;
- `401`: invalid token;
- `403`: access denied;
- `404`: PFMP does not exist.

### `POST /api/messages/{idPfmp}`

| Item | Details |
| --- | --- |
| Controller | `MessageController` |
| Required role | Authenticated |
| Request body | `MessageRequestDto` |
| Response | `MessageResponseDto` |

Request:

```json
{
  "contenu": "Message"
}
```

Business rules:

- content is required;
- the same PFMP access checks as the history endpoint apply;
- `RoleExpediteur` is taken from the JWT role.

## Administration

### `GET /api/administrateur`

| Item | Details |
| --- | --- |
| Controller | `AdministrateurController` |
| Required role | `Administrateur` |
| Response | `{ adminRowDto, stat }` |

Purpose: returns PFMP dashboard rows and global statistics for establishments managed by the connected administrator.

Error cases:

- `401` / `403`: authentication or role problem;
- `404`: administrator, establishment, class, student, or PFMP not found.

### `GET /api/administrateur/recherche`

| Item | Details |
| --- | --- |
| Controller | `AdministrateurController` |
| Required role | `Administrateur` |
| Query parameters | `nomRecherche`, `entrepriseRecherche`, `status`, `idEtablissement`, `idClasse` |
| Response | `{ adminRowDto, stat }` |

Accepted `status` values:

- `tous`;
- `encours`;
- `valide`;
- `incomplet`.

Business rules:

- `idEtablissement` and `idClasse` must be provided together;
- the establishment must be managed by the connected administrator;
- statistics are recalculated after filtering.

Error cases:

- `400`: invalid status or incomplete establishment/class filter;
- `403`: establishment not allowed;
- `404`: no result.

### `GET /api/administrateur/classes`

| Item | Details |
| --- | --- |
| Controller | `AdministrateurController` |
| Required role | `Administrateur` |
| Response | List of `AdminClassStatsDto` |

Purpose: returns class-level PFMP and attendance statistics.

Fields include:

- `idEtablissement`;
- `idClasse`;
- `libelleFiliere`;
- `nombreEleves`;
- `enCours`;
- `presence`;
- `absence`;
- `tauxPresence`.

TODO: the frontend first tries `/api/administrateur/classes/stats`, then falls back to `/api/administrateur/classes`. Only `/api/administrateur/classes` is confirmed in the backend.

## Attendance

### `POST /api/presence/initialiser`

| Item | Details |
| --- | --- |
| Controller | `TablePreseceController` |
| Required role | `Administrateur` |
| Request body | None |

Purpose: initializes attendance for the current day for active PFMPs managed by the connected administrator.

Business rules:

- does nothing on Saturday or Sunday;
- finds active PFMPs for the current day where `Pfmp.Id_Utilisateur` matches the administrator id;
- limits creation to days present in `PlanningJours`;
- updates `NON_RENSEIGNE` rows to `PRESENT`;
- creates missing rows as `PRESENT`.

Responses:

- `200` with a message for weekend, already initialized, or no active PFMP;
- `401` / `403` for authentication or role problems.

### `PUT /api/presence/update/{studentId}`

| Item | Details |
| --- | --- |
| Controller | `TablePreseceController` |
| Required role | `Enseignant`, `Administrateur` |
| Request body | `UpdateTablePresenceDto` |

Request:

```json
{
  "etat": "PRESENT",
  "retard": 0,
  "dateJour": "2026-08-21",
  "justification": false
}
```

Business rules:

- `Etat` must be `PRESENT` or `ABSENT`;
- `Retard` must be zero or positive;
- `DateJour` is required;
- a Teacher / Referent must be assigned to the student and the date must be inside the PFMP;
- an Administrator must be the PFMP administrator and the date must be inside the PFMP;
- if `ABSENT`, lateness is forced to `0`;
- if `PRESENT`, the provided lateness is kept.

Error cases:

- `400`: invalid request;
- `401` / `403`: authentication, role, or scope problem;
- `404`: no attendance row found for that student and date.

TODO: the frontend also tries `PUT /api/presence/modify` before falling back to this endpoint. That `modify` endpoint is not confirmed in backend code.

## Users

### `POST /api/utilisateur`

| Item | Details |
| --- | --- |
| Controller | `UtilisateurController` |
| Required role | `Administrateur` |
| Request body | `CreateUtilisateurDto` |
| Response | `CreateUtilisateurDto` without password |

Request:

```json
{
  "nom": "LastName",
  "prenom": "FirstName",
  "login": "login@example.test",
  "pwd": "password"
}
```

Business rules:

- hashes the password with `PasswordHelper`;
- creates only a base `Utilisateur` row.

TODO: this endpoint does not create the role profile (`Etudiant`, `Referent`, or `Administrateur`) in the inspected code.

## News

### `GET /api/news`

| Item | Details |
| --- | --- |
| Controller | `NewsController` |
| Required role | Authenticated |
| Response | List of `NewsDto` |

Purpose: fetches and parses the CERT-FR RSS feed.

Error cases:

- `401`: not authenticated;
- `500`: unable to fetch or parse the feed.

## Profile

`ProfileController` exists with `[Route("api/profile")]`, but `ProfileMe()` does not have an explicit `[HttpGet]`, `[Authorize]`, or route attribute in the inspected code.

The frontend currently tries:

- `GET /api/profile/me`;
- `GET /api/profile`;
- `GET /api/etudiants/me/profile`;
- `PUT /api/profile/me`;
- `PUT /api/etudiants/me/profile`.

TODO: verify or complete the profile controller before documenting these as working endpoints.
