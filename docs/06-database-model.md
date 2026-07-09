# 06 - Database Model

The database model is represented by EF Core entity classes in `PFMPManager.Api/Models` and by `DbSet` declarations in `AppDbContext`.

Important: `AppDbContext` mainly configures composite keys for linking tables. The relationships below are based on the models and controller/service queries. Foreign key constraints should be verified in the actual SQL schema if needed.

## Main Entities

| Entity | Purpose |
| --- | --- |
| `Utilisateur` | Base user account: name, login, password hash. |
| `Etudiant` | Student profile and apparent link to a referent. |
| `Referent` | Teacher / Referent profile. |
| `Administrateur` | Administrator profile. |
| `Pfmp` | Internship period. |
| `Organisation` | Host organisation/company. |
| `Professionnel` | Professional / Internship supervisor. |
| `Planning` | Weekly total. |
| `PlanningJours` | Schedule days and time slots. |
| `Contacter` | Student contact request with an organisation. |
| `RapportJournalier` | Daily report. |
| `Remplir` | Link between student and daily report. |
| `TablePresence` | Attendance, absence, lateness, justification. |
| `Message` | PFMP-scoped message. |
| `Etablissement` | School establishment. |
| `GroupeClasse` | Class group linked to an establishment and program. |
| `Filiere` | Program / field of study. |
| `Etudier` | Student enrollment in a class group for a school period. |
| `Administrer` | Administrator to establishment link. |
| `Travailler` | Professional to organisation link. |
| `RefreshToken` | Hashed refresh tokens, rotation metadata, fingerprint hash. |

## Keys Configured in `AppDbContext`

Composite keys:

| Entity | Key |
| --- | --- |
| `Remplir` | `(Id_Utilisateur, Id_RapportJournalier)` |
| `Contacter` | `(Id_Utilisateur, SIRET)` |
| `Travailler` | `(Id_Utilisateur, SIRET)` |
| `Etudier` | `(Id_Utilisateur, Id_Etablissement, Id_Classe)` |
| `GroupeClasse` | `(Id_Etablissement, Id_Classe)` |
| `Administrer` | `(Id_Utilisateur, Id_Etablissement)` |

Other entities use `[Key]` attributes in their model classes.

## Users and Roles

`Utilisateur` is the base account table.

Application roles are resolved through role/profile tables:

```text
Utilisateur
  |-- Etudiant       -> role "Etudiant"
  |-- Referent       -> role "Enseignant"
  |-- Administrateur -> role "Administrateur"
  |-- Professionnel  -> business model only in current login flow
```

`RoleService` checks these tables in this order: `Etudiant`, `Referent`, then `Administrateur`.

## Student, Referent, and Class Group

In code queries, `Etudiant` appears to store both the student user id and the assigned referent id:

```text
Utilisateur
  |
  v
Etudiant
  | Id_Utilisateur_1 = student user id
  | Id_Utilisateur   = referent user id, to verify in schema
  v
Etudier
  |
  v
GroupeClasse
  |
  v
Etablissement / Filiere
```

The Teacher / Referent access checks use `Etudiant.Id_Utilisateur == referentId` and `Etudiant.Id_Utilisateur_1 == studentId`.

## Administrator and Establishments

```text
Administrateur
  |
  v
Administrer
  |
  v
Etablissement
  |
  v
GroupeClasse
  |
  v
Etudier
  |
  v
Etudiant
```

Administrator endpoints load students through the establishments managed by the connected administrator.

## PFMP

Important `Pfmp` fields:

- `Id_PFMP`;
- `DateDebut`;
- `DateFin`;
- `Id_Utilisateur`: administrator linked to the PFMP;
- `Id_Planning`;
- `SIRET`;
- `Id_Utilisateur_1`: student linked to the PFMP.

Business relationship:

```text
Student
  |
  v
PFMP
  |-- Organisation through SIRET
  |-- Planning through Id_Planning
  |-- Administrator through Id_Utilisateur
```

## Schedule / Planning

`Planning` stores `TotalHebdo`.

`PlanningJours` stores:

- `Jour`;
- `MatinDebut`;
- `MatinFin`;
- `ApresMidiDebut`;
- `ApresMidiFin`;
- `TotalMinutes`;
- `Id_Planning`.

Backend validation requires:

- a day label;
- complete or empty time slots;
- start before end;
- morning not overlapping afternoon;
- correct daily total;
- correct weekly total;
- weekly total not greater than 2100 minutes.

## Contact Requests

`Contacter` links a student to an organisation:

- `Id_Utilisateur`;
- `SIRET`;
- `TypeContact`;
- `DateDemande`;
- `StatutDemande`.

Statuses handled by the code:

- `En attente`;
- `Refuse`;
- `Accepte`.

To create a PFMP, the student must have an `Accepte` contact request for the requested SIRET.

## Attendance

`TablePresence` stores:

- `Id_TablePresence`;
- `DateJour`;
- `Etat`;
- `Retard`;
- `Justification`;
- `Id_Utilisateur` for the student.

States visible in code:

- `NON_RENSEIGNE`;
- `PRESENT`;
- `ABSENT`.

Attendance rows are created:

- during complete PFMP creation for working days in the schedule;
- or by the administrator daily initialization endpoint if rows are missing.

## Daily Reports

`RapportJournalier` stores:

- `Id_RapportJournalier`;
- `DateRapport`;
- `LienVersFichier`;
- `Id_PFMP`.

`Remplir` links the report to a student.

Confirmed rules:

- a report date must be inside a student PFMP period;
- only one daily report per day and PFMP is allowed;
- export/PDF features use reports inside the PFMP period.

## Messages

`Message` stores:

- `Id_Message`;
- `Id_PFMP`;
- `Id_Utilisateur`;
- `RoleExpediteur`;
- `Contenu`;
- `DateEnvoi`.

Messaging is restricted to active PFMPs and authorized participants.

## Organisations and Professionals

`Organisation` is identified by `SIRET`.

`Professionnel` is identified by `Id_Utilisateur`.

`Travailler` links a professional to an organisation:

```text
Professional / Utilisateur
  |
  v
Travailler
  |
  v
Organisation
```

During PFMP creation, the backend creates or reuses the internship supervisor and ensures the `Travailler` relation exists.

## Refresh Tokens

`RefreshToken` stores:

- `TokenHash`;
- `CreatedAt`;
- `ExpiresAt`;
- `RevokedAt`;
- `ReplacedByTokenHash`;
- `Id_Utilisateur`;
- `TokenFamilyId`;
- `FingerprintHash`.

The raw refresh token is not stored. Refresh token rotation uses token families to detect reuse.

## MySQL Docker Volume

The Docker volume is:

```text
docker-test_mysql_data
```

It is external, so it survives `docker compose down`. Do not use `docker compose down -v` unless you intentionally want to delete local database data.

See also:

- [DATABASE_BACKUP.md](DATABASE_BACKUP.md)
- [08 - Docker Deployment](08-docker-deployment.md)
