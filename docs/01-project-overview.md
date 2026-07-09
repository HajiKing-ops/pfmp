# 01 - Project Overview

PFMP Manager is a web application for managing PFMP internship periods in a school context. It helps students, administrators, and partially teachers/referents follow internship information, company contact steps, daily reports, attendance, and PFMP-related messages.

## Purpose

The application centralizes information that is often spread across several tools:

- student PFMP periods;
- host organisations;
- contact requests and internship search steps;
- weekly schedules;
- daily reports;
- attendance, absences, and lateness;
- PFMP-scoped messages;
- administrator supervision by establishment and class group.

## Users

| Actor | Current usage |
| --- | --- |
| Student | Logs in, follows PFMPs, manages contact requests, fills daily reports, creates PFMP records, and uses messaging. |
| Administrator | Logs in, supervises PFMPs for managed establishments, reviews class statistics, initializes or updates attendance, and uses admin messaging. |
| Teacher / Referent | Supported by some backend authorization rules for assigned students. A dedicated Flutter UI is not currently wired in `main.dart`. |
| Professional / Internship supervisor | Exists in the data model through `Professionnel` and `Travailler`. This actor does not log into the application in the current version. |

## Main User Flows

### Student Flow

1. Log in through `POST /api/login`.
2. Open the student area when the returned role is `Etudiant`.
3. View dashboard and PFMP information.
4. Create or update organisation contact requests.
5. Create a complete PFMP after an accepted contact request.
6. Fill the daily report.
7. Use messaging for the active PFMP.
8. Export a PFMP daily report PDF from `Mes PFMP`.

### Administrator Flow

1. Log in through `POST /api/login`.
2. Open the admin area when the returned role is `Administrateur`.
3. Review PFMPs for students in managed establishments.
4. View global and class-level statistics.
5. Initialize attendance for the current day.
6. Update attendance or absence information.
7. Use messaging for visible active PFMPs.

### Teacher / Referent Flow

The backend recognizes the role `Enseignant` from the `Referent` table. Access checks also use the `Etudiant` table, where `Id_Utilisateur` appears to represent the referent and `Id_Utilisateur_1` the student.

Backend capabilities confirmed in code:

- read PFMPs for assigned students;
- read and send messages for active PFMPs of assigned students;
- update attendance for an assigned student when the date is inside the PFMP period.

TODO: create or wire a Flutter Teacher / Referent area if this role must be used in the application.

## Current Scope

Confirmed in code:

- ASP.NET Core API under `/api`;
- JWT authentication through HttpOnly cookies;
- refresh token storage as hashes in the database;
- fingerprint cookie `Fgp`;
- roles `Etudiant`, `Enseignant`, and `Administrateur`;
- Flutter student area;
- Flutter administrator area;
- Nginx static hosting and `/api` reverse proxy;
- MySQL persistence through EF Core;
- PDF generation for daily reports with QuestPDF;
- PFMP-scoped messaging;
- attendance states `PRESENT`, `ABSENT`, and `NON_RENSEIGNE`.

## Not Included Yet or To Verify

- No dedicated Flutter Teacher / Referent area is currently wired.
- No Professional / Internship supervisor login flow is implemented.
- No CI/CD pipeline is visible.
- No production HTTPS configuration is implemented in the repository.
- No monitoring, automated backups, or log rotation setup is visible.
