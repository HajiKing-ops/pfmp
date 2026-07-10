# 06 - Database model

The data model is represented by the EF Core entities in `PFMPManager.Api/Models` and by the `DbSet` properties on `AppDbContext`.

Important: `AppDbContext` mainly configures the composite primary keys of certain join tables. The business relationships described below are inferred from the controller/service code and from column names. Whether foreign-key constraints exist at the database schema level still needs to be checked in the SQL schema.

## Main DbSets

| Entity | Role |
| --- | --- |
| `Utilisateur` | Base account: last name, first name, login, hashed password. |
| `Etudiant` | Student profile, with an apparent link to a referent. |
| `Referent` | Teacher/referent profile. |
| `Administrateur` | Administrator profile. |
| `Pfmp` | Work-based training placement period. |
| `Organisation` | Host company/organization. |
| `Professionnel` | Workplace supervisor/professional. |
| `Planning` | Weekly total for a schedule. |
| `PlanningJours` | Days and time slots for a schedule. |
| `Contacter` | Contact application between a student and an organization. |
| `RapportJournalier` | Logbook entry. |
| `Remplir` | Link between a student and a logbook entry. |
| `TablePresence` | Attendance, absence, lateness, justification. |
| `Message` | Message tied to a PFMP. |
| `Etablissement` | School. |
| `GroupeClasse` | Class, tied to a school and a program. |
| `Filiere` | Training program/track. |
| `Etudier` | A student's enrollment in a class for a school period. |
| `Administrer` | Link between an administrator and a school. |
| `Travailler` | Link between a professional and an organization. |
| `RefreshToken` | Hashed refresh tokens, rotation, and fingerprint. |

## Keys configured in `AppDbContext`

Tables with a composite key:

| Entity | Key |
| --- | --- |
| `Remplir` | `(Id_Utilisateur, Id_RapportJournalier)` |
| `Contacter` | `(Id_Utilisateur, SIRET)` |
| `Travailler` | `(Id_Utilisateur, SIRET)` |
| `Etudier` | `(Id_Utilisateur, Id_Etablissement, Id_Classe)` |
| `GroupeClasse` | `(Id_Etablissement, Id_Classe)` |
| `Administrer` | `(Id_Utilisateur, Id_Etablissement)` |

Other entities use `[Key]` on their classes.

## Users and roles

The shared account type is `Utilisateur`.

Application roles:

```text
Utilisateur
  |-- Etudiant          -> role "Etudiant"
  |-- Referent          -> role "Enseignant"
  |-- Administrateur    -> role "Administrateur"
  |-- Professionnel     -> business-model entity, not a login role currently
```

`RoleService` checks roles in this order: student, referent, administrator.

## Inferred business relationships

### Student, referent, and class

```text
Utilisateur
  |
  v
Etudiant
  | Id_Utilisateur_1 = student's user account
  | Id_Utilisateur   = apparent referent
  v
Etudier
  |
  v
GroupeClasse
  |
  v
Etablissement / Filiere
```

The teacher-side code checks the assignment with `Etudiant.Id_Utilisateur == referentId` and `Etudiant.Id_Utilisateur_1 == studentId`.

### Administrator and schools

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

Admin endpoints load students starting from the schools the administrator manages.

### PFMP

Main fields on `Pfmp`:

- `Id_PFMP`;
- `DateDebut`;
- `DateFin`;
- `Id_Utilisateur`: the administrator tied to the PFMP;
- `Id_Planning`;
- `SIRET`;
- `Id_Utilisateur_1`: the student.

Business relationship:

```text
Etudiant
  |
  v
PFMP
  |-- Organisation via SIRET
  |-- Planning via Id_Planning
  |-- Administrateur via Id_Utilisateur
```

## Schedule

`Planning` holds `TotalHebdo` (weekly total).

`PlanningJours` holds:

- `Jour` (day);
- `MatinDebut` (morning start);
- `MatinFin` (morning end);
- `ApresMidiDebut` (afternoon start);
- `ApresMidiFin` (afternoon end);
- `TotalMinutes`;
- `Id_Planning`.

Backend validation enforces:

- a day must be set;
- a time slot must be fully filled in or fully empty;
- start before end;
- morning must not overlap the afternoon;
- correct daily total;
- correct weekly total, capped at 2100 minutes.

## Applications

`Contacter` links a student to an organization:

- `Id_Utilisateur`;
- `SIRET`;
- `TypeContact`;
- `DateDemande`;
- `StatutDemande`.

Statuses handled by the code:

- `En attente` (pending);
- `Refuse` (rejected);
- `Accepte` (accepted).

To create a PFMP, the student must have an `Accepte` application for the requested SIRET.

## Attendance

`TablePresence` holds:

- `Id_TablePresence`;
- `DateJour`;
- `Etat`;
- `Retard`;
- `Justification`;
- `Id_Utilisateur` (the student).

Visible states:

- `NON_RENSEIGNE` (not filled in);
- `PRESENT`;
- `ABSENT`.

Attendance rows are created:

- while a PFMP is being created, for the working days in the schedule;
- or through the admin's daily initialization, when a row is missing.

## Logbook and reports

`RapportJournalier` holds:

- `Id_RapportJournalier`;
- `DateRapport`;
- `LienVersFichier`;
- `Id_PFMP`.

`Remplir` links the student to the report.

Visible rules:

- a report must fall within a PFMP period;
- only one report per day per PFMP;
- export (PDF or JSON) uses the reports from the PFMP period.

## Messages

`Message` holds:

- `Id_Message`;
- `Id_PFMP`;
- `Id_Utilisateur`;
- `RoleExpediteur`;
- `Contenu`;
- `DateEnvoi`.

Messaging is restricted to active PFMPs and authorized users.

## Organizations and professionals

`Organisation` is identified by `SIRET`.

`Professionnel` is identified by `Id_Utilisateur`.

`Travailler` links a professional to an organization:

```text
Professionnel / Utilisateur
  |
  v
Travailler
  |
  v
Organisation
```

While a PFMP is being created, the backend creates or finds the workplace supervisor and makes sure the `Travailler` relationship exists.

## Refresh tokens

`RefreshToken` stores:

- `TokenHash`;
- `CreatedAt`;
- `ExpiresAt`;
- `RevokedAt`;
- `ReplacedByTokenHash`;
- `Id_Utilisateur`;
- `TokenFamilyId`;
- `FingerprintHash`.

The raw token is never stored. Rotation keeps a family of tokens so reuse can be detected and the whole family revoked.

## MySQL and the Docker volume

The configured Docker volume is:

```text
docker-test_mysql_data
```

It is external, so it survives `docker compose down`. Do not use `docker compose down -v` unless the goal is to delete local data.

See also:

- [MySQL backup & restore](DATABASE_BACKUP.md)
- [08 - Docker and deployment](08-docker-deployment.md)
