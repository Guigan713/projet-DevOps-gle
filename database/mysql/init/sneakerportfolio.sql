-- MySQL dump 10.13  Distrib 8.0.42, for Linux (x86_64)
--
-- Host: localhost    Database: sneakerportfolio
-- ------------------------------------------------------
-- Server version	8.0.42-0ubuntu0.24.04.1

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
-- Table structure for table `about`
--

DROP TABLE IF EXISTS `about`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `about` (
  `id` int NOT NULL AUTO_INCREMENT,
  `about_img` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `about`
--

LOCK TABLES `about` WRITE;
/*!40000 ALTER TABLE `about` DISABLE KEYS */;
INSERT INTO `about` VALUES (1,'Guigan.jpg');
/*!40000 ALTER TABLE `about` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aboutme`
--

DROP TABLE IF EXISTS `aboutme`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aboutme` (
  `id` int NOT NULL AUTO_INCREMENT,
  `aboutme_img` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aboutme`
--

LOCK TABLES `aboutme` WRITE;
/*!40000 ALTER TABLE `aboutme` DISABLE KEYS */;
INSERT INTO `aboutme` VALUES (1,'Guigan.jpg');
/*!40000 ALTER TABLE `aboutme` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `home`
--

DROP TABLE IF EXISTS `home`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `home` (
  `id` int NOT NULL AUTO_INCREMENT,
  `home_img` text NOT NULL,
  `hello_title` varchar(255) NOT NULL,
  `gui_title` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home`
--

LOCK TABLES `home` WRITE;
/*!40000 ALTER TABLE `home` DISABLE KEYS */;
INSERT INTO `home` VALUES (1,'ct2.jpg','Sneaker Portfolio','Guigan713');
/*!40000 ALTER TABLE `home` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pics`
--

DROP TABLE IF EXISTS `pics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pics` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shoe_name` varchar(255) NOT NULL,
  `shoe_brand` varchar(255) NOT NULL,
  `photographer` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `shoe_img` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pics`
--

LOCK TABLES `pics` WRITE;
/*!40000 ALTER TABLE `pics` DISABLE KEYS */;
INSERT INTO `pics` VALUES (1,'Gel Lyte Speed San Fermin Sample','Asics','Guigan713','Guigan713','24kts2.jpg'),(2,'Gel Lyte 3 252 Sample','Asics','Guigan713','Guigan713','252s3.jpg'),(3,'Gel Lyte 3 Alvin Purple Sample','Asics','Anthonysuz','Guigan713','alvin1.jpg'),(4,'Gel Lyte 3 A.R.C Pigeon','Asics','AlexisTrch','Guigan713','arc1.jpg'),(5,'1500 BFR BlackBeard','New Balance','Anthonysuz','Guigan713','bfr4.jpg'),(6,'Gel Lyte 3 Blueberry','Asics','AlexisTrch','Guigan713','blueberryBridge.jpg'),(7,'Gel Lyte 3 Blue Sample','Asics','AlexisTrch','Guigan713','blueSample.jpg'),(8,'GT 2 Brick Sample','Asics','AlexisTrch','Guigan713','bricks.jpg'),(9,'Gel Lyte 3 Cervidae Sample','Asics','Guigan713','Guigan713','cervidae1.jpg'),(10,'Gel Lyte 3 CultureShoq 1','Asics','Tcoolkicks','Guigan713','cs1.jpg'),(11,'Gel Lyte 3 CultureShoq 2','Asics','AlexisTrch','Guigan713','cs2.jpg'),(12,'Gel Lyte 3 Crooked Tongue Sample','Asics','AlexisTrch','Guigan713','ct1.jpg'),(13,'Gel Lyte 3 A.R.C Curry','Asics','Guigan713','Guigan713','curry4.jpg'),(14,'Gel Lyte 3 LaMjc','Asics','Tcoolkicks','Guigan713','LaMjc2.jpg'),(15,'Gel Lyte 3 Mint','Asics','Guigan713','Guigan713','mint2.jpg'),(16,'Gel Lyte 3 Mita Blueberry','Asics','AlexisTrch','Guigan713','mita1.jpg'),(17,'Gel Lyte 3 HAL Mortar','Asics','AlexisTrch','Guigan713','mortar.jpg'),(18,'Gel Lyte 3 Solefly Nighthaven','Asics','Guigan713','Guigan713','nighthaven2.jpg'),(19,'Gel Lyte 3 Nicekicks 1.0','Asics','Guigan713','Guigan713','nk13.jpg'),(20,'Gel Lyte 3 Nicekicks 2.0','Asics','Guigan713','Guigan713','nk24.jpg'),(21,'Gel Lyte 3 Nicekicks 1.0','Asics','Guigan713','Guigan713','nk25.jpg'),(22,'Gel Lyte 3 Patta Coat of arms','Asics','AlexisTrch','Guigan713','patta1.jpg'),(23,'Gel Lyte 3 Patta Coat of arms','Asics','AlexisTrch','Guigan713','patta2.jpg'),(24,'Gel Lyte 3 PATTA GR','Asics','Guigan713','Tcoolkicks','pattaex.jpg'),(25,'Gel Lyte Respector Sample','Asics','Sham Nizam','Guigan713','respector1.jpg'),(26,'Gel Lyte Respector Sample','Asics','Sham Nizam','Guigan713','respector2.jpg'),(27,'Gel Lyte 3 Salmon Toe','Asics','Guigan713','Guigan713','salmon3.jpg'),(28,'Gel Lyte 3 Solebox Carpenter bee Sample','Asics','AlexisTrch','Guigan713','sb1.jpg'),(29,'Gel Lyte 3 Solebox Carpenter bee Sample','Asics','AlexisTrch','Guigan713','sb2.jpg'),(30,'Gel Lyte 3 Super Blue Sample','Asics','Tcoolkicks','Guigan713','sbs1.jpg'),(31,'Gel Lyte 3 Slamjam 5th Dimension','Asics','Guigan713','Guigan713','sj5th.jpg'),(32,'Gel Lyte 3 Kith Super red','Asics','Sham Nizam','Guigan713','sr1.jpg'),(33,'Gel Lyte 3 Kith Super red','Asics','AlexisTrch','Guigan713','sr3.jpg'),(34,'Gel Lyte 3 Woei Vintage Nylon','Asics','Guigan713','Guigan713','vintage1.jpg'),(35,'Gel Lyte 3 Woei Vintage Nylon','Asics','Guigan713','Guigan713','vintage3.jpg'),(36,'Gel Lyte 3 Woei Vintage Nylon','Asics','Guigan713','Guigan713','vintage4.jpg'),(37,'Gel Lyte 3 Woei Vintage Nylon','Asics','Guigan713','Tcoolkicks','vintagewoei.jpg'),(38,'Gel Lyte 3 Hanon Wildcats','Asics','Guigan713','Guigan713','wildcats3.jpg'),(39,'Gel Lyte 3 Cervidae Sample','Asics','Guigan713','Guigan713','woei4.jpg');
/*!40000 ALTER TABLE `pics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `snaps`
--

DROP TABLE IF EXISTS `snaps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `snaps` (
  `id` int NOT NULL AUTO_INCREMENT,
  `shoe_name` varchar(255) NOT NULL,
  `shoe_brand` varchar(255) NOT NULL,
  `photographer` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `shoe_img` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `snaps`
--

LOCK TABLES `snaps` WRITE;
/*!40000 ALTER TABLE `snaps` DISABLE KEYS */;
/*!40000 ALTER TABLE `snaps` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-08 11:22:18
