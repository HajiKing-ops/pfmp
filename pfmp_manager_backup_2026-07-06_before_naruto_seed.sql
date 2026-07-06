-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: pfmp_manager
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Administrateur`
--

DROP TABLE IF EXISTS `Administrateur`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Administrateur` (
  `Id_Utilisateur` int NOT NULL,
  PRIMARY KEY (`Id_Utilisateur`),
  CONSTRAINT `Administrateur_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Utilisateur` (`Id_Utilisateur`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Administrateur`
--

LOCK TABLES `Administrateur` WRITE;
/*!40000 ALTER TABLE `Administrateur` DISABLE KEYS */;
INSERT INTO `Administrateur` VALUES (23);
/*!40000 ALTER TABLE `Administrateur` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Administrer`
--

DROP TABLE IF EXISTS `Administrer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Administrer` (
  `Id_Utilisateur` int NOT NULL,
  `Id_Etablissement` int NOT NULL,
  PRIMARY KEY (`Id_Utilisateur`,`Id_Etablissement`),
  KEY `Id_Etablissement` (`Id_Etablissement`),
  CONSTRAINT `Administrer_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Administrateur` (`Id_Utilisateur`),
  CONSTRAINT `Administrer_ibfk_2` FOREIGN KEY (`Id_Etablissement`) REFERENCES `Etablissement` (`Id_Etablissement`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Administrer`
--

LOCK TABLES `Administrer` WRITE;
/*!40000 ALTER TABLE `Administrer` DISABLE KEYS */;
INSERT INTO `Administrer` VALUES (23,3);
/*!40000 ALTER TABLE `Administrer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Choisir`
--

DROP TABLE IF EXISTS `Choisir`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Choisir` (
  `Id_Utilisateur` int NOT NULL,
  `Id_OptionClasse` int NOT NULL,
  PRIMARY KEY (`Id_Utilisateur`,`Id_OptionClasse`),
  KEY `Id_OptionClasse` (`Id_OptionClasse`),
  CONSTRAINT `Choisir_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Etudiant` (`Id_Utilisateur_1`),
  CONSTRAINT `Choisir_ibfk_2` FOREIGN KEY (`Id_OptionClasse`) REFERENCES `OptionClasse` (`Id_OptionClasse`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Choisir`
--

LOCK TABLES `Choisir` WRITE;
/*!40000 ALTER TABLE `Choisir` DISABLE KEYS */;
/*!40000 ALTER TABLE `Choisir` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Contacter`
--

DROP TABLE IF EXISTS `Contacter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Contacter` (
  `Id_Utilisateur` int NOT NULL,
  `SIRET` varchar(14) NOT NULL,
  `TypeContact` varchar(70) DEFAULT NULL,
  `DateDemande` date DEFAULT NULL,
  `StatutDemande` varchar(12) DEFAULT NULL,
  PRIMARY KEY (`Id_Utilisateur`,`SIRET`),
  KEY `SIRET` (`SIRET`),
  CONSTRAINT `Contacter_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Etudiant` (`Id_Utilisateur_1`),
  CONSTRAINT `Contacter_ibfk_2` FOREIGN KEY (`SIRET`) REFERENCES `Organisation` (`SIRET`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Contacter`
--

LOCK TABLES `Contacter` WRITE;
/*!40000 ALTER TABLE `Contacter` DISABLE KEYS */;
INSERT INTO `Contacter` VALUES (25,'10000000000001','Email','2026-04-10','Accepte'),(26,'10000000000002','Telephone','2026-06-12','Accepte'),(27,'10000000000003','Email','2026-06-20','Accepte'),(28,'10000000000005','Email','2026-06-28','En attente'),(29,'10000000000004','Email','2026-06-01','Accepte');
/*!40000 ALTER TABLE `Contacter` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Demarches`
--

DROP TABLE IF EXISTS `Demarches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Demarches` (
  `Id_Utilisateur` int NOT NULL,
  `SIRET` varchar(14) NOT NULL,
  `dateRefus` date DEFAULT NULL,
  `status` varchar(50) NOT NULL,
  `contact` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Id_Utilisateur`,`SIRET`),
  KEY `SIRET` (`SIRET`),
  CONSTRAINT `Demarches_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Etudiant` (`Id_Utilisateur_1`),
  CONSTRAINT `Demarches_ibfk_2` FOREIGN KEY (`SIRET`) REFERENCES `Organisation` (`SIRET`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Demarches`
--

LOCK TABLES `Demarches` WRITE;
/*!40000 ALTER TABLE `Demarches` DISABLE KEYS */;
/*!40000 ALTER TABLE `Demarches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Etablissement`
--

DROP TABLE IF EXISTS `Etablissement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Etablissement` (
  `Id_Etablissement` int NOT NULL AUTO_INCREMENT,
  `NomEtablissement` varchar(50) DEFAULT NULL,
  `Adresse` varchar(50) DEFAULT NULL,
  `CodePostal` varchar(7) DEFAULT NULL,
  `Ville` varchar(50) DEFAULT NULL,
  `NumTelephone` varchar(10) DEFAULT NULL,
  `AdresseMail` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Id_Etablissement`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Etablissement`
--

LOCK TABLES `Etablissement` WRITE;
/*!40000 ALTER TABLE `Etablissement` DISABLE KEYS */;
INSERT INTO `Etablissement` VALUES (3,'Lycée Eugène Jamot','12 avenue de la République','23200','Aubusson','0555667788','contact@lycee-jamot.pfmp.test');
/*!40000 ALTER TABLE `Etablissement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Etudiant`
--

DROP TABLE IF EXISTS `Etudiant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Etudiant` (
  `Id_Utilisateur_1` int NOT NULL,
  `Date_Naissance` date DEFAULT NULL,
  `Adresse` varchar(100) DEFAULT NULL,
  `CodePostal` varchar(7) DEFAULT NULL,
  `Ville` varchar(50) DEFAULT NULL,
  `NumTelephone` varchar(10) DEFAULT NULL,
  `AdresseMail` varchar(75) DEFAULT NULL,
  `Id_Utilisateur` int NOT NULL,
  PRIMARY KEY (`Id_Utilisateur_1`),
  KEY `Id_Utilisateur` (`Id_Utilisateur`),
  CONSTRAINT `Etudiant_ibfk_1` FOREIGN KEY (`Id_Utilisateur_1`) REFERENCES `Utilisateur` (`Id_Utilisateur`),
  CONSTRAINT `Etudiant_ibfk_2` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Referent` (`Id_Utilisateur`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Etudiant`
--

LOCK TABLES `Etudiant` WRITE;
/*!40000 ALTER TABLE `Etudiant` DISABLE KEYS */;
INSERT INTO `Etudiant` VALUES (25,'2006-05-05','4 rue des Mouettes','23200','Aubusson','0601010101','luffy.student@pfmp.test',24),(26,'2006-11-11','8 rue des Forges','23200','Aubusson','0602020202','zoro.student@pfmp.test',24),(27,'2005-07-03','15 avenue du Lavoir','23200','Aubusson','0603030303','nami.student@pfmp.test',24),(28,'2005-03-02','22 rue du Pont','23200','Aubusson','0604040404','sanji.student@pfmp.test',24),(29,'2006-10-06','31 route de Guéret','23200','Aubusson','0605050505','law.student@pfmp.test',24);
/*!40000 ALTER TABLE `Etudiant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Etudier`
--

DROP TABLE IF EXISTS `Etudier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Etudier` (
  `Id_Utilisateur` int NOT NULL,
  `Id_Etablissement` int NOT NULL,
  `Id_Classe` int NOT NULL,
  `AnneeRentree` int DEFAULT NULL,
  `AnneeSortie` int DEFAULT NULL,
  PRIMARY KEY (`Id_Utilisateur`,`Id_Etablissement`,`Id_Classe`),
  KEY `Id_Etablissement` (`Id_Etablissement`,`Id_Classe`),
  CONSTRAINT `Etudier_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Etudiant` (`Id_Utilisateur_1`),
  CONSTRAINT `Etudier_ibfk_2` FOREIGN KEY (`Id_Etablissement`, `Id_Classe`) REFERENCES `GroupeClasse` (`Id_Etablissement`, `Id_Classe`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Etudier`
--

LOCK TABLES `Etudier` WRITE;
/*!40000 ALTER TABLE `Etudier` DISABLE KEYS */;
INSERT INTO `Etudier` VALUES (25,3,5,2025,2027),(26,3,5,2025,2027),(27,3,6,2025,2027),(28,3,6,2025,2027),(29,3,5,2025,2027);
/*!40000 ALTER TABLE `Etudier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Filiere`
--

DROP TABLE IF EXISTS `Filiere`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Filiere` (
  `Id_Filiere` int NOT NULL AUTO_INCREMENT,
  `LibelleFiliere` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Id_Filiere`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Filiere`
--

LOCK TABLES `Filiere` WRITE;
/*!40000 ALTER TABLE `Filiere` DISABLE KEYS */;
INSERT INTO `Filiere` VALUES (3,'BTS SIO');
/*!40000 ALTER TABLE `Filiere` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `GroupeClasse`
--

DROP TABLE IF EXISTS `GroupeClasse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `GroupeClasse` (
  `Id_Etablissement` int NOT NULL,
  `Id_Classe` int NOT NULL AUTO_INCREMENT,
  `LibelleClasse` varchar(50) DEFAULT NULL,
  `Grade` varchar(15) DEFAULT NULL,
  `Id_Filiere` int NOT NULL,
  PRIMARY KEY (`Id_Etablissement`,`Id_Classe`),
  KEY `idx_id_classe` (`Id_Classe`),
  KEY `Id_Filiere` (`Id_Filiere`),
  CONSTRAINT `GroupeClasse_ibfk_1` FOREIGN KEY (`Id_Etablissement`) REFERENCES `Etablissement` (`Id_Etablissement`),
  CONSTRAINT `GroupeClasse_ibfk_2` FOREIGN KEY (`Id_Filiere`) REFERENCES `Filiere` (`Id_Filiere`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GroupeClasse`
--

LOCK TABLES `GroupeClasse` WRITE;
/*!40000 ALTER TABLE `GroupeClasse` DISABLE KEYS */;
INSERT INTO `GroupeClasse` VALUES (3,5,'BTS SIO 1 SLAM','BTS1',3),(3,6,'BTS SIO 2 SLAM','BTS2',3);
/*!40000 ALTER TABLE `GroupeClasse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Message`
--

DROP TABLE IF EXISTS `Message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Message` (
  `Id_Message` int NOT NULL AUTO_INCREMENT,
  `RoleExpediteur` varchar(50) NOT NULL,
  `Contenu` varchar(250) NOT NULL,
  `DateEnvoi` datetime DEFAULT NULL,
  `Id_Utilisateur` int NOT NULL,
  `Id_PFMP` int NOT NULL,
  PRIMARY KEY (`Id_Message`),
  KEY `Id_Utilisateur` (`Id_Utilisateur`),
  KEY `Id_PFMP` (`Id_PFMP`),
  CONSTRAINT `Message_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Utilisateur` (`Id_Utilisateur`),
  CONSTRAINT `Message_ibfk_2` FOREIGN KEY (`Id_PFMP`) REFERENCES `PFMP` (`Id_PFMP`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Message`
--

LOCK TABLES `Message` WRITE;
/*!40000 ALTER TABLE `Message` DISABLE KEYS */;
INSERT INTO `Message` VALUES (9,'Administrateur','Bonjour Roronoa, pensez a completer votre journal de bord cette semaine.','2026-07-02 09:10:00',23,10),(10,'Etudiant','Bonjour, je le mets a jour aujourd hui. Merci.','2026-07-02 12:30:00',26,10),(11,'Administrateur','Trafalgar, votre maitre de stage a confirme le planning.','2026-07-01 10:00:00',23,11),(12,'Etudiant','Parfait, merci pour le suivi.','2026-07-01 17:20:00',29,11);
/*!40000 ALTER TABLE `Message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `OptionClasse`
--

DROP TABLE IF EXISTS `OptionClasse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `OptionClasse` (
  `Id_OptionClasse` int NOT NULL AUTO_INCREMENT,
  `LibelleOption` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Id_OptionClasse`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `OptionClasse`
--

LOCK TABLES `OptionClasse` WRITE;
/*!40000 ALTER TABLE `OptionClasse` DISABLE KEYS */;
/*!40000 ALTER TABLE `OptionClasse` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Organisation`
--

DROP TABLE IF EXISTS `Organisation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Organisation` (
  `SIRET` varchar(14) NOT NULL,
  `RaisonSociale` varchar(50) DEFAULT NULL,
  `SecteurActivite` varchar(50) DEFAULT NULL,
  `Adresse` varchar(100) DEFAULT NULL,
  `AdresseMail` varchar(75) DEFAULT NULL,
  `NumTelephone` varchar(10) DEFAULT NULL,
  `SiteWeb` varchar(100) DEFAULT NULL,
  `Activite` varchar(50) DEFAULT NULL,
  `CodePostal` varchar(10) DEFAULT NULL,
  `Ville` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`SIRET`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Organisation`
--

LOCK TABLES `Organisation` WRITE;
/*!40000 ALTER TABLE `Organisation` DISABLE KEYS */;
INSERT INTO `Organisation` VALUES ('10000000000001','Baratie Digital','Services numeriques','18 rue Haute-Vienne','contact@baratie-digital.pfmp.test','0555000001','https://baratie-digital.pfmp.test','Developpement web','87000','Limoges'),('10000000000002','Thousand Sunny Tech','Informatique','9 place Espagne','contact@thousand-sunny-tech.pfmp.test','0555000002','https://thousand-sunny-tech.pfmp.test','Developpement logiciel','23200','Aubusson'),('10000000000003','Galley-La Software','Edition logicielle','3 avenue de la Gare','contact@galley-la-software.pfmp.test','0555000003','https://galley-la-software.pfmp.test','Plateformes metier','23000','Guéret'),('10000000000004','Water Seven Solutions','Cloud et support','42 boulevard Carnot','contact@water-seven-solutions.pfmp.test','0555000004','https://water-seven-solutions.pfmp.test','Infrastructure applicative','87000','Limoges'),('10000000000005','Red Force Consulting','Conseil informatique','7 rue des Volcans','contact@red-force-consulting.pfmp.test','0555000005','https://red-force-consulting.pfmp.test','Cybersecurite','63000','Clermont-Ferrand');
/*!40000 ALTER TABLE `Organisation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PFMP`
--

DROP TABLE IF EXISTS `PFMP`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PFMP` (
  `Id_PFMP` int NOT NULL AUTO_INCREMENT,
  `DateDebut` date DEFAULT NULL,
  `DateFin` date DEFAULT NULL,
  `Id_Utilisateur` int NOT NULL,
  `Id_Planning` int NOT NULL,
  `SIRET` varchar(14) NOT NULL,
  `Id_Utilisateur_1` int NOT NULL,
  `Id_MaitreStage` int DEFAULT NULL,
  PRIMARY KEY (`Id_PFMP`),
  KEY `Id_Utilisateur` (`Id_Utilisateur`),
  KEY `Id_Planning` (`Id_Planning`),
  KEY `SIRET` (`SIRET`),
  KEY `Id_Utilisateur_1` (`Id_Utilisateur_1`),
  KEY `FK_PFMP_Travailler_MaitreStage` (`Id_MaitreStage`,`SIRET`),
  CONSTRAINT `FK_PFMP_Travailler_MaitreStage` FOREIGN KEY (`Id_MaitreStage`, `SIRET`) REFERENCES `Travailler` (`Id_Utilisateur`, `SIRET`),
  CONSTRAINT `PFMP_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Administrateur` (`Id_Utilisateur`),
  CONSTRAINT `PFMP_ibfk_2` FOREIGN KEY (`Id_Planning`) REFERENCES `Planning` (`Id_Planning`),
  CONSTRAINT `PFMP_ibfk_3` FOREIGN KEY (`SIRET`) REFERENCES `Organisation` (`SIRET`),
  CONSTRAINT `PFMP_ibfk_4` FOREIGN KEY (`Id_Utilisateur_1`) REFERENCES `Etudiant` (`Id_Utilisateur_1`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PFMP`
--

LOCK TABLES `PFMP` WRITE;
/*!40000 ALTER TABLE `PFMP` DISABLE KEYS */;
INSERT INTO `PFMP` VALUES (9,'2026-05-04','2026-06-12',23,9,'10000000000001',25,30),(10,'2026-07-01','2026-08-07',23,10,'10000000000002',26,31),(11,'2026-06-22','2026-07-31',23,11,'10000000000004',29,33),(12,'2026-09-07','2026-10-16',23,12,'10000000000003',27,32);
/*!40000 ALTER TABLE `PFMP` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Planning`
--

DROP TABLE IF EXISTS `Planning`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Planning` (
  `Id_Planning` int NOT NULL AUTO_INCREMENT,
  `TotalHebdo` int DEFAULT NULL,
  PRIMARY KEY (`Id_Planning`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Planning`
--

LOCK TABLES `Planning` WRITE;
/*!40000 ALTER TABLE `Planning` DISABLE KEYS */;
INSERT INTO `Planning` VALUES (9,2100),(10,2100),(11,2100),(12,2100);
/*!40000 ALTER TABLE `Planning` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PlanningJours`
--

DROP TABLE IF EXISTS `PlanningJours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PlanningJours` (
  `Id_planningJour` int NOT NULL AUTO_INCREMENT,
  `Jour` varchar(20) DEFAULT NULL,
  `MatinDebut` time DEFAULT NULL,
  `MatinFin` time DEFAULT NULL,
  `ApresMidiDebut` time DEFAULT NULL,
  `ApresMidiFin` time DEFAULT NULL,
  `TotalMinutes` int DEFAULT NULL,
  `Id_Planning` int NOT NULL,
  PRIMARY KEY (`Id_planningJour`),
  KEY `Id_Planning` (`Id_Planning`),
  CONSTRAINT `PlanningJours_ibfk_1` FOREIGN KEY (`Id_Planning`) REFERENCES `Planning` (`Id_Planning`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PlanningJours`
--

LOCK TABLES `PlanningJours` WRITE;
/*!40000 ALTER TABLE `PlanningJours` DISABLE KEYS */;
INSERT INTO `PlanningJours` VALUES (53,'Lundi','09:00:00','12:00:00','13:00:00','17:00:00',420,9),(54,'Mardi','09:00:00','12:00:00','13:00:00','17:00:00',420,9),(55,'Mercredi','09:00:00','12:00:00','13:00:00','17:00:00',420,9),(56,'Jeudi','09:00:00','12:00:00','13:00:00','17:00:00',420,9),(57,'Vendredi','09:00:00','12:00:00','13:00:00','17:00:00',420,9),(58,'Lundi','09:00:00','12:00:00','13:00:00','17:00:00',420,10),(59,'Mardi','09:00:00','12:00:00','13:00:00','17:00:00',420,10),(60,'Mercredi','09:00:00','12:00:00','13:00:00','17:00:00',420,10),(61,'Jeudi','09:00:00','12:00:00','13:00:00','17:00:00',420,10),(62,'Vendredi','09:00:00','12:00:00','13:00:00','17:00:00',420,10),(65,'Lundi','09:00:00','12:00:00','13:00:00','17:00:00',420,11),(66,'Mardi','09:00:00','12:00:00','13:00:00','17:00:00',420,11),(67,'Mercredi','09:00:00','12:00:00','13:00:00','17:00:00',420,11),(68,'Jeudi','09:00:00','12:00:00','13:00:00','17:00:00',420,11),(69,'Vendredi','09:00:00','12:00:00','13:00:00','17:00:00',420,11),(72,'Lundi','09:00:00','12:00:00','13:00:00','17:00:00',420,12),(73,'Mardi','09:00:00','12:00:00','13:00:00','17:00:00',420,12),(74,'Mercredi','09:00:00','12:00:00','13:00:00','17:00:00',420,12),(75,'Jeudi','09:00:00','12:00:00','13:00:00','17:00:00',420,12),(76,'Vendredi','09:00:00','12:00:00','13:00:00','17:00:00',420,12);
/*!40000 ALTER TABLE `PlanningJours` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Professionnel`
--

DROP TABLE IF EXISTS `Professionnel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Professionnel` (
  `Id_Utilisateur` int NOT NULL,
  `Fonction` varchar(50) DEFAULT NULL,
  `Adresse` varchar(100) DEFAULT NULL,
  `CodePostal` varchar(7) DEFAULT NULL,
  `Ville` varchar(50) DEFAULT NULL,
  `NumTelephone` varchar(10) DEFAULT NULL,
  `AdresseMail` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`Id_Utilisateur`),
  CONSTRAINT `Professionnel_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Utilisateur` (`Id_Utilisateur`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Professionnel`
--

LOCK TABLES `Professionnel` WRITE;
/*!40000 ALTER TABLE `Professionnel` DISABLE KEYS */;
INSERT INTO `Professionnel` VALUES (30,'Lead developpeur','18 rue Haute-Vienne','87000','Limoges','0655010001','franky.pro@pfmp.test'),(31,'Responsable support logiciel','9 place Espagne','23200','Aubusson','0655010002','brook.pro@pfmp.test'),(32,'Chef de projet web','3 avenue de la Gare','23000','Guéret','0655010003','jinbe.pro@pfmp.test'),(33,'Consultante cloud','42 boulevard Carnot','87000','Limoges','0655010004','vivi.pro@pfmp.test');
/*!40000 ALTER TABLE `Professionnel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Proposer`
--

DROP TABLE IF EXISTS `Proposer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Proposer` (
  `Id_Etablissement` int NOT NULL,
  `Id_Classe` int NOT NULL,
  `Id_OptionClasse` int NOT NULL,
  PRIMARY KEY (`Id_Etablissement`,`Id_Classe`,`Id_OptionClasse`),
  KEY `Id_OptionClasse` (`Id_OptionClasse`),
  CONSTRAINT `Proposer_ibfk_1` FOREIGN KEY (`Id_Etablissement`, `Id_Classe`) REFERENCES `GroupeClasse` (`Id_Etablissement`, `Id_Classe`),
  CONSTRAINT `Proposer_ibfk_2` FOREIGN KEY (`Id_OptionClasse`) REFERENCES `OptionClasse` (`Id_OptionClasse`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Proposer`
--

LOCK TABLES `Proposer` WRITE;
/*!40000 ALTER TABLE `Proposer` DISABLE KEYS */;
/*!40000 ALTER TABLE `Proposer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RapportJournalier`
--

DROP TABLE IF EXISTS `RapportJournalier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RapportJournalier` (
  `Id_RapportJournalier` int NOT NULL AUTO_INCREMENT,
  `DateRapport` date DEFAULT NULL,
  `LienVersFichier` varchar(100) DEFAULT NULL,
  `Id_PFMP` int NOT NULL,
  PRIMARY KEY (`Id_RapportJournalier`),
  KEY `Id_PFMP` (`Id_PFMP`),
  CONSTRAINT `RapportJournalier_ibfk_1` FOREIGN KEY (`Id_PFMP`) REFERENCES `PFMP` (`Id_PFMP`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RapportJournalier`
--

LOCK TABLES `RapportJournalier` WRITE;
/*!40000 ALTER TABLE `RapportJournalier` DISABLE KEYS */;
INSERT INTO `RapportJournalier` VALUES (13,'2026-05-05','/journal/luffy-2026-05-05.pdf',9),(14,'2026-05-19','/journal/luffy-2026-05-19.pdf',9),(15,'2026-06-10','/journal/luffy-2026-06-10.pdf',9),(16,'2026-07-01','/journal/zoro-2026-07-01.pdf',10),(17,'2026-07-02','/journal/zoro-2026-07-02.pdf',10),(18,'2026-06-23','/journal/law-2026-06-23.pdf',11);
/*!40000 ALTER TABLE `RapportJournalier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Referent`
--

DROP TABLE IF EXISTS `Referent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Referent` (
  `Id_Utilisateur` int NOT NULL,
  `NumTelephone` varchar(10) DEFAULT NULL,
  `AdresseMail` varchar(75) DEFAULT NULL,
  PRIMARY KEY (`Id_Utilisateur`),
  CONSTRAINT `Referent_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Utilisateur` (`Id_Utilisateur`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Referent`
--

LOCK TABLES `Referent` WRITE;
/*!40000 ALTER TABLE `Referent` DISABLE KEYS */;
INSERT INTO `Referent` VALUES (24,'0601020304','shanks.referent@pfmp.test');
/*!40000 ALTER TABLE `Referent` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RefreshToken`
--

DROP TABLE IF EXISTS `RefreshToken`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RefreshToken` (
  `Id_RefreshToken` int NOT NULL AUTO_INCREMENT,
  `TokenHash` varchar(256) DEFAULT NULL,
  `CreatedAt` datetime DEFAULT NULL,
  `ExpiresAt` datetime DEFAULT NULL,
  `RevokedAt` datetime DEFAULT NULL,
  `ReplacedByTokenHash` varchar(256) DEFAULT NULL,
  `Id_Utilisateur` int NOT NULL,
  `TokenFamilyId` varchar(36) NOT NULL,
  `FingerprintHash` varchar(256) NOT NULL,
  PRIMARY KEY (`Id_RefreshToken`),
  KEY `FK_RefreshToken_Utilisateur` (`Id_Utilisateur`),
  CONSTRAINT `FK_RefreshToken_Utilisateur` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Utilisateur` (`Id_Utilisateur`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RefreshToken`
--

LOCK TABLES `RefreshToken` WRITE;
/*!40000 ALTER TABLE `RefreshToken` DISABLE KEYS */;
INSERT INTO `RefreshToken` VALUES (1,'x+5CK4Zm9+f8cmae9v7TzSlKX0k8QIQMPkVgiEhrod0=','2026-07-06 19:40:26','2026-07-13 19:40:26','2026-07-06 19:40:26',NULL,23,'684ccca3-fe4f-4bf5-978a-e756eecfb830','XE1a4p0jrF/An2vCAKmRGJybHSkZydZ/NxoDCYgJ+EQ='),(2,'vB28t9ygbIshOOeXDHKi2ZGLOrLd3+ki5bmEPDgiYjg=','2026-07-06 19:40:26','2026-07-13 19:40:26','2026-07-06 19:40:26',NULL,26,'9217e80f-5bbe-4179-b973-49c5d8a56b7e','bfXDpCNqrRXh15fRxUGPeWYSVnlReBsbaZsLMMhMcI4='),(3,'InXJ2a8j8jRonfERCK1Wtp43X9STfBpPCWfsCmodaM4=','2026-07-06 19:41:42','2026-07-13 19:41:42','2026-07-06 19:41:43',NULL,23,'7a00f793-6927-4568-9744-1e1aef804650','EX8GRaHiRG3fACuFh/gGueOv/k2O0MpRJfI0XiCk8GI='),(4,'wEc+TsWoDJFj4Ndo+j4KyykPOFty4d8ODdND1XgbL8Q=','2026-07-06 19:41:43','2026-07-13 19:41:43','2026-07-06 19:41:44',NULL,26,'ab6e5958-ca1f-4894-8874-424f945ccee8','AMsBSjRyHOuSCnt/eU0NjzX8RZmfDfH2YD/ael0rpio='),(5,'vCo2nStihDWZ7+fRFUuryPZi4DD81Xy01WrOTv38ZwY=','2026-07-06 20:14:10','2026-07-13 20:14:10','2026-07-06 20:14:10',NULL,23,'fd2565db-45e0-41fc-9250-68212cf283d1','FaaXGTX42u/FIyytl8R3KGVte+Mi3p0pW1kssh3gkoA=');
/*!40000 ALTER TABLE `RefreshToken` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Remplir`
--

DROP TABLE IF EXISTS `Remplir`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Remplir` (
  `Id_Utilisateur` int NOT NULL,
  `Id_RapportJournalier` int NOT NULL,
  PRIMARY KEY (`Id_Utilisateur`,`Id_RapportJournalier`),
  KEY `Id_RapportJournalier` (`Id_RapportJournalier`),
  CONSTRAINT `Remplir_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Etudiant` (`Id_Utilisateur_1`),
  CONSTRAINT `Remplir_ibfk_2` FOREIGN KEY (`Id_RapportJournalier`) REFERENCES `RapportJournalier` (`Id_RapportJournalier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Remplir`
--

LOCK TABLES `Remplir` WRITE;
/*!40000 ALTER TABLE `Remplir` DISABLE KEYS */;
INSERT INTO `Remplir` VALUES (25,13),(25,14),(25,15),(26,16),(26,17),(29,18);
/*!40000 ALTER TABLE `Remplir` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TablePresence`
--

DROP TABLE IF EXISTS `TablePresence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `TablePresence` (
  `Id_TablePresence` int NOT NULL AUTO_INCREMENT,
  `DateJour` date NOT NULL,
  `Etat` varchar(50) NOT NULL,
  `Retard` int DEFAULT NULL,
  `Justification` tinyint(1) DEFAULT NULL,
  `Id_Utilisateur` int NOT NULL,
  PRIMARY KEY (`Id_TablePresence`),
  KEY `Id_Utilisateur` (`Id_Utilisateur`),
  CONSTRAINT `TablePresence_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Etudiant` (`Id_Utilisateur_1`)
) ENGINE=InnoDB AUTO_INCREMENT=373 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TablePresence`
--

LOCK TABLES `TablePresence` WRITE;
/*!40000 ALTER TABLE `TablePresence` DISABLE KEYS */;
INSERT INTO `TablePresence` VALUES (249,'2026-05-04','PRESENT',0,0,25),(250,'2026-05-05','PRESENT',0,0,25),(251,'2026-05-06','PRESENT',0,0,25),(252,'2026-05-07','PRESENT',0,0,25),(253,'2026-05-08','PRESENT',0,0,25),(254,'2026-05-11','PRESENT',0,0,25),(255,'2026-05-12','PRESENT',0,0,25),(256,'2026-05-13','PRESENT',0,0,25),(257,'2026-05-14','PRESENT',0,0,25),(258,'2026-05-15','PRESENT',0,0,25),(259,'2026-05-18','ABSENT',0,0,25),(260,'2026-05-19','PRESENT',0,0,25),(261,'2026-05-20','PRESENT',0,0,25),(262,'2026-05-21','PRESENT',0,0,25),(263,'2026-05-22','PRESENT',0,0,25),(264,'2026-05-25','PRESENT',0,0,25),(265,'2026-05-26','PRESENT',0,0,25),(266,'2026-05-27','PRESENT',0,0,25),(267,'2026-05-28','PRESENT',0,0,25),(268,'2026-05-29','PRESENT',0,0,25),(269,'2026-06-01','PRESENT',0,0,25),(270,'2026-06-02','PRESENT',0,0,25),(271,'2026-06-03','ABSENT',0,0,25),(272,'2026-06-04','PRESENT',0,0,25),(273,'2026-06-05','PRESENT',0,0,25),(274,'2026-06-08','PRESENT',0,0,25),(275,'2026-06-09','PRESENT',0,0,25),(276,'2026-06-10','PRESENT',0,0,25),(277,'2026-06-11','PRESENT',0,0,25),(278,'2026-06-12','PRESENT',0,0,25),(280,'2026-07-01','PRESENT',0,0,26),(281,'2026-07-02','PRESENT',0,0,26),(282,'2026-07-03','ABSENT',0,0,26),(283,'2026-07-06','PRESENT',0,0,26),(284,'2026-07-07','NON_RENSEIGNE',0,0,26),(285,'2026-07-08','NON_RENSEIGNE',0,0,26),(286,'2026-07-09','NON_RENSEIGNE',0,0,26),(287,'2026-07-10','NON_RENSEIGNE',0,0,26),(288,'2026-07-13','NON_RENSEIGNE',0,0,26),(289,'2026-07-14','NON_RENSEIGNE',0,0,26),(290,'2026-07-15','NON_RENSEIGNE',0,0,26),(291,'2026-07-16','NON_RENSEIGNE',0,0,26),(292,'2026-07-17','NON_RENSEIGNE',0,0,26),(293,'2026-07-20','NON_RENSEIGNE',0,0,26),(294,'2026-07-21','NON_RENSEIGNE',0,0,26),(295,'2026-07-22','NON_RENSEIGNE',0,0,26),(296,'2026-07-23','NON_RENSEIGNE',0,0,26),(297,'2026-07-24','NON_RENSEIGNE',0,0,26),(298,'2026-07-27','NON_RENSEIGNE',0,0,26),(299,'2026-07-28','NON_RENSEIGNE',0,0,26),(300,'2026-07-29','NON_RENSEIGNE',0,0,26),(301,'2026-07-30','NON_RENSEIGNE',0,0,26),(302,'2026-07-31','NON_RENSEIGNE',0,0,26),(303,'2026-08-03','NON_RENSEIGNE',0,0,26),(304,'2026-08-04','NON_RENSEIGNE',0,0,26),(305,'2026-08-05','NON_RENSEIGNE',0,0,26),(306,'2026-08-06','NON_RENSEIGNE',0,0,26),(307,'2026-08-07','NON_RENSEIGNE',0,0,26),(311,'2026-06-22','PRESENT',0,0,29),(312,'2026-06-23','PRESENT',0,0,29),(313,'2026-06-24','PRESENT',0,0,29),(314,'2026-06-25','PRESENT',0,0,29),(315,'2026-06-26','ABSENT',0,0,29),(316,'2026-06-29','PRESENT',0,0,29),(317,'2026-06-30','PRESENT',0,0,29),(318,'2026-07-01','PRESENT',0,0,29),(319,'2026-07-02','ABSENT',0,0,29),(320,'2026-07-03','PRESENT',0,0,29),(321,'2026-07-06','PRESENT',0,0,29),(322,'2026-07-07','NON_RENSEIGNE',0,0,29),(323,'2026-07-08','NON_RENSEIGNE',0,0,29),(324,'2026-07-09','NON_RENSEIGNE',0,0,29),(325,'2026-07-10','NON_RENSEIGNE',0,0,29),(326,'2026-07-13','NON_RENSEIGNE',0,0,29),(327,'2026-07-14','NON_RENSEIGNE',0,0,29),(328,'2026-07-15','NON_RENSEIGNE',0,0,29),(329,'2026-07-16','NON_RENSEIGNE',0,0,29),(330,'2026-07-17','NON_RENSEIGNE',0,0,29),(331,'2026-07-20','NON_RENSEIGNE',0,0,29),(332,'2026-07-21','NON_RENSEIGNE',0,0,29),(333,'2026-07-22','NON_RENSEIGNE',0,0,29),(334,'2026-07-23','NON_RENSEIGNE',0,0,29),(335,'2026-07-24','NON_RENSEIGNE',0,0,29),(336,'2026-07-27','NON_RENSEIGNE',0,0,29),(337,'2026-07-28','NON_RENSEIGNE',0,0,29),(338,'2026-07-29','NON_RENSEIGNE',0,0,29),(339,'2026-07-30','NON_RENSEIGNE',0,0,29),(340,'2026-07-31','NON_RENSEIGNE',0,0,29),(342,'2026-09-07','NON_RENSEIGNE',0,0,27),(343,'2026-09-08','NON_RENSEIGNE',0,0,27),(344,'2026-09-09','NON_RENSEIGNE',0,0,27),(345,'2026-09-10','NON_RENSEIGNE',0,0,27),(346,'2026-09-11','NON_RENSEIGNE',0,0,27),(347,'2026-09-14','NON_RENSEIGNE',0,0,27),(348,'2026-09-15','NON_RENSEIGNE',0,0,27),(349,'2026-09-16','NON_RENSEIGNE',0,0,27),(350,'2026-09-17','NON_RENSEIGNE',0,0,27),(351,'2026-09-18','NON_RENSEIGNE',0,0,27),(352,'2026-09-21','NON_RENSEIGNE',0,0,27),(353,'2026-09-22','NON_RENSEIGNE',0,0,27),(354,'2026-09-23','NON_RENSEIGNE',0,0,27),(355,'2026-09-24','NON_RENSEIGNE',0,0,27),(356,'2026-09-25','NON_RENSEIGNE',0,0,27),(357,'2026-09-28','NON_RENSEIGNE',0,0,27),(358,'2026-09-29','NON_RENSEIGNE',0,0,27),(359,'2026-09-30','NON_RENSEIGNE',0,0,27),(360,'2026-10-01','NON_RENSEIGNE',0,0,27),(361,'2026-10-02','NON_RENSEIGNE',0,0,27),(362,'2026-10-05','NON_RENSEIGNE',0,0,27),(363,'2026-10-06','NON_RENSEIGNE',0,0,27),(364,'2026-10-07','NON_RENSEIGNE',0,0,27),(365,'2026-10-08','NON_RENSEIGNE',0,0,27),(366,'2026-10-09','NON_RENSEIGNE',0,0,27),(367,'2026-10-12','NON_RENSEIGNE',0,0,27),(368,'2026-10-13','NON_RENSEIGNE',0,0,27),(369,'2026-10-14','NON_RENSEIGNE',0,0,27),(370,'2026-10-15','NON_RENSEIGNE',0,0,27),(371,'2026-10-16','NON_RENSEIGNE',0,0,27);
/*!40000 ALTER TABLE `TablePresence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Travailler`
--

DROP TABLE IF EXISTS `Travailler`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Travailler` (
  `Id_Utilisateur` int NOT NULL,
  `SIRET` varchar(14) NOT NULL,
  PRIMARY KEY (`Id_Utilisateur`,`SIRET`),
  KEY `SIRET` (`SIRET`),
  CONSTRAINT `Travailler_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Professionnel` (`Id_Utilisateur`),
  CONSTRAINT `Travailler_ibfk_2` FOREIGN KEY (`SIRET`) REFERENCES `Organisation` (`SIRET`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Travailler`
--

LOCK TABLES `Travailler` WRITE;
/*!40000 ALTER TABLE `Travailler` DISABLE KEYS */;
INSERT INTO `Travailler` VALUES (30,'10000000000001'),(31,'10000000000002'),(32,'10000000000003'),(33,'10000000000004');
/*!40000 ALTER TABLE `Travailler` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Utilisateur`
--

DROP TABLE IF EXISTS `Utilisateur`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Utilisateur` (
  `Id_Utilisateur` int NOT NULL AUTO_INCREMENT,
  `Nom` varchar(25) DEFAULT NULL,
  `Prenom` varchar(25) DEFAULT NULL,
  `Login` varchar(50) NOT NULL,
  `Pwd` varchar(256) NOT NULL,
  PRIMARY KEY (`Id_Utilisateur`),
  UNIQUE KEY `Login` (`Login`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Utilisateur`
--

LOCK TABLES `Utilisateur` WRITE;
/*!40000 ALTER TABLE `Utilisateur` DISABLE KEYS */;
INSERT INTO `Utilisateur` VALUES (23,'Robin','Nico','robin.admin@pfmp.test','z88NafH4hXJuScpIjOr4Wm1anUBxwzGxhvIQB15nYzu69zTpDsZEyVwh139jffPvN18b8c75pdReQ77zmS/OmQ=='),(24,'Shanks','','shanks.referent@pfmp.test','M6LvDy8cbaDiBv/m5Mu3er53eBa520wrVZ7dvbsF+UGDoTqrlpuSjBRpcRT0O0OF4vF4aReHYD1poJ5B2JTiqw=='),(25,'Luffy','Monkey D.','luffy.student@pfmp.test','6sUlwz5iS5dRl30V6NROSLvF3B5doeglBlQL67bIB6xdSw8guLjD2V+XfgvEvOHtKCzfXSlPYxkS2aT+8j5qOw=='),(26,'Zoro','Roronoa','zoro.student@pfmp.test','0PI+f0i02axUY/RNEvy/TyytqrXW8NHVJ6IVRDzxIxx3oNv9ITUQTmFKf0nAjUO01Fuom8MjEEk4nrRi1m4hrA=='),(27,'Nami','','nami.student@pfmp.test','6kZjNyjYnOnT7exbtrBbFSHzW+6aXB2eK55urQ9hWz2fym6Yf/fXld1FH3U2o5QuBizlaUFdwE6bnJmwSLvOYw=='),(28,'Vinsmoke','Sanji','sanji.student@pfmp.test','uwHz6iEqW+iltvwKjPp1ivyG9MbY1hTArpiKGasu33EtN+1YCFROAwAa9nqXE8+lmNd5IDJi/uIWdv7Rjjwamw=='),(29,'Law','Trafalgar','law.student@pfmp.test','9xtEGrfCpGyYQVLg9Sh578aP/fxB23y/cu8ehAv6WsvkVqYeyG7KEi/VFS8Hw6uymx/9XfV09zWDGQaN+84fgQ=='),(30,'Franky','','franky.pro@pfmp.test','LPXXC+k7Is66ebxIUfQ1jbRpRIPuhRkDcfFDW/1w521HU3RPfEMSO0w6a6OxZnRfXuJ7LZo0WR+pdo1nMVEZvA=='),(31,'Brook','','brook.pro@pfmp.test','Sn6PBMa/Icn5DqiSpRhoQ/0dm2xaL/Ww9ol7IulP2TmFMfKwXhmp1Wv9RVgnkIEMXmBG9DOgNz/4K4lgHDw2Tw=='),(32,'Jinbe','','jinbe.pro@pfmp.test','jCtz8eipBYv+bb2ORhAinPpzbWUBXF/LV+5desOzOzTUq/ERWvQPLIjLZeqtgb9tFRVEODsUoeaBPDQGHifCxQ=='),(33,'Nefertari','Vivi','vivi.pro@pfmp.test','6e7HLP+BdYvuWE6+whjQt2CsW8A+xW1WaLFoO/uxOG/WMcEzDudnO9e5b0PAV/cBv5CmUSfgNxedWZP/DCSesg==');
/*!40000 ALTER TABLE `Utilisateur` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-06 20:53:22
