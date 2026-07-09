# 03 - Roles and Permissions

Application roles are resolved by `RoleService`:

1. If the user exists in `Etudiant`, the role is `Etudiant`.
2. Otherwise, if the user exists in `Referent`, the role is `Enseignant`.
3. Otherwise, if the user exists in `Administrateur`, the role is `Administrateur`.
4. Otherwise, no role is returned.

The Professional / Internship supervisor exists in the business model, but `RoleService` does not return a `Professionnel` role.

## Important Teacher / Referent Rule

A Teacher / Referent must only follow assigned students.

In the current code, this assignment is checked through the `Etudiant` table:

- `Etudiant.Id_Utilisateur` appears to represent the referent;
- `Etudiant.Id_Utilisateur_1` appears to represent the student.

A Teacher / Referent is not an Administrator. The current code does not confirm that a teacher officially validates PFMP records. Teacher access is limited to endpoints where the `Enseignant` role is allowed and where the student assignment check passes.

## Permission Table

| Feature | Student | Teacher / Referent | Administrator | Professional / Internship supervisor |
| --- | --- | --- | --- | --- |
| Log in | Yes | Backend role exists | Yes | Not confirmed in code |
| Dedicated Flutter area | Yes | No visible area wired | Yes | No |
| View own dashboard | Yes | No | No | No |
| View PFMP records | Own PFMPs only | Assigned students only | Through admin endpoints | No |
| Create a complete PFMP | Yes | No | No | No |
| Manage contact requests | Yes | No | No | No |
| Fill daily reports | Yes | No | No | No |
| Export own daily report PDF | Yes | No confirmed support | No confirmed support | No |
| Read/send PFMP messages | Own active PFMPs | Active PFMPs of assigned students | Active PFMPs in admin scope | No |
| Initialize attendance | No | No | Yes | No |
| Update attendance | No | Assigned students and valid PFMP dates | Admin-owned PFMPs and valid dates | No |
| View admin statistics | No | No | Yes | No |
| Create a base user account | No | No | Yes | No |

## Student

A Student can:

- access the student Flutter area;
- view PFMPs through `/api/pfmp/recherche/{studentId}`;
- create a PFMP through `/api/pfmp/complete`;
- create and update contact requests;
- create and view daily reports;
- check whether today's daily report exists;
- export daily report data and PDF for owned PFMPs;
- use messaging for active owned PFMPs.

Limits:

- a Student cannot read another student's PFMP data;
- a Student cannot access administrator endpoints;
- a Student cannot initialize or update attendance.

## Teacher / Referent

Confirmed backend capabilities:

- read PFMPs of assigned students;
- read and send messages for active PFMPs of assigned students;
- update attendance for an assigned student when the date is inside the PFMP period.

Limits:

- no dedicated Flutter Teacher / Referent area is wired in `main.dart`;
- no administrator access;
- no PFMP creation;
- no official PFMP validation confirmed in code;
- no dedicated `/api/referent/...` controller routes currently exist.

## Administrator

An Administrator can:

- access the Flutter administrator area;
- view PFMPs for students in managed establishments;
- filter students by name, company, status, establishment, or class;
- view class-level statistics;
- initialize attendance for the current day;
- update attendance for PFMPs in their scope;
- use admin messaging on visible active PFMPs;
- create a base user account through `/api/utilisateur`.

Limits:

- `POST /api/utilisateur` creates only a base `Utilisateur`, not a role profile;
- admin attendance scope uses `Pfmp.Id_Utilisateur == adminId`;
- the current daily report PDF endpoint effectively requires the connected user to be the student who owns the PFMP.

## Professional / Internship Supervisor

The business model includes:

- `Professionnel`;
- `Travailler`;
- a related `Utilisateur` record created or reused during PFMP creation.

However:

- `RoleService` does not return `Professionnel`;
- no controller uses `[Authorize(Roles = "Professionnel")]`;
- no Flutter Professional / Internship supervisor UI is visible.

Conclusion: this actor exists in the business model only in the current version.
