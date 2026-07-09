# 05 - Frontend Guide

The frontend is located in `appli_pfmp`. It is a Flutter application, mainly used as Flutter Web in this repository.

## Project Structure

```text
appli_pfmp/lib/
|-- application/      # Main screens
|-- bloc/             # BLoC events, states, and logic
|-- custom/           # Widgets, colors, helpers, responsive utilities
|-- data/             # HTTP API calls
|-- helpers/          # Utility functions
|-- model/            # Dart models
`-- main.dart         # Application entry point and main navigation
```

## Entry Point and Navigation

`main.dart` creates a `MaterialApp` with these BLoC providers:

- `AuthentificationBloc`;
- `PfmpBloc`;
- `EntreeJournalBloc`;
- `DemarcheBloc`;
- `InfosAdminBloc`.

The initial screen is `PageAuth`.

After login:

- role `Administrateur` opens `AccueilAdmin`;
- role `Etudiant` opens the student shell `PfmpManager`;
- any other role currently shows `Utilisateur inconnu`.

This means the backend has partial Teacher / Referent support, but no dedicated Flutter Teacher / Referent area is currently wired.

## API Calls

Files in `lib/data` use `BrowserClient()..withCredentials = true`.

Implications:

- the frontend does not send an `Authorization` header;
- the browser sends HttpOnly cookies automatically;
- Flutter does not read the JWT directly;
- API URLs are relative, such as `/api/login` and `/api/dashboard`.

In Docker, Nginx forwards `/api/...` to the ASP.NET Core API container. When running Flutter directly with `flutter run`, verify how `/api` is routed because the Flutter development server does not proxy it automatically.

## Authentication Behavior

Relevant files:

- `application/authentification.dart`;
- `bloc/authentification_bloc/*`;
- `data/authentification_api.dart`.

Flow:

1. The user enters login and password.
2. `AuthentificationBloc` calls `loginRequest`.
3. `POST /api/login` returns user information and sets cookies.
4. The returned role controls navigation.
5. `logout()` calls `POST /api/logout` and returns to `PageAuth`.

Visible states:

- local form validation;
- loading indicator after successful login transition;
- error message for empty credentials, invalid credentials, or unreachable server.

## Student Area

Main student navigation in `PfmpManager`:

| Page | Widget | Purpose |
| --- | --- | --- |
| Dashboard | `Accueil` | PFMP dashboard, statistics, daily report reminders. |
| PFMP Search | `RecherchePfmp` | Contact request management and external map link. |
| Daily Report | `JournalBord` | Daily report list and creation. |
| Messaging | `Messagerie` | Messages for the active PFMP. |
| My PFMPs | `MesPfmp` | PFMP list, PFMP creation, PDF export. |
| My Profile | `MonProfil` | Student profile display through profile endpoints to verify. |

### Dashboard

Relevant files:

- `application/accueil.dart`;
- `data/dashboard_api.dart`;
- `data/journal_api.dart`;
- `helpers/pfmp_stats.dart`.

The dashboard loads PFMPs, dashboard data, daily report counts, and planned PFMP hours. Daily report reminders are stored in browser `localStorage` for Flutter Web.

### PFMP Search and Contact Requests

Relevant files:

- `application/recherche_pfmp.dart`;
- `application/formulaire_nouvelle_demarche.dart`;
- `application/formulaire_modif_demarche.dart`;
- `data/demarche_api.dart`.

Features:

- list the connected student's contact requests;
- create a new `En attente` request;
- update a request to `En attente`, `Refuse`, or `Accepte`;
- open an external Google Maps link.

### My PFMPs and PFMP Creation

Relevant files:

- `application/mes_pfmp.dart`;
- `application/formulaire_nouvelle_pfmp.dart`;
- `data/pfmp_api.dart`;
- `custom/custom_functions/format_planning.dart`;
- `custom/custom_functions/calculs_horaires.dart`.

Features:

- load student PFMPs;
- show a `+ Nouvelle PFMP` action;
- build a weekly schedule from selected days and time slots;
- call `POST /api/pfmp/complete`;
- open `/api/journal/pdf/{idPfmp}` with `Uri.base.resolve`.

TODO / risks:

- the form has `siteWebController`, but the inspected payload does not include `siteWeb`;
- the backend requires `siteWeb`;
- the inspected payload currently uses hardcoded PFMP dates `2026-08-20` and `2026-09-20`;
- verify this before demonstrating PFMP creation.

### Daily Reports

Relevant files:

- `application/journal_de_bord.dart`;
- `bloc/journal_bloc/*`;
- `data/journal_api.dart`.

Features:

- load daily reports with `GET /api/journal`;
- create a report with `POST /api/journal`;
- check today's report with `GET /api/journal/alerte`.

The backend has `PUT /api/journal/update/{id}`, but the inspected frontend code does not clearly use it.

### Student Messaging

Relevant files:

- `application/messagerie.dart`;
- `data/message_api.dart`.

Features:

- selects the active PFMP;
- loads message history with `/api/messages/{idPfmp}`;
- sends messages;
- shows loading, empty, and error states.

The backend only allows messaging for active PFMPs and authorized users.

### Student Profile

Relevant files:

- `application/mon_profil.dart`;
- `data/profile_api.dart`;
- `model/profile.dart`.

The frontend tries several profile endpoints:

- `GET /api/profile/me`;
- `GET /api/profile`;
- `GET /api/etudiants/me/profile`;
- `PUT /api/profile/me`;
- `PUT /api/etudiants/me/profile`.

TODO: the backend profile controller must be verified or completed before these routes are considered stable.

## Administrator Area

Main file: `application/accueil_admin.dart`.

| Tab/action | Widget | Purpose |
| --- | --- | --- |
| Supervision | `SupervisionAdmin` | PFMP list/table, filters, statistics, attendance updates. |
| Period management | `PeriodesAdmin` | Class statistics and students in a selected class. |
| Messaging | `MessagerieAdmin` | Messages for visible active PFMPs. |
| Drawer action | Attendance initialization | Calls `/api/presence/initialiser`. |

### Admin Supervision

Relevant files:

- `application/supervision_admin.dart`;
- `data/infos_admin_api.dart`;
- `data/presence_api.dart`;
- `model/infos_admin.dart`.

Features:

- display `stageTotal`, `encours`, `valide`, and `absencesTotal`;
- filter by status and student name;
- show a responsive table/card layout;
- open an attendance dialog;
- send attendance updates.

To verify:

- `presence_api.dart` first tries `PUT /api/presence/modify`;
- if it receives 404 or 405, it falls back to `PUT /api/presence/update/{idEtudiant}`;
- `/api/presence/modify` is not confirmed in backend code.

### Period Management

Relevant files:

- `application/periodes_admin.dart`;
- `data/infos_admin_api.dart`;
- `model/admin_class_stats.dart`.

Features:

- load class statistics;
- first try `/api/administrateur/classes/stats`, then fallback to `/api/administrateur/classes`;
- select a class;
- load students with `/api/administrateur/recherche?idEtablissement=...&idClasse=...`.

Only `/api/administrateur/classes` is confirmed in backend code.

### Admin Messaging

Relevant files:

- `application/messagerie_admin.dart`;
- `data/message_api.dart`.

Features:

- selects active PFMP conversations among visible students;
- loads and sends messages through `/api/messages/{idPfmp}`;
- handles loading, empty, and error states.

## Teacher / Referent Area

No dedicated Flutter Teacher / Referent area is currently wired in `main.dart`.

Backend support exists for:

- `GET /api/pfmp/recherche/{studentId}/{pfmpId?}`;
- `PUT /api/presence/update/{studentId}`;
- `GET /api/messages/{idPfmp}`;
- `POST /api/messages/{idPfmp}`.

TODO: create or wire a Teacher / Referent frontend area if this role must be available to users.

## Loading and Error Handling

Patterns visible in the frontend:

- `CircularProgressIndicator` during loading;
- BLoC states such as `Loading`, `Success`, and `Error`;
- SnackBar messages for user actions;
- empty states in several pages;
- fallback endpoint attempts in profile, attendance, and admin class APIs.

## Frontend Risks and To Verify

- Relative `/api` URLs work with Nginx but require routing/proxy verification when using `flutter run` directly.
- Teacher / Referent UI is missing.
- Profile frontend exists but backend routing is not confirmed.
- PFMP creation must be verified for `siteWeb` and hardcoded dates.
- Some existing source comments/text may contain encoding issues; this documentation avoids relying on those comments for behavior.
