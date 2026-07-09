# 12 - TODO and Future Improvements

This file lists realistic future improvements. These items are not documented as implemented features unless the code confirms them.

## Backend

- Clean up long controllers.
- Move duplicated business logic into services.
- Standardize API responses.
- Add a consistent error format for `400`, `401`, `403`, `404`, and `500`.
- Add an automated backend test project.
- Test PFMP access rules.
- Test Student, Teacher / Referent, and Administrator role boundaries.
- Test refresh token rotation and token reuse behavior.
- Add structured logging.
- Add global exception handling middleware.
- Add pagination for large lists.
- Verify or complete `ProfileController`.
- Add explicit `[Authorize]` and HTTP route attributes for profile endpoints.
- Remove or replace the internship supervisor temporary password behavior.
- Clarify whether `POST /api/utilisateur` should create only a base account or a full role profile.

## PFMP and Schedule

- Verify the Flutter PFMP creation form.
- Send `siteWeb` if the backend keeps it required.
- Replace hardcoded PFMP dates with date inputs.
- Display API business errors clearly in the frontend.
- Add automated schedule validation tests:
  - incomplete time slots;
  - morning/afternoon overlap;
  - incorrect daily total;
  - incorrect weekly total;
  - empty schedule.
- Verify the `Semaine` calculation in PFMP details.

## Teacher / Referent

Dedicated Teacher / Referent endpoints are not confirmed in the current backend. If this role must be fully supported, verify or create endpoints such as:

```text
GET /api/referent/mes-etudiants
GET /api/referent/etudiants/{idEtudiant}/pfmps
GET /api/referent/pfmps/{idPfmp}/planning
GET /api/referent/pfmps/{idPfmp}/presences
GET /api/referent/pfmps/{idPfmp}/rapports-journaliers
```

Frontend work to consider:

- Teacher / Referent dashboard;
- assigned student list;
- PFMP details;
- attendance view;
- daily report view;
- messaging.

Rules to preserve:

- a Teacher / Referent sees only assigned students;
- a Teacher / Referent is not an Administrator;
- a Teacher / Referent should not officially validate PFMP data unless a clear business rule is added.

## Frontend

- Add a Flutter shell for `Enseignant` if needed.
- Stabilize the profile screen with confirmed backend routes.
- Remove fallback calls to unimplemented endpoints once the API is stable:
  - `/api/presence/modify`;
  - `/api/administrateur/classes/stats`;
  - alternative profile endpoints.
- Improve API error display.
- Add widget tests and API service tests.
- Verify direct `flutter run` behavior with relative `/api` URLs.
- Add frontend environment configuration if needed.
- Review and fix encoding issues in existing source comments/text where appropriate.

## Attendance

- Clarify the difference between attendance rows created during PFMP creation and daily admin initialization.
- Add an official batch update endpoint if the frontend should update several days in one action.
- Add attendance change history if needed.
- Define rules for editing past and future days.

## Daily Reports

- Wire the frontend to `PUT /api/journal/update/{id}` if editing daily reports is required.
- Add Teacher / Referent or Administrator report views if needed.
- Improve PDF output:
  - layout;
  - student details;
  - signatures;
  - statistics;
  - complete period summary.

## Messaging

- Add pagination or incremental loading.
- Add read/unread status if needed.
- Add message length validation.
- Add moderation or admin tools if required.

## DevOps

- Add CI/CD.
- Build the backend automatically.
- Run Flutter analysis automatically.
- Run automated tests.
- Deploy to a real server or cloud provider.
- Add production HTTPS.
- Add monitoring.
- Add scheduled MySQL backups.
- Test backup restore regularly.
- Add log rotation.
- Add deeper API health checks.
- Create the MySQL application user through Compose initialization SQL or documented setup.

## Security

- Use stronger secrets.
- Keep production secrets out of source code and local documentation.
- Use HTTPS in production.
- Use `Secure=true` cookies under HTTPS.
- Do not expose the database publicly.
- Keep the API internal in production-style mode when Nginx can proxy `/api`.
- Verify forwarded headers behind Nginx.
- Add systematic `401` and `403` tests.
- Remove the internship supervisor temporary password.
- Add a password reset/change process if real users will manage accounts.

## MLOps / Future Analytics

Future ideas, not currently implemented:

- dashboard statistics;
- missing daily report detection;
- attendance and absence risk indicators;
- student follow-up analytics;
- Teacher / Referent alerts;
- CSV or BI exports;
- anonymized dashboards.

These are future analytics ideas, not immediate priorities.

## Documentation

- Keep `README.md` as the main entry point.
- Update `04-backend-api.md` whenever routes change.
- Update `05-frontend-guide.md` whenever screens change.
- Add screenshots only if they do not contain sensitive data.
- Document the final process for creating complete users by role once it is stable.
