# 10 - Testing Checklist

This is a manual checklist for validating the project after setup, authentication changes, Docker changes, or a delivery.

## Docker

- [ ] `docker volume create docker-test_mysql_data` was run on a new machine.
- [ ] `.env` was created from `.env.example`.
- [ ] `docker compose up --build` starts without blocking errors.
- [ ] `pfmp_mysql` is healthy.
- [ ] `pfmp_api` is running.
- [ ] `pfmp_flutter` is running.
- [ ] `docker compose ps` shows all expected services.
- [ ] `http://localhost:65427` opens Flutter in development Docker mode.
- [ ] In production-style mode, `http://localhost` opens Flutter.
- [ ] Logs do not show MySQL connection failures.

## API

- [ ] `GET /openapi/v1.json` responds in `Development`.
- [ ] A protected route without cookies returns `401`.
- [ ] An admin route with a student session returns `403`.
- [ ] Important API errors are understandable from the frontend.

## Authentication

- [ ] Valid login works.
- [ ] Invalid login fails clearly.
- [ ] Cookies are created after login:
  - [ ] `AccessToken`;
  - [ ] `RefreshToken`;
  - [ ] `Fgp`.
- [ ] The frontend does not need to read the JWT.
- [ ] A protected request works after login.
- [ ] `POST /api/login/refresh` rotates the session.
- [ ] `POST /api/logout` logs out.
- [ ] Cookies are removed or invalidated after logout.
- [ ] Reusing an old refresh token is rejected.
- [ ] A missing or invalid fingerprint is rejected.

## Roles

### Student

- [ ] Student opens the student area.
- [ ] Dashboard loads.
- [ ] Student cannot call `/api/administrateur`.
- [ ] Student cannot read another student's PFMPs.
- [ ] Student sees only their own contact requests.
- [ ] Student sees only their own daily reports.

### Administrator

- [ ] Administrator opens the admin area.
- [ ] Admin supervision loads students/PFMPs.
- [ ] Global statistics are displayed.
- [ ] Filters work.
- [ ] Period management loads class groups.
- [ ] Selecting a class loads students.
- [ ] Attendance initialization displays a clear message.
- [ ] Administrator cannot update attendance outside their scope.

### Teacher / Referent

- [ ] To verify: role `Enseignant` can log in at backend level.
- [ ] To verify: Flutter currently shows `Utilisateur inconnu` for this role.
- [ ] `GET /api/pfmp/recherche/{studentId}` works for an assigned student.
- [ ] The same endpoint returns `403` for a non-assigned student.
- [ ] `PUT /api/presence/update/{studentId}` works only for an assigned student and a valid PFMP date.

### Professional / Internship Supervisor

- [ ] To verify: no Professional login is expected.
- [ ] No endpoint uses `[Authorize(Roles = "Professionnel")]`.

## PFMP

- [ ] An `Accepte` contact request exists before PFMP creation.
- [ ] PFMP creation with a valid schedule works.
- [ ] PFMP creation without an accepted contact request returns `400`.
- [ ] Overlapping PFMP creation returns `400`.
- [ ] Incomplete schedule time slots return `400`.
- [ ] Incorrect daily total returns `400`.
- [ ] Incorrect weekly total returns `400`.
- [ ] Attendance rows are created for planned work days.
- [ ] TODO: verify the Flutter form sends `siteWeb`.
- [ ] TODO: verify Flutter PFMP dates are not hardcoded before demo or release.

## Contact Requests

- [ ] Contact request list loads.
- [ ] Creating an `En attente` request works.
- [ ] Duplicate creation returns `409`.
- [ ] Updating to `Accepte` works.
- [ ] Updating to `Refuse` works.
- [ ] Invalid status returns `400`.

## Daily Reports

- [ ] Daily report list loads.
- [ ] Creating today's report works during a PFMP.
- [ ] Creating a report outside a PFMP period returns `404`.
- [ ] Creating a second report for the same day returns `409`.
- [ ] Daily report alert correctly reports whether today's report exists.
- [ ] `/api/journal/export/{idPfmp}` works for the owner.
- [ ] `/api/journal/pdf/{idPfmp}` downloads for the owner.
- [ ] PDF access is rejected for another user.

## Attendance

- [ ] Admin initialization creates or updates today's attendance.
- [ ] Weekend initialization returns the expected message.
- [ ] `PRESENT` accepts zero or positive lateness.
- [ ] `ABSENT` forces lateness to `0`.
- [ ] Missing date returns `400`.
- [ ] Invalid state returns `400`.
- [ ] Date outside PFMP returns `403`.
- [ ] Missing attendance row returns `404`.
- [ ] Frontend fallback to `PUT /api/presence/update/{idEtudiant}` works after `/api/presence/modify` fails.

## Messages

- [ ] Student messaging loads for an active PFMP.
- [ ] Admin messaging loads for a visible active PFMP.
- [ ] Sending a message works.
- [ ] Empty messages are blocked.
- [ ] Inactive PFMP returns `400`.
- [ ] Missing PFMP returns `404`.
- [ ] Unauthorized user returns `403`.

## Admin Period Management

- [ ] `/api/administrateur/classes` returns class statistics.
- [ ] The frontend fallback from `/api/administrateur/classes/stats` is handled.
- [ ] Class statistics are consistent.
- [ ] Selecting a class calls `/api/administrateur/recherche`.
- [ ] Student cards show PFMP, company, internship supervisor, attendance, and absences.

## Security and Configuration

- [ ] `.env` is not committed.
- [ ] Real secrets are not documented.
- [ ] `JWT_SECRET` is strong outside development.
- [ ] MySQL is not publicly exposed.
- [ ] Production-style mode exposes only Nginx/frontend.
- [ ] `Secure=true` cookies are planned for HTTPS production.
- [ ] CORS lists only required origins.
