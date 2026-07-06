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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Etablissement`
--

LOCK TABLES `Etablissement` WRITE;
/*!40000 ALTER TABLE `Etablissement` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Filiere`
--

LOCK TABLES `Filiere` WRITE;
/*!40000 ALTER TABLE `Filiere` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GroupeClasse`
--

LOCK TABLES `GroupeClasse` WRITE;
/*!40000 ALTER TABLE `GroupeClasse` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Message`
--

LOCK TABLES `Message` WRITE;
/*!40000 ALTER TABLE `Message` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PFMP`
--

LOCK TABLES `PFMP` WRITE;
/*!40000 ALTER TABLE `PFMP` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Planning`
--

LOCK TABLES `Planning` WRITE;
/*!40000 ALTER TABLE `Planning` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PlanningJours`
--

LOCK TABLES `PlanningJours` WRITE;
/*!40000 ALTER TABLE `PlanningJours` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RapportJournalier`
--

LOCK TABLES `RapportJournalier` WRITE;
/*!40000 ALTER TABLE `RapportJournalier` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RefreshToken`
--

LOCK TABLES `RefreshToken` WRITE;
/*!40000 ALTER TABLE `RefreshToken` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TablePresence`
--

LOCK TABLES `TablePresence` WRITE;
/*!40000 ALTER TABLE `TablePresence` DISABLE KEYS */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Utilisateur`
--

LOCK TABLES `Utilisateur` WRITE;
/*!40000 ALTER TABLE `Utilisateur` DISABLE KEYS */;
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

-- Dump completed on 2026-07-06 19:33:15
