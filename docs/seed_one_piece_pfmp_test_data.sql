-- Local PFMP Manager test seed.
-- Scope: One Piece-inspired school scenario for Lycée Eugène Jamot.
-- Backend code is not touched by this script.

START TRANSACTION;

CREATE TEMPORARY TABLE seed_logins (login VARCHAR(75) PRIMARY KEY);
INSERT INTO seed_logins (login) VALUES
  ('robin.admin@pfmp.test'),
  ('shanks.referent@pfmp.test'),
  ('luffy.student@pfmp.test'),
  ('zoro.student@pfmp.test'),
  ('nami.student@pfmp.test'),
  ('sanji.student@pfmp.test'),
  ('law.student@pfmp.test'),
  ('franky.pro@pfmp.test'),
  ('brook.pro@pfmp.test'),
  ('jinbe.pro@pfmp.test'),
  ('vivi.pro@pfmp.test');

CREATE TEMPORARY TABLE seed_sirets (siret VARCHAR(14) PRIMARY KEY);
INSERT INTO seed_sirets (siret) VALUES
  ('10000000000001'),
  ('10000000000002'),
  ('10000000000003'),
  ('10000000000004'),
  ('10000000000005');

CREATE TEMPORARY TABLE seed_user_ids AS
SELECT u.Id_Utilisateur AS id
FROM Utilisateur u
JOIN seed_logins l ON l.login = u.Login;

CREATE TEMPORARY TABLE seed_etab_ids AS
SELECT Id_Etablissement AS id
FROM Etablissement
WHERE NomEtablissement IN ('Lycée Eugène Jamot', 'Lyc?e Eug?ne Jamot')
  AND Ville = 'Aubusson';

CREATE TEMPORARY TABLE seed_pfmp_ids (
  id INT PRIMARY KEY,
  planning_id INT NOT NULL
);
INSERT IGNORE INTO seed_pfmp_ids (id, planning_id)
SELECT Id_PFMP, Id_Planning
FROM PFMP
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids);
INSERT IGNORE INTO seed_pfmp_ids (id, planning_id)
SELECT Id_PFMP, Id_Planning
FROM PFMP
WHERE Id_Utilisateur_1 IN (SELECT id FROM seed_user_ids);
INSERT IGNORE INTO seed_pfmp_ids (id, planning_id)
SELECT Id_PFMP, Id_Planning
FROM PFMP
WHERE SIRET IN (SELECT siret FROM seed_sirets);

CREATE TEMPORARY TABLE seed_report_ids AS
SELECT Id_RapportJournalier AS id
FROM RapportJournalier
WHERE Id_PFMP IN (SELECT id FROM seed_pfmp_ids);

DELETE FROM Message
WHERE Id_PFMP IN (SELECT id FROM seed_pfmp_ids)
   OR Id_Utilisateur IN (SELECT id FROM seed_user_ids);

DELETE FROM Remplir
WHERE Id_RapportJournalier IN (SELECT id FROM seed_report_ids)
   OR Id_Utilisateur IN (SELECT id FROM seed_user_ids);

DELETE FROM RapportJournalier
WHERE Id_RapportJournalier IN (SELECT id FROM seed_report_ids);

DELETE FROM TablePresence
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids);

DELETE FROM PFMP
WHERE Id_PFMP IN (SELECT id FROM seed_pfmp_ids);

DELETE FROM PlanningJours
WHERE Id_Planning IN (SELECT planning_id FROM seed_pfmp_ids);

DELETE FROM Planning
WHERE Id_Planning IN (SELECT planning_id FROM seed_pfmp_ids);

DELETE FROM Contacter
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids)
   OR SIRET IN (SELECT siret FROM seed_sirets);

DELETE FROM Travailler
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids)
   OR SIRET IN (SELECT siret FROM seed_sirets);

DELETE FROM Professionnel
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids);

DELETE FROM Etudier
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids)
   OR Id_Etablissement IN (SELECT id FROM seed_etab_ids);

DELETE FROM Etudiant
WHERE Id_Utilisateur_1 IN (SELECT id FROM seed_user_ids);

DELETE FROM Administrer
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids)
   OR Id_Etablissement IN (SELECT id FROM seed_etab_ids);

DELETE FROM Administrateur
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids);

DELETE FROM Referent
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids);

DELETE FROM GroupeClasse
WHERE Id_Etablissement IN (SELECT id FROM seed_etab_ids);

DELETE FROM Organisation
WHERE SIRET IN (SELECT siret FROM seed_sirets);

DELETE FROM Utilisateur
WHERE Id_Utilisateur IN (SELECT id FROM seed_user_ids);

DELETE e
FROM Etablissement e
WHERE e.Id_Etablissement IN (SELECT id FROM seed_etab_ids)
  AND NOT EXISTS (
    SELECT 1
    FROM GroupeClasse gc
    WHERE gc.Id_Etablissement = e.Id_Etablissement
  )
  AND NOT EXISTS (
    SELECT 1
    FROM Administrer a
    WHERE a.Id_Etablissement = e.Id_Etablissement
  );

DELETE f
FROM Filiere f
WHERE f.LibelleFiliere = 'BTS SIO'
  AND NOT EXISTS (
    SELECT 1
    FROM GroupeClasse gc
    WHERE gc.Id_Filiere = f.Id_Filiere
  );

INSERT INTO Etablissement
  (NomEtablissement, Adresse, CodePostal, Ville, NumTelephone, AdresseMail)
VALUES
  ('Lycée Eugène Jamot', '12 avenue de la République', '23200', 'Aubusson', '0555667788', 'contact@lycee-jamot.pfmp.test');
SET @idEtab := LAST_INSERT_ID();

INSERT INTO Filiere (LibelleFiliere)
VALUES ('BTS SIO');
SET @idFiliere := LAST_INSERT_ID();

INSERT INTO GroupeClasse
  (Id_Etablissement, LibelleClasse, Grade, Id_Filiere)
VALUES
  (@idEtab, 'BTS SIO 1 SLAM', 'BTS1', @idFiliere);
SET @classeSio1 := LAST_INSERT_ID();

INSERT INTO GroupeClasse
  (Id_Etablissement, LibelleClasse, Grade, Id_Filiere)
VALUES
  (@idEtab, 'BTS SIO 2 SLAM', 'BTS2', @idFiliere);
SET @classeSio2 := LAST_INSERT_ID();

INSERT INTO Utilisateur (Nom, Prenom, Login, Pwd) VALUES
  ('Robin', 'Nico', 'robin.admin@pfmp.test', 'z88NafH4hXJuScpIjOr4Wm1anUBxwzGxhvIQB15nYzu69zTpDsZEyVwh139jffPvN18b8c75pdReQ77zmS/OmQ=='),
  ('Shanks', '', 'shanks.referent@pfmp.test', 'M6LvDy8cbaDiBv/m5Mu3er53eBa520wrVZ7dvbsF+UGDoTqrlpuSjBRpcRT0O0OF4vF4aReHYD1poJ5B2JTiqw=='),
  ('Luffy', 'Monkey D.', 'luffy.student@pfmp.test', '6sUlwz5iS5dRl30V6NROSLvF3B5doeglBlQL67bIB6xdSw8guLjD2V+XfgvEvOHtKCzfXSlPYxkS2aT+8j5qOw=='),
  ('Zoro', 'Roronoa', 'zoro.student@pfmp.test', '0PI+f0i02axUY/RNEvy/TyytqrXW8NHVJ6IVRDzxIxx3oNv9ITUQTmFKf0nAjUO01Fuom8MjEEk4nrRi1m4hrA=='),
  ('Nami', '', 'nami.student@pfmp.test', '6kZjNyjYnOnT7exbtrBbFSHzW+6aXB2eK55urQ9hWz2fym6Yf/fXld1FH3U2o5QuBizlaUFdwE6bnJmwSLvOYw=='),
  ('Vinsmoke', 'Sanji', 'sanji.student@pfmp.test', 'uwHz6iEqW+iltvwKjPp1ivyG9MbY1hTArpiKGasu33EtN+1YCFROAwAa9nqXE8+lmNd5IDJi/uIWdv7Rjjwamw=='),
  ('Law', 'Trafalgar', 'law.student@pfmp.test', '9xtEGrfCpGyYQVLg9Sh578aP/fxB23y/cu8ehAv6WsvkVqYeyG7KEi/VFS8Hw6uymx/9XfV09zWDGQaN+84fgQ=='),
  ('Franky', '', 'franky.pro@pfmp.test', 'LPXXC+k7Is66ebxIUfQ1jbRpRIPuhRkDcfFDW/1w521HU3RPfEMSO0w6a6OxZnRfXuJ7LZo0WR+pdo1nMVEZvA=='),
  ('Brook', '', 'brook.pro@pfmp.test', 'Sn6PBMa/Icn5DqiSpRhoQ/0dm2xaL/Ww9ol7IulP2TmFMfKwXhmp1Wv9RVgnkIEMXmBG9DOgNz/4K4lgHDw2Tw=='),
  ('Jinbe', '', 'jinbe.pro@pfmp.test', 'jCtz8eipBYv+bb2ORhAinPpzbWUBXF/LV+5desOzOzTUq/ERWvQPLIjLZeqtgb9tFRVEODsUoeaBPDQGHifCxQ=='),
  ('Nefertari', 'Vivi', 'vivi.pro@pfmp.test', '6e7HLP+BdYvuWE6+whjQt2CsW8A+xW1WaLFoO/uxOG/WMcEzDudnO9e5b0PAV/cBv5CmUSfgNxedWZP/DCSesg==');

SELECT @idRobin := Id_Utilisateur FROM Utilisateur WHERE Login = 'robin.admin@pfmp.test';
SELECT @idShanks := Id_Utilisateur FROM Utilisateur WHERE Login = 'shanks.referent@pfmp.test';
SELECT @idLuffy := Id_Utilisateur FROM Utilisateur WHERE Login = 'luffy.student@pfmp.test';
SELECT @idZoro := Id_Utilisateur FROM Utilisateur WHERE Login = 'zoro.student@pfmp.test';
SELECT @idNami := Id_Utilisateur FROM Utilisateur WHERE Login = 'nami.student@pfmp.test';
SELECT @idSanji := Id_Utilisateur FROM Utilisateur WHERE Login = 'sanji.student@pfmp.test';
SELECT @idLaw := Id_Utilisateur FROM Utilisateur WHERE Login = 'law.student@pfmp.test';
SELECT @idFranky := Id_Utilisateur FROM Utilisateur WHERE Login = 'franky.pro@pfmp.test';
SELECT @idBrook := Id_Utilisateur FROM Utilisateur WHERE Login = 'brook.pro@pfmp.test';
SELECT @idJinbe := Id_Utilisateur FROM Utilisateur WHERE Login = 'jinbe.pro@pfmp.test';
SELECT @idVivi := Id_Utilisateur FROM Utilisateur WHERE Login = 'vivi.pro@pfmp.test';

INSERT INTO Administrateur (Id_Utilisateur) VALUES (@idRobin);
INSERT INTO Administrer (Id_Utilisateur, Id_Etablissement) VALUES (@idRobin, @idEtab);

INSERT INTO Referent (Id_Utilisateur, NumTelephone, AdresseMail)
VALUES (@idShanks, '0601020304', 'shanks.referent@pfmp.test');

INSERT INTO Etudiant
  (Id_Utilisateur_1, Date_Naissance, Adresse, CodePostal, Ville, NumTelephone, AdresseMail, Id_Utilisateur)
VALUES
  (@idLuffy, '2006-05-05', '4 rue des Mouettes', '23200', 'Aubusson', '0601010101', 'luffy.student@pfmp.test', @idShanks),
  (@idZoro, '2006-11-11', '8 rue des Forges', '23200', 'Aubusson', '0602020202', 'zoro.student@pfmp.test', @idShanks),
  (@idNami, '2005-07-03', '15 avenue du Lavoir', '23200', 'Aubusson', '0603030303', 'nami.student@pfmp.test', @idShanks),
  (@idSanji, '2005-03-02', '22 rue du Pont', '23200', 'Aubusson', '0604040404', 'sanji.student@pfmp.test', @idShanks),
  (@idLaw, '2006-10-06', '31 route de Guéret', '23200', 'Aubusson', '0605050505', 'law.student@pfmp.test', @idShanks);

INSERT INTO Etudier
  (Id_Utilisateur, Id_Etablissement, Id_Classe, AnneeRentree, AnneeSortie)
VALUES
  (@idLuffy, @idEtab, @classeSio1, 2025, 2027),
  (@idZoro, @idEtab, @classeSio1, 2025, 2027),
  (@idLaw, @idEtab, @classeSio1, 2025, 2027),
  (@idNami, @idEtab, @classeSio2, 2025, 2027),
  (@idSanji, @idEtab, @classeSio2, 2025, 2027);

INSERT INTO Organisation
  (SIRET, RaisonSociale, SecteurActivite, Activite, Adresse, CodePostal, Ville, AdresseMail, NumTelephone, SiteWeb)
VALUES
  ('10000000000001', 'Baratie Digital', 'Services numeriques', 'Developpement web', '18 rue Haute-Vienne', '87000', 'Limoges', 'contact@baratie-digital.pfmp.test', '0555000001', 'https://baratie-digital.pfmp.test'),
  ('10000000000002', 'Thousand Sunny Tech', 'Informatique', 'Developpement logiciel', '9 place Espagne', '23200', 'Aubusson', 'contact@thousand-sunny-tech.pfmp.test', '0555000002', 'https://thousand-sunny-tech.pfmp.test'),
  ('10000000000003', 'Galley-La Software', 'Edition logicielle', 'Plateformes metier', '3 avenue de la Gare', '23000', 'Guéret', 'contact@galley-la-software.pfmp.test', '0555000003', 'https://galley-la-software.pfmp.test'),
  ('10000000000004', 'Water Seven Solutions', 'Cloud et support', 'Infrastructure applicative', '42 boulevard Carnot', '87000', 'Limoges', 'contact@water-seven-solutions.pfmp.test', '0555000004', 'https://water-seven-solutions.pfmp.test'),
  ('10000000000005', 'Red Force Consulting', 'Conseil informatique', 'Cybersecurite', '7 rue des Volcans', '63000', 'Clermont-Ferrand', 'contact@red-force-consulting.pfmp.test', '0555000005', 'https://red-force-consulting.pfmp.test');

INSERT INTO Professionnel
  (Id_Utilisateur, Fonction, Adresse, CodePostal, Ville, NumTelephone, AdresseMail)
VALUES
  (@idFranky, 'Lead developpeur', '18 rue Haute-Vienne', '87000', 'Limoges', '0655010001', 'franky.pro@pfmp.test'),
  (@idBrook, 'Responsable support logiciel', '9 place Espagne', '23200', 'Aubusson', '0655010002', 'brook.pro@pfmp.test'),
  (@idJinbe, 'Chef de projet web', '3 avenue de la Gare', '23000', 'Guéret', '0655010003', 'jinbe.pro@pfmp.test'),
  (@idVivi, 'Consultante cloud', '42 boulevard Carnot', '87000', 'Limoges', '0655010004', 'vivi.pro@pfmp.test');

INSERT INTO Travailler (Id_Utilisateur, SIRET) VALUES
  (@idFranky, '10000000000001'),
  (@idBrook, '10000000000002'),
  (@idJinbe, '10000000000003'),
  (@idVivi, '10000000000004');

INSERT INTO Contacter
  (Id_Utilisateur, SIRET, TypeContact, DateDemande, StatutDemande)
VALUES
  (@idLuffy, '10000000000001', 'Email', '2026-04-10', 'Accepte'),
  (@idZoro, '10000000000002', 'Telephone', '2026-06-12', 'Accepte'),
  (@idNami, '10000000000003', 'Email', '2026-06-20', 'Accepte'),
  (@idLaw, '10000000000004', 'Email', '2026-06-01', 'Accepte'),
  (@idSanji, '10000000000005', 'Email', '2026-06-28', 'En attente');

CREATE TEMPORARY TABLE seed_numbers (n INT PRIMARY KEY);
INSERT INTO seed_numbers (n)
SELECT ones.n + tens.n * 10 + hundreds.n * 100
FROM
  (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) ones
  CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) tens
  CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2) hundreds
WHERE ones.n + tens.n * 10 + hundreds.n * 100 <= 250;

INSERT INTO Planning (TotalHebdo) VALUES (2100);
SET @planLuffy := LAST_INSERT_ID();
INSERT INTO PlanningJours
  (Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, Id_Planning)
VALUES
  ('Lundi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planLuffy),
  ('Mardi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planLuffy),
  ('Mercredi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planLuffy),
  ('Jeudi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planLuffy),
  ('Vendredi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planLuffy);
INSERT INTO PFMP
  (DateDebut, DateFin, Id_Utilisateur, Id_Planning, SIRET, Id_Utilisateur_1, Id_MaitreStage)
VALUES
  ('2026-05-04', '2026-06-12', @idRobin, @planLuffy, '10000000000001', @idLuffy, @idFranky);
SET @pfmpLuffy := LAST_INSERT_ID();

INSERT INTO Planning (TotalHebdo) VALUES (2100);
SET @planZoro := LAST_INSERT_ID();
INSERT INTO PlanningJours
  (Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, Id_Planning)
SELECT Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, @planZoro
FROM PlanningJours
WHERE Id_Planning = @planLuffy;
INSERT INTO PFMP
  (DateDebut, DateFin, Id_Utilisateur, Id_Planning, SIRET, Id_Utilisateur_1, Id_MaitreStage)
VALUES
  ('2026-07-01', '2026-08-07', @idRobin, @planZoro, '10000000000002', @idZoro, @idBrook);
SET @pfmpZoro := LAST_INSERT_ID();

INSERT INTO Planning (TotalHebdo) VALUES (2100);
SET @planLaw := LAST_INSERT_ID();
INSERT INTO PlanningJours
  (Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, Id_Planning)
SELECT Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, @planLaw
FROM PlanningJours
WHERE Id_Planning = @planLuffy;
INSERT INTO PFMP
  (DateDebut, DateFin, Id_Utilisateur, Id_Planning, SIRET, Id_Utilisateur_1, Id_MaitreStage)
VALUES
  ('2026-06-22', '2026-07-31', @idRobin, @planLaw, '10000000000004', @idLaw, @idVivi);
SET @pfmpLaw := LAST_INSERT_ID();

INSERT INTO Planning (TotalHebdo) VALUES (2100);
SET @planNami := LAST_INSERT_ID();
INSERT INTO PlanningJours
  (Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, Id_Planning)
SELECT Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, @planNami
FROM PlanningJours
WHERE Id_Planning = @planLuffy;
INSERT INTO PFMP
  (DateDebut, DateFin, Id_Utilisateur, Id_Planning, SIRET, Id_Utilisateur_1, Id_MaitreStage)
VALUES
  ('2026-09-07', '2026-10-16', @idRobin, @planNami, '10000000000003', @idNami, @idJinbe);
SET @pfmpNami := LAST_INSERT_ID();

INSERT INTO TablePresence (DateJour, Etat, Retard, Justification, Id_Utilisateur)
SELECT d.date_jour,
       CASE
         WHEN d.date_jour IN ('2026-05-18', '2026-06-03') THEN 'ABSENT'
         ELSE 'PRESENT'
       END,
       0,
       FALSE,
       @idLuffy
FROM (
  SELECT DATE_ADD('2026-05-04', INTERVAL n DAY) AS date_jour,
         CASE DAYOFWEEK(DATE_ADD('2026-05-04', INTERVAL n DAY))
           WHEN 2 THEN 'Lundi'
           WHEN 3 THEN 'Mardi'
           WHEN 4 THEN 'Mercredi'
           WHEN 5 THEN 'Jeudi'
           WHEN 6 THEN 'Vendredi'
         END AS jour
  FROM seed_numbers
  WHERE DATE_ADD('2026-05-04', INTERVAL n DAY) <= '2026-06-12'
) d
JOIN PlanningJours pj ON pj.Id_Planning = @planLuffy AND pj.Jour = d.jour;

INSERT INTO TablePresence (DateJour, Etat, Retard, Justification, Id_Utilisateur)
SELECT d.date_jour,
       CASE
         WHEN d.date_jour > '2026-07-06' THEN 'NON_RENSEIGNE'
         WHEN d.date_jour = '2026-07-03' THEN 'ABSENT'
         ELSE 'PRESENT'
       END,
       0,
       FALSE,
       @idZoro
FROM (
  SELECT DATE_ADD('2026-07-01', INTERVAL n DAY) AS date_jour,
         CASE DAYOFWEEK(DATE_ADD('2026-07-01', INTERVAL n DAY))
           WHEN 2 THEN 'Lundi'
           WHEN 3 THEN 'Mardi'
           WHEN 4 THEN 'Mercredi'
           WHEN 5 THEN 'Jeudi'
           WHEN 6 THEN 'Vendredi'
         END AS jour
  FROM seed_numbers
  WHERE DATE_ADD('2026-07-01', INTERVAL n DAY) <= '2026-08-07'
) d
JOIN PlanningJours pj ON pj.Id_Planning = @planZoro AND pj.Jour = d.jour;

INSERT INTO TablePresence (DateJour, Etat, Retard, Justification, Id_Utilisateur)
SELECT d.date_jour,
       CASE
         WHEN d.date_jour >= '2026-07-06' THEN 'NON_RENSEIGNE'
         WHEN d.date_jour IN ('2026-06-26', '2026-07-02') THEN 'ABSENT'
         ELSE 'PRESENT'
       END,
       0,
       FALSE,
       @idLaw
FROM (
  SELECT DATE_ADD('2026-06-22', INTERVAL n DAY) AS date_jour,
         CASE DAYOFWEEK(DATE_ADD('2026-06-22', INTERVAL n DAY))
           WHEN 2 THEN 'Lundi'
           WHEN 3 THEN 'Mardi'
           WHEN 4 THEN 'Mercredi'
           WHEN 5 THEN 'Jeudi'
           WHEN 6 THEN 'Vendredi'
         END AS jour
  FROM seed_numbers
  WHERE DATE_ADD('2026-06-22', INTERVAL n DAY) <= '2026-07-31'
) d
JOIN PlanningJours pj ON pj.Id_Planning = @planLaw AND pj.Jour = d.jour;

INSERT INTO TablePresence (DateJour, Etat, Retard, Justification, Id_Utilisateur)
SELECT d.date_jour,
       'NON_RENSEIGNE',
       0,
       FALSE,
       @idNami
FROM (
  SELECT DATE_ADD('2026-09-07', INTERVAL n DAY) AS date_jour,
         CASE DAYOFWEEK(DATE_ADD('2026-09-07', INTERVAL n DAY))
           WHEN 2 THEN 'Lundi'
           WHEN 3 THEN 'Mardi'
           WHEN 4 THEN 'Mercredi'
           WHEN 5 THEN 'Jeudi'
           WHEN 6 THEN 'Vendredi'
         END AS jour
  FROM seed_numbers
  WHERE DATE_ADD('2026-09-07', INTERVAL n DAY) <= '2026-10-16'
) d
JOIN PlanningJours pj ON pj.Id_Planning = @planNami AND pj.Jour = d.jour;

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-05-05', '/journal/luffy-2026-05-05.pdf', @pfmpLuffy);
SET @rapportLuffy1 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idLuffy, @rapportLuffy1);

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-05-19', '/journal/luffy-2026-05-19.pdf', @pfmpLuffy);
SET @rapportLuffy2 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idLuffy, @rapportLuffy2);

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-06-10', '/journal/luffy-2026-06-10.pdf', @pfmpLuffy);
SET @rapportLuffy3 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idLuffy, @rapportLuffy3);

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-07-01', '/journal/zoro-2026-07-01.pdf', @pfmpZoro);
SET @rapportZoro1 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idZoro, @rapportZoro1);

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-07-02', '/journal/zoro-2026-07-02.pdf', @pfmpZoro);
SET @rapportZoro2 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idZoro, @rapportZoro2);

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-06-23', '/journal/law-2026-06-23.pdf', @pfmpLaw);
SET @rapportLaw1 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idLaw, @rapportLaw1);

INSERT INTO Message (Id_PFMP, Id_Utilisateur, RoleExpediteur, Contenu, DateEnvoi)
VALUES
  (@pfmpZoro, @idRobin, 'Administrateur', 'Bonjour Roronoa, pensez a completer votre journal de bord cette semaine.', '2026-07-02 09:10:00'),
  (@pfmpZoro, @idZoro, 'Etudiant', 'Bonjour, je le mets a jour aujourd hui. Merci.', '2026-07-02 12:30:00'),
  (@pfmpLaw, @idRobin, 'Administrateur', 'Trafalgar, votre maitre de stage a confirme le planning.', '2026-07-01 10:00:00'),
  (@pfmpLaw, @idLaw, 'Etudiant', 'Parfait, merci pour le suivi.', '2026-07-01 17:20:00');

COMMIT;

SELECT 'seed_complete' AS status,
       @idEtab AS id_etablissement,
       @classeSio1 AS id_classe_sio_1_slam,
       @classeSio2 AS id_classe_sio_2_slam,
       @pfmpLuffy AS pfmp_luffy_completed,
       @pfmpZoro AS pfmp_zoro_ongoing,
       @pfmpLaw AS pfmp_law_ongoing,
       @pfmpNami AS pfmp_nami_future;
