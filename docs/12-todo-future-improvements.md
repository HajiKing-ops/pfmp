# 12 - TODO and future improvements

This list separates technical, business, and DevOps improvements. It does not describe features that are already available.

## Backend

- Clean up the longest controllers.
- Move duplicated business logic into services.
- Standardize API error responses.
- Add a common format for `400`, `401`, `403`, `404`, `500`.
- Add a backend test project.
- Test PFMP access rules.
- Test admin/student/teacher roles.
- Test refresh token rotation.
- Add structured logs.
- Add global error handling/middleware.
- Add pagination on large lists.
- Verify or finalize `ProfileController`.
- Add `[Authorize]` and explicit routes to the profile endpoints.
- Fix the workplace-supervisor creation flow that uses a temporary password.
- Clarify admin user creation: base account only, or a full role.
- Decide, for `GET /api/news` and `GET /api/journal/export/{idPfmp}`, whether they should stay backend-only, be wired to a Flutter page, or be removed (see [04 - Backend API](04-backend-api.md)).
- Verify the exact spelling of the attendance controller (`TablePreseceController` in the inspected code) and correct the documentation if needed.

## PFMP and scheduling

- Verify the Flutter PFMP creation form.
- Send `siteWeb` in the payload, since the API requires it.
- Replace hardcoded dates with real date fields.
- Show the API's business error messages instead of a generic failure.
- Add schedule tests:
  - incomplete time slots;
  - morning/afternoon overlap;
  - incorrect daily total;
  - incorrect weekly total;
  - empty schedule.
- Verify the `Semaine` (week number) calculation in PFMP details.

## Teacher / referent

Proposed endpoints, to verify or create:

```text
GET /api/referent/mes-etudiants
GET /api/referent/etudiants/{idEtudiant}/pfmps
GET /api/referent/pfmps/{idPfmp}/planning
GET /api/referent/pfmps/{idPfmp}/presences
GET /api/referent/pfmps/{idPfmp}/rapports-journaliers
```

Flutter interface to build if this role is meant to be used:

- referent home screen;
- list of assigned students;
- PFMP details;
- attendance;
- logbooks;
- messaging.

Rules to preserve:

- a referent only sees their own students;
- a referent is not an administrator;
- a referent does not officially validate a PFMP, unless an explicit business rule is added for that.

## Frontend

- Add a Flutter shell for the `Enseignant` role.
- Finalize the profile screen once the backend is stable.
- Remove fallbacks to non-existent endpoints once the API is stable:
  - `/api/presence/modify`;
  - `/api/administrateur/classes/stats`;
  - the alternative profile endpoints.
- Improve how API errors are displayed.
- Add widget tests and API service tests.
- Verify `flutter run` mode with relative `/api` URLs.
- Add frontend environment configuration if needed.
- Fix character encoding in text and comments.
- Add a user-creation screen if `POST /api/utilisateur` should stay usable from the admin interface.

## Attendance

- Clarify the difference between attendance rows created during PFMP creation and the admin's daily initialization.
- Add an official batch endpoint if the frontend needs to edit several days in one action.
- Add an edit history if needed.
- Add more explicit checks for future/past days, based on the business rule.

## Logbook

- Wire up the frontend update flow if editing a report is desired.
- Add a teacher/admin view of reports if needed.
- Improve the PDF:
  - layout;
  - student information;
  - signatures;
  - statistics;
  - full period coverage.

## Messaging

- Add pagination or incremental loading.
- Add a read/unread status if needed.
- Add a message length limit.
- Add moderation/admin access if necessary.

## DevOps

- Set up CI/CD.
- Add automatic backend builds.
- Add automatic Flutter analysis.
- Add automated tests.
- Add deployment to a server or the cloud.
- Add production HTTPS.
- Add monitoring.
- Add scheduled MySQL backups.
- Test backup restoration.
- Add log rotation.
- Add more complete API health checks.
- Create the application-level MySQL user in Compose/an init SQL script, or document its creation during setup.

## Security

- Use strong secrets.
- Move secrets out of `appsettings.json` and local `.env` files before production.
- Switch cookies to `Secure=true` under HTTPS.
- Never expose MySQL publicly.
- Do not expose the API directly in production-style mode.
- Verify `ForwardedHeaders` behind Nginx.
- Add systematic 401/403 tests.
- Remove the temporary professional password.
- Add a password change/reset policy.

## Future MLOps / analytics

Future ideas, not present in the current code and **not a short-term priority**:

- advanced statistics dashboard;
- detection of missing reports;
- absence indicators;
- PFMP dropout-risk indicators;
- longitudinal tracking by class/program;
- alerts for referents;
- CSV/BI export;
- anonymized dashboards.

## Documentation

- Keep `README.md` as the main entry point.
- Update `04-backend-api.md` whenever a route is added.
- Update `05-frontend-guide.md` whenever a screen is added.
- Add screenshots only if they contain no sensitive data.
- Document the full per-role user-creation procedure once it's stabilized.
- Re-run a verification pass of this documentation against the code once full repository access (backend, frontend, Docker) is available for an automated review.
