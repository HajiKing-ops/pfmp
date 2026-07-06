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
INSERT INTO `Administrateur` VALUES (7);
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
INSERT INTO `Administrer` VALUES (7,1);
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
INSERT INTO `Contacter` VALUES (3,'123','commerce@gmail.com','2026-06-19','Accepte'),(3,'12345','commerce@gmail.com','2026-06-19','Accepte'),(4,'123','commerce@gmail.com','2026-06-19','Refuse'),(4,'1234','rbgerb','2026-06-06','Refuse'),(4,'12345','nvl coord','2026-06-26','Refuse'),(4,'14417034819541','nouvelle coordinneetationage','2026-06-26','Accepte'),(4,'15011894435933','vedzsv','2026-06-26','En attente'),(4,'17334840504201','vezv','2026-06-26','En attente'),(4,'25587664685451','cercecc','2026-02-26','En attente'),(4,'28707096088869','vezv','2026-06-26','En attente'),(4,'60222557122150','ezcv','2026-03-26','Refuse'),(4,'84987768852967','vezve','2026-06-26','En attente'),(4,'91814908632797','eazf','2026-06-26','En attente'),(4,'91847009398547','vezv','2026-06-26','En attente'),(4,'95061606381566','vezve','2026-06-26','En attente'),(4,'97637145277952','cazc','2026-06-26','En attente'),(5,'123','commerce@gmail.com','2026-06-19','Accepte'),(5,'12345','commerce@gmail.com','2026-06-19','Accepte'),(9,'123','commerce@gmail.com','2026-06-19','Accepte'),(9,'1234','commerce@gmail.com','2026-06-19','Accepte'),(9,'12345','commerce@gmail.com','2026-06-19','Accepte'),(16,'12345','commerce@gmail.com','2026-06-19','Accepte'),(17,'12345','commerce@gmail.com','2026-06-19','Accepte');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Etablissement`
--

LOCK TABLES `Etablissement` WRITE;
/*!40000 ALTER TABLE `Etablissement` DISABLE KEYS */;
INSERT INTO `Etablissement` VALUES (1,'School Eugene Jamot','1 Rue Williams Dumazet','23200','Aubusson','0555677280','ce.0230002c@ac-limoges.fr');
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
INSERT INTO `Etudiant` VALUES (3,'2005-05-01','27 Rue de la Paix','75012','Paris','06893434','nami@gmail.com',1),(4,'2006-06-01','rue du tokyo','60342','Lille','33224234','usopp@gmail.com',2),(5,'2007-06-01','rue du famous','0003','Nice','343323234','sanj@gmail.com',1),(9,'2005-05-01','27 Rue de la Paix','75012','Paris','06893434','brook@gmail.com',2),(16,'2005-05-01','27 Rue de la Paix','75012','Paris','06893434','john@gmail.com',2),(17,'2005-05-01','27 Rue de la Paix','75012','Paris','06893434','bob@gmail.com',2);
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
INSERT INTO `Etudier` VALUES (3,1,1,2026,2027),(4,1,1,2026,2027),(5,1,1,2026,2027),(9,1,1,2026,2027),(16,1,1,2026,2027),(17,1,1,2026,2027);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Filiere`
--

LOCK TABLES `Filiere` WRITE;
/*!40000 ALTER TABLE `Filiere` DISABLE KEYS */;
INSERT INTO `Filiere` VALUES (1,'BTS SIO');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GroupeClasse`
--

LOCK TABLES `GroupeClasse` WRITE;
/*!40000 ALTER TABLE `GroupeClasse` DISABLE KEYS */;
INSERT INTO `GroupeClasse` VALUES (1,1,'SLAM','BRS',1);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Message`
--

LOCK TABLES `Message` WRITE;
/*!40000 ALTER TABLE `Message` DISABLE KEYS */;
INSERT INTO `Message` VALUES (1,'Etudiant','hi how are you','2026-06-24 14:53:30',3,1),(2,'Etudiant','hi how are you','2026-06-25 10:16:19',5,3),(3,'Administrateur','im good and you','2026-06-25 10:17:00',7,3);
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
INSERT INTO `Organisation` VALUES ('00022212145605','L\'ateleir du cycliste','Mtiers dans l\'entreprise: Mcanicien vlo, vendeu','2 Rue Nationale, 23200 Aubusson',NULL,'055566438',NULL,NULL,NULL,NULL),('00196421129443','Centre Hospitalier de Gueret Service des Urgences','Sant et mdico-social','4 Rue des Bndictins, 23000 Guret',NULL,'055541123',NULL,NULL,NULL,NULL),('00210980202330','Fondation Partage et Vie - EHPAD Le Mas Faure - Ah','Sant et mdico-social','3 Route Nationale, 23150 Moutier-d\'Ahun',NULL,'055500071',NULL,NULL,NULL,NULL),('01072276823749','Capella Ceramics','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566462',NULL,NULL,NULL,NULL),('01590179792897','Lyce Pierre Bourdan','Administration publique','6 Place Bonnyaud, 23000 Guret',NULL,'055552167',NULL,NULL,NULL,NULL),('01796485257284','King Jouet','Commerce et services','4 Rue des Bndictins, 23000 Guret',NULL,'055541119','https://www.kingjouet.fr',NULL,NULL,NULL),('01844513312754','L\'picerie et La Cave d\'Aubusson','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566313',NULL,NULL,NULL,NULL),('02404391554894','Syl\'boutique','Commerce vtements et mode','4 Alle des Tapis, 23200 Aubusson',NULL,'055566189',NULL,NULL,NULL,NULL),('02667691639937','Capucine','Commerce et services','3 Route Nationale, 23260 Crocq',NULL,'055500041',NULL,NULL,NULL,NULL),('02681024041255','1000 Pierres','Exposition et vente de minraux','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566367',NULL,NULL,NULL,NULL),('02975584587998','Sport 2000 Guret','Sport et loisirs','6 Place Bonnyaud, 23000 Guret',NULL,'055552145','https://www.sport2000.fr',NULL,NULL,NULL),('04821871462542','Tentacule et Libellule','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566313',NULL,NULL,NULL,NULL),('05042264289035','Maison de la Presse Felletin','Librairie presse','7 Rue Jean Jaurs, 23500 Felletin',NULL,'055539171',NULL,NULL,NULL,NULL),('05227271002761','Ephad Les Signolles','Commerce et services','15 Place d\'Armes, 23000 Guret',NULL,'055552143',NULL,NULL,NULL,NULL),('05682124035376','Chapuzet Kvin','Commerce et services','3 Route Nationale, 23700 Auzances',NULL,'055500017',NULL,NULL,NULL,NULL),('06764783610828','Imajeans Gueret','Commerce vtements et mode','6 Place Bonnyaud, 23000 Guret',NULL,'055552133',NULL,NULL,NULL,NULL),('06887619644672','Prepa 23','Commerce et services','5 Rue du Bourg, 23260 Crocq',NULL,'055500030',NULL,NULL,NULL,NULL),('07152155800622','Garage Mendes','Automobile et mcanique','1 Rue Principale, 23260 Crocq',NULL,'055500049',NULL,NULL,NULL,NULL),('07516912783425','Le Cheyenne','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566123',NULL,NULL,NULL,NULL),('07570215896875','Carrefour Express Felletin','Grande distribution alimentaire','3 Rue Porte de Banize, 23500 Felletin',NULL,'055539162','https://www.carrefour.fr',NULL,NULL,NULL),('07689845425143','Brialcash','Commerce et services','9 Rue du Thtre, 23000 Guret',NULL,'055552088',NULL,NULL,NULL,NULL),('08127045800993','La Noisettine','Commerce et services','9 Rue du Commerce, 23200 Aubusson',NULL,'055566236',NULL,NULL,NULL,NULL),('08328915750783','Le Kiosque','Commerce et services','2 Rue Nationale, 23200 Aubusson',NULL,'055566058',NULL,NULL,NULL,NULL),('08407014196583','Boulangerie SAUVANET ADRIEN','Boulangerie ptisserie','4 Alle des Tapis, 23200 Aubusson',NULL,'055566189',NULL,NULL,NULL,NULL),('08463294130617','Ppinire Boustie','Commerce et services','3 Route Nationale, 23000 Creuse',NULL,'055500062',NULL,NULL,NULL,NULL),('08536072126112','MONOPRIX','Grande distribution alimentaire','21 Rue de la Chtre, 23000 Guret',NULL,'055541034','https://www.monoprix.fr',NULL,NULL,NULL),('08704258257143','ASIO mutuelle','Assurance','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566195',NULL,NULL,NULL,NULL),('08705064428958','Canaille','Commerce et services','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566355',NULL,NULL,NULL,NULL),('08949000863478','Bagilet Latapie Sidonie','Commerce et services','5 Rue du Bourg, 23260 Crocq',NULL,'055500033',NULL,NULL,NULL,NULL),('09440893836318','Loren Institut','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566052',NULL,NULL,NULL,NULL),('10203893476418','Livre Libre','Librairie presse','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566545',NULL,NULL,NULL,NULL),('10447781644635','Le Troubadour','Commerce et services','3 Rue Porte de Banize, 23500 Felletin',NULL,'055539257',NULL,NULL,NULL,NULL),('10641117386389','MDA Electromnager Discount','Commerce et services','15 Place d\'Armes, 23000 Guret',NULL,'055552127',NULL,NULL,NULL,NULL),('11161483156175','Hospital Center Les Gents D\'or','Sant et mdico-social','5 Rue du Bourg, 23000 Creuse',NULL,'055500078',NULL,NULL,NULL,NULL),('11510250461589','Quali prim','Commerce et services','12 Rue Vieille, 23200 Aubusson',NULL,'055566040',NULL,NULL,NULL,NULL),('12074521091541','Au Fil du Temps','Commerce et services','8 Rue des Dports, 23200 Aubusson',NULL,'055566254',NULL,NULL,NULL,NULL),('12175287332203','JARDINS DIVERS Felletin','Commerce et services','10 Grand Rue, 23500 Felletin',NULL,'055539284',NULL,NULL,NULL,NULL),('12215514905274','GROUPE CPN NOTAIRES - Me Jean-Yves CANOVA ET Me Pi','Services juridiques et comptables','8 Rue des Dports, 23200 Aubusson',NULL,'055566094',NULL,NULL,NULL,NULL),('123','Co\'Ordi','Informatique','10 Rue Exemple, 23000 Guret','commerce@gmail.com','098722','yo.com',NULL,NULL,NULL),('1234','TechPlus','Informatique','15 Avenue Victor Hugo','contact@techplus.fr','3423423','yo.com','Developpement web et maintenance informatique','23000','Gueret'),('12345','BureauService','Services','5 Place du Marche','contact@bureauservice.fr','078492723','yo.com','Gestion administrative et bureautique','23600','Limoges'),('12792906863913','Le Comptoir d\'Aubusson','Commerce et services','12 Rue Vieille, 23200 Aubusson',NULL,'055566230',NULL,NULL,NULL,NULL),('13330267096167','Atomic Vlo','Automobile et mcanique','3 Route Nationale, 23000 Creuse',NULL,'055500059',NULL,NULL,NULL,NULL),('14184829378612','Zeeman, 3251','Commerce et services','9 Rue du Thtre, 23000 Guret',NULL,'055552014','https://www.zeeman.com',NULL,NULL,NULL),('14417034819541','Eurovia Poitou Charentes Limousin - Aubusson','Commerce et services','9 Rue du Commerce, 23200 Aubusson',NULL,'055566266',NULL,NULL,NULL,NULL),('14460538989636','Aubusson Immobilier','Agence immobilire','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566581',NULL,NULL,NULL,NULL),('14587391414445','Alta Conduite 23','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566212',NULL,NULL,NULL,NULL),('15011894435933','Intermarch SUPER Aubusson','Grande distribution alimentaire','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566331','https://www.intermarche.com',NULL,NULL,NULL),('15193554533891','Le monde du macaron','Commerce et services','21 Rue de la Chtre, 23000 Guret',NULL,'055541040',NULL,NULL,NULL,NULL),('15450194247046','Au Chat Noir','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566147',NULL,NULL,NULL,NULL),('15542713004293','.ma Shoes','Commerce et services','4 Alle des Tapis, 23200 Aubusson',NULL,'055566349',NULL,NULL,NULL,NULL),('16435043437864','Le Number','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566272',NULL,NULL,NULL,NULL),('16706104756755','LCL Banque et assurance','Assurance','4 Alle des Tapis, 23200 Aubusson',NULL,'055566129','https://www.lcl.fr',NULL,NULL,NULL),('16718099677720','Baudoin Beatrice Architecte','Architecture et ingnierie','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566272',NULL,NULL,NULL,NULL),('17334840504201','ATL Production','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566052',NULL,NULL,NULL,NULL),('17791581698462','Vlo Futur','Automobile et mcanique','3 Route Nationale, 23000 Creuse',NULL,'055500080',NULL,NULL,NULL,NULL),('17936345496962','LA PLACE des crateurs','Commerce et services','3 Rue Porte de Banize, 23500 Felletin',NULL,'055539022',NULL,NULL,NULL,NULL),('18792365833498','Abeille Assurances - Felletin','Assurance','7 Rue Jean Jaurs, 23500 Felletin',NULL,'055539046',NULL,NULL,NULL,NULL),('18803927367600','Aymard Thierry','Commerce et services','1 Rue Principale, 23260 Crocq',NULL,'055500058',NULL,NULL,NULL,NULL),('18841533459753','GEMO GUERET OUEST Chaussures et Vtements','Commerce vtements et mode','21 Rue de la Chtre, 23000 Guret',NULL,'055541090','https://www.gemo.com',NULL,NULL,NULL),('19410512547313','Vib\'s (Cache Cache - Bonobo - Bral)','Commerce et services','12 Rue Eugne France, 23000 Guret',NULL,'055552026',NULL,NULL,NULL,NULL),('19614727804289','Sauvanet Mazuel','Plombier chauffagiste','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566361',NULL,NULL,NULL,NULL),('19854630368238','Bfm Aurence','Commerce et services','8 Rue Jean Jaurs, 87000 Limoges',NULL,'055579063',NULL,NULL,NULL,NULL),('20058696030313','Point Nickel','Commerce et services','3 Route Nationale, 23700 Auzances',NULL,'055500023',NULL,NULL,NULL,NULL),('20068118240844','ALLIANCE Forts Bois','Menuiserie et travail du bois','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566367',NULL,NULL,NULL,NULL),('20411801587568','Leitao','Commerce et services','3 Route Nationale, 23000 Creuse',NULL,'055500032',NULL,NULL,NULL,NULL),('21294177038015','Le Petit Casino','Grande distribution alimentaire','3 Route Nationale, 23260 Crocq',NULL,'055500050',NULL,NULL,NULL,NULL),('21772928970307','Pharmacie Lagrange & Malartre','Pharmacie','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566195',NULL,NULL,NULL,NULL),('23226472569626','Atomic Moto','Automobile et mcanique','5 Rue du Bourg, 23000 Creuse',NULL,'055500066',NULL,NULL,NULL,NULL),('23418347435127','La Petite Agence','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566343',NULL,NULL,NULL,NULL),('23718168547114','Berthelier et fils','Commerce et services','1 Rue Principale, 23260 Crocq',NULL,'055500079',NULL,NULL,NULL,NULL),('23747429352693','Diminu\'tif','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566242',NULL,NULL,NULL,NULL),('23769014626422','Grgoire et Breuil','Commerce et services','5 Rue du Bourg, 23000 Creuse',NULL,'055500066',NULL,NULL,NULL,NULL),('24961252952478','DALAUDIERE AUTOMATION','Automobile et mcanique','1 Rue Principale, 23260 Crocq',NULL,'055500025',NULL,NULL,NULL,NULL),('25125129084324','CHAUSSEA Guret','Commerce et services','15 Place d\'Armes, 23000 Guret',NULL,'055552161','https://www.chaussea.com',NULL,NULL,NULL),('25411901000351','Thlem assurances Crocq','Assurance','5 Rue du Bourg, 23260 Crocq',NULL,'055500093',NULL,NULL,NULL,NULL),('25488245851462','Office de Tourisme du Grand Guret','Commerce et services','9 Rue du Thtre, 23000 Guret',NULL,'055552054',NULL,NULL,NULL,NULL),('25587664685451','Netto','Grande distribution alimentaire','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566117','https://www.netto.fr',NULL,NULL,NULL),('25697035867367','Scierie du Pont Vallereix','Menuiserie et travail du bois','5 Rue du Bourg, 23000 Creuse',NULL,'055500069',NULL,NULL,NULL,NULL),('25860679912061','PUYBARET','Restauration','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566551',NULL,NULL,NULL,NULL),('26020769081393','Hospital Center Eugene Jamot','Sant et mdico-social','1 Rue Principale, 23300 La Souterraine',NULL,'055500016',NULL,NULL,NULL,NULL),('26743443236442','Cabinet Veterinaire Des Tours','Commerce et services','1 Rue Principale, 23260 Crocq',NULL,'055500034',NULL,NULL,NULL,NULL),('27611203783808','La Rose Des Vents','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566557',NULL,NULL,NULL,NULL),('27780350668091','Pressiat Sarl','Commerce et services','1 Rue Principale, 23000 Creuse',NULL,'055500037',NULL,NULL,NULL,NULL),('27803022301918','L\'Esprit du lieu','Commerce et services','9 Rue du Commerce, 23200 Aubusson',NULL,'055566486',NULL,NULL,NULL,NULL),('28474233186749','Creuse Mdical','Sant et mdico-social','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566135',NULL,NULL,NULL,NULL),('28543081034974','Intermarch CONTACT Felletin','Grande distribution alimentaire','14 Avenue des Dports, 23500 Felletin',NULL,'055539263','https://www.intermarche.com',NULL,NULL,NULL),('28581593850284','Boucherie Romain Freitas Sarl','Boucherie charcuterie','14 Avenue des Dports, 23500 Felletin',NULL,'055539168',NULL,NULL,NULL,NULL),('28660466414827','Moreau et Fils -Scierie','Menuiserie et travail du bois','5 Rue du Bourg, 23000 Creuse',NULL,'055500099',NULL,NULL,NULL,NULL),('28707096088869','SARL Bujon - Citron','Automobile et mcanique','3 Route Nationale, 23000 Creuse',NULL,'055500038',NULL,NULL,NULL,NULL),('29250364385366','Escapade','Commerce et services','9 Rue du Commerce, 23200 Aubusson',NULL,'055566456',NULL,NULL,NULL,NULL),('29297684505726','Piscine du Grand Guret','Sport et loisirs','4 Rue des Bndictins, 23000 Guret',NULL,'055541175',NULL,NULL,NULL,NULL),('29663685538292','Souvenir D\' Antan Antiquites Brocante J.Dabin','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566082',NULL,NULL,NULL,NULL),('30003925105817','Quincaillerie et Equipement Creusois','Bricolage et matriaux','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566147',NULL,NULL,NULL,NULL),('30197215790611','MarcoGaspar','Commerce et services','12 Rue Vieille, 23200 Aubusson',NULL,'055566480',NULL,NULL,NULL,NULL),('30495170608092','Dupradeaux Cyrille','Commerce et services','5 Rue du Bourg, 23260 Crocq',NULL,'055500024',NULL,NULL,NULL,NULL),('30603974080875','Le Caf du Commerce','Restauration','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566385',NULL,NULL,NULL,NULL),('30616318862172','Defi-Mat / Micard Agriculture','Culture et patrimoine','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566397',NULL,NULL,NULL,NULL),('30709267631835','Maison de Retraite La Plaudine','Sant et mdico-social','1 Rue Principale, 87200 Saint-Junien',NULL,'055500022',NULL,NULL,NULL,NULL),('30769746433563','JOUVIN RENOV','Commerce et services','1 Rue Principale, 23000 Creuse',NULL,'055500073',NULL,NULL,NULL,NULL),('30825643451663','EHPAD SAINT JEAN','+ de 18 ans','8 Rue des Dports, 23200 Aubusson',NULL,'055566284',NULL,NULL,NULL,NULL),('31502866991864','La Cit des Insectes','Commerce et services','3 Route Nationale, 23000 Creuse',NULL,'055500077',NULL,NULL,NULL,NULL),('31545709274120','Carrire du Thym - Fayolle et Fils','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566593',NULL,NULL,NULL,NULL),('32431096139652','NATAQUASHOP - MLCN SPORTS','Sport et loisirs','3 Route Nationale, 23000 Creuse',NULL,'055500032',NULL,NULL,NULL,NULL),('34408516125986','CASH INFORMATIQUE','Informatique et numrique','4 Alle des Tapis, 23200 Aubusson',NULL,'055566569',NULL,NULL,NULL,NULL),('34674666784214','Les Maisons du pont','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566117',NULL,NULL,NULL,NULL),('34708152633091','Latelier de laurine','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566022',NULL,NULL,NULL,NULL),('35688917451401','FIDUCIAL Expertise Aubusson','Services juridiques et comptables','2 Rue Nationale, 23200 Aubusson',NULL,'055566218','https://www.fiducial.fr',NULL,NULL,NULL),('35984781842795','Sophlore','Commerce et services','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566575',NULL,NULL,NULL,NULL),('36009963235950','Chez Armand','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566397',NULL,NULL,NULL,NULL),('36822977885960','E.Leclerc Brico','Grande distribution alimentaire','21 Rue de la Chtre, 23000 Guret',NULL,'055541096','https://www.leclerc.com',NULL,NULL,NULL),('37581774553162','ici Creuse','Commerce et services','15 Place d\'Armes, 23000 Guret',NULL,'055552155',NULL,NULL,NULL,NULL),('37702266932377','Arbortech','Commerce et services','3 Route Nationale, 23260 Crocq',NULL,'055500095',NULL,NULL,NULL,NULL),('38323817934348','Aubusson Immobilier agence de felletin','Agence immobilire','14 Avenue des Dports, 23500 Felletin',NULL,'055539088',NULL,NULL,NULL,NULL),('38340062818249','Structure Bois','Menuiserie et travail du bois','5 Rue du Bourg, 23260 Crocq',NULL,'055500018',NULL,NULL,NULL,NULL),('39155019256815','Bati-Dcor 23','Btiment et travaux publics','1 Rue Principale, 23000 Sainte-Feyre',NULL,'055500076',NULL,NULL,NULL,NULL),('39589595661185','Raynaud Christian','Commerce et services','3 Route Nationale, 23000 Creuse',NULL,'055500011',NULL,NULL,NULL,NULL),('39675561872043','Citadelle','Commerce et services','4 Alle des Tapis, 23200 Aubusson',NULL,'055566569',NULL,NULL,NULL,NULL),('39691733820304','BNP Paribas','Banque et services financiers','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566147','https://www.bnpparibas.fr',NULL,NULL,NULL),('40206657673499','Muse de la Snatorie','Culture et patrimoine','15 Place d\'Armes, 23000 Guret',NULL,'055552121',NULL,NULL,NULL,NULL),('40523517331060','Au Poil Fou','Commerce et services','2 Rue Nationale, 23200 Aubusson',NULL,'055566468',NULL,NULL,NULL,NULL),('41896837235523','Atelier Claire-Marie Steinmetz','Commerce et services','10 Grand Rue, 23500 Felletin',NULL,'055539174',NULL,NULL,NULL,NULL),('41993604578006','Un Instant  Soi','Commerce et services','12 Rue Vieille, 23200 Aubusson',NULL,'055566010',NULL,NULL,NULL,NULL),('42572906336984','AUTO ECOLE MARYSE','Automobile et mcanique','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566082',NULL,NULL,NULL,NULL),('42763801178636','Gamm vert','Agriculture et fournitures agricoles','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566242','https://www.gammvert.fr',NULL,NULL,NULL),('43264682495676','Marcon Immobilier Aubusson','Agence immobilire','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566587',NULL,NULL,NULL,NULL),('43353576373414','Maison des Sports - UNSS Creuse','Sport et loisirs','15 Place d\'Armes, 23000 Guret',NULL,'055552139',NULL,NULL,NULL,NULL),('43393027882009','MISS BOCAUX & MISTER LOCAL','Commerce et services','5 Rue du Bourg, 23000 Sainte-Feyre',NULL,'055500090',NULL,NULL,NULL,NULL),('44678326848819','Rugby Club Gurtois','Sport et loisirs','21 Rue de la Chtre, 23000 Guret',NULL,'055541018',NULL,NULL,NULL,NULL),('45290130860637','Banque Populaire Aquitaine Centre Atlantique','Banque et services financiers','9 Rue du Commerce, 23200 Aubusson',NULL,'055566426','https://www.banquepopulaire.fr',NULL,NULL,NULL),('45353841243271','BAR DE LA TOUR','Restauration','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566313',NULL,NULL,NULL,NULL),('45774901748433','Le Chant du Monde','Commerce et services','4 Alle des Tapis, 23200 Aubusson',NULL,'055566599',NULL,NULL,NULL,NULL),('46225791947040','Lgend\'HAIR','Coiffure','14 Avenue des Dports, 23500 Felletin',NULL,'055539043',NULL,NULL,NULL,NULL),('47206178005516','Arlette Coiffure','Coiffure','5 Rue du Bourg, 23000 Creuse',NULL,'055500012',NULL,NULL,NULL,NULL),('47254784457164','Centre Hospitalier La Valette','Sant et mdico-social','5 Rue du Bourg, 23000 Creuse',NULL,'055500099',NULL,NULL,NULL,NULL),('47363185018589','Nc Coiffure','Coiffure','2 Rue Nationale, 23200 Aubusson',NULL,'055566218',NULL,NULL,NULL,NULL),('47386269651119','Chemin Naturo','Commerce et services','12 Rue Vieille, 23200 Aubusson',NULL,'055566290',NULL,NULL,NULL,NULL),('47878584883123','Gansoinat EURL','Commerce et services','5 Rue du Bourg, 23700 Auzances',NULL,'055500045',NULL,NULL,NULL,NULL),('48626275408079','Kebap 23','Commerce et services','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566515',NULL,NULL,NULL,NULL),('48701174251011','Gendraud Entreprise','Commerce et services','3 Route Nationale, 23260 Crocq',NULL,'055500059',NULL,NULL,NULL,NULL),('48953361461178','Mairie de Limoges','Administration publique','5 Place de la Rpublique, 87000 Limoges',NULL,'055578035',NULL,NULL,NULL,NULL),('48991817801141','MAAF Assurances','Assurance','9 Rue du Commerce, 23200 Aubusson',NULL,'055566266','https://www.maaf.fr',NULL,NULL,NULL),('49382199552029','Le Barbier Felletin','Coiffure','7 Rue Jean Jaurs, 23500 Felletin',NULL,'055539236',NULL,NULL,NULL,NULL),('49434618689596','EHPAD de Sainte-Feyre','Sant et mdico-social','3 Route Nationale, 23000 Creuse',NULL,'055500029',NULL,NULL,NULL,NULL),('49568689457023','Prfecture de la Creuse','Administration publique','4 Rue des Bndictins, 23000 Guret',NULL,'055541153',NULL,NULL,NULL,NULL),('49958720292366','Le Gallia','Commerce et services','8 Rue des Dports, 23200 Aubusson',NULL,'055566444',NULL,NULL,NULL,NULL),('50449570942403','Crdit Mutuel','Banque et services financiers','9 Rue du Thtre, 23000 Guret',NULL,'055552048','https://www.creditmutuel.fr',NULL,NULL,NULL),('50731884279194','Vival Mrinchal','Grande distribution alimentaire','1 Rue Principale, 23260 Crocq',NULL,'055500031','https://www.vival.fr',NULL,NULL,NULL),('51088868568452','Vittoria Tattoo Shop','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566527',NULL,NULL,NULL,NULL),('51270895648555','PEUGEOT - SARL MONMANEIX','Automobile et mcanique','8 Rue des Dports, 23200 Aubusson',NULL,'055566474',NULL,NULL,NULL,NULL),('51485194973781','RENAULT DACIA','Automobile et mcanique','3 Avenue Charles de Gaulle, 23000 Guret',NULL,'055541147',NULL,NULL,NULL,NULL),('51544513970251','Passant Yves','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566367',NULL,NULL,NULL,NULL),('51946869655464','Hospital Aubusson - Site Le Mont','Sant et mdico-social','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566385',NULL,NULL,NULL,NULL),('52045950914925','EHPAD Jean Mazet','Sant et mdico-social','5 Place Quinault, 23500 Felletin',NULL,'055539215',NULL,NULL,NULL,NULL),('52616411447405','Espace Laine Laines Et Cration','Artisanat d\'art - Tapisserie','14 Avenue des Dports, 23500 Felletin',NULL,'055539028',NULL,NULL,NULL,NULL),('52734473237120','Optique Deblais','Optique','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566153',NULL,NULL,NULL,NULL),('52848170976917','B.E.M.P Bureau d\'Etudes Mathieu Penaud','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566587',NULL,NULL,NULL,NULL),('53261270412441','Ehpad Clairefontaine Fondation Partage et Vie','Sant et mdico-social','1 Rue Principale, 23000 Creuse',NULL,'055500091',NULL,NULL,NULL,NULL),('53385265755172','E.Leclerc GUERET','Grande distribution alimentaire','6 Place Bonnyaud, 23000 Guret',NULL,'055552189','https://www.leclerc.com',NULL,NULL,NULL),('53658894933733','Inaba Yukie','Commerce et services','4 Alle des Tapis, 23200 Aubusson',NULL,'055566159',NULL,NULL,NULL,NULL),('53753949084816','Boucherie Digoin','Boucherie charcuterie','12 Rue Vieille, 23200 Aubusson',NULL,'055566420',NULL,NULL,NULL,NULL),('54336546901860','Menuiseries Fayette - Fabricant et installateur','Menuiserie et travail du bois','5 Rue du Bourg, 23000 Sainte-Feyre',NULL,'055500060',NULL,NULL,NULL,NULL),('54485496511451','Mairie de Gueret','Administration publique','18 Rue du Snateur Cornu, 23000 Guret',NULL,'055541068',NULL,NULL,NULL,NULL),('55181138535881','Penache Feyssac SARL','Commerce et services','1 Rue Principale, 23260 Crocq',NULL,'055500016',NULL,NULL,NULL,NULL),('55272425601357','Teinture Aubusson Lab. Nadia PETKOVIC','Commerce et services','9 Rue du Commerce, 23200 Aubusson',NULL,'055566296',NULL,NULL,NULL,NULL),('55336581546450','Limousine de lavage automatique','Automobile et mcanique','2 Rue Nationale, 23200 Aubusson',NULL,'055566438',NULL,NULL,NULL,NULL),('55512502028038','Chaussures Au Chat Noir','Commerce vtements et mode','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566141',NULL,NULL,NULL,NULL),('56125689448176','Le France','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566337',NULL,NULL,NULL,NULL),('56468585312452','Nature Horse 23','Fleuristerie et nature','12 Rue Eugne France, 23000 Guret',NULL,'055552076',NULL,NULL,NULL,NULL),('56617014998174','Atelier A2','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566533',NULL,NULL,NULL,NULL),('57380429997902','Rochez Florent','Commerce et services','1 Rue Principale, 23000 Creuse',NULL,'055500058',NULL,NULL,NULL,NULL),('57571336142767','Ptisserie Rullire','Boulangerie ptisserie','12 Rue Vieille, 23200 Aubusson',NULL,'055566260',NULL,NULL,NULL,NULL),('58618025371264','Boubet Isabelle','Commerce et services','5 Rue du Bourg, 23000 Creuse',NULL,'055500054',NULL,NULL,NULL,NULL),('59352480151474','Oceathys','Commerce et services','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566581',NULL,NULL,NULL,NULL),('59527399327922','Atelier de la Rozeille Ebnisterie d\'Art','Menuiserie et travail du bois','3 Route Nationale, 23000 Creuse',NULL,'055500044',NULL,NULL,NULL,NULL),('59542590437643','Drojat Nathalie','Commerce et services','7 Rue Jean Jaurs, 23500 Felletin',NULL,'055539221',NULL,NULL,NULL,NULL),('59912033175229','Scierie Labourier','Menuiserie et travail du bois','5 Rue du Bourg, 23000 Creuse',NULL,'055500072',NULL,NULL,NULL,NULL),('60031927595726','Boulangerie Bourgninaud Philippe','Boulangerie ptisserie','1 Rue Principale, 23260 Crocq',NULL,'055500082',NULL,NULL,NULL,NULL),('60222557122150','Allianz Assurance AUBUSSON - Franck DECELLE','Assurance','12 Rue Vieille, 23200 Aubusson',NULL,'055566010','https://www.allianz.fr',NULL,NULL,NULL),('60289183039638','Le Chant des Simples','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566492',NULL,NULL,NULL,NULL),('60319701786020','Manufacture Robert Four','Artisanat d\'art - Tapisserie','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566492',NULL,NULL,NULL,NULL),('60563244461179','Muse des Compagnons du Tour de France - Cit des ','Culture et patrimoine','12 Rue du Consulat, 87000 Limoges',NULL,'055577049',NULL,NULL,NULL,NULL),('60794352319740','Espace Paul Rebeyrolle','Commerce et services','1 Rue Principale, 87200 Saint-Junien',NULL,'055500070',NULL,NULL,NULL,NULL),('61082459442577','Nathy Coiff','Coiffure','4 Alle des Tapis, 23200 Aubusson',NULL,'055566539',NULL,NULL,NULL,NULL),('61364134273819','Htel de Colbert','Htellerie','9 Rue du Commerce, 23200 Aubusson',NULL,'055566456',NULL,NULL,NULL,NULL),('61838354230496','La Rizire','Commerce et services','12 Rue Vieille, 23200 Aubusson',NULL,'055566450',NULL,NULL,NULL,NULL),('62120602798328','L\'Atelier du Cycliste','Sport et loisirs','8 Rue des Dports, 23200 Aubusson',NULL,'055566064',NULL,NULL,NULL,NULL),('63154505958427','Boutique LM','Commerce vtements et mode','8 Rue des Dports, 23200 Aubusson',NULL,'055566034',NULL,NULL,NULL,NULL),('63270069446074','Les Essentielles','Commerce et services','12 Rue Vieille, 23200 Aubusson',NULL,'055566010',NULL,NULL,NULL,NULL),('63569235551011','MMA Assurances','Assurance','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566325','https://www.mma.fr',NULL,NULL,NULL),('63675927897548','Boulangerie Ptisserie Jocelyn Berthe','Boulangerie ptisserie','1 Rue Principale, 23150 Moutier-d\'Ahun',NULL,'055500013',NULL,NULL,NULL,NULL),('64151751849258','Roulez facile','Commerce et services','5 Rue du Bourg, 23300 La Souterraine',NULL,'055500087',NULL,NULL,NULL,NULL),('64524883245034','Paul Rnovation Couverture & Maonnerie en creuse','Btiment et travaux publics','8 Rue des Dports, 23200 Aubusson',NULL,'055566094',NULL,NULL,NULL,NULL),('64529415571650','Elancia | GUERET','Commerce et services','3 Avenue Charles de Gaulle, 23000 Guret',NULL,'055541125',NULL,NULL,NULL,NULL),('64852713448282','Multi Services Cadorel','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566432',NULL,NULL,NULL,NULL),('65183601489988','Viva Construction Bois','Btiment et travaux publics','3 Route Nationale, 23260 Crocq',NULL,'055500032',NULL,NULL,NULL,NULL),('65437771904889','Conseil dpartemental de la Creuse','Administration publique','12 Rue Eugne France, 23000 Guret',NULL,'055552060',NULL,NULL,NULL,NULL),('65820019631281','L\'EPICERIE','Commerce et services','4 Alle des Tapis, 23200 Aubusson',NULL,'055566379',NULL,NULL,NULL,NULL),('65993575880319','Milton Avenue','Commerce et services','4 Rue des Bndictins, 23000 Guret',NULL,'055541169',NULL,NULL,NULL,NULL),('66161473877590','Hospital Center Bernard Desplas','Sant et mdico-social','3 Route Nationale, 23000 Sainte-Feyre',NULL,'055500092',NULL,NULL,NULL,NULL),('66614615512788','EHPAD Plisson Fontanier','Sant et mdico-social','5 Rue du Bourg, 23000 Creuse',NULL,'055500036',NULL,NULL,NULL,NULL),('66656826726459','Aux Produits D\'Adle','Commerce et services','4 Alle des Tapis, 23200 Aubusson',NULL,'055566189',NULL,NULL,NULL,NULL),('67197423016668','Crdit Agricole Centre France - Aubusson','Banque et services financiers','12 Rue Vieille, 23200 Aubusson',NULL,'055566290','https://www.credit-agricole.fr',NULL,NULL,NULL),('67477018685795','Pub 51','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566533',NULL,NULL,NULL,NULL),('67590911942991','Vival Crocq','Grande distribution alimentaire','5 Rue du Bourg, 23260 Crocq',NULL,'055500024','https://www.vival.fr',NULL,NULL,NULL),('67648066596654','cap velo creuse','Automobile et mcanique','1 Rue Principale, 23000 Creuse',NULL,'055500094',NULL,NULL,NULL,NULL),('67883286178598','Mairie d\'Aubusson','Administration publique','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566111',NULL,NULL,NULL,NULL),('68148139489630','Antalya Kebab','Restauration','4 Alle des Tapis, 23200 Aubusson',NULL,'055566319',NULL,NULL,NULL,NULL),('68653015346355','Manufacture PINTON','Artisanat d\'art - Tapisserie','5 Place Quinault, 23500 Felletin',NULL,'055539085',NULL,NULL,NULL,NULL),('68657024515177','Visserias Sarl','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566117',NULL,NULL,NULL,NULL),('68980495326617','AGENCE CREUSOISE','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566153',NULL,NULL,NULL,NULL),('70026468679915','Toyota - Garage de l\'Avenir - Gueret','Automobile et mcanique','6 Place Bonnyaud, 23000 Guret',NULL,'055552183',NULL,NULL,NULL,NULL),('70275714219106',' Ct \"la cantine\"','Restauration','8 Rue des Dports, 23200 Aubusson',NULL,'055566474',NULL,NULL,NULL,NULL),('70561918789090','Atelier Les Michelines','Commerce et services','3 Rue Porte de Banize, 23500 Felletin',NULL,'055539037',NULL,NULL,NULL,NULL),('70665889884526','Boucherie Montel Jrme','Boucherie charcuterie','1 Rue Principale, 23260 Crocq',NULL,'055500061',NULL,NULL,NULL,NULL),('70897571028824','Maison de la Presse Cigarette lectronique Tabac','Librairie presse','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566373',NULL,NULL,NULL,NULL),('71071127885513','Trsors de la Nature','Fleuristerie et nature','12 Rue Vieille, 23200 Aubusson',NULL,'055566420',NULL,NULL,NULL,NULL),('71287150883774','GiFi GUERET','Commerce et services','9 Rue du Thtre, 23000 Guret',NULL,'055552020','https://www.gifi.fr',NULL,NULL,NULL),('71484731101030','Saint Cricq Loisirs','Commerce et services','8 Rue des Dports, 23200 Aubusson',NULL,'055566254',NULL,NULL,NULL,NULL),('71797470006514','C2color','Commerce et services','2 Rue Nationale, 23200 Aubusson',NULL,'055566248',NULL,NULL,NULL,NULL),('71892490860576','Impression Nouvelle','Commerce et services','2 Rue Nationale, 23200 Aubusson',NULL,'055566498',NULL,NULL,NULL,NULL),('71982753899288','Au Petit Bonheur - Bouquiniste','Commerce et services','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566361',NULL,NULL,NULL,NULL),('72276545145413','Scieries des Gardes','Menuiserie et travail du bois','5 Place Quinault, 23500 Felletin',NULL,'055539165',NULL,NULL,NULL,NULL),('72295439928606','Creuse Oxygne','Commerce et services','21 Rue de la Chtre, 23000 Guret',NULL,'055541074',NULL,NULL,NULL,NULL),('72404634829807','Bibliothque francophone multimdia de Limoges','Culture et patrimoine','12 Rue du Consulat, 87000 Limoges',NULL,'055577028',NULL,NULL,NULL,NULL),('72536679589254','Ehpad Les Myosotis','Sant et mdico-social','5 Rue du Bourg, 23000 Creuse',NULL,'055500057',NULL,NULL,NULL,NULL),('72739320615117','Maxi Zoo Guret','Commerce et services','15 Place d\'Armes, 23000 Guret',NULL,'055552195','https://www.maxizoo.fr',NULL,NULL,NULL),('73185780806047','DARTY Gueret','Commerce et services','18 Rue du Snateur Cornu, 23000 Guret',NULL,'055541012','https://www.darty.com',NULL,NULL,NULL),('73190566463516','LE CAFE DES ARTS','Restauration','2 Rue Nationale, 23200 Aubusson',NULL,'055566278',NULL,NULL,NULL,NULL),('73356073706399','Sermo','Commerce et services','2 Rue Nationale, 23200 Aubusson',NULL,'055566468',NULL,NULL,NULL,NULL),('73549861625680','SUEZ Activit Eau France','Commerce et services','3 Route Nationale, 23000 Creuse',NULL,'055500086',NULL,NULL,NULL,NULL),('73846982087899','Adecco Aubusson','Travail temporaire','4 Alle des Tapis, 23200 Aubusson',NULL,'055566539','https://www.adecco.fr',NULL,NULL,NULL),('73891951975183','La Snatorerie  23000 Guret','Commerce et services','3 Avenue Charles de Gaulle, 23000 Guret',NULL,'055541141',NULL,NULL,NULL,NULL),('73962860093104','Ehpad Les quatre cadrans','Sant et mdico-social','5 Rue du Bourg, 23000 Creuse',NULL,'055500030',NULL,NULL,NULL,NULL),('73970481456598','Cecchetti Sarl','Commerce et services','1 Rue Principale, 23000 Creuse',NULL,'055500010',NULL,NULL,NULL,NULL),('74869582881994','Jardins Divers Aubusson','Commerce et services','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566177',NULL,NULL,NULL,NULL),('75159881737067','Action Guret','Commerce et services','3 Avenue Charles de Gaulle, 23000 Guret',NULL,'055541197','https://www.action.com',NULL,NULL,NULL),('75309237882925','Tand\'Aime','Commerce et services','1 Rue Principale, 23000 Creuse',NULL,'055500073',NULL,NULL,NULL,NULL),('75312309639569','Maison Etcaetera','Commerce et services','2 Rue Nationale, 23200 Aubusson',NULL,'055566278',NULL,NULL,NULL,NULL),('75374521929048','FAYETTE','Commerce et services','3 Route Nationale, 23000 Creuse',NULL,'055500038',NULL,NULL,NULL,NULL),('75459100538760','Blanchard Hygine Service','Commerce et services','1 Rue Principale, 23000 Creuse',NULL,'055500040',NULL,NULL,NULL,NULL),('75944592906303','Pressing','Pressing et blanchisserie','9 Rue du Commerce, 23200 Aubusson',NULL,'055566426',NULL,NULL,NULL,NULL),('77116372653525','Audouze Bernard (SARL)','Commerce et services','5 Rue du Bourg, 23000 Creuse',NULL,'055500051',NULL,NULL,NULL,NULL),('77875163410975','Chaumeix SA','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566183',NULL,NULL,NULL,NULL),('77911525375013','La Poste Aubusson','Commerce et services','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566515',NULL,NULL,NULL,NULL),('78051319293963','Aubusson lectricit','lectricit','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566575',NULL,NULL,NULL,NULL),('78837115975911','La Poste Felletin','Commerce et services','14 Avenue des Dports, 23500 Felletin',NULL,'055539198',NULL,NULL,NULL,NULL),('78885127741109','Garage Malcom','Automobile et mcanique','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566177',NULL,NULL,NULL,NULL),('79238595419473','Caquineau Christophe','Commerce et services','2 Rue Nationale, 23200 Aubusson',NULL,'055566248',NULL,NULL,NULL,NULL),('79590596551348','Janicaud','Commerce et services','1 Rue Principale, 23000 Creuse',NULL,'055500070',NULL,NULL,NULL,NULL),('79819640087885','France Matriaux - Barlaud Matriaux','Restauration','5 Place Quinault, 23500 Felletin',NULL,'055539135',NULL,NULL,NULL,NULL),('79826363656449','Agence Groupama Aubusson','Assurance','12 Rue Vieille, 23200 Aubusson',NULL,'055566260','https://www.groupama.fr',NULL,NULL,NULL),('80263030432742','Intermarch CONTACT','Grande distribution alimentaire','14 Avenue des Dports, 23500 Felletin',NULL,'055539248','https://www.intermarche.com',NULL,NULL,NULL),('80454658965921','Chirac Chantal','Commerce et services','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566521',NULL,NULL,NULL,NULL),('80519907691825','MAF DIAGNOSTIC IMMOBILIER & AUDIT NERGTIQUE','Agence immobilire','8 Rue des Dports, 23200 Aubusson',NULL,'055566064',NULL,NULL,NULL,NULL),('80610662584725','Pharmacie Espagne','Pharmacie','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566581',NULL,NULL,NULL,NULL),('80649181106239','Le Chapitre','Commerce et services','9 Rue du Commerce, 23200 Aubusson',NULL,'055566016',NULL,NULL,NULL,NULL),('81542465209242',' La Terrade','Commerce et services','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566581',NULL,NULL,NULL,NULL),('81617314315246','Atelier de Marie-Valrie','Commerce et services','12 Rue Vieille, 23200 Aubusson',NULL,'055566040',NULL,NULL,NULL,NULL),('82272605064798','MNConstruction-Couverture','Btiment et travaux publics','5 Rue du Bourg, 23150 Moutier-d\'Ahun',NULL,'055500039',NULL,NULL,NULL,NULL),('82464914194697','Intersport Gueret','Sport et loisirs','21 Rue de la Chtre, 23000 Guret',NULL,'055541052','https://www.intersport.fr',NULL,NULL,NULL),('82476487575722','LB Rnovation','Btiment et travaux publics','5 Rue du Bourg, 23150 Moutier-d\'Ahun',NULL,'055500087',NULL,NULL,NULL,NULL),('82856245332637','Intermarch SUPER Sainte-Feyre','Grande distribution alimentaire','4 Rue des Bndictins, 23000 Guret',NULL,'055541197','https://www.intermarche.com',NULL,NULL,NULL),('83236184152889','ChaMaux Photographie et galerie d\'art Chabredier','Culture et patrimoine','9 Rue du Commerce, 23200 Aubusson',NULL,'055566076',NULL,NULL,NULL,NULL),('84275255155447','AXA Assurance et Banque Martial Beaufils','Assurance','9 Rue du Commerce, 23200 Aubusson',NULL,'055566296','https://www.axa.fr',NULL,NULL,NULL),('84889747312629','Galerie Jabert Tapisserie Aubusson','Artisanat d\'art - Tapisserie','12 Rue Vieille, 23200 Aubusson',NULL,'055566070',NULL,NULL,NULL,NULL),('84987768852967','SECAL Socit d\'Expertise Comptable Aquitaine Limo','Services juridiques et comptables','10 Grand Rue, 23500 Felletin',NULL,'055539159',NULL,NULL,NULL,NULL),('85012634617834','Mari\'ailes','Commerce et services','8 Rue des Dports, 23200 Aubusson',NULL,'055566094',NULL,NULL,NULL,NULL),('85024396314016','Ac\'tif coiffure','Coiffure','2 Rue Nationale, 23200 Aubusson',NULL,'055566088',NULL,NULL,NULL,NULL),('85130853093779','EHPAD Les Bouquets en Creuse','Sant et mdico-social','1 Rue Principale, 23000 Creuse',NULL,'055500064',NULL,NULL,NULL,NULL),('86276362755029','Briconautes Aubusson','Bricolage et matriaux','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566141',NULL,NULL,NULL,NULL),('86359462142651','Geaix Frres','Commerce et services','1 Rue Principale, 23000 Creuse',NULL,'055500052',NULL,NULL,NULL,NULL),('87297225385738','Lyce Jean Favard','Administration publique','18 Rue du Snateur Cornu, 23000 Guret',NULL,'055541046',NULL,NULL,NULL,NULL),('87326223550575','La Maison Du Plateau','Commerce et services','10 Grand Rue, 23500 Felletin',NULL,'055539034',NULL,NULL,NULL,NULL),('87352372526639','GUYAJEUX AUBUSSON','Commerce et services','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566391',NULL,NULL,NULL,NULL),('87535806823847','FASCIAUX PROPRETE','Commerce et services','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566111',NULL,NULL,NULL,NULL),('87904348089101','Pressing - Michard Bezon Nathalie','Pressing et blanchisserie','8 Rue des Dports, 23200 Aubusson',NULL,'055566444',NULL,NULL,NULL,NULL),('87917946634374','MauveBoutique','Commerce vtements et mode','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566111',NULL,NULL,NULL,NULL),('88330634974252','Dominique Vergne','Commerce et services','3 Route Nationale, 23260 Crocq',NULL,'055500014',NULL,NULL,NULL,NULL),('88386262886522','Carrefour Aubusson','Grande distribution alimentaire','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566355','https://www.carrefour.fr',NULL,NULL,NULL),('88386586068062','Pizza Lino','Restauration','4 Alle des Tapis, 23200 Aubusson',NULL,'055566319',NULL,NULL,NULL,NULL),('89218364695304','Pile Poil Catherine','Commerce et services','21 Rue du Docteur Fenouil, 23200 Aubusson',NULL,'055566212',NULL,NULL,NULL,NULL),('89227609976500','La Boutique des artisans d\'aubusson','Commerce vtements et mode','4 Alle des Tapis, 23200 Aubusson',NULL,'055566129',NULL,NULL,NULL,NULL),('89499687055369','La Cave d\'Aubusson','Commerce et services','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566391',NULL,NULL,NULL,NULL),('89659616192888','SOS Admin','Commerce et services','1 Rue Principale, 23150 Moutier-d\'Ahun',NULL,'055500079',NULL,NULL,NULL,NULL),('89795485729744','Pharmacie Moreau','Pharmacie','2 Rue Nationale, 23200 Aubusson',NULL,'055566088',NULL,NULL,NULL,NULL),('90496058423112','L\'atelier de la Charpente Plante','Btiment et travaux publics','5 Place Quinault, 23500 Felletin',NULL,'055539180',NULL,NULL,NULL,NULL),('90830437561983','OCEATHYS','Commerce et services','9 Rue du Commerce, 23200 Aubusson',NULL,'055566046',NULL,NULL,NULL,NULL),('91173192898558','Boucherie Rimareix','Boucherie charcuterie','3 Place du Gnral de Gaulle, 23200 Aubusson',NULL,'055566527',NULL,NULL,NULL,NULL),('91425405727365','LE BISTROT DE COCO','Restauration','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566171',NULL,NULL,NULL,NULL),('91526392012741','Le Havane','Commerce et services','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566551',NULL,NULL,NULL,NULL),('91814908632797','Fonderies Fraisse','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566373',NULL,NULL,NULL,NULL),('91847009398547','CBC communication','Informatique et numrique','5 Rue du Bourg, 23000 Creuse',NULL,'055500045',NULL,NULL,NULL,NULL),('91925804999049','Boulangerie Patisserie PRUGNARD','Boulangerie ptisserie','3 Route Nationale, 23260 Crocq',NULL,'055500020',NULL,NULL,NULL,NULL),('91936168837247','Chez Max','Commerce et services','8 Rue des Dports, 23200 Aubusson',NULL,'055566414',NULL,NULL,NULL,NULL),('92183436138435','Librairie La Licorne','Librairie presse','15 Avenue des Lissiers, 23200 Aubusson',NULL,'055566331',NULL,NULL,NULL,NULL),('92272662251880','Extra - Thoraval','Commerce et services','3 Route Nationale, 23000 Sainte-Feyre',NULL,'055500083',NULL,NULL,NULL,NULL),('92408154691133','Les Dlices D\'Alice','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566593',NULL,NULL,NULL,NULL),('92536888881613','Group Digital','Informatique et numrique','8 Rue des Dports, 23200 Aubusson',NULL,'055566284',NULL,NULL,NULL,NULL),('93058291171039','Bruno Barlaud','Restauration','3 Rue Porte de Banize, 23500 Felletin',NULL,'055539227',NULL,NULL,NULL,NULL),('93228808974572','Le Libre Regard','Commerce et services','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566165',NULL,NULL,NULL,NULL),('93290505143304','Bouillot Btiment Travaux Publics','Commerce et services','3 Route Nationale, 23000 Creuse',NULL,'055500086',NULL,NULL,NULL,NULL),('93369487520073','Expert-comptable SECAL Socit d\'Expertise Comptab','Services juridiques et comptables','5 Place de la Rpublique, 87000 Limoges',NULL,'055578053',NULL,NULL,NULL,NULL),('93427827217844','Boulangerie Ptisserie \"Les Dlices d\'Alice SARL\"','Boulangerie ptisserie','7 Rue Jean Jaurs, 23500 Felletin',NULL,'055539296',NULL,NULL,NULL,NULL),('93536497306746','Battut Construction','Btiment et travaux publics','3 Route Nationale, 23260 Crocq',NULL,'055500065',NULL,NULL,NULL,NULL),('93706702964216','Boulangerie Alleyrat Jean-Pierre','Boulangerie ptisserie','5 Rue du Bourg, 23000 Creuse',NULL,'055500075',NULL,NULL,NULL,NULL),('93734507605931','Manpower Gueret','Travail temporaire','18 Rue du Snateur Cornu, 23000 Guret',NULL,'055541062','https://www.manpower.fr',NULL,NULL,NULL),('94081586142389','ComarK','Commerce et services','7 Rue Jean Jaurs, 23500 Felletin',NULL,'055539076',NULL,NULL,NULL,NULL),('94342143536633','Cordonnerie Mondino','Commerce et services','2 Rue Nationale, 23200 Aubusson',NULL,'055566028',NULL,NULL,NULL,NULL),('94525227705413','muse dpartemental de la tapisserie d\'Aubusson','Artisanat d\'art - Tapisserie','9 Rue du Commerce, 23200 Aubusson',NULL,'055566456',NULL,NULL,NULL,NULL),('95061606381566','Codechamp SA','Commerce et services','3 Route Nationale, 23000 Creuse',NULL,'055500080',NULL,NULL,NULL,NULL),('95119195896362','Entreprise Magne Jean-Pierre','Commerce et services','1 Rue Principale, 23000 Creuse',NULL,'055500031',NULL,NULL,NULL,NULL),('95361944792188','T.T.P.M Transports et Travaux Publics Marchois','Transport','9 Rue du Commerce, 23200 Aubusson',NULL,'055566046',NULL,NULL,NULL,NULL),('95942003174802','Crdit Agricole Centre France - Felletin','Banque et services financiers','14 Avenue des Dports, 23500 Felletin',NULL,'055539183','https://www.credit-agricole.fr',NULL,NULL,NULL),('96018217274029','Assainissement Graveron Pre et Fils','Commerce et services','9 Rue du Commerce, 23200 Aubusson',NULL,'055566426',NULL,NULL,NULL,NULL),('96650476192971','Mignaton Sarl','Commerce et services','5 Place Quinault, 23500 Felletin',NULL,'055539055',NULL,NULL,NULL,NULL),('97580726896311','Les Opticiens','Optique','8 Rue des Dports, 23200 Aubusson',NULL,'055566224',NULL,NULL,NULL,NULL),('97602622827674','Floranice','Commerce et services','18 Avenue de la Rpublique, 23200 Aubusson',NULL,'055566563',NULL,NULL,NULL,NULL),('97637145277952','Chausson Matriaux','Bricolage et matriaux','8 Rue des Dports, 23200 Aubusson',NULL,'055566224',NULL,NULL,NULL,NULL),('97638012251374','Limoges Fine Arts Museum','Commerce et services','8 Rue Jean Jaurs, 87000 Limoges',NULL,'055579042',NULL,NULL,NULL,NULL),('98224372912964','Vallette D\'Osia Marc','Commerce et services','7 Place de l\'Htel de Ville, 23200 Aubusson',NULL,'055566325',NULL,NULL,NULL,NULL),('99153854727336','art broc galerie','Culture et patrimoine','1 Rue Principale, 23000 Creuse',NULL,'055500019',NULL,NULL,NULL,NULL),('99454890205465','Maison de Retraite Pierre Ferrand','Sant et mdico-social','3 Route Nationale, 23000 Creuse',NULL,'055500098',NULL,NULL,NULL,NULL),('99562873732887','Espace Fayolles Salle Multi-sport Mur descalade','Sport et loisirs','12 Rue Eugne France, 23000 Guret',NULL,'055552082',NULL,NULL,NULL,NULL),('99626156997795','EHPAD groupe afp  Las Mlaes','Sant et mdico-social','3 Route Nationale, 23400 Bourganeuf',NULL,'055500050',NULL,NULL,NULL,NULL);
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
  PRIMARY KEY (`Id_PFMP`),
  KEY `Id_Utilisateur` (`Id_Utilisateur`),
  KEY `Id_Planning` (`Id_Planning`),
  KEY `SIRET` (`SIRET`),
  KEY `Id_Utilisateur_1` (`Id_Utilisateur_1`),
  CONSTRAINT `PFMP_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Administrateur` (`Id_Utilisateur`),
  CONSTRAINT `PFMP_ibfk_2` FOREIGN KEY (`Id_Planning`) REFERENCES `Planning` (`Id_Planning`),
  CONSTRAINT `PFMP_ibfk_3` FOREIGN KEY (`SIRET`) REFERENCES `Organisation` (`SIRET`),
  CONSTRAINT `PFMP_ibfk_4` FOREIGN KEY (`Id_Utilisateur_1`) REFERENCES `Etudiant` (`Id_Utilisateur_1`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PFMP`
--

LOCK TABLES `PFMP` WRITE;
/*!40000 ALTER TABLE `PFMP` DISABLE KEYS */;
INSERT INTO `PFMP` VALUES (1,'2026-06-20','2026-07-19',7,3,'123',3),(2,'2026-06-20','2026-07-19',7,4,'123',4),(3,'2026-06-20','2026-07-19',7,5,'123',5),(4,'2026-06-20','2026-07-19',7,6,'123',9),(5,'2026-08-20','2026-09-19',7,7,'1234',9),(6,'2026-10-20','2026-11-19',7,8,'12345',9),(7,'2026-10-20','2026-11-19',7,9,'12345',5),(8,'2026-10-20','2026-11-19',7,10,'12345',3),(9,'2026-06-30','2026-07-29',7,11,'12345',16),(10,'2026-06-30','2026-07-29',7,12,'12345',17);
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
INSERT INTO `Planning` VALUES (3,1230),(4,1230),(5,1230),(6,1230),(7,1230),(8,1230),(9,1230),(10,1230),(11,1230),(12,1230);
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
  `TotalHeures` int DEFAULT NULL,
  `Id_Planning` int NOT NULL,
  PRIMARY KEY (`Id_planningJour`),
  KEY `Id_Planning` (`Id_Planning`),
  CONSTRAINT `PlanningJours_ibfk_1` FOREIGN KEY (`Id_Planning`) REFERENCES `Planning` (`Id_Planning`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PlanningJours`
--

LOCK TABLES `PlanningJours` WRITE;
/*!40000 ALTER TABLE `PlanningJours` DISABLE KEYS */;
INSERT INTO `PlanningJours` VALUES (1,'Lundi','08:30:00','12:00:00','13:00:00','16:30:00',420,3),(2,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,3),(3,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,3),(4,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,3),(5,'Lundi','08:30:00','12:00:00','13:00:00','16:30:00',420,4),(6,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,4),(7,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,4),(8,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,4),(9,'Lundi','08:30:00','12:00:00','13:00:00','16:30:00',420,5),(10,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,5),(11,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,5),(12,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,5),(13,'Lundi','08:30:00','12:00:00','13:00:00','16:30:00',420,6),(14,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,6),(15,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,6),(16,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,6),(17,'Lundi','08:30:00','12:00:00','13:00:00','16:30:00',420,7),(18,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,7),(19,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,7),(20,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,7),(21,'Lundi','08:30:00','12:00:00','13:00:00','16:30:00',420,8),(22,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,8),(23,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,8),(24,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,8),(25,'Lundi','08:30:00','12:00:00','13:00:00','16:30:00',420,9),(26,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,9),(27,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,9),(28,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,9),(29,'Lundi','08:30:00','12:00:00','13:00:00','16:30:00',420,10),(30,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,10),(31,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,10),(32,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,10),(33,'Lundi','08:30:00','12:00:00','13:00:00','16:30:00',420,11),(34,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,11),(35,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,11),(36,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,11),(37,'Mardi','08:30:00','12:00:00','13:00:00','16:30:00',420,12),(38,'Mercredi','09:00:00','12:00:00',NULL,NULL,180,12),(39,'Jeudi',NULL,NULL,'14:00:00','18:00:00',240,12),(40,'Vendredi','09:00:00','12:00:00','13:30:00','17:00:00',390,12);
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
INSERT INTO `Professionnel` VALUES (14,'Technicien informatique',NULL,NULL,NULL,'0600000000','jean.dupont@example.com');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RapportJournalier`
--

LOCK TABLES `RapportJournalier` WRITE;
/*!40000 ALTER TABLE `RapportJournalier` DISABLE KEYS */;
INSERT INTO `RapportJournalier` VALUES (1,'2026-06-21','yo habibi',1),(2,'2026-06-23','Today i have done something big',2),(3,'2026-06-25','today i did coding and worked a lot',3),(4,'2026-06-26','Something big again',2),(5,'2026-06-29','uyt,kuy,ruy,yu,',2),(6,'2026-07-03','dsfdsfdsf',2);
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
INSERT INTO `Referent` VALUES (1,'9080323','Monkey.DLuffy@gmail.com'),(2,'90803232','roronoa.zoro@gmail.com');
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
  `TokenHash` varchar(256) NOT NULL,
  `CreatedAt` datetime DEFAULT NULL,
  `ExpiresAt` datetime DEFAULT NULL,
  `RevokedAt` datetime DEFAULT NULL,
  `ReplacedByTokenHash` varchar(256) DEFAULT NULL,
  `Id_Utilisateur` int NOT NULL,
  `TokenFamilyId` varchar(36) NOT NULL DEFAULT '',
  `FingerprintHash` varchar(256) NOT NULL DEFAULT '',
  PRIMARY KEY (`Id_RefreshToken`),
  UNIQUE KEY `TokenHash` (`TokenHash`),
  KEY `Id_Utilisateur` (`Id_Utilisateur`),
  CONSTRAINT `RefreshToken_ibfk_1` FOREIGN KEY (`Id_Utilisateur`) REFERENCES `Utilisateur` (`Id_Utilisateur`)
) ENGINE=InnoDB AUTO_INCREMENT=145 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RefreshToken`
--

LOCK TABLES `RefreshToken` WRITE;
/*!40000 ALTER TABLE `RefreshToken` DISABLE KEYS */;
INSERT INTO `RefreshToken` VALUES (1,'M8DawjQ/LwoCw24KjrWggf+h13pez9VU6YFT95DKjR8=','2026-06-24 13:00:19','2026-07-01 13:00:19','2026-07-01 14:36:39',NULL,3,'',''),(2,'/S46Wg8EOpFhQfVfWH3P7yZQeNvsbEFt2RHkAcbr2AY=','2026-06-24 13:08:19','2026-07-01 13:08:19','2026-07-01 14:36:39',NULL,3,'',''),(3,'XsLkO8D7VQ15AeJZWLp+udGdhtINt7jsfOSxqJEakm4=','2026-06-24 13:51:58','2026-07-01 13:51:58','2026-07-01 14:36:39',NULL,3,'',''),(4,'Twa1niowZ98iiYkRa1/LP/bWMFmBPJF/nQWvneJHtvY=','2026-06-24 14:34:01','2026-07-01 14:34:01','2026-07-01 14:36:39',NULL,3,'',''),(5,'zMGA1J/rrU7hY8DzqUtcmt+/RaYSu1dl1/3tgUVvZJU=','2026-06-24 14:45:04','2026-07-01 14:45:04','2026-07-01 14:36:39',NULL,3,'',''),(6,'bF4HRtB7QlqBrdPEgMlJHQUJBGgnFYSqCJzci4wxWA8=','2026-06-24 14:53:47','2026-07-01 14:53:47','2026-07-01 14:36:39',NULL,1,'',''),(7,'SKAJpTH91BO1utn5FHyjAt484vpN3Sda5z1hOTzfYsU=','2026-06-24 14:54:07','2026-07-01 14:54:07','2026-07-01 14:36:39',NULL,3,'',''),(8,'n7rA28wS5IeF1duYD64dB1qANTdrQMeJUynLbLsbYlY=','2026-06-25 07:56:36','2026-07-02 07:56:36','2026-07-01 14:36:39',NULL,3,'',''),(9,'fCnx5uqVIF6Nh/i2om1WFYuWLhPap0nDMRBWncEwPcQ=','2026-06-25 07:56:43','2026-07-02 07:56:43','2026-07-01 14:36:39',NULL,3,'',''),(10,'EfT4ZWO7MpQmNjzYkxaB/nfNjVOKQJyk8Zunr+wcS3U=','2026-06-25 08:01:42','2026-07-02 08:01:42','2026-07-01 14:36:39',NULL,3,'',''),(11,'8aMCrTJ5YJydY6Pkmu9RSqrYyVU1U5UnrV+pU6xd7kA=','2026-06-25 08:15:37','2026-07-02 08:15:37','2026-07-01 14:36:39',NULL,4,'',''),(12,'67+Rv5J3lKFg+QA2OgmVSnVpiMSm4zO0IQMWZkaApqs=','2026-06-25 08:17:55','2026-07-02 08:17:55','2026-07-01 14:36:39',NULL,7,'',''),(13,'WYdkKVTu6KWg9F5tbfcmzS879mfgb3QspFcZUe1ZXGI=','2026-06-25 08:19:42','2026-07-02 08:19:42','2026-07-01 14:36:39',NULL,7,'',''),(14,'DkRA9/Ym3zBp/lVJqQAUpPiA7OZXp7HhQI6Otc327Zk=','2026-06-25 08:23:06','2026-07-02 08:23:06','2026-07-01 14:36:39',NULL,3,'',''),(15,'wnx6oRLKDPnw0e9XoQ510ZT4ba0MCErYmrRc3CgxEro=','2026-06-25 09:06:19','2026-07-02 09:06:19','2026-07-01 14:36:39',NULL,7,'',''),(16,'Dq7rkKAw2yMAMW8eZxFQto5uRWdDQSCdu7f7ZOWouHs=','2026-06-25 09:11:38','2026-07-02 09:11:38','2026-07-01 14:36:39',NULL,3,'',''),(17,'iplgRjrB43QXUalNTM0KVYfHQ33Ngkv9qdDyEIAn1oI=','2026-06-25 09:59:03','2026-07-02 09:59:03','2026-07-01 14:36:39',NULL,7,'',''),(18,'E5yYScGFZDXhijY56orjHVlPku0lPeyq06fc9kJ5KeE=','2026-06-25 10:07:22','2026-07-02 10:07:22','2026-07-01 14:36:39',NULL,7,'',''),(19,'PaQOdxfhL6zl1q3fSlZvhQQN7RmV8ypbrrpCk9XmTyU=','2026-06-25 10:09:15','2026-07-02 10:09:15','2026-07-01 14:36:39',NULL,3,'',''),(20,'cbwLGLWeOL1c3KkHJ6icq+cJSR+KXjBhq7boqdfF5Xg=','2026-06-25 10:12:50','2026-07-02 10:12:50','2026-07-01 14:36:39',NULL,5,'',''),(21,'iHcokCk60g9S/dQH67r9dNIqWe3ZZkdlfDn4GJsa5iA=','2026-06-25 10:15:28','2026-07-02 10:15:28','2026-07-01 14:36:39',NULL,3,'',''),(22,'Gpf40ijxRqGc1v/hWqVcyJDG+8VCcH5qp1JSuc3CBz4=','2026-06-25 10:16:30','2026-07-02 10:16:30','2026-07-01 14:36:39',NULL,7,'',''),(23,'SVMXPFf6qdko40fOIbqxDlfGgwe3LTX63yVjQvvMgqQ=','2026-06-25 10:19:04','2026-07-02 10:19:04','2026-07-01 14:36:39',NULL,5,'',''),(24,'mZapMC+/8siC4VSx2x88K9y9rzMqVFnv36pvmOOE/QU=','2026-06-25 12:32:12','2026-07-02 12:32:12','2026-07-01 14:36:39',NULL,3,'',''),(25,'69qXzgzs1oBGYWefv8Mzw4VSti8V+YH7IBZnvrD0UU8=','2026-06-25 12:34:15','2026-07-02 12:34:15','2026-07-01 14:36:39',NULL,4,'',''),(26,'fj5IVO0y+bsmi7KiHsbIej5Y6oih/7N48FdC/m41DW4=','2026-06-25 12:40:53','2026-07-02 12:40:53','2026-07-01 14:36:39',NULL,4,'',''),(27,'R1X9erkqTMk/J/hqCr7mbtpjjnGzow4oXzFyEouYUzk=','2026-06-25 13:01:52','2026-07-02 13:01:52','2026-07-01 14:36:39',NULL,4,'',''),(28,'TmmFpQGR15CLMVdU0ebt8HBni4W97AHO+sUcCWixog8=','2026-06-25 14:09:49','2026-07-02 14:09:49','2026-07-01 14:36:39',NULL,4,'',''),(29,'oD1s7Dp0mxfomnYVaNSVtPm5vzrjjIyOPyohr4gUY6U=','2026-06-25 14:31:56','2026-07-02 14:31:56','2026-07-01 14:36:39',NULL,4,'',''),(30,'Y5TNzjNA81MJEb+CyLwdSzCObpJjx6izWyMVMzUGxy0=','2026-06-26 06:48:13','2026-07-03 06:48:13','2026-07-01 14:36:39',NULL,4,'',''),(31,'OUxBZxUqnX9WSsIgb11sHECj7+JlN71RJQVbpY5kRNQ=','2026-06-26 07:08:59','2026-07-03 07:08:59','2026-07-01 14:36:39',NULL,4,'',''),(32,'qOG9/c7pDYxnz333PO5NhM2O+6Q4AyEM5h/8bYPQpaQ=','2026-06-26 07:26:04','2026-07-03 07:26:04','2026-07-01 14:36:39',NULL,4,'',''),(33,'PianbxRevRlgiRIecwuJidnVOk7xbGmefCOl2yv42Xw=','2026-06-26 07:33:27','2026-07-03 07:33:27','2026-07-01 14:36:39',NULL,4,'',''),(34,'TVrOjdVYvi7SWq/4BI6V5/dk71THLuKz6w0IJPVmJc8=','2026-06-26 08:08:04','2026-07-03 08:08:04','2026-07-01 14:36:39',NULL,9,'',''),(35,'/6DdCb/L+rcfnBbS7ibVdpVB/Ds4hwrQyQ1La/d9hjk=','2026-06-26 08:22:55','2026-07-03 08:22:55','2026-07-01 14:36:39',NULL,9,'',''),(36,'UyLS9X5ciVW7w0YRRiZLnjDMDr1X5qL1jtLo2XFOieA=','2026-06-26 08:43:40','2026-07-03 08:43:40','2026-07-01 14:36:39',NULL,9,'',''),(37,'rdliiYcGEZ5Lfg7ThSsLwdn9lQB3nlyEt36aRjLi25k=','2026-06-26 08:43:40','2026-07-03 08:43:40','2026-07-01 14:36:39',NULL,4,'',''),(38,'kNy4QIPHdCASSYh/jeeljCyQdPhKPGgsaQ1+7MBbglQ=','2026-06-26 09:08:04','2026-07-03 09:08:04','2026-07-01 14:36:39',NULL,4,'',''),(39,'eATKYHHuCByFT0VuOxtGoi6vrSJzHxhEQwKGkLlpSUA=','2026-06-26 09:31:44','2026-07-03 09:31:44','2026-07-01 14:36:39',NULL,4,'',''),(40,'1z5lxKdkDEz24lQzALAgsTZPmwi4Hl8i/k4EIGcRnys=','2026-06-26 09:33:29','2026-07-03 09:33:29','2026-07-01 14:36:39',NULL,4,'',''),(41,'LfSn+pEsfrS3UcpIknxR//XPPF6FN1bNYYqWnKrcTXk=','2026-06-26 10:12:03','2026-07-03 10:12:03','2026-07-01 14:36:39',NULL,9,'',''),(42,'dsz+1qAAn2nBk8eQCKBhdgTCphpYoJ+wh0tIhkGYG0Q=','2026-06-26 12:12:10','2026-07-03 12:12:10','2026-07-01 14:36:39',NULL,9,'',''),(43,'D3wfQfdZRmfFEDUd+Tj9e1tW7CUMisnzEmjQvIK32Z4=','2026-06-26 12:27:36','2026-07-03 12:27:36','2026-07-01 14:36:39',NULL,9,'',''),(44,'gwc3fzATPr/9zJAOKTTVPxOTCVsysaMfhkjB9SvgIXg=','2026-06-26 12:36:31','2026-07-03 12:36:31','2026-07-01 14:36:39',NULL,4,'',''),(45,'ulZ9NKQ9KV6AlYBbbQ/itBCSR5JQT/6v6w9epwumcgc=','2026-06-26 12:50:37','2026-07-03 12:50:37','2026-07-01 14:36:39',NULL,4,'',''),(46,'LjmetDQQT17YbGO7HYirZ/mFXQE4psk9YcMj9yiC+XY=','2026-06-26 12:55:57','2026-07-03 12:55:57','2026-07-01 14:36:39',NULL,4,'',''),(47,'78jYcTn6KSKZ7Wu4ome4XGJbsel6IrI3ZJfQrtY/kic=','2026-06-26 12:57:07','2026-07-03 12:57:07','2026-07-01 14:36:39',NULL,5,'',''),(48,'SCU2m5PGbvhe0AKYT6eUd111BGhtrzB5SAKr+uHdkC0=','2026-06-26 13:15:10','2026-07-03 13:15:10','2026-07-01 14:36:39',NULL,4,'',''),(49,'xBDiEJ1PdaQImU2C8HNt70EJAtO3U4a6IA3slM2Zdko=','2026-06-26 13:40:24','2026-07-03 13:40:24','2026-07-01 14:36:39',NULL,4,'',''),(50,'UxKjNYghe4ZN6xeu5yNhH/joLbdjfnGmlZ0IVWm5WYE=','2026-06-26 13:54:17','2026-07-03 13:54:17','2026-07-01 14:36:39',NULL,4,'',''),(51,'V45X8ozo+rQNKDU1e69LlABhA9qsBrzAz4ANWtLcMcY=','2026-06-26 14:16:22','2026-07-03 14:16:22','2026-07-01 14:36:39',NULL,3,'',''),(52,'D+rtQU3Eie58K9ENyXKgo4xwvJODG6XjIHymumlYB20=','2026-06-26 14:50:59','2026-07-03 14:50:59','2026-07-01 14:36:39',NULL,4,'',''),(53,'NNnxD9hjIIBbRNDewbpQy2AdBQZDNgMEw5YM8aE/fhE=','2026-06-29 06:46:58','2026-07-06 06:46:58','2026-07-01 14:36:39',NULL,4,'',''),(54,'L/HzSb/Qb+ICJ/w4GsS0ZnD16VdNh7HvXcFBWTsXBmI=','2026-06-29 07:12:48','2026-07-06 07:12:48','2026-07-01 14:36:39',NULL,4,'',''),(55,'WGi+vnXHpg3W1GLNOv+KynHrTGlGwYyTmZG2ZW86Uuc=','2026-06-29 07:47:34','2026-07-06 07:47:34','2026-07-01 14:36:39',NULL,7,'',''),(56,'0QWbfs6MIO49wWHg6WLxG6a2WGUlxjFiiwImaIFOOt0=','2026-06-29 07:51:53','2026-07-06 07:51:53','2026-07-01 14:36:39',NULL,7,'',''),(57,'vhof/MV3lj07sSloBQGGnTw/KwoT8UQtCeT77fQm1Vc=','2026-06-29 08:30:22','2026-07-06 08:30:22','2026-07-01 14:36:39',NULL,7,'',''),(58,'h7JMrT8bMBZhWGr2YPWDtkXXJOXWavzPRHy79/qMzAM=','2026-06-29 08:35:15','2026-07-06 08:35:15','2026-07-01 14:36:39',NULL,7,'',''),(59,'X3uaNwgIeTvHp2/FnQNedu3BlwAvBS1iWwQLNJVlmZw=','2026-06-29 08:40:18','2026-07-06 08:40:18','2026-07-01 14:36:39',NULL,4,'',''),(60,'klOxRynLSpaoXyVGKb8ERkS+K5qp9XgvGoTL5q8ZFLE=','2026-06-29 08:40:39','2026-07-06 08:40:39','2026-07-01 14:36:39',NULL,7,'',''),(61,'1QC3p2ln6SqyXxc3HcLybxUQR70Qt9YrFjd0p8pcPdA=','2026-06-29 08:44:14','2026-07-06 08:44:14','2026-07-01 14:36:39',NULL,7,'',''),(62,'gHfJNFksptFx9mldvBfUhVvxEzo8ZX64/R5TtJUVgeQ=','2026-06-29 08:58:39','2026-07-06 08:58:39','2026-07-01 14:36:39',NULL,7,'',''),(63,'Hhb2gdL2i+yuehIBEixui/UVv0dgO0SRTZSiBlQu66U=','2026-06-29 09:06:46','2026-07-06 09:06:46','2026-07-01 14:36:39',NULL,4,'',''),(64,'WZ3hzLwwJ/yykaWcYLSy94Zy9sTvIBtsMR3h7ueevDg=','2026-06-29 09:35:09','2026-07-06 09:35:09','2026-07-01 14:36:39',NULL,7,'',''),(65,'Sp3uXPnTdrlx/hCyQt2KetZj0VU1Kdp69GT5yIl9xHc=','2026-06-29 09:54:33','2026-07-06 09:54:33','2026-07-01 14:36:39',NULL,7,'',''),(66,'sqGaHpdR3dwc2U3OXS2Fla/uPTjEI0Y/cuEcISp9QE4=','2026-06-29 09:55:36','2026-07-06 09:55:36','2026-07-01 14:36:39',NULL,7,'',''),(67,'yQadN7SfjKQhv3wIZw7cdQILge71tVznxkvY7nJSpWc=','2026-06-29 10:21:57','2026-07-06 10:21:57','2026-07-01 14:36:39',NULL,4,'',''),(68,'16UkrIEA6W0O1rOdGySrSOgINyqGxQ3RDe+EmUL7Vkg=','2026-06-29 11:40:24','2026-07-06 11:40:24','2026-07-01 14:36:39',NULL,4,'',''),(69,'SBx8Nj9yZYtHLvFHTrGxpz/D5tkEfcfZDMBh4qHilec=','2026-06-29 12:13:45','2026-07-06 12:13:45','2026-07-01 14:36:39',NULL,7,'',''),(70,'Qb5N+kqQF0/ZfS+GnH01IPWJVt8MtDDbCcF47FlFjJ4=','2026-06-29 12:21:18','2026-07-06 12:21:18','2026-07-01 14:36:39',NULL,4,'',''),(71,'30dFmzEJQRZ/6o84DM8eX0JotnELky/t2NgkPg3OaBQ=','2026-06-29 13:01:42','2026-07-06 13:01:42','2026-07-01 14:36:39',NULL,4,'',''),(72,'oHtupRFLD1CEEzrw6AUf1+fQcGqJqwyD+/k8JbypBrE=','2026-06-29 13:08:41','2026-07-06 13:08:41','2026-07-01 14:36:39',NULL,4,'',''),(73,'7WLISh7d/eMnROF1bWjmXSnNDPzCk8tXK/vfWWRNCTg=','2026-06-29 13:08:46','2026-07-06 13:08:46','2026-07-01 14:36:39',NULL,4,'',''),(74,'02HbonNQ3trdkNEJMV0IkaUJzd8jsZ+7/CNvPLNKN0w=','2026-06-29 13:08:49','2026-07-06 13:08:49','2026-07-01 14:36:39',NULL,4,'',''),(75,'O/eYViw4PN5P1+uRk2Orfoox6G11pAqjKxckaIep/NI=','2026-06-29 13:09:35','2026-07-06 13:09:35','2026-07-01 14:36:39',NULL,7,'',''),(76,'cs5dWilB5NdVoysZkHsu05z3g3vzjsJY49KHo/4vzRU=','2026-06-29 13:40:49','2026-07-06 13:40:49','2026-07-01 14:36:39','n8XXhHhkMzN4e6IyqFSKETsY08rlR49fRwuClB1Aerg=',4,'',''),(77,'n8XXhHhkMzN4e6IyqFSKETsY08rlR49fRwuClB1Aerg=','2026-06-29 14:17:39','2026-07-06 14:17:39','2026-07-01 14:36:39',NULL,4,'',''),(78,'JhgRH00Vx+fmh4k8IcoKEBTu0UiK+BxZ3mmHJcm5nsE=','2026-06-30 06:55:32','2026-07-07 06:55:32','2026-07-01 14:36:39',NULL,7,'',''),(79,'60wG/1JgtsayPT38x7iM2UZmSeQlfUVoqGc3xcoEVo8=','2026-06-30 07:02:49','2026-07-07 07:02:49','2026-07-01 14:36:39',NULL,7,'',''),(80,'71XAG6k+qi/wbKF507WeXLxVNdPCvStuCxaK7I4LH1o=','2026-06-30 07:55:18','2026-07-07 07:55:18','2026-07-01 14:36:39',NULL,7,'',''),(81,'3yAG3Qv93vx5uv0ijA+EsG6UZKgGKMv4+v6x36jRb5E=','2026-06-30 08:12:23','2026-07-07 08:12:23','2026-07-01 14:36:39',NULL,7,'',''),(82,'CXwMJlEbVO9Y/aM5HJ8EDB71gJmNqydpiM1fiYqqMoU=','2026-06-30 11:19:18','2026-07-07 11:19:18','2026-07-01 14:36:39',NULL,7,'',''),(83,'i9SKKKqoY5v3kxVRNr46vQCLquJSh7JVbDjZfF1cOp0=','2026-06-30 11:27:37','2026-07-07 11:27:37','2026-07-01 14:36:39',NULL,16,'',''),(84,'THI+eGvOLEDDMgBF0Y7THyyX9tgAXu4V+yOaO42KtdA=','2026-06-30 11:31:41','2026-07-07 11:31:41','2026-07-01 14:36:39',NULL,7,'',''),(85,'cRscCMeVWG7KixzhYuFX/4a+azHMlPDYLG+YRhKGut0=','2026-06-30 11:33:19','2026-07-07 11:33:19','2026-07-01 14:36:39',NULL,17,'',''),(86,'9l46Y6YdU41Ksv394/w3Mg9tzsPtDcTiuf6MYM9Ri9U=','2026-06-30 12:47:50','2026-07-07 12:47:50','2026-07-01 14:36:39',NULL,7,'',''),(87,'RTAL7hHX2RsJx3hOrSNZdrDcP2uUBLkw4pykQiohIYk=','2026-06-30 14:11:38','2026-07-07 14:11:38','2026-07-01 14:36:39',NULL,7,'',''),(88,'PjQRRuWEVhhwOh49f9KHBuXbU+q4+i9+Yb9VxWJHhF8=','2026-06-30 14:12:39','2026-07-07 14:12:39','2026-07-01 14:36:39',NULL,1,'',''),(89,'j/gwh6D9uTCK559Jv6XTRFoqnQLbzSyj9uwJlbafy9s=','2026-06-30 14:12:56','2026-07-07 14:12:56','2026-07-01 14:36:39',NULL,7,'',''),(90,'RFiZ0o4ebNKmhL/fCKtfMjfxyuf51/YmwKwv4V/T/2M=','2026-06-30 14:16:41','2026-07-07 14:16:41','2026-07-01 14:36:39',NULL,7,'',''),(91,'Czv1og7RoROvzEHmFGmZrxqWmTt2d+6aMsZpJobSaJg=','2026-07-01 07:07:19','2026-07-08 07:07:19','2026-07-01 14:36:39',NULL,7,'',''),(92,'cgkb7MSTOHfCBHKrJBYdTItP8evnTfGtKtzAUUneq8c=','2026-07-01 07:22:30','2026-07-08 07:22:30','2026-07-01 14:36:39',NULL,7,'',''),(93,'VY2a47KW2V2e/sjThhboN0CgpWh1JCr+Wj9ps1rFIWc=','2026-07-01 08:01:01','2026-07-08 08:01:01','2026-07-01 14:36:39',NULL,7,'',''),(94,'JV/u7QXxnT2NTzeBkn0ruxZycVj/JNafbRnL1ayrO68=','2026-07-01 08:08:18','2026-07-08 08:08:18','2026-07-01 14:36:39',NULL,7,'',''),(95,'aS2qHZZDA6WbE/wOsLKMlLikIjmFiSaHX6zZY1+nSs8=','2026-07-01 08:09:42','2026-07-08 08:09:42','2026-07-01 14:36:39',NULL,7,'',''),(96,'U7p2nXgwfmmmBTqaExHoTrnbG46h36x+GdZPSPxP2lk=','2026-07-01 08:12:04','2026-07-08 08:12:04','2026-07-01 14:36:39',NULL,7,'',''),(97,'lPOA2t75D+McnnWmQXelIMsQg1TcObIHlNDqnclO7sY=','2026-07-01 09:50:32','2026-07-08 09:50:32','2026-07-01 14:36:39','QC0MvJvixDyJXiRWtonbAM24hRcf42BGhSLsL8XaUT4=',7,'ce1e00d2-4dfd-41af-a758-88e5ed0236f9',''),(98,'QC0MvJvixDyJXiRWtonbAM24hRcf42BGhSLsL8XaUT4=','2026-07-01 09:52:13','2026-07-08 09:52:13','2026-07-01 14:36:39',NULL,7,'ce1e00d2-4dfd-41af-a758-88e5ed0236f9',''),(99,'rbqt9Xlx2SW15pMXGuOqviku4rW+TiuTndnDOrKbLfc=','2026-07-01 09:54:19','2026-07-08 09:54:19','2026-07-01 14:36:39','ePUHxn+bIocaTMKi+K2fYa16U71moHhk1KqYetRJpVo=',7,'33137b22-1732-4332-ba67-b5298cf3702f',''),(100,'ePUHxn+bIocaTMKi+K2fYa16U71moHhk1KqYetRJpVo=','2026-07-01 09:54:38','2026-07-08 09:54:38','2026-07-01 14:36:39',NULL,7,'33137b22-1732-4332-ba67-b5298cf3702f',''),(101,'8vYi6+cb/Kpeeg98WKKVEWDs3S8xFLZXev7Z+1VlQ9Q=','2026-07-01 12:30:07','2026-07-08 12:30:07','2026-07-01 14:36:39',NULL,7,'d6b1d87c-a0fd-45e2-a4ba-a1885fa6298a',''),(102,'GNgU2M0ur/WMY+kgrEUw25FjiRBjiJ3qkf2CrR+QOYc=','2026-07-01 12:41:59','2026-07-08 12:41:59','2026-07-01 14:36:39',NULL,7,'8820d24c-63e2-4e31-91ea-d380832f9b3f',''),(103,'guRoRAQDRoEAtE5YM5ZoRLFtGUfuppWKI6ZvycxmnOY=','2026-07-01 12:57:26','2026-07-08 12:57:26','2026-07-01 14:36:39',NULL,7,'f16ef44f-ff48-4949-929f-84bb975d647f',''),(104,'7WfIJgLojToOVIu/woOf9WGdiOgL8kPV0hBDgIJDRWg=','2026-07-01 12:58:05','2026-07-08 12:58:05','2026-07-01 14:36:39',NULL,7,'ea1b7c93-d3dd-4f3a-aadb-27fd047af3ec',''),(105,'DdZdWFhumSbFG8cFClGDBLsl8El1wptjWxsm6wnEqMs=','2026-07-01 13:01:26','2026-07-08 13:01:26','2026-07-01 14:36:39',NULL,7,'fe3b8519-0d23-427e-9e96-56ac298d11a4',''),(106,'7lj6iB49Ifb5hTdn5hYcCuwXnez3JLedHhWYx6OyHh8=','2026-07-01 13:01:39','2026-07-08 13:01:39','2026-07-01 14:36:39',NULL,7,'3cfe0df3-6598-402f-9116-14d3489a845e',''),(107,'wXh8OyIWD33PSF9fnKnIg9jFhW2fK/D17fVHkyTBLpE=','2026-07-01 13:03:52','2026-07-08 13:03:52','2026-07-01 14:36:39',NULL,7,'0d203368-8f0b-4369-b3d9-976690b633b0',''),(108,'Fl1MQ6lxOUnkmdi87osqIU2/JwMlSyTOjEETrNrRZno=','2026-07-01 13:08:19','2026-07-08 13:08:19','2026-07-01 14:36:39',NULL,17,'10fb0c66-8d5f-47a3-932f-1322095f412a',''),(109,'LsWUeONS9qC6trdw8ui0/EGq3McT+PMYKmUDB8PHRqk=','2026-07-01 13:23:44','2026-07-08 13:23:44','2026-07-01 14:36:39',NULL,7,'66e90815-82d1-47b6-aa18-828c80ed6a75',''),(110,'ZtnWhBqc2Rmji3p6v0RPS/A2tvXHShs8Eqav1uGeNTo=','2026-07-01 14:09:20','2026-07-08 14:09:20','2026-07-01 14:36:39',NULL,7,'0e6b02b1-0082-4255-8f54-aed737e55500',''),(111,'kHy7E1W+KHAypOErOZbGilF3OgPjxEE2djWZDt61g2Q=','2026-07-01 14:10:05','2026-07-08 14:10:05','2026-07-01 14:36:39','Omb7xwiLatvuxoecxuS3vM0293WsYIT244stpTmbj9k=',7,'66ca2096-d54b-4ce0-aa61-32e907b812c3',''),(112,'NnGeY1zGQlhIXOBSR1WmTLA/ZL5hxolDgcSOUWJo10E=','2026-07-01 14:18:28','2026-07-08 14:18:28','2026-07-01 14:36:39',NULL,4,'',''),(113,'Omb7xwiLatvuxoecxuS3vM0293WsYIT244stpTmbj9k=','2026-07-01 14:22:05','2026-07-08 14:22:05','2026-07-01 14:36:39',NULL,7,'',''),(114,'I1UTbuc6E0U85OA2pY1quc35ITCCJpmALGjXCsF3+HE=','2026-07-01 14:23:34','2026-07-08 14:23:34','2026-07-01 14:36:39',NULL,4,'',''),(115,'LmVJNmfaXmL3BraPmkwmOnJxtzI4BGwxDSAxyg66MPc=','2026-07-01 14:37:27','2026-07-08 14:37:27',NULL,NULL,7,'2f396b49-ee05-436c-869c-a5367c4d78d5','vZytP672CQCXujVZon+/+Ljd07tZ2D+xRdklmVgZI7c='),(116,'5XVneq3n0p+pHZyyKqjCQ87RmoEMsp6+86+VhZTsukQ=','2026-07-01 14:54:40','2026-07-08 14:54:40','2026-07-01 14:55:14','9IoDOwZZjS2yr+NIyBUrLfrpaKQJh8sqzBqrlys2GO0=',7,'b6789ccd-d1da-41d2-9a70-677b160054ad','jOccoPWIi9XnyhD3h/5KHxT2SX5BxeOb6AHPiKLHkH8='),(117,'9IoDOwZZjS2yr+NIyBUrLfrpaKQJh8sqzBqrlys2GO0=','2026-07-01 14:55:14','2026-07-08 14:55:14','2026-07-01 14:55:59',NULL,7,'b6789ccd-d1da-41d2-9a70-677b160054ad','jOccoPWIi9XnyhD3h/5KHxT2SX5BxeOb6AHPiKLHkH8='),(118,'JTXMezTYLYXvEGZfKHhciKHxwFsni2sjtijmmM9LSsA=','2026-07-02 06:47:50','2026-07-09 06:47:50',NULL,NULL,4,'',''),(119,'ABMZ8uJKcBbLxNf/rGeP5MawPMrNdYuR+BFESG/oBio=','2026-07-02 06:48:09','2026-07-09 06:48:09',NULL,NULL,4,'',''),(120,'gX0w5S4evXaS2dC4UH+cNHkGvyxTJwL2blENiyXNp6o=','2026-07-02 08:34:40','2026-07-09 08:34:40',NULL,NULL,4,'',''),(121,'Ywc9iOMI2n2wutIYTRl/c4jpdg2gKL4mhUyc4r44a+0=','2026-07-02 08:35:11','2026-07-09 08:35:11',NULL,NULL,4,'',''),(122,'DwxsD2ZzprV4PLqp8JhXxB24bXyBuae4i6qgzAQT05w=','2026-07-02 12:38:11','2026-07-09 12:38:11',NULL,NULL,4,'13eda4f2-0bdc-4abc-a8e7-ec5f558dd806','0zRiBy7ogVGgPbW6ESUPF/2Mk1Y1RBrHqkc9bWTa/ug='),(123,'NARmS43iGJMuESQbU7RkhN20XN2eK16oPBa+uevsvQA=','2026-07-02 12:39:15','2026-07-09 12:39:15',NULL,NULL,7,'216d00bd-d7ca-4871-85fa-eef7000daee7','xUkG9FG3dCB4vhIUgAfTxfAkkkCmska+9uEo6vxfpYU='),(124,'7qqbpPqplsRnt9I4dBgfGFF4ciyPFo7cYekIrm1e6H8=','2026-07-02 12:40:21','2026-07-09 12:40:21',NULL,NULL,7,'f0282820-15f5-4f43-984d-c959b9a680d1','eLhpPGWDfDz0//d+TmiX0CWFCxXuVK1xeU+OHJrCoyM='),(125,'q6pa2HWOux5ZDv1w1lsitQrepa/ZP3Q/jUzBvt0CMm4=','2026-07-02 12:42:06','2026-07-09 12:42:06',NULL,NULL,7,'f341991e-4355-4fcd-98a0-da2801dcbad3','MhAZJwrzwArlrnEFEwqUL7Y9l7fYgkmniPtfSB3cYa4='),(126,'KwvwRwVYKfbOW+1e55bJ6qixsHgkhtQlZZ4eNsaSzZI=','2026-07-02 12:42:41','2026-07-09 12:42:41',NULL,NULL,7,'74e99664-3cd8-4c51-a904-4239e4d1a8fa','ZzIo16aexJ225OlQBY6gmLzw36ZTXhzMP+jpUKy0eMg='),(127,'pkIFPFTLw+aJhOjAuOUT/M8imPKTODQ71nWduecjvhM=','2026-07-02 12:49:15','2026-07-09 12:49:15',NULL,NULL,7,'40808b30-ff5e-461b-9cf4-ca0c8a4ff84f','UfArdSD3UB3iylXd4Zuz2GOILkuDY7+vxv9BY+nGBow='),(128,'wkUWr4r8ND3VSCPxoyuWGJbOlKYuASQiCGpVb8ln/cc=','2026-07-02 12:49:51','2026-07-09 12:49:51',NULL,NULL,4,'6e61e87e-a951-4d1c-bf1e-63bad8c4f33e','4MjeTzkngQHf0EPlaFJMxC44VKj3rRC5bRj5a4ozpy8='),(129,'w+kjXSk/V6UsLBVimkPintxjvks4T3C+TUjQkLAIECU=','2026-07-02 13:23:58','2026-07-09 13:23:58',NULL,NULL,4,'47efedce-419a-4300-88c9-e374de86bc74','CvoEKnkc+qHiPXurMdx0KJZCEemTqzeOv+suSHOTt0I='),(130,'qKvgFdUxMICZdXsDybOTzRYGtbR2LZlhBzP4tioXbtM=','2026-07-02 13:30:33','2026-07-09 13:30:33',NULL,NULL,4,'de02dc32-ea27-4e5e-825f-d51e6838ae16','/VocUPGZoBKfASsJEQd7lqU3cU0N99Z1h3GEqPsX35w='),(131,'r8uJIA5a1HMPkmjA95LkzTCmxfC3KDZz7rKA01pnV5E=','2026-07-02 13:35:04','2026-07-09 13:35:04',NULL,NULL,4,'04357c88-9e43-42f6-bc25-5151181e76d8','yJKhgcQoYlLO4GrWJz2tgHMG+zpNrNK37EXL2ViEhO0='),(132,'vo5NIR0T6eu0Acer+h1bcd5JVRbInkMVobR1eRo9MnU=','2026-07-02 13:38:12','2026-07-09 13:38:12',NULL,NULL,4,'549f642c-e6a3-4960-9dc3-99cb510467c0','HeyaLtfKep7DDqMcsbmEu7ESseShc8DQBvE0t9X3gLk='),(133,'QTZwRx9AZrLYaKXiTcSbvrG7DbzmSjJpClC/vds1UFA=','2026-07-02 13:40:30','2026-07-09 13:40:30',NULL,NULL,4,'8276ad03-02a8-4cd2-b9b9-613eae680418','4LLIj0185ug6DQKhM+Lzmr0tViWiiexKFlWGEN1G2X8='),(134,'9vZOLNW82exwzXogJ6UFUltloyY5OIdMd0/2OWjEaSk=','2026-07-02 13:45:51','2026-07-09 13:45:51',NULL,NULL,4,'ca7313a2-64c2-462a-8d60-52298a75dd8b','MP1HRuSFreoTOvW4MFs2ir7sk2Mq67B/s4tLmBTAxD0='),(135,'X1R7j02Jc3CckhgZG+zp7Hf7fFbDrS+1gVTMQnFP/t4=','2026-07-02 14:29:35','2026-07-09 14:29:35',NULL,NULL,4,'f876ec85-1ce4-4685-8fd9-45c25b377c67','f5zhC5oTPqXZ49Xny+nupfUjUVxyM5daGpYqOoodViU='),(136,'ba7o69LEN95ab+mfscaU2Gd/modK0KfIg7Mdm1VKHOA=','2026-07-02 14:29:35','2026-07-09 14:29:35',NULL,NULL,4,'6226823e-e9e8-435a-95a7-cdf0db491157','vws4sHYPOpC1M+5O7jdvQvaufOk0TrzpPgEDqtTqyiw='),(137,'ci7PsYvq2H88qdTYgp8yXGxGezoc6vF59zTB87xj1LA=','2026-07-02 14:30:26','2026-07-09 14:30:26',NULL,NULL,4,'0128d3aa-7211-44b3-a8e6-f8821fc12ab2','sZ913r1gMiIWBlEqIqlnJyRH4lFL22rBqCJ6/lJFLUY='),(138,'e3SN8c4CRz+StgBRwgskJGybcCOIy3tgHloIOIxJ70g=','2026-07-03 06:39:11','2026-07-10 06:39:11',NULL,NULL,4,'ead5f48b-d3c8-41bc-9e7b-79802973db10','X9PDrTpHzD004sNAg4aajjWNuOOeKAqyc67Vlv8Rms8='),(139,'Fu2HdbasxBXcBAlJus6+FYXDLSAxo5UbMnUVJtN3+H4=','2026-07-03 06:39:42','2026-07-10 06:39:42',NULL,NULL,4,'e995d853-00ce-4b1c-be90-8705b256d2de','VUwdPMTk1whHTMvxMH5ZAx5L3CKqpDkECiTLCiP75GQ='),(140,'ItNwA6I7BtKjypytp4rL8WiLg+vcuKAVLTioiYd40qE=','2026-07-03 06:51:36','2026-07-10 06:51:36',NULL,NULL,4,'ac4d58a9-1486-4244-a4c4-65a8849f6f9c','MmpcwOWSY9shtRNazCzt5DDk953SCtdKds3pzOAVLVI='),(141,'FM2tkl6B0j73aBiKS1X77Ezzw6SmPivoaTPULCmeLv8=','2026-07-03 06:54:51','2026-07-10 06:54:51',NULL,NULL,4,'ca426521-17b3-47e7-982d-e01638b81d2c','OilWtnwj6hol4z1j+FXAteBb64sJ3PKPE8zG1fr+VDM='),(142,'7SfIMAnIyWXPHoLIG+LE2jG1MyMYFmjZxYr5b+QLW8k=','2026-07-03 06:55:07','2026-07-10 06:55:07',NULL,NULL,4,'24bc16ad-f697-4a6b-8505-15c5fdbf2468','9u1XHLNz/1rlWI7Q3mT/h44oKnJAvpkrWS2TNOAmNJ4='),(143,'KsGHHNwg1gbjUQcBoNCiZYm1VlvYhOv+E2b9I2Pg28o=','2026-07-03 06:55:58','2026-07-10 06:55:58',NULL,NULL,7,'38afdaec-fd25-4e42-b25e-c84d3a355bf0','gkms8TlCbfTgLB3mmJH6ZIEjOp3WEpBYEyHc2CfFmpU='),(144,'7j+4mlzDX6GCrSYOsE4zXP2TCDKnghey8c42ZvNr/FM=','2026-07-03 06:58:54','2026-07-10 06:58:54',NULL,NULL,5,'15dd625f-411f-4626-a91a-6069fd4cc8a4','EDDdCwZ+EyIHlZctOam2MDOyMRvIjgmiu4C0HmYGnuk=');
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
INSERT INTO `Remplir` VALUES (3,1),(4,2),(5,3),(4,4),(4,5),(4,6);
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TablePresence`
--

LOCK TABLES `TablePresence` WRITE;
/*!40000 ALTER TABLE `TablePresence` DISABLE KEYS */;
INSERT INTO `TablePresence` VALUES (1,'2026-06-23','PRESENT',0,0,3),(2,'2026-06-23','PRESENT',0,0,4),(3,'2026-06-26','PRESENT',0,0,3),(4,'2026-06-30','PRESENT',20,1,17);
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
INSERT INTO `Travailler` VALUES (14,'123'),(14,'1234'),(14,'12345');
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Utilisateur`
--

LOCK TABLES `Utilisateur` WRITE;
/*!40000 ALTER TABLE `Utilisateur` DISABLE KEYS */;
INSERT INTO `Utilisateur` VALUES (1,'Luffy','Monkey.D','luffy','nCemS+hfMAFGYgvdqIwSmGi/QSkwYWh2BYnuKiHD0pndk136lPB65HSxL3zJ17aFfxRGhJuonThXIxQiK6HkZg=='),(2,'Zoro','Roronoa','zoro','UNyMOPhoD67cZDEeNhetdm2aWHr5z6BsZkLyT8iP+hl2nd46p3P3mjmx5eWuHH3pknN8sIKCYNZua/JWdgafkA=='),(3,'nami','Navigator','nami','agsVAQevej9ituvDPuexs3EDc7PRKBz34wWfMAJq3VtPOeByyOtboPEDbeYo5yv+lveZ1+8gL8bprEOYzU8+/w=='),(4,'Usopp','Snipper King','usopp','AiOZKycUWvLQIArdcXZYPG0zmt86MBxeGCc4fMPkahQB0oSTAVmVWShZyoFN/1lIpoZE80aEy8M/LqH0bE8tUQ=='),(5,'Vinsmoke','Sanji','sanji','Gb0Yzta8KABrUg/TciWaGxPMjcqiDfNOLPHQp/WFk9Fh9AErnHwa6IPFI5y1Sjv/WJwLDi65HPsDwO6y+/g2iQ=='),(6,'Chopper','Tony Tony','tony','RA+ftKzmUvYlsFhtCHGDwApHy8QxHm3gY0ZhoiF/AjEppPRMxoMfnwsKHbt/ifn6GUZfnkauchI953lZD/EBZg=='),(7,'Robin','Nico','nico','97CXg4P1deu0L0IGsDZ4b8m+HXcSWTm2DjrlFkAOLokZROxc7jW/43WmSgMJ7/4A9O/c9nUBDYmRuE+zQZ3bfQ=='),(8,'Shipwright','Franky','franky','HWBPQGFnFuBvhTDVLPftjYB7hp1q5KpsLzQc32Uuz9ytpgZFtyjJ09QEbDugAFYuCGm/Umfw0XOMf/98iCvhGw=='),(9,'Musician','Brook','brook','Tqu72sSxwIMHaRcSwiccsReJsv1lbyMbCUSoFb/l16kH32WP7UvqB0SOWf2chJlUnkwsasb5lOVo6MJEHWbRpA=='),(10,'Helmsman','Jinbe','jinbe','7ghHk+yosKmenLGyf0/6wDotC4B5hOh7rQyuXR/JyjqNfEbMzWauEX8GOa3hHdruOtlwPx1sF9c4LckdL3R9TA=='),(11,'Vivi','Nefertari ','vivi','5QgHI8b97kkGzrpnxaXbDaHUG7RPupZhYlWArzDa405j46lZ6YNA8mROAYIALJgkfyImg/Stv5OrupTjvi2cfw=='),(14,'Dupont','Jean','jean.dupont@example.com','9/A5DLK2ir0v3yrljXyRjAM7C06KypRaWqYA6hDC089kFaf1V3jaJwq47Dq0JTL5/FiD8+MgTCxDt9VbdXWVcQ=='),(15,'Eren','Yeager','eren','GSmcvcmNqQ/pDAcuY7hvxtVb5c7UmLTN/X7avNO2o4U/8FvSpgdJdkRxNyYEnKv/2Juf1pNaXvrNdAGjmmRt0A=='),(16,'john','john','john','2Zo3K5C/gpsdubmFV9iFUC7HiTSzEqpK2tyG6p6Gl4NuKKdnJVEi2oP53pCeIt+QT+azYb+pRhHCbFfLfpWrrw=='),(17,'bob','bob','bob','/GXOPbaVoEPEP7wv6EMWb+aAmN4Py5E6Nd+UGbatg948CAdwor86i3Z3dTC2eskOgTibcFvNs4XK9ndSUN28nQ==');
/*!40000 ALTER TABLE `Utilisateur` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `__EFMigrationsHistory`
--

DROP TABLE IF EXISTS `__EFMigrationsHistory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `__EFMigrationsHistory` (
  `MigrationId` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ProductVersion` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`MigrationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `__EFMigrationsHistory`
--

LOCK TABLES `__EFMigrationsHistory` WRITE;
/*!40000 ALTER TABLE `__EFMigrationsHistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `__EFMigrationsHistory` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-03  7:05:37
