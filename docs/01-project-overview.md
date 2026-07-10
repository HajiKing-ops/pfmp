# 01 - Project overview

PFMP Manager is an application for tracking PFMP work-based training placements in a school context. It helps students, administrators, and, on the backend side, teachers/referents, follow placement periods, applications, the logbook, attendance, and messages.

## Goal

The application centralizes information that is often scattered across different places:

- a student's PFMPs;
- host organizations;
- contact applications;
- the weekly schedule;
- the logbook;
- attendance and absences;
- messages tied to a PFMP;
- oversight of classes and students by the administration.

## Users

| Actor | Current usage |
| --- | --- |
| Student | Logs in, tracks their PFMPs, submits applications, fills in their logbook, views/creates a PFMP, and uses messaging. |
| Administrator | Logs in, views PFMPs for students in their schools, filters trainees, tracks classes, initializes/edits attendance, and uses admin messaging. |
| Teacher / Referent | On the backend, can access PFMPs for assigned students, messages, and attendance edits, depending on the existing endpoints. On the Flutter side, no dedicated interface is wired into `main.dart`. |
| Professional / Workplace supervisor | Exists in the `Professionnel` and `Travailler` entities. Created/linked while a PFMP is being created, but this role does not currently log in. |

## Main flows

### Student

1. Log in via `/api/login`.
2. Access the student area if the returned role is `Etudiant`.
3. View the dashboard and PFMPs.
4. Add or edit applications to organizations.
5. Create a complete PFMP after an application is accepted.
6. Fill in the logbook.
7. Message on the active PFMP.
8. Export the logbook to PDF from `My PFMPs`.

### Administrator

1. Log in via `/api/login`.
2. Access the admin area if the returned role is `Administrateur`.
3. Oversee the PFMPs visible for their schools.
4. View overall and per-class statistics.
5. Initialize the day's attendance.
6. Edit attendance/absences.
7. Message on the visible active PFMPs.

### Teacher / Referent

The backend recognizes the `Enseignant` role based on the `Referent` table. Access checks also use the relationship visible on `Etudiant`: `Id_Utilisateur` appears to represent the referent, and `Id_Utilisateur_1` the student.

Existing backend functions:

- reading PFMPs for assigned students;
- access to messages on active PFMPs for assigned students;
- updating attendance for an assigned student on a date within their PFMP.

TODO: build or wire up a Flutter teacher interface if this role is meant to be used by the application.

## Current scope

Features visible in the code:

- REST API built with ASP.NET Core under `/api`;
- JWT authentication via HttpOnly cookies;
- refresh token stored hashed in the database;
- `Fgp` fingerprint cookie;
- roles `Etudiant`, `Enseignant`, `Administrateur`;
- dedicated Flutter area for students;
- dedicated Flutter area for administrators;
- Nginx serving Flutter Web and proxying `/api`;
- MySQL database via EF Core;
- PDF logbook export with QuestPDF;
- PFMP messaging flow;
- attendance with states `PRESENT`, `ABSENT`, `NON_RENSEIGNE`;
- a security-news feed (CERT-FR) via `/api/news`.

## Out of scope or incomplete

- No teacher/referent Flutter interface wired up yet.
- No login for the professional/workplace-supervisor role.
- Profile backend to verify: the controller exists, but the action carries no explicit HTTP attribute.
- `GET /api/news` and `GET /api/journal/export/{idPfmp}` (JSON logbook export) both exist on the backend, but no Flutter page consuming them was identified in the files reviewed — to verify. See [04 - Backend API](04-backend-api.md#endpoints-with-no-confirmed-frontend-consumer).
- No visible backend test project.
- No visible CI/CD.
- No complete production HTTPS configuration in the repository.
- No visible monitoring, automated backups, or log rotation.
