-- Local PFMP Manager test seed.
-- Scope: Naruto-inspired data for Lycée Suzanne Valadon only.
-- This script intentionally does not target Lycée Eugène Jamot / One Piece data.

START TRANSACTION;

CREATE TEMPORARY TABLE seed_naruto_logins (login VARCHAR(75) PRIMARY KEY);
INSERT INTO seed_naruto_logins (login) VALUES
  ('tsunade.admin@pfmp.test'),
  ('kakashi.referent@pfmp.test'),
  ('naruto.student@pfmp.test'),
  ('sasuke.student@pfmp.test'),
  ('sakura.student@pfmp.test'),
  ('hinata.student@pfmp.test'),
  ('shikamaru.student@pfmp.test'),
  ('lee.student@pfmp.test'),
  ('minato.pro@pfmp.test'),
  ('itachi.pro@pfmp.test'),
  ('jiraiya.pro@pfmp.test'),
  ('neji.pro@pfmp.test'),
  ('obito.pro@pfmp.test');

CREATE TEMPORARY TABLE seed_naruto_sirets (siret VARCHAR(14) PRIMARY KEY);
INSERT INTO seed_naruto_sirets (siret) VALUES
  ('20000000000001'),
  ('20000000000002'),
  ('20000000000003'),
  ('20000000000004'),
  ('20000000000005'),
  ('20000000000006');

CREATE TEMPORARY TABLE seed_naruto_user_ids AS
SELECT u.Id_Utilisateur AS id
FROM Utilisateur u
JOIN seed_naruto_logins l ON l.login = u.Login;

CREATE TEMPORARY TABLE seed_valadon_etab_ids AS
SELECT Id_Etablissement AS id
FROM Etablissement
WHERE NomEtablissement IN ('Lycée Suzanne Valadon', 'Lyc?e Suzanne Valadon')
  AND Ville = 'Limoges';

CREATE TEMPORARY TABLE seed_naruto_pfmp_ids (
  id INT PRIMARY KEY,
  planning_id INT NOT NULL
);
INSERT IGNORE INTO seed_naruto_pfmp_ids (id, planning_id)
SELECT Id_PFMP, Id_Planning
FROM PFMP
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids);
INSERT IGNORE INTO seed_naruto_pfmp_ids (id, planning_id)
SELECT Id_PFMP, Id_Planning
FROM PFMP
WHERE Id_Utilisateur_1 IN (SELECT id FROM seed_naruto_user_ids);
INSERT IGNORE INTO seed_naruto_pfmp_ids (id, planning_id)
SELECT Id_PFMP, Id_Planning
FROM PFMP
WHERE SIRET IN (SELECT siret FROM seed_naruto_sirets);

CREATE TEMPORARY TABLE seed_naruto_report_ids AS
SELECT Id_RapportJournalier AS id
FROM RapportJournalier
WHERE Id_PFMP IN (SELECT id FROM seed_naruto_pfmp_ids);

DELETE FROM Message
WHERE Id_PFMP IN (SELECT id FROM seed_naruto_pfmp_ids)
   OR Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids);

DELETE FROM Remplir
WHERE Id_RapportJournalier IN (SELECT id FROM seed_naruto_report_ids)
   OR Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids);

DELETE FROM RapportJournalier
WHERE Id_RapportJournalier IN (SELECT id FROM seed_naruto_report_ids);

DELETE FROM TablePresence
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids);

DELETE FROM PFMP
WHERE Id_PFMP IN (SELECT id FROM seed_naruto_pfmp_ids);

DELETE FROM PlanningJours
WHERE Id_Planning IN (SELECT planning_id FROM seed_naruto_pfmp_ids);

DELETE FROM Planning
WHERE Id_Planning IN (SELECT planning_id FROM seed_naruto_pfmp_ids);

DELETE FROM Contacter
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids)
   OR SIRET IN (SELECT siret FROM seed_naruto_sirets);

DELETE FROM Travailler
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids)
   OR SIRET IN (SELECT siret FROM seed_naruto_sirets);

DELETE FROM Professionnel
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids);

DELETE FROM Etudier
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids)
   OR Id_Etablissement IN (SELECT id FROM seed_valadon_etab_ids);

DELETE FROM Etudiant
WHERE Id_Utilisateur_1 IN (SELECT id FROM seed_naruto_user_ids);

DELETE FROM Administrer
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids)
   OR Id_Etablissement IN (SELECT id FROM seed_valadon_etab_ids);

DELETE FROM Administrateur
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids);

DELETE FROM Referent
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids);

DELETE FROM GroupeClasse
WHERE Id_Etablissement IN (SELECT id FROM seed_valadon_etab_ids);

DELETE FROM Organisation
WHERE SIRET IN (SELECT siret FROM seed_naruto_sirets);

DELETE FROM RefreshToken
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids);

DELETE FROM Utilisateur
WHERE Id_Utilisateur IN (SELECT id FROM seed_naruto_user_ids);

DELETE e
FROM Etablissement e
WHERE e.Id_Etablissement IN (SELECT id FROM seed_valadon_etab_ids)
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

INSERT INTO Filiere (LibelleFiliere)
SELECT 'BTS SIO'
WHERE NOT EXISTS (
  SELECT 1
  FROM Filiere
  WHERE LibelleFiliere = 'BTS SIO'
);
SET @idFiliere := (
  SELECT Id_Filiere
  FROM Filiere
  WHERE LibelleFiliere = 'BTS SIO'
  ORDER BY Id_Filiere
  LIMIT 1
);

INSERT INTO Etablissement
  (NomEtablissement, Adresse, CodePostal, Ville, NumTelephone, AdresseMail)
VALUES
  ('Lycée Suzanne Valadon', '39 rue François Perrin', '87000', 'Limoges', '0555121212', 'contact@valadon.pfmp.test');
SET @idValadon := LAST_INSERT_ID();

INSERT INTO GroupeClasse
  (Id_Etablissement, LibelleClasse, Grade, Id_Filiere)
VALUES
  (@idValadon, 'BTS SIO 1 SLAM', 'BTS1', @idFiliere);
SET @classeSio1Slam := LAST_INSERT_ID();

INSERT INTO GroupeClasse
  (Id_Etablissement, LibelleClasse, Grade, Id_Filiere)
VALUES
  (@idValadon, 'BTS SIO 2 SLAM', 'BTS2', @idFiliere);
SET @classeSio2Slam := LAST_INSERT_ID();

INSERT INTO GroupeClasse
  (Id_Etablissement, LibelleClasse, Grade, Id_Filiere)
VALUES
  (@idValadon, 'BTS SIO 1 SISR', 'BTS1', @idFiliere);
SET @classeSio1Sisr := LAST_INSERT_ID();

INSERT INTO GroupeClasse
  (Id_Etablissement, LibelleClasse, Grade, Id_Filiere)
VALUES
  (@idValadon, 'BTS SIO 2 SISR', 'BTS2', @idFiliere);
SET @classeSio2Sisr := LAST_INSERT_ID();

INSERT INTO Utilisateur (Nom, Prenom, Login, Pwd) VALUES
  ('Senju', 'Tsunade', 'tsunade.admin@pfmp.test', 'J8ja6BSPuQd6V3OyZ2+kkegBtSPEpdgYXJI/FVuOn3soVBFQs42ofBQ3F8t5dXN5BMXzAAYbs7SBWogKX/UWtg=='),
  ('Hatake', 'Kakashi', 'kakashi.referent@pfmp.test', 'PUbb6xKuvSI2p2nzCqYIWFpUwds8dhiRjD1aBsKfgabkf1g/Hozr0BITqMcQAVjPDTTqe4AhmZGC6liRrTKLng=='),
  ('Uzumaki', 'Naruto', 'naruto.student@pfmp.test', 'CexguoQ/dhxxh1El353CExDuytiT0ZPewkwmSaG/J3B6xRflGgKlICTuEsDgKoGd4LR9gll3CXGknS761aaK4Q=='),
  ('Uchiha', 'Sasuke', 'sasuke.student@pfmp.test', 'ihLjhIdu/fFZ9z/d4WFBrftUBMi1h/AiZqWx6IgopvF5XSjaZ5D/xAhLNCjHue9oIZxuz8fELubK8j3tRXZiqA=='),
  ('Haruno', 'Sakura', 'sakura.student@pfmp.test', '/28ajf0GWaChEr2kzESc9WvHfrOeZAzgCVv+0R/SnwcUdAxEC9kwPI4GfkmYptPH7VatEYa/lWxQa8NbCvdJOQ=='),
  ('Hyuga', 'Hinata', 'hinata.student@pfmp.test', 'n8yR0ZHqIg45F76jFtiwBRMPvtaci399XIhg9AYUUl9UhTXAQpNqlSoJ3aFiiA6scRgw8qg2Lhzg0t69PKyIlg=='),
  ('Nara', 'Shikamaru', 'shikamaru.student@pfmp.test', 'QTGtgJ9uORHPoC7B8WWzXNuXO4SXxZyiy8SnbjgvSVkVXjndiwrXz2kg2W7SkphEoP4B4Y7BRdv2k9ZxZGt9pg=='),
  ('Lee', 'Rock', 'lee.student@pfmp.test', 'f+7QO4fueYx8HuZFy7jiQSOKi5/Ppg+taFm4eIFmgclivc2DkHKjlTH4YnHMPsx6vFkPQHGgHdeldmte0bJ8AA=='),
  ('Namikaze', 'Minato', 'minato.pro@pfmp.test', 'n8LIq+gCc2kVRYwjaj4qC5AZof0LMFoWDdb2YgRBYCVoCCZHn1ZJsAWMIdhG2rC2XLlMKOPgzXZHysg9PE8foA=='),
  ('Uchiha', 'Itachi', 'itachi.pro@pfmp.test', 'KsrkHiU1zkdR25ztlP4XIAZU6An8pcS8pcM2leD/PHJIReAoENoVC9yKhQ8uptaTR5HKJV9/I88Www39ltnSMQ=='),
  ('Jiraiya', '', 'jiraiya.pro@pfmp.test', 'kSNLRA863Tqc46DIKJMFcxNtW49R4rSZq0cILhnenlqVjiNfXrn/oZNOW9TRF9a1/5BaP8dWD56DjfRBPjwIuQ=='),
  ('Hyuga', 'Neji', 'neji.pro@pfmp.test', 'oF1ZQrjRx1i4TCw1wy9AQOdWAUNtxSj92gC2sTzeOZHwOY0TrL+O19WZSkaV6U2QHHK8c/9vRz++CSx1JiLxgA=='),
  ('Uchiha', 'Obito', 'obito.pro@pfmp.test', '1KoH64K9Z4yx3UkVlpwTeQj8hZuGYSA4XH3XRchB/RyHIkUSO7WLKrZy4TydSaFOui3CNm5KgOOnUaHyuiIelQ==');

SET @idTsunade := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'tsunade.admin@pfmp.test');
SET @idKakashi := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'kakashi.referent@pfmp.test');
SET @idNaruto := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'naruto.student@pfmp.test');
SET @idSasuke := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'sasuke.student@pfmp.test');
SET @idSakura := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'sakura.student@pfmp.test');
SET @idHinata := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'hinata.student@pfmp.test');
SET @idShikamaru := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'shikamaru.student@pfmp.test');
SET @idLee := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'lee.student@pfmp.test');
SET @idMinato := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'minato.pro@pfmp.test');
SET @idItachi := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'itachi.pro@pfmp.test');
SET @idJiraiya := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'jiraiya.pro@pfmp.test');
SET @idNeji := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'neji.pro@pfmp.test');
SET @idObito := (SELECT Id_Utilisateur FROM Utilisateur WHERE Login = 'obito.pro@pfmp.test');

INSERT INTO Administrateur (Id_Utilisateur) VALUES (@idTsunade);
INSERT INTO Administrer (Id_Utilisateur, Id_Etablissement) VALUES (@idTsunade, @idValadon);

INSERT INTO Referent (Id_Utilisateur, NumTelephone, AdresseMail)
VALUES (@idKakashi, '0610101010', 'kakashi.referent@pfmp.test');

INSERT INTO Etudiant
  (Id_Utilisateur_1, Date_Naissance, Adresse, CodePostal, Ville, NumTelephone, AdresseMail, Id_Utilisateur)
VALUES
  (@idNaruto, '2006-10-10', '7 rue des Cerisiers', '87000', 'Limoges', '0611111111', 'naruto.student@pfmp.test', @idKakashi),
  (@idSasuke, '2006-07-23', '11 avenue Montjovis', '87000', 'Limoges', '0622222222', 'sasuke.student@pfmp.test', @idKakashi),
  (@idSakura, '2005-03-28', '14 rue des Arts', '87000', 'Limoges', '0633333333', 'sakura.student@pfmp.test', @idKakashi),
  (@idHinata, '2005-12-27', '21 rue de Nexon', '87000', 'Limoges', '0644444444', 'hinata.student@pfmp.test', @idKakashi),
  (@idShikamaru, '2006-09-22', '5 rue du Mas Loubier', '87000', 'Limoges', '0655555555', 'shikamaru.student@pfmp.test', @idKakashi),
  (@idLee, '2005-11-27', '18 avenue Baudin', '87000', 'Limoges', '0666666666', 'lee.student@pfmp.test', @idKakashi);

INSERT INTO Etudier
  (Id_Utilisateur, Id_Etablissement, Id_Classe, AnneeRentree, AnneeSortie)
VALUES
  (@idNaruto, @idValadon, @classeSio1Slam, 2025, 2027),
  (@idSasuke, @idValadon, @classeSio1Slam, 2025, 2027),
  (@idSakura, @idValadon, @classeSio2Slam, 2025, 2027),
  (@idHinata, @idValadon, @classeSio2Slam, 2025, 2027),
  (@idShikamaru, @idValadon, @classeSio1Sisr, 2025, 2027),
  (@idLee, @idValadon, @classeSio2Sisr, 2025, 2027);

INSERT INTO Organisation
  (SIRET, RaisonSociale, SecteurActivite, Activite, Adresse, CodePostal, Ville, AdresseMail, NumTelephone, SiteWeb)
VALUES
  ('20000000000001', 'Konoha Digital', 'Services numeriques', 'Developpement web', '12 rue Jean Jaures', '87000', 'Limoges', 'contact@konoha-digital.pfmp.test', '0555200001', 'https://konoha-digital.pfmp.test'),
  ('20000000000002', 'Uzumaki Web Studio', 'Developpement web', 'Applications frontend', '6 boulevard Carnot', '87000', 'Limoges', 'contact@uzumaki-web-studio.pfmp.test', '0555200002', 'https://uzumaki-web-studio.pfmp.test'),
  ('20000000000003', 'Uchiha Security Lab', 'Cybersecurite', 'Audit et developpement securise', '24 rue des Gras', '63000', 'Clermont-Ferrand', 'contact@uchiha-security-lab.pfmp.test', '0555200003', 'https://uchiha-security-lab.pfmp.test'),
  ('20000000000004', 'Hokage Cloud Services', 'Cloud et DevOps', 'Hebergement et infrastructure', '8 quai des Chartrons', '33000', 'Bordeaux', 'contact@hokage-cloud-services.pfmp.test', '0555200004', 'https://hokage-cloud-services.pfmp.test'),
  ('20000000000005', 'Nara Software Consulting', 'Conseil informatique', 'Logiciels metier', '3 avenue de la Gare', '23000', 'Guéret', 'contact@nara-software-consulting.pfmp.test', '0555200005', 'https://nara-software-consulting.pfmp.test'),
  ('20000000000006', 'Hyuga Network Solutions', 'Support informatique', 'Administration reseau', '10 rue Victor Hugo', '86000', 'Poitiers', 'contact@hyuga-network-solutions.pfmp.test', '0555200006', 'https://hyuga-network-solutions.pfmp.test');

INSERT INTO Professionnel
  (Id_Utilisateur, Fonction, Adresse, CodePostal, Ville, NumTelephone, AdresseMail)
VALUES
  (@idKakashi, 'Lead developpeur web', '12 rue Jean Jaures', '87000', 'Limoges', '0677010001', 'kakashi.referent@pfmp.test'),
  (@idMinato, 'Responsable frontend', '6 boulevard Carnot', '87000', 'Limoges', '0677010002', 'minato.pro@pfmp.test'),
  (@idItachi, 'Consultant securite', '24 rue des Gras', '63000', 'Clermont-Ferrand', '0677010003', 'itachi.pro@pfmp.test'),
  (@idJiraiya, 'Architecte cloud', '8 quai des Chartrons', '33000', 'Bordeaux', '0677010004', 'jiraiya.pro@pfmp.test'),
  (@idObito, 'Chef de projet logiciel', '3 avenue de la Gare', '23000', 'Guéret', '0677010005', 'obito.pro@pfmp.test'),
  (@idNeji, 'Administrateur reseau', '10 rue Victor Hugo', '86000', 'Poitiers', '0677010006', 'neji.pro@pfmp.test');

INSERT INTO Travailler (Id_Utilisateur, SIRET) VALUES
  (@idKakashi, '20000000000001'),
  (@idMinato, '20000000000002'),
  (@idItachi, '20000000000003'),
  (@idJiraiya, '20000000000004'),
  (@idObito, '20000000000005'),
  (@idNeji, '20000000000006');

INSERT INTO Contacter
  (Id_Utilisateur, SIRET, TypeContact, DateDemande, StatutDemande)
VALUES
  (@idNaruto, '20000000000001', 'Email', '2026-04-08', 'Accepte'),
  (@idSasuke, '20000000000003', 'Telephone', '2026-06-10', 'Accepte'),
  (@idSakura, '20000000000004', 'Email', '2026-06-18', 'Accepte'),
  (@idShikamaru, '20000000000005', 'Email', '2026-06-05', 'Accepte'),
  (@idLee, '20000000000006', 'Email', '2026-06-24', 'Accepte'),
  (@idHinata, '20000000000002', 'Email', '2026-06-25', 'En attente');

CREATE TEMPORARY TABLE seed_numbers (n INT PRIMARY KEY);
INSERT INTO seed_numbers (n)
SELECT ones.n + tens.n * 10 + hundreds.n * 100
FROM
  (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) ones
  CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) tens
  CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2) hundreds
WHERE ones.n + tens.n * 10 + hundreds.n * 100 <= 250;

INSERT INTO Planning (TotalHebdo) VALUES (2100);
SET @planNaruto := LAST_INSERT_ID();
INSERT INTO PlanningJours
  (Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, Id_Planning)
VALUES
  ('Lundi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planNaruto),
  ('Mardi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planNaruto),
  ('Mercredi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planNaruto),
  ('Jeudi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planNaruto),
  ('Vendredi', '09:00:00', '12:00:00', '13:00:00', '17:00:00', 420, @planNaruto);
INSERT INTO PFMP
  (DateDebut, DateFin, Id_Utilisateur, Id_Planning, SIRET, Id_Utilisateur_1, Id_MaitreStage)
VALUES
  ('2026-04-27', '2026-06-05', @idTsunade, @planNaruto, '20000000000001', @idNaruto, @idKakashi);
SET @pfmpNaruto := LAST_INSERT_ID();

INSERT INTO Planning (TotalHebdo) VALUES (2100);
SET @planSasuke := LAST_INSERT_ID();
INSERT INTO PlanningJours
  (Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, Id_Planning)
SELECT Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, @planSasuke
FROM PlanningJours
WHERE Id_Planning = @planNaruto;
INSERT INTO PFMP
  (DateDebut, DateFin, Id_Utilisateur, Id_Planning, SIRET, Id_Utilisateur_1, Id_MaitreStage)
VALUES
  ('2026-07-01', '2026-08-07', @idTsunade, @planSasuke, '20000000000003', @idSasuke, @idItachi);
SET @pfmpSasuke := LAST_INSERT_ID();

INSERT INTO Planning (TotalHebdo) VALUES (2100);
SET @planSakura := LAST_INSERT_ID();
INSERT INTO PlanningJours
  (Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, Id_Planning)
SELECT Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, @planSakura
FROM PlanningJours
WHERE Id_Planning = @planNaruto;
INSERT INTO PFMP
  (DateDebut, DateFin, Id_Utilisateur, Id_Planning, SIRET, Id_Utilisateur_1, Id_MaitreStage)
VALUES
  ('2026-09-14', '2026-10-23', @idTsunade, @planSakura, '20000000000004', @idSakura, @idJiraiya);
SET @pfmpSakura := LAST_INSERT_ID();

INSERT INTO Planning (TotalHebdo) VALUES (2100);
SET @planShikamaru := LAST_INSERT_ID();
INSERT INTO PlanningJours
  (Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, Id_Planning)
SELECT Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, @planShikamaru
FROM PlanningJours
WHERE Id_Planning = @planNaruto;
INSERT INTO PFMP
  (DateDebut, DateFin, Id_Utilisateur, Id_Planning, SIRET, Id_Utilisateur_1, Id_MaitreStage)
VALUES
  ('2026-06-29', '2026-08-14', @idTsunade, @planShikamaru, '20000000000005', @idShikamaru, @idObito);
SET @pfmpShikamaru := LAST_INSERT_ID();

INSERT INTO Planning (TotalHebdo) VALUES (2100);
SET @planLee := LAST_INSERT_ID();
INSERT INTO PlanningJours
  (Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, Id_Planning)
SELECT Jour, MatinDebut, MatinFin, ApresMidiDebut, ApresMidiFin, TotalMinutes, @planLee
FROM PlanningJours
WHERE Id_Planning = @planNaruto;
INSERT INTO PFMP
  (DateDebut, DateFin, Id_Utilisateur, Id_Planning, SIRET, Id_Utilisateur_1, Id_MaitreStage)
VALUES
  ('2026-11-02', '2026-12-11', @idTsunade, @planLee, '20000000000006', @idLee, @idNeji);
SET @pfmpLee := LAST_INSERT_ID();

INSERT INTO TablePresence (DateJour, Etat, Retard, Justification, Id_Utilisateur)
SELECT d.date_jour,
       CASE
         WHEN d.date_jour IN ('2026-05-12', '2026-05-29') THEN 'ABSENT'
         ELSE 'PRESENT'
       END,
       0,
       FALSE,
       @idNaruto
FROM (
  SELECT DATE_ADD('2026-04-27', INTERVAL n DAY) AS date_jour,
         CASE DAYOFWEEK(DATE_ADD('2026-04-27', INTERVAL n DAY))
           WHEN 2 THEN 'Lundi'
           WHEN 3 THEN 'Mardi'
           WHEN 4 THEN 'Mercredi'
           WHEN 5 THEN 'Jeudi'
           WHEN 6 THEN 'Vendredi'
         END AS jour
  FROM seed_numbers
  WHERE DATE_ADD('2026-04-27', INTERVAL n DAY) <= '2026-06-05'
) d
JOIN PlanningJours pj ON pj.Id_Planning = @planNaruto AND pj.Jour = d.jour;

INSERT INTO TablePresence (DateJour, Etat, Retard, Justification, Id_Utilisateur)
SELECT d.date_jour,
       CASE
         WHEN d.date_jour > '2026-07-06' THEN 'NON_RENSEIGNE'
         WHEN d.date_jour = '2026-07-03' THEN 'ABSENT'
         ELSE 'PRESENT'
       END,
       0,
       FALSE,
       @idSasuke
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
JOIN PlanningJours pj ON pj.Id_Planning = @planSasuke AND pj.Jour = d.jour;

INSERT INTO TablePresence (DateJour, Etat, Retard, Justification, Id_Utilisateur)
SELECT d.date_jour,
       'NON_RENSEIGNE',
       0,
       FALSE,
       @idSakura
FROM (
  SELECT DATE_ADD('2026-09-14', INTERVAL n DAY) AS date_jour,
         CASE DAYOFWEEK(DATE_ADD('2026-09-14', INTERVAL n DAY))
           WHEN 2 THEN 'Lundi'
           WHEN 3 THEN 'Mardi'
           WHEN 4 THEN 'Mercredi'
           WHEN 5 THEN 'Jeudi'
           WHEN 6 THEN 'Vendredi'
         END AS jour
  FROM seed_numbers
  WHERE DATE_ADD('2026-09-14', INTERVAL n DAY) <= '2026-10-23'
) d
JOIN PlanningJours pj ON pj.Id_Planning = @planSakura AND pj.Jour = d.jour;

INSERT INTO TablePresence (DateJour, Etat, Retard, Justification, Id_Utilisateur)
SELECT d.date_jour,
       CASE
         WHEN d.date_jour > '2026-07-06' THEN 'NON_RENSEIGNE'
         WHEN d.date_jour = '2026-07-02' THEN 'ABSENT'
         ELSE 'PRESENT'
       END,
       0,
       FALSE,
       @idShikamaru
FROM (
  SELECT DATE_ADD('2026-06-29', INTERVAL n DAY) AS date_jour,
         CASE DAYOFWEEK(DATE_ADD('2026-06-29', INTERVAL n DAY))
           WHEN 2 THEN 'Lundi'
           WHEN 3 THEN 'Mardi'
           WHEN 4 THEN 'Mercredi'
           WHEN 5 THEN 'Jeudi'
           WHEN 6 THEN 'Vendredi'
         END AS jour
  FROM seed_numbers
  WHERE DATE_ADD('2026-06-29', INTERVAL n DAY) <= '2026-08-14'
) d
JOIN PlanningJours pj ON pj.Id_Planning = @planShikamaru AND pj.Jour = d.jour;

INSERT INTO TablePresence (DateJour, Etat, Retard, Justification, Id_Utilisateur)
SELECT d.date_jour,
       'NON_RENSEIGNE',
       0,
       FALSE,
       @idLee
FROM (
  SELECT DATE_ADD('2026-11-02', INTERVAL n DAY) AS date_jour,
         CASE DAYOFWEEK(DATE_ADD('2026-11-02', INTERVAL n DAY))
           WHEN 2 THEN 'Lundi'
           WHEN 3 THEN 'Mardi'
           WHEN 4 THEN 'Mercredi'
           WHEN 5 THEN 'Jeudi'
           WHEN 6 THEN 'Vendredi'
         END AS jour
  FROM seed_numbers
  WHERE DATE_ADD('2026-11-02', INTERVAL n DAY) <= '2026-12-11'
) d
JOIN PlanningJours pj ON pj.Id_Planning = @planLee AND pj.Jour = d.jour;

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-04-28', '/journal/naruto-2026-04-28.pdf', @pfmpNaruto);
SET @rapportNaruto1 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idNaruto, @rapportNaruto1);

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-05-06', '/journal/naruto-2026-05-06.pdf', @pfmpNaruto);
SET @rapportNaruto2 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idNaruto, @rapportNaruto2);

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-07-01', '/journal/sasuke-2026-07-01.pdf', @pfmpSasuke);
SET @rapportSasuke1 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idSasuke, @rapportSasuke1);

INSERT INTO RapportJournalier (DateRapport, LienVersFichier, Id_PFMP)
VALUES ('2026-07-02', '/journal/shikamaru-2026-07-02.pdf', @pfmpShikamaru);
SET @rapportShikamaru1 := LAST_INSERT_ID();
INSERT INTO Remplir (Id_Utilisateur, Id_RapportJournalier) VALUES (@idShikamaru, @rapportShikamaru1);

INSERT INTO Message (Id_PFMP, Id_Utilisateur, RoleExpediteur, Contenu, DateEnvoi)
VALUES
  (@pfmpSasuke, @idTsunade, 'Administrateur', 'Bonjour Sasuke, le suivi PFMP est ouvert pour cette semaine.', '2026-07-02 09:00:00'),
  (@pfmpSasuke, @idSasuke, 'Etudiant', 'Bonjour, je confirme que le planning est bien commence.', '2026-07-02 12:10:00'),
  (@pfmpShikamaru, @idTsunade, 'Administrateur', 'Shikamaru, merci de verifier votre journal de bord avant vendredi.', '2026-07-01 10:20:00'),
  (@pfmpShikamaru, @idShikamaru, 'Etudiant', 'Bien recu, je le mets a jour aujourd hui.', '2026-07-01 16:45:00');

COMMIT;

SELECT 'seed_complete' AS status,
       @idValadon AS id_etablissement,
       @classeSio1Slam AS id_classe_sio_1_slam,
       @classeSio2Slam AS id_classe_sio_2_slam,
       @classeSio1Sisr AS id_classe_sio_1_sisr,
       @classeSio2Sisr AS id_classe_sio_2_sisr,
       @pfmpNaruto AS pfmp_naruto_completed,
       @pfmpSasuke AS pfmp_sasuke_ongoing,
       @pfmpSakura AS pfmp_sakura_future,
       @pfmpShikamaru AS pfmp_shikamaru_ongoing,
       @pfmpLee AS pfmp_lee_future;
