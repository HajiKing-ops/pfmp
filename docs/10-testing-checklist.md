# 10 - Testing checklist

This checklist is manual. It's meant to quickly verify that the project works after an install, an authentication change, a Docker change, or before a release.

## Docker

- [ ] `docker volume create docker-test_mysql_data` run on any new machine.
- [ ] `.env` created from `.env.example`.
- [ ] `docker compose up --build` starts with no blocking error.
- [ ] `pfmp_mysql` is healthy.
- [ ] `pfmp_api` is running.
- [ ] `pfmp_flutter` is running.
- [ ] `docker compose ps` shows all three services.
- [ ] `http://localhost:65427` opens Flutter in Docker development.
- [ ] In production-style mode, `http://localhost` opens Flutter.
- [ ] Logs contain no MySQL connection error.

## API

- [ ] `GET /openapi/v1.json` responds in the Development environment.
- [ ] A protected route with no cookies returns `401`.
- [ ] An admin route with a student account returns `403`.
- [ ] Important API errors are readable on the frontend side.

## Authentication

- [ ] Valid login works.
- [ ] Invalid login returns an error.
- [ ] Cookies created after login:
  - [ ] `AccessToken`;
  - [ ] `RefreshToken`;
  - [ ] `Fgp`.
- [ ] The frontend never needs to read the JWT.
- [ ] A protected request works after login.
- [ ] `POST /api/login/refresh` renews the session.
- [ ] `POST /api/logout` logs the user out.
- [ ] Cookies are removed or invalidated after logout.
- [ ] A reused refresh token is rejected.
- [ ] A missing or invalid fingerprint is rejected.

## Roles

### Student

- [ ] The student lands on the student area.
- [ ] The dashboard loads.
- [ ] The student cannot call `/api/administrateur`.
- [ ] The student cannot read another student's PFMPs.
- [ ] The student only sees their own applications.
- [ ] The student only sees their own logbook entries.

### Administrator

- [ ] The administrator lands on the admin area.
- [ ] Admin supervision loads trainees.
- [ ] Overall statistics display correctly.
- [ ] Filters work.
- [ ] Class management loads classes.
- [ ] Selecting a class loads its students.
- [ ] Initializing attendance shows a clear message.
- [ ] The administrator cannot edit attendance outside their scope.

### Teacher / referent

- [ ] To verify: the `Enseignant` role can log in on the API side.
- [ ] To verify: the Flutter interface currently shows `Utilisateur inconnu`.
- [ ] `GET /api/pfmp/recherche/{studentId}` works for an assigned student.
- [ ] The same endpoint returns `403` for a student who isn't assigned.
- [ ] `PUT /api/presence/update/{studentId}` only works for an assigned student and a date within the PFMP.

### Professional

- [ ] To verify: no professional login is expected.
- [ ] No `[Authorize(Roles = "Professionnel")]` endpoint is exposed.

## PFMP

- [ ] An `Accepte` application exists before PFMP creation.
- [ ] PFMP creation with a valid schedule works.
- [ ] PFMP creation without an accepted application returns `400`.
- [ ] PFMP creation with an overlap returns `400`.
- [ ] A schedule with incomplete time slots returns `400`.
- [ ] A schedule with an incorrect daily total returns `400`.
- [ ] A schedule with an incorrect weekly total returns `400`.
- [ ] Initial attendance rows are created for working days.
- [ ] TODO: confirm the Flutter form actually sends `siteWeb`.
- [ ] TODO: confirm the Flutter form's dates are not hardcoded.

## Applications

- [ ] The application list loads.
- [ ] Creating a `En attente` application works.
- [ ] Creating a duplicate returns `409`.
- [ ] Updating to `Accepte` works.
- [ ] Updating to `Refuse` works.
- [ ] An invalid status returns `400`.

## Logbook

- [ ] The logbook list loads.
- [ ] Adding today's entry works during an active PFMP.
- [ ] Adding an entry outside the PFMP period returns `404`.
- [ ] A second entry for the same day returns `409`.
- [ ] The logbook alert correctly reports whether today's entry exists.
- [ ] JSON export `/api/journal/export/{idPfmp}` works for the owner.
- [ ] PDF `/api/journal/pdf/{idPfmp}` downloads for the owner.
- [ ] PDF is rejected for another user.

## Attendance

- [ ] Admin initialization creates or updates today's attendance.
- [ ] Initialization on a weekend returns the expected message.
- [ ] `PRESENT` attendance accepts a positive or zero lateness value.
- [ ] `ABSENT` attendance forces lateness to 0.
- [ ] Attendance with no date returns `400`.
- [ ] An invalid state returns `400`.
- [ ] A date outside the PFMP returns `403`.
- [ ] No attendance row found for the date returns `404`.
- [ ] Frontend fallback `PUT /api/presence/update/{idEtudiant}` works after `/api/presence/modify` fails.

## Messages

- [ ] Student messaging loads for an active PFMP.
- [ ] Admin messaging loads for a visible active PFMP.
- [ ] Sending a message works.
- [ ] An empty message is blocked.
- [ ] An inactive PFMP returns `400`.
- [ ] A non-existent PFMP returns `404`.
- [ ] An unauthorized user returns `403`.

## Admin - Class management

- [ ] `/api/administrateur/classes` returns the classes.
- [ ] The frontend handles the fallback from `/api/administrateur/classes/stats`.
- [ ] Class statistics are consistent.
- [ ] Selecting a class calls `/api/administrateur/recherche`.
- [ ] The student list shows PFMP, company, workplace supervisor, attendance, and absences.

## News

- [ ] `GET /api/news` returns CERT-FR news items for an authenticated user.
- [ ] `GET /api/news` rejects an unauthenticated request (`401`).
- [ ] TODO: confirm whether any Flutter page consumes this endpoint (see [04 - Backend API](04-backend-api.md)).

## Security and configuration

- [ ] `.env` is not committed.
- [ ] Real values are not documented anywhere.
- [ ] `JWT_SECRET` is strong outside of development.
- [ ] MySQL is not exposed publicly.
- [ ] In production-style mode, only the Nginx interface is exposed.
- [ ] `Secure=true` cookies are planned for HTTPS production.
- [ ] CORS only lists the origins that are actually needed.
