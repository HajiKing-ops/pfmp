# 05 - Flutter frontend guide

The frontend lives in `appli_pfmp`. It is a Flutter application that mainly targets Flutter Web in this repository.

## Structure

```text
appli_pfmp/lib/
|-- application/      # Main screens
|-- bloc/             # BLoC events/states/logic
|-- custom/           # Widgets, colors, helpers, responsive layout
|-- data/             # HTTP API calls
|-- helpers/          # Utility functions
|-- model/            # Dart models
`-- main.dart         # Entry point and top-level navigation
```

## Entry point

`main.dart` creates a `MaterialApp` with several BLoCs:

- `AuthentificationBloc`;
- `PfmpBloc`;
- `EntreeJournalBloc`;
- `DemarcheBloc`;
- `InfosAdminBloc`.

The initial screen is `PageAuth`.

After login:

- role `Administrateur` -> `AccueilAdmin`;
- role `Etudiant` -> student shell `PfmpManager`;
- any other role -> `Utilisateur inconnu` ("unknown user") screen.

Conclusion: the `Enseignant` role exists on the API side, but has no Flutter shell wired up currently.

## API calls

Files in `lib/data` use `BrowserClient()..withCredentials = true`.

This means:

- the frontend never sends an `Authorization` header;
- HttpOnly cookies are sent by the browser itself;
- the JWT is never read by the Flutter code;
- URLs are relative: `/api/login`, `/api/dashboard`, etc.

In Docker, relative URLs go through the Nginx proxy. In direct Flutter development, you need to check the local proxy, since `flutter run -d chrome` does not automatically redirect `/api` to ASP.NET Core.

## Authentication

Files:

- `application/authentification.dart`;
- `bloc/authentification_bloc/*`;
- `data/authentification_api.dart`.

Flow:

1. The user enters their login and password.
2. `AuthentificationBloc` calls `loginRequest`.
3. `POST /api/login` returns the user and sets the cookies.
4. The role determines the navigation.
5. `logout()` calls `POST /api/logout`, then returns to `PageAuth`.

Visible states:

- form with local login validation;
- loader during the transition after success;
- error message for empty fields, incorrect credentials, or an unreachable server.

## Student area

Main navigation inside `PfmpManager`:

| Page | Widget | Function |
| --- | --- | --- |
| Home | `Accueil` | Dashboard, PFMP stats, logbook reminders. |
| Find a PFMP | `RecherchePfmp` | Contact applications and a link to Google Maps. |
| Logbook | `JournalBord` | List and creation of logbook entries. |
| Messaging | `Messagerie` | Messages for the active PFMP. |
| My PFMPs | `MesPfmp` | List of PFMPs, PFMP creation, PDF export. |
| My profile | `MonProfil` | Displays the student profile via profile endpoints that need to be verified. |

### Student home

Files:

- `application/accueil.dart`;
- `data/dashboard_api.dart`;
- `data/journal_api.dart`;
- `helpers/pfmp_stats.dart`.

Functions:

- loads PFMPs with `PfmpBloc`;
- loads `/api/dashboard`;
- counts logbook entries;
- computes scheduled hours across PFMPs;
- suggests logbook reminders stored in web `localStorage`.

### Find a PFMP

Files:

- `application/recherche_pfmp.dart`;
- `application/formulaire_nouvelle_demarche.dart`;
- `application/formulaire_modif_demarche.dart`;
- `data/demarche_api.dart`.

Functions:

- lists the student's applications;
- creates an application with status `En attente`;
- edits an application to `En attente`, `Refuse`, or `Accepte`;
- shows a link to an external Google Maps view.

### My PFMPs and PFMP creation

Files:

- `application/mes_pfmp.dart`;
- `application/formulaire_nouvelle_pfmp.dart`;
- `data/pfmp_api.dart`;
- `custom/custom_functions/format_planning.dart`;
- `custom/custom_functions/calculs_horaires.dart`.

Functions:

- loads the student's PFMPs;
- shows a `+ New PFMP` button;
- builds a schedule across days and time slots;
- sends `POST /api/pfmp/complete`;
- opens `/api/journal/pdf/{idPfmp}` via `Uri.base.resolve`.

TODO / risks found:

- the form has a `siteWebController`, but the inspected payload does not include `siteWeb`;
- the API requires `siteWeb`;
- the dates currently sent are hardcoded as `2026-08-20` and `2026-09-20`;
- to verify before any live demo of PFMP creation.

### Logbook

Files:

- `application/journal_de_bord.dart`;
- `bloc/journal_bloc/*`;
- `data/journal_api.dart`.

Functions:

- loads entries with `GET /api/journal`;
- adds an entry with `POST /api/journal`;
- checks today's alert with `GET /api/journal/alerte`;
- the visible frontend code does not call the backend endpoints `PUT /api/journal/update/{id}` or `GET /api/journal/export/{idPfmp}` (see [04 - Backend API](04-backend-api.md)).

### Student messaging

Files:

- `application/messagerie.dart`;
- `data/message_api.dart`.

Functions:

- selects the active PFMP;
- loads the history from `/api/messages/{idPfmp}`;
- sends a message;
- handles the loader, empty state, and error SnackBar.

The backend messaging endpoints reject inactive PFMPs.

### My profile

Files:

- `application/mon_profil.dart`;
- `data/profile_api.dart`;
- `model/profile.dart`.

The frontend tries several endpoints:

- `GET /api/profile/me`;
- `GET /api/profile`;
- `GET /api/etudiants/me/profile`;
- `PUT /api/profile/me`;
- `PUT /api/etudiants/me/profile`.

TODO: the profile backend needs verification, since `ProfileController.ProfileMe()` has no explicit HTTP attribute (see [04 - Backend API](04-backend-api.md)).

## Administrator area

Main file: `application/accueil_admin.dart`.

Tabs:

| Tab | Widget | Function |
| --- | --- | --- |
| Supervision | `SupervisionAdmin` | PFMP table/list, filters, statistics, and attendance edits. |
| Class management | `PeriodesAdmin` | Per-class statistics and the list of students in a class. |
| Messaging | `MessagerieAdmin` | Messages for the active PFMPs visible to the admin. |
| Action drawer | Initialize attendance | Calls `/api/presence/initialiser`. |

TODO: no user-creation screen (`POST /api/utilisateur`) was identified in the tabs above, even though the endpoint exists on the backend — see [04 - Backend API](04-backend-api.md).

### Admin supervision

Files:

- `application/supervision_admin.dart`;
- `data/infos_admin_api.dart`;
- `data/presence_api.dart`;
- `model/infos_admin.dart`.

Functions:

- displays the `stageTotal`, `encours`, `valide`, `absencesTotal` statistics;
- filters by valid/incomplete status and name/first-name search;
- shows a desktop table or responsive cards;
- opens an attendance modal;
- sends attendance edits.

Point to verify:

- `presence_api.dart` first tries `PUT /api/presence/modify`;
- on a 404/405, it calls the real endpoint `PUT /api/presence/update/{idEtudiant}`;
- the `modify` endpoint does not exist on the backend.

### Class management

Files:

- `application/periodes_admin.dart`;
- `data/infos_admin_api.dart`;
- `model/admin_class_stats.dart`.

Functions:

- loads class statistics;
- tries `/api/administrateur/classes/stats`, then falls back to `/api/administrateur/classes`;
- selects a class;
- loads the students in that class via `/api/administrateur/recherche?idEtablissement=...&idClasse=...`.

### Admin messaging

Files:

- `application/messagerie_admin.dart`;
- `data/message_api.dart`.

Functions:

- selects conversations among the active PFMPs of visible trainees;
- loads and sends messages via `/api/messages/{idPfmp}`;
- handles the loader, empty state, and SnackBar.

## Teacher / referent area

No dedicated interface is wired into `main.dart`.

The backend does, however, authorize `Enseignant` on:

- `GET /api/pfmp/recherche/{studentId}/{pfmpId?}`;
- `PUT /api/presence/update/{studentId}`;
- `GET/POST /api/messages/{idPfmp}`, via internal checks.

TODO: build or wire up a Flutter teacher shell if this role is meant to be made available.

## Loading/error states

The project uses several mechanisms:

- `CircularProgressIndicator` during loading;
- BLoC states `Loading`, `Success`, `Error`;
- SnackBar for action errors;
- cards or empty-state messages on several pages;
- fallback endpoints on the admin/profile/attendance side in some services.

## Frontend points to watch

- Relative `/api` URLs work with Nginx, but are not enough on their own for a direct `flutter run`.
- Teacher interface missing.
- Profile frontend exists, but the backend needs verification.
- PFMP creation to verify before real use: `siteWeb` and hardcoded dates.
- `GET /api/news` and `GET /api/journal/export/{idPfmp}` exist on the backend with no identified Flutter page consuming them (see [04 - Backend API](04-backend-api.md)).
- Some comments and text strings contain incorrectly encoded characters in a few existing files.
