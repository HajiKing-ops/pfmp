# 04 - Backend API

Technical basics:

- ASP.NET Core API in `PFMPManager.Api`.
- Routes under `/api`.
- Authentication via HttpOnly cookies: `AccessToken`, `RefreshToken`, `Fgp`.
- Roles are enforced with `[Authorize(Roles = "...")]` where present.
- DTOs live in `PFMPManager.Api/DTOs`.

The endpoints below are based on the controllers currently present in the code. No dedicated referent endpoint of the form `/api/referent/...` exists in the inspected code.

## Table of contents

- [Authentication](#authentication)
- [Student dashboard](#student-dashboard)
- [PFMP](#pfmp)
- [Applications](#applications)
- [Organizations](#organizations)
- [Logbook](#logbook)
- [Messages](#messages)
- [Administration](#administration)
- [Attendance](#attendance)
- [Users](#users)
- [News](#news)
- [Profile](#profile)
- [Endpoints with no confirmed frontend consumer](#endpoints-with-no-confirmed-frontend-consumer)

## Authentication

### `POST /api/login`

| Field | Value |
| --- | --- |
| Role | Public |
| Controller | `AuthController` |
| Body | `LoginRequestDto` |
| Response | `LoginResponseDto` + cookies |

Purpose: authenticate a user and open a session via HttpOnly cookies.

Body:

```json
{
  "login": "identifier",
  "pwd": "password"
}
```

200 response:

```json
{
  "id_Utilisateur": 1,
  "nom": "LastName",
  "prenom": "FirstName",
  "role": "Etudiant"
}
```

Rules:

- validates the login;
- validates the password with PBKDF2;
- determines the role with `RoleService`;
- creates a JWT access token;
- creates a raw refresh token, storing only its hash in the database;
- creates a fingerprint, storing its hash in the JWT and in the database;
- sets the `AccessToken`, `RefreshToken`, `Fgp` cookies.

Possible errors:

- `400`: empty login/password, or missing password hash;
- `401`: user not found or incorrect password;
- `404`: role not found;
- `500`: unhandled server error.

### `POST /api/login/refresh`

| Field | Value |
| --- | --- |
| Role | Session cookie |
| Controller | `AuthController` |
| Body | None |
| Response | `LoginResponseDto` + new cookies |

Purpose: renew the session (access token and refresh token) without re-entering credentials.

Rules:

- reads `RefreshToken` from the cookies;
- compares its hash against the database;
- rejects a revoked or expired token;
- revokes the whole token family if an already-used refresh token is replayed;
- compares the `Fgp` cookie against the stored hash;
- replaces the access token and the refresh token.

Possible errors:

- `400`: missing `RefreshToken` cookie;
- `401`: token not found, revoked, expired, user/role not found, or invalid fingerprint;
- `500`: unhandled server error.

### `POST /api/logout`

| Field | Value |
| --- | --- |
| Role | Session cookie |
| Controller | `AuthController` |
| Body | None |
| Response | Confirmation text |

Purpose: end the session and revoke the current refresh token.

Rules:

- reads `RefreshToken`;
- looks up its hash in the database;
- marks the token as revoked;
- clears `AccessToken`, `RefreshToken`, `Fgp`.

Possible errors:

- `400`: missing cookie;
- `401`: token not found or already revoked;
- `500`: unhandled server error.

## Student dashboard

### `GET /api/dashboard`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `DashboardController` |
| Response | `DashboardDto` |

Purpose: return data for the current student's active PFMP.

Response:

```json
{
  "dateDebut": "2026-08-20T00:00:00",
  "dateFin": "2026-09-20T00:00:00",
  "id_Planning": 1,
  "siret": "12345678900000",
  "idAdministrateur": 2,
  "idEtudiant": 3,
  "idPfmp": 4,
  "jourRestants": 10,
  "joursRenseignes": 5,
  "minutesTotales": 2100
}
```

Rules:

- looks for an active PFMP where `DateDebut <= today <= DateFin`;
- counts logbook entries within the period;
- reads the associated schedule.

Possible errors:

- `401`: invalid token;
- `403`: role is not student;
- `404`: no active PFMP, or schedule not found;
- `500`: unhandled server error.

## PFMP

### `GET /api/pfmp/recherche/{studentId}/{pfmpId?}`

| Field | Value |
| --- | --- |
| Role | `Etudiant`, `Enseignant` |
| Controller | `PfmpController` |
| Response | List of `PfmpDetailDto` |

Purpose: retrieve a student's PFMPs, with organization, workplace supervisor, and schedule details.

Parameters:

- `studentId`: id of the target student;
- `pfmpId`: optional, narrows to a single PFMP.

Access rules:

- a student can only read their own PFMPs;
- a teacher can only read PFMPs for students assigned to them via the `Etudiant` table.

Response:

```json
[
  {
    "dateDebut": "2026-08-20T00:00:00",
    "dateFin": "2026-09-20T00:00:00",
    "id_Planning": 1,
    "siret": "12345678900000",
    "idEtudiant": 3,
    "idPfmp": 4,
    "jourRestants": 10,
    "raisonSociale": "Company",
    "semaine": 4,
    "prenomMaitreStage": "FirstName",
    "nomMaitreStage": "LastName",
    "fonctionMaitreStage": "Supervisor",
    "telephoneMaitreStage": "0000000000",
    "emailMaitreStage": "mail@example.test",
    "planningJours": []
  }
]
```

Possible errors:

- `401`: invalid token;
- `403`: access denied;
- `404`: no PFMP found;
- `500`: unhandled server error.

### `POST /api/pfmp/complete`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `PfmpController` |
| Body | `CreateCompletePfmpDto` |
| Response | `PfmpDto` |

Purpose: create a complete PFMP (organization, schedule, workplace supervisor, initial attendance rows) from an accepted application.

Expected body:

```json
{
  "raisonSociale": "Company",
  "secteurActivite": "IT",
  "siret": "12345678900000",
  "adresse": "Address",
  "numTelephone": "0000000000",
  "siteWeb": "https://example.test",
  "totalHebdo": 2100,
  "planningJours": [
    {
      "jour": "Lundi",
      "matinDebut": "08:00:00",
      "matinFin": "12:00:00",
      "apresMidiDebut": "13:00:00",
      "apresMidiFin": "16:00:00",
      "totalMinutes": 420
    }
  ],
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

- all main fields are required, including `siteWeb`;
- `dateFin` must be greater than or equal to `dateDebut`;
- the schedule must contain at least one valid day;
- each day's total must match its time slots;
- the weekly total must match the computed value and be no more than 2100 minutes;
- an administrator must be found for the student's school for the current year;
- the student must have an `Accepte` application for the organization;
- the period must not overlap another PFMP for the same student;
- the organization must already exist;
- the workplace supervisor is created or found as a `Utilisateur` and a `Professionnel`;
- the `Travailler` relationship is created if needed;
- the schedule, schedule days, PFMP, and initial attendance rows are all created within a transaction.

Risks worth noting:

- the code creates the professional's user account with a temporary password of `test1234`;
- the current frontend appears not to send `siteWeb`, even though the API requires it;
- the current frontend appears to send hardcoded dates.

Possible errors:

- `400`: incomplete body, invalid schedule, application not accepted, overlap;
- `401`: invalid token;
- `403`: role is not student;
- `404`: administrator or organization not found;
- `500`: unhandled server error.

## Applications

### `GET /api/demarches`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `DemarcheController` |
| Response | List of `ContacterDto` |

Purpose: return the applications submitted by the current student.

Errors:

- `401`: invalid token;
- `403`: role is not student;
- `404`: no application or organization not found.

### `POST /api/demarches/{siret}`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `DemarcheController` |
| Body | `CreateContacterDto` |
| Response | `ContacterDto` |

Purpose: submit a new contact application to an organization.

Body:

```json
{
  "typeContact": "Mail",
  "dateDemande": "2026-07-07",
  "statutDemande": "En attente"
}
```

Rules:

- the organization must exist;
- the initial status must be `En attente`;
- only one application per student/SIRET pair.

Errors:

- `400`: invalid fields, or status other than `En attente`;
- `401` / `403`;
- `404`: organization not found;
- `409`: application already exists.

### `PUT /api/demarches/modify/{siret}`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `DemarcheController` |
| Body | `CreateContacterDto` |
| Response | `ContacterDto` |

Purpose: update the status of an existing application.

Accepted statuses:

- `En attente`;
- `Refuse`;
- `Accepte`.

Errors:

- `400`: invalid fields or unauthorized status;
- `401` / `403`;
- `404`: organization or application not found.

## Organizations

### `GET /api/entreprises`

| Field | Value |
| --- | --- |
| Role | Authenticated |
| Controller | `OrganisationController` |
| Response | List of `OrganisationDto` |

Purpose: return all organizations. No pagination visible.

### `GET /api/entreprises/recherche`

| Field | Value |
| --- | --- |
| Role | Authenticated |
| Controller | `OrganisationController` |
| Query | `nom`, `codePostal`, `secteur` |
| Response | List of `OrganisationDto` |

Purpose: search organizations by name, postal code, or sector.

Rules:

- `nom` uses `Contains`;
- `codePostal` uses an exact match;
- `secteur` uses `Contains`.

Errors:

- `401`: not authenticated;
- `404`: no results.

## Logbook

### `GET /api/journal`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `RapportJournalierController` |
| Response | List of `JournalDto` |

Purpose: return the current student's logbook entries.

Errors:

- `401` / `403`;
- `404`: no entries.

### `POST /api/journal`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `RapportJournalierController` |
| Body | `CreateJournalDto` |
| Response | `JournalDto` |

Purpose: add a logbook entry for a given date.

Body:

```json
{
  "dateRapport": "2026-08-21",
  "lienVersFichier": "Report text or link"
}
```

Rules:

- `LienVersFichier` is required;
- `DateRapport` is required;
- one of the student's PFMPs must cover that date;
- only one entry per day per PFMP.

Errors:

- `400`: missing required field;
- `404`: no PFMP covers that date;
- `409`: entry already exists.

### `PUT /api/journal/update/{id}`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `RapportJournalierController` |
| Body | `UpdateRapportJournalierDto` |
| Response | `JournalDto` |

Purpose: edit an existing logbook entry.

> Not consumed by the Flutter frontend in the files reviewed — see [05 - Flutter frontend guide](05-frontend-guide.md).

Rules:

- the entry must belong to one of the student's PFMPs;
- the new date must stay within the PFMP period.

Errors:

- `400`: invalid id/date/link, or date outside the period;
- `404`: entry not found.

### `GET /api/journal/alerte`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `RapportJournalierController` |
| Response | `{ idEtudiant, journalExiste }` |

Purpose: check whether the student already has an entry for today.

### `GET /api/journal/export/{idPfmp}`

| Field | Value |
| --- | --- |
| Role | `Etudiant` |
| Controller | `RapportJournalierController` |
| Response | `{ pfmp, journal }` object |

Purpose: export a PFMP's logbook entries as JSON.

> No Flutter page consuming this endpoint was identified in the files reviewed — to verify (see "Endpoints with no confirmed frontend consumer" at the end of this document).

Rules:

- the PFMP must belong to the current student;
- the PFMP's dates must be set;
- returns entries between `DateDebut` and `DateFin`.

### `GET /api/journal/pdf/{idPfmp}`

| Field | Value |
| --- | --- |
| Role | Authenticated, but effective access is restricted to the owning student |
| Controller | `RapportJournalierController` |
| Response | PDF file |

Purpose: generate and download a PFMP's logbook as a PDF (using QuestPDF).

Rules:

- the action is annotated `[Authorize]` (with no explicit role restriction);
- the code uses the current user's id as the student id;
- a teacher/admin therefore does not pass the check, unless their id happens to match the PFMP owner;
- generates a PDF with QuestPDF.

Errors:

- `400`: invalid id or missing dates;
- `401`: invalid token;
- `403`: PFMP not owned by the current user;
- `404`: student, organization, or entries not found.

## Messages

### `GET /api/messages/{idPfmp}`

| Field | Value |
| --- | --- |
| Role | Authenticated |
| Controller | `MessageController` |
| Response | List of `MessageResponseDto` |

Purpose: retrieve the message history for an active PFMP.

Rules:

- the PFMP must exist;
- the PFMP must be active;
- the user must be allowed to access the PFMP:
  - the owning student;
  - an assigned teacher;
  - an administrator linked to the student's schools/classes.

Errors:

- `400`: PFMP not active;
- `401`: invalid token;
- `403`: access denied;
- `404`: PFMP does not exist.

### `POST /api/messages/{idPfmp}`

| Field | Value |
| --- | --- |
| Role | Authenticated |
| Controller | `MessageController` |
| Body | `MessageRequestDto` |
| Response | `MessageResponseDto` |

Purpose: send a new message on an active PFMP.

Body:

```json
{
  "contenu": "Message"
}
```

Rules:

- content is required;
- same PFMP checks as for the history endpoint;
- `RoleExpediteur` is taken from the JWT.

## Administration

### `GET /api/administrateur`

| Field | Value |
| --- | --- |
| Role | `Administrateur` |
| Controller | `AdministrateurController` |
| Response | `{ adminRowDto, stat }` |

Purpose: return PFMP rows and statistics for the schools this administrator manages.

Errors:

- `401` / `403`;
- `404`: administrator, school, class, student, or PFMP not found.

### `GET /api/administrateur/recherche`

| Field | Value |
| --- | --- |
| Role | `Administrateur` |
| Controller | `AdministrateurController` |
| Query | `nomRecherche`, `entrepriseRecherche`, `status`, `idEtablissement`, `idClasse` |
| Response | `{ adminRowDto, stat }` |

Purpose: filter visible PFMPs by name, company, status, school, or class.

Accepted statuses:

- `tous` (all);
- `encours` (in progress);
- `valide` (validated);
- `incomplet` (incomplete).

Rules:

- `idEtablissement` and `idClasse` must be provided together;
- the filtered school must belong to the administrator;
- statistics are recalculated after filtering.

Errors:

- `400`: invalid status, or partial class/school filter;
- `403`: school not authorized for this admin;
- `404`: no results.

### `GET /api/administrateur/classes`

| Field | Value |
| --- | --- |
| Role | `Administrateur` |
| Controller | `AdministrateurController` |
| Response | List of `AdminClassStatsDto` |

Purpose: return statistics grouped by class.

Fields:

- `idEtablissement`;
- `idClasse`;
- `libelleFiliere`;
- `nombreEleves`;
- `enCours`;
- `presence`;
- `absence`;
- `tauxPresence`.

TODO: the frontend first tries `/api/administrateur/classes/stats`, then falls back to `/api/administrateur/classes`. Only `/api/administrateur/classes` exists on the backend.

## Attendance

### `POST /api/presence/initialiser`

| Field | Value |
| --- | --- |
| Role | `Administrateur` |
| Controller | `TablePreseceController` *(spelling as observed in the inspected code — to verify)* |
| Body | None |

Purpose: create or update today's attendance rows for the active PFMPs managed by the current administrator.

Rules:

- does nothing on Saturday/Sunday;
- looks for active PFMPs today where `Pfmp.Id_Utilisateur` matches the logged-in admin;
- limited to days present in `PlanningJours`;
- turns today's `NON_RENSEIGNE` attendance rows into `PRESENT`;
- creates any missing rows for today as `PRESENT`.

Responses:

- `200` with a message if it's the weekend, already initialized, or there is no active PFMP;
- `401` / `403` otherwise.

### `PUT /api/presence/update/{studentId}`

| Field | Value |
| --- | --- |
| Role | `Enseignant`, `Administrateur` |
| Controller | `TablePreseceController` *(spelling as observed in the inspected code — to verify)* |
| Body | `UpdateTablePresenceDto` |

Purpose: update a student's attendance status for a given date.

Body:

```json
{
  "etat": "PRESENT",
  "retard": 0,
  "dateJour": "2026-08-21",
  "justification": false
}
```

Rules:

- `etat` must be `PRESENT` or `ABSENT`;
- `retard` (lateness, in minutes) must be zero or positive;
- the date is required;
- a teacher must be linked to the student, and the date must fall within the PFMP;
- an administrator must be the administrator of the PFMP, and the date must fall within the PFMP;
- if `ABSENT`, `Retard` is forced to 0;
- if `PRESENT`, the submitted lateness value is kept.

Possible errors:

- `400`: invalid body;
- `401` / `403`;
- `404`: no attendance row found for that date.

TODO: the frontend also tries `PUT /api/presence/modify` first. This `modify` endpoint does not currently exist on the backend.

## Users

### `POST /api/utilisateur`

| Field | Value |
| --- | --- |
| Role | `Administrateur` |
| Controller | `UtilisateurController` |
| Body | `CreateUtilisateurDto` |
| Response | `CreateUtilisateurDto` without the password |

Purpose: create a base `Utilisateur` account.

Body:

```json
{
  "nom": "LastName",
  "prenom": "FirstName",
  "login": "login@example.test",
  "pwd": "password"
}
```

Rules:

- hashes the password with `PasswordHelper`;
- creates only a `Utilisateur` row.

TODO: creating the role profile (`Etudiant`, `Referent`, `Administrateur`) is not visible in this endpoint. No Flutter screen for user creation was identified in the files reviewed either — to verify.

## News

### `GET /api/news`

| Field | Value |
| --- | --- |
| Role | Authenticated |
| Controller | `NewsController` |
| Response | List of `NewsDto` |

Purpose: read the CERT-FR RSS feed and return title, link, description, and date.

Errors:

- `401`: not authenticated;
- `500`: unable to fetch or parse the feed.

> No Flutter page consuming this endpoint was identified in the files reviewed — to verify (see "Endpoints with no confirmed frontend consumer" below).

## Profile

`ProfileController` exists with `[Route("api/profile")]`, but the `ProfileMe()` action has no `[HttpGet]`, `[Authorize]`, or explicit route attribute in the inspected code.

The frontend tries:

- `GET /api/profile/me`;
- `GET /api/profile`;
- `GET /api/etudiants/me/profile`;
- `PUT /api/profile/me`;
- `PUT /api/etudiants/me/profile`.

TODO: verify or finalize the profile controller before documenting these endpoints as available.

## Endpoints with no confirmed frontend consumer

This section brings together, in one place, the backend endpoints for which **no Flutter page or call was identified** in the [05 - Flutter frontend guide](05-frontend-guide.md) files reviewed for this documentation. This does not mean these endpoints are useless or broken — only that their frontend consumption could not be confirmed with the files available.

| Endpoint | Finding |
| --- | --- |
| `GET /api/news` | Exists on the backend (CERT-FR RSS feed). No "News" page appears in the Flutter navigation described in `05-frontend-guide.md`. |
| `GET /api/journal/export/{idPfmp}` | Exists on the backend (JSON export). Only the PDF export (`GET /api/journal/pdf/{idPfmp}`) is described as used by `My PFMPs`. |
| `POST /api/utilisateur` | Restricted to administrators. No user-creation screen is described in the admin tabs (`Supervision`, `Class management`, `Messaging`, the "Initialize attendance" action). |
| `PUT /api/journal/update/{id}` | Confirmed unused — explicitly flagged as such in `05-frontend-guide.md`. |

TODO: for each row, confirm whether it is a missing screen to build, an existing screen that simply isn't documented, or a genuinely unused endpoint to remove.
