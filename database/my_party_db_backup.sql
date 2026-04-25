/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.5-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: my_party_4
-- ------------------------------------------------------
-- Server version	11.8.5-MariaDB-3 from Debian

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `Clients`
--

DROP TABLE IF EXISTS `Clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Clients` (
  `client_id` int(11) NOT NULL AUTO_INCREMENT,
  `coordinator_id` int(11) NOT NULL,
  `creator_user_role` varchar(50) NOT NULL CHECK (`creator_user_role` in ('coordinator','admin')),
  `full_name` varchar(255) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `img_url` text DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`client_id`),
  UNIQUE KEY `uc_client_phone_in_coordinator_creator` (`coordinator_id`,`phone_number`),
  UNIQUE KEY `uc_client_email_in_coordinator_creator` (`coordinator_id`,`email`),
  CONSTRAINT `Clients_ibfk_1` FOREIGN KEY (`coordinator_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_clientss_before_update` BEFORE UPDATE ON `Clients`
    FOR EACH ROW
    BEGIN
        IF NEW.`email` != OLD.`email` AND NEW.`email` IS NOT NULL THEN
            IF EXISTS (SELECT 1 FROM `Clients` WHERE `email` = NEW.`email` AND `client_id` != NEW.`client_id`) THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists for another user';
            END IF;
        END IF;
        IF NEW.`phone_number` != OLD.`phone_number` AND NEW.`phone_number` IS NOT NULL THEN
            IF EXISTS (SELECT 1 FROM `Clients` WHERE `phone_number` = NEW.`phone_number` AND `client_id` != NEW.`client_id`) THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'phone_number already exists for another client';
            END IF;
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Events`
--

DROP TABLE IF EXISTS `Events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Events` (
  `event_id` int(11) NOT NULL AUTO_INCREMENT,
  `coordinator_id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `event_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `img_url` text DEFAULT NULL,
  `budget` decimal(10,2) DEFAULT 0.00,
  `event_date` date NOT NULL,
  `event_duration` int(11) DEFAULT NULL,
  `event_duration_unit` enum('DAY','WEEK','MONTH') DEFAULT 'WEEK',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`event_id`),
  KEY `client_id` (`client_id`),
  KEY `coordinator_id` (`coordinator_id`),
  CONSTRAINT `Events_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `Clients` (`client_id`) ON DELETE CASCADE,
  CONSTRAINT `Events_ibfk_2` FOREIGN KEY (`coordinator_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_events_before_insert` BEFORE INSERT ON `Events`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coordinator must have coordinator role';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_events_before_update` BEFORE UPDATE ON `Events`
    FOR EACH ROW
    BEGIN
        
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coordinator must have coordinator role';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_events_after_update` AFTER UPDATE ON `Events`
    FOR EACH ROW
    BEGIN
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN 
            UPDATE `Task_Assigns` SET `deleted_at` = NOW() WHERE `event_id` = OLD.event_id;
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Incomes`
--

DROP TABLE IF EXISTS `Incomes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Incomes` (
  `income_id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `payment_date` date NOT NULL,
  `url_image` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`income_id`),
  KEY `event_id` (`event_id`),
  CONSTRAINT `Incomes_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `Events` (`event_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Notifications`
--

DROP TABLE IF EXISTS `Notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Notifications` (
  `notification_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`notification_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `Notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Permissions`
--

DROP TABLE IF EXISTS `Permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Permissions` (
  `permission_name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`permission_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Ratings_Task_Assign`
--

DROP TABLE IF EXISTS `Ratings_Task_Assign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Ratings_Task_Assign` (
  `rating_id` int(11) NOT NULL AUTO_INCREMENT,
  `task_assign_id` int(11) NOT NULL,
  `coordinator_id` int(11) NOT NULL,
  `user_assign_id` int(11) NOT NULL,
  `rating_value` int(11) NOT NULL CHECK (`rating_value` between 1 and 5),
  `rating_comment` text DEFAULT NULL,
  `rated_at` timestamp NULL DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`rating_id`),
  UNIQUE KEY `uc_coordinator_rate` (`coordinator_id`,`task_assign_id`),
  KEY `task_assign_id` (`task_assign_id`),
  CONSTRAINT `Ratings_Task_Assign_ibfk_1` FOREIGN KEY (`task_assign_id`) REFERENCES `Task_Assigns` (`task_assign_id`) ON DELETE CASCADE,
  CONSTRAINT `Ratings_Task_Assign_ibfk_2` FOREIGN KEY (`coordinator_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `check_different_users` CHECK (`user_assign_id` <> `coordinator_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_ratings_task_assign_before_insert` BEFORE INSERT ON `Ratings_Task_Assign`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rater must be a coordinator';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_ratings_task_assign_before_update` BEFORE UPDATE ON `Ratings_Task_Assign`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rater must be a coordinator';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Role_Details`
--

DROP TABLE IF EXISTS `Role_Details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Role_Details` (
  `detail_name` varchar(255) NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`detail_name`,`role_name`),
  KEY `idx_role_name` (`role_name`),
  CONSTRAINT `Role_Details_ibfk_1` FOREIGN KEY (`role_name`) REFERENCES `Roles` (`role_name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Role_Permissions`
--

DROP TABLE IF EXISTS `Role_Permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Role_Permissions` (
  `role_name` varchar(50) NOT NULL,
  `permission_name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`role_name`,`permission_name`),
  KEY `idx_permission_name` (`permission_name`),
  CONSTRAINT `Role_Permissions_ibfk_1` FOREIGN KEY (`role_name`) REFERENCES `Roles` (`role_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Role_Permissions_ibfk_2` FOREIGN KEY (`permission_name`) REFERENCES `Permissions` (`permission_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Roles`
--

DROP TABLE IF EXISTS `Roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Roles` (
  `role_name` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Service_Requests`
--

DROP TABLE IF EXISTS `Service_Requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Service_Requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(11) NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `Service_Requests_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Services`
--

DROP TABLE IF EXISTS `Services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Services` (
  `service_id` int(11) NOT NULL AUTO_INCREMENT,
  `service_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`service_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Supplier_Services`
--

DROP TABLE IF EXISTS `Supplier_Services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Supplier_Services` (
  `supplier_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`supplier_id`,`service_id`),
  KEY `service_id` (`service_id`),
  CONSTRAINT `Supplier_Services_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `Supplier_Services_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `Services` (`service_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_supplier_services_before_insert` BEFORE INSERT ON `Supplier_Services`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`supplier_id`, 'supplier') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not a supplier';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_supplier_services_before_update` BEFORE UPDATE ON `Supplier_Services`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`supplier_id`, 'supplier') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not a supplier';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Task_Assigns`
--

DROP TABLE IF EXISTS `Task_Assigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Task_Assigns` (
  `task_assign_id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `type_task` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `service_id` int(11) DEFAULT NULL,
  `user_assign_id` int(11) DEFAULT NULL,
  `coordinator_id` int(11) NOT NULL,
  `status` enum('PENDING','IN_PROGRESS','UNDER_REVIEW','COMPLETED','CANCELLED','REJECTED') DEFAULT 'PENDING',
  `description` text DEFAULT NULL,
  `cost` decimal(10,2) DEFAULT 0.00,
  `url_image` varchar(255) DEFAULT NULL,
  `date_start` date DEFAULT NULL,
  `date_due` date DEFAULT NULL,
  `date_completion` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`task_assign_id`),
  KEY `service_id` (`service_id`),
  KEY `idx_event_id` (`event_id`),
  KEY `idx_user_assign_id` (`user_assign_id`),
  KEY `idx_coordinator_id` (`coordinator_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `Task_Assigns_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `Events` (`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Task_Assigns_ibfk_2` FOREIGN KEY (`service_id`) REFERENCES `Supplier_Services` (`service_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Task_Assigns_ibfk_3` FOREIGN KEY (`user_assign_id`) REFERENCES `Supplier_Services` (`supplier_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `Task_Assigns_ibfk_4` FOREIGN KEY (`coordinator_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_task_assigns_before_insert` BEFORE INSERT ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن إنشاء المهام من قبل غير المنسقين';
        END IF;
        IF NEW.`user_assign_id` IS NOT NULL AND NOT (fn_user_has_role(NEW.`user_assign_id`, 'coordinator') OR fn_user_has_role(NEW.`user_assign_id`, 'supplier')) THEN
            SET @msg_error = CONCAT('لا يمكن تعيين المهام لغير المنسقين أو الموردين رقم المستخدم هو ', IFNULL(NEW.`user_assign_id`, 'NULL'));
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg_error;
        END IF;
        IF NEW.`date_start` IS NOT NULL AND NEW.`date_start` < CURDATE() THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن إنشاء المهام في الماضي';
        END IF;
        IF NEW.`date_due` IS NOT NULL AND NEW.`date_start` IS NOT NULL AND NEW.`date_due` <= NEW.`date_start` THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن أن يكون تاريخ الانتهاء قبل تاريخ البدء';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_task_assigns_before_update` BEFORE UPDATE ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        IF OLD.`date_due` IS NOT NULL AND OLD.`date_due` < CURDATE() THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تحديث المهام في الماضي';
        END IF;
        IF NEW.`date_due` IS NOT NULL AND NEW.`date_start` IS NOT NULL AND NEW.`date_due` <= NEW.`date_start` THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن أن يكون تاريخ الانتهاء قبل تاريخ البدء';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_task_assigns_after_update` AFTER UPDATE ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN 
            UPDATE `Task_Reminders` SET `deleted_at` = NOW() WHERE `task_assign_id` = OLD.task_assign_id;
            UPDATE `Ratings_Task_Assign` SET `deleted_at` = NOW() WHERE `task_assign_id` = OLD.task_assign_id;
        END IF; 
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_task_assigns_before_delete` BEFORE DELETE ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        
        UPDATE `Task_Reminders` SET `deleted_at` = NOW() WHERE `task_assign_id` = OLD.`task_assign_id`;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Task_Reminders`
--

DROP TABLE IF EXISTS `Task_Reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Task_Reminders` (
  `reminder_id` int(11) NOT NULL AUTO_INCREMENT,
  `task_assign_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL COMMENT 'المستخدم الذي أنشأ التذكير (منسق أو مورد)',
  `reminder_type` enum('INTERVAL','BEFORE_DUE') NOT NULL DEFAULT 'BEFORE_DUE',
  `reminder_value` int(11) NOT NULL,
  `reminder_unit` enum('MINUTE','HOUR','DAY','WEEK') NOT NULL DEFAULT 'DAY',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`reminder_id`),
  KEY `idx_task_assign` (`task_assign_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_active` (`is_active`),
  CONSTRAINT `Task_Reminders_ibfk_1` FOREIGN KEY (`task_assign_id`) REFERENCES `Task_Assigns` (`task_assign_id`) ON DELETE CASCADE,
  CONSTRAINT `Task_Reminders_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `User_Detail_Values`
--

DROP TABLE IF EXISTS `User_Detail_Values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `User_Detail_Values` (
  `user_id` int(11) NOT NULL,
  `detail_name` varchar(255) NOT NULL,
  `detail_value` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`,`detail_name`),
  KEY `idx_detail_name` (`detail_name`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `User_Detail_Values_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `User_Detail_Values_ibfk_2` FOREIGN KEY (`detail_name`) REFERENCES `Role_Details` (`detail_name`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `User_FCM_Tokens`
--

DROP TABLE IF EXISTS `User_FCM_Tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `User_FCM_Tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token` text NOT NULL,
  `device_type` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uc_user_token` (`user_id`,`token`(255)),
  KEY `idx_user_fcm` (`user_id`),
  CONSTRAINT `User_FCM_Tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `User_Permissions`
--

DROP TABLE IF EXISTS `User_Permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `User_Permissions` (
  `user_id` int(11) NOT NULL,
  `permission_name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`,`permission_name`),
  KEY `permission_name` (`permission_name`),
  CONSTRAINT `User_Permissions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `User_Permissions_ibfk_2` FOREIGN KEY (`permission_name`) REFERENCES `Permissions` (`permission_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Users`
--

DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `img_url` text DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone_number` (`phone_number`),
  KEY `idx_role_name` (`role_name`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `Users_ibfk_1` FOREIGN KEY (`role_name`) REFERENCES `Roles` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_before_insert` BEFORE INSERT ON `Users`
    FOR EACH ROW 
    BEGIN
        IF EXISTS (SELECT 1 FROM `Users` WHERE `email` = NEW.`email`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists for another user';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_before_update` BEFORE UPDATE ON `Users`
    FOR EACH ROW
    BEGIN
        IF NEW.`email` != OLD.`email` THEN
            IF EXISTS (SELECT 1 FROM `Users` WHERE `email` = NEW.`email` AND `user_id` != NEW.`user_id`) THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists for another user';
            END IF;
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_after_update` AFTER UPDATE ON `Users`
    FOR EACH ROW
    BEGIN 
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL AND OLD.role_name = 'coordinator' THEN 
            CALL sp_delete_all_events_of_coordinator(OLD.user_id);
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary table structure for view `vw_clients_detailed`
--

DROP TABLE IF EXISTS `vw_clients_detailed`;
/*!50001 DROP VIEW IF EXISTS `vw_clients_detailed`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_clients_detailed` AS SELECT
 1 AS `client_id`,
  1 AS `coordinator_id`,
  1 AS `creator_user_role`,
  1 AS `client_name`,
  1 AS `client_phone`,
  1 AS `img_url`,
  1 AS `email`,
  1 AS `address`,
  1 AS `created_at`,
  1 AS `updated_at`,
  1 AS `deleted_at`,
  1 AS `total_events`,
  1 AS `total_tasks`,
  1 AS `completed_tasks`,
  1 AS `pending_tasks`,
  1 AS `cancelled_tasks`,
  1 AS `total_spent` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_events_detailed`
--

DROP TABLE IF EXISTS `vw_events_detailed`;
/*!50001 DROP VIEW IF EXISTS `vw_events_detailed`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_events_detailed` AS SELECT
 1 AS `event_id`,
  1 AS `coordinator_id`,
  1 AS `client_id`,
  1 AS `event_name`,
  1 AS `description`,
  1 AS `location`,
  1 AS `img_url`,
  1 AS `budget`,
  1 AS `event_date`,
  1 AS `event_duration`,
  1 AS `event_duration_unit`,
  1 AS `created_at`,
  1 AS `updated_at`,
  1 AS `deleted_at`,
  1 AS `is_deleted`,
  1 AS `status`,
  1 AS `coordinator_name`,
  1 AS `coordinator_phone`,
  1 AS `coordinator_email`,
  1 AS `total_income`,
  1 AS `total_expenses`,
  1 AS `total_tasks`,
  1 AS `completed_tasks`,
  1 AS `completion_percentage`,
  1 AS `client_name`,
  1 AS `client_phone`,
  1 AS `client_email`,
  1 AS `client_img` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_events_detailed_with_coor`
--

DROP TABLE IF EXISTS `vw_events_detailed_with_coor`;
/*!50001 DROP VIEW IF EXISTS `vw_events_detailed_with_coor`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_events_detailed_with_coor` AS SELECT
 1 AS `event_id`,
  1 AS `coordinator_id`,
  1 AS `client_id`,
  1 AS `event_name`,
  1 AS `description`,
  1 AS `location`,
  1 AS `img_url`,
  1 AS `budget`,
  1 AS `event_date`,
  1 AS `event_duration`,
  1 AS `event_duration_unit`,
  1 AS `created_at`,
  1 AS `updated_at`,
  1 AS `deleted_at`,
  1 AS `is_deleted`,
  1 AS `status`,
  1 AS `coordinator_name`,
  1 AS `coordinator_phone`,
  1 AS `coordinator_email`,
  1 AS `total_income`,
  1 AS `total_expenses`,
  1 AS `total_tasks`,
  1 AS `completed_tasks`,
  1 AS `completion_percentage` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_get_all_admins`
--

DROP TABLE IF EXISTS `vw_get_all_admins`;
/*!50001 DROP VIEW IF EXISTS `vw_get_all_admins`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_get_all_admins` AS SELECT
 1 AS `user_id`,
  1 AS `role_name`,
  1 AS `full_name`,
  1 AS `phone_number`,
  1 AS `img_url`,
  1 AS `email`,
  1 AS `password`,
  1 AS `is_active`,
  1 AS `created_at`,
  1 AS `updated_at`,
  1 AS `deleted_at`,
  1 AS `is_deleted` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_get_all_coordinators`
--

DROP TABLE IF EXISTS `vw_get_all_coordinators`;
/*!50001 DROP VIEW IF EXISTS `vw_get_all_coordinators`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_get_all_coordinators` AS SELECT
 1 AS `user_id`,
  1 AS `role_name`,
  1 AS `full_name`,
  1 AS `phone_number`,
  1 AS `img_url`,
  1 AS `email`,
  1 AS `password`,
  1 AS `is_active`,
  1 AS `created_at`,
  1 AS `updated_at`,
  1 AS `deleted_at`,
  1 AS `is_deleted` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_get_all_suppliers`
--

DROP TABLE IF EXISTS `vw_get_all_suppliers`;
/*!50001 DROP VIEW IF EXISTS `vw_get_all_suppliers`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_get_all_suppliers` AS SELECT
 1 AS `user_id`,
  1 AS `role_name`,
  1 AS `full_name`,
  1 AS `phone_number`,
  1 AS `img_url`,
  1 AS `email`,
  1 AS `password`,
  1 AS `is_active`,
  1 AS `created_at`,
  1 AS `updated_at`,
  1 AS `deleted_at`,
  1 AS `is_deleted`,
  1 AS `address` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_get_all_suppliers_and_services`
--

DROP TABLE IF EXISTS `vw_get_all_suppliers_and_services`;
/*!50001 DROP VIEW IF EXISTS `vw_get_all_suppliers_and_services`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_get_all_suppliers_and_services` AS SELECT
 1 AS `service_id`,
  1 AS `supplier_id`,
  1 AS `service_name`,
  1 AS `service_description`,
  1 AS `role_name`,
  1 AS `full_name`,
  1 AS `phone_number`,
  1 AS `email`,
  1 AS `password`,
  1 AS `img_url`,
  1 AS `is_active`,
  1 AS `address`,
  1 AS `supplier_has_service`,
  1 AS `service_is_deleted`,
  1 AS `supplier_is_deleted`,
  1 AS `service_created_at`,
  1 AS `service_updated_at`,
  1 AS `service_deleted_at`,
  1 AS `supplier_created_at`,
  1 AS `supplier_updated_at`,
  1 AS `supplier_deleted_at` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_notifications`
--

DROP TABLE IF EXISTS `vw_notifications`;
/*!50001 DROP VIEW IF EXISTS `vw_notifications`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_notifications` AS SELECT
 1 AS `notification_id`,
  1 AS `user_id`,
  1 AS `type`,
  1 AS `title`,
  1 AS `message`,
  1 AS `is_read`,
  1 AS `created_at`,
  1 AS `updated_at`,
  1 AS `deleted_at`,
  1 AS `recipient_type`,
  1 AS `recipient_name` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_task_reminders_details`
--

DROP TABLE IF EXISTS `vw_task_reminders_details`;
/*!50001 DROP VIEW IF EXISTS `vw_task_reminders_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_task_reminders_details` AS SELECT
 1 AS `reminder_id`,
  1 AS `task_assign_id`,
  1 AS `user_id`,
  1 AS `user_name`,
  1 AS `user_email`,
  1 AS `reminder_type`,
  1 AS `reminder_value`,
  1 AS `reminder_unit`,
  1 AS `is_active`,
  1 AS `created_at`,
  1 AS `task_description`,
  1 AS `task_status`,
  1 AS `date_due`,
  1 AS `event_name`,
  1 AS `event_date` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_tasks_full`
--

DROP TABLE IF EXISTS `vw_tasks_full`;
/*!50001 DROP VIEW IF EXISTS `vw_tasks_full`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_tasks_full` AS SELECT
 1 AS `task_assign_id`,
  1 AS `event_id`,
  1 AS `type_task`,
  1 AS `notes`,
  1 AS `service_id`,
  1 AS `user_assign_id`,
  1 AS `coordinator_id`,
  1 AS `status`,
  1 AS `description`,
  1 AS `cost`,
  1 AS `url_image`,
  1 AS `date_start`,
  1 AS `date_due`,
  1 AS `date_completion`,
  1 AS `created_at`,
  1 AS `updated_at`,
  1 AS `deleted_at`,
  1 AS `event_name`,
  1 AS `task_creator_name`,
  1 AS `assignment_type`,
  1 AS `assigne_name`,
  1 AS `rating_value`,
  1 AS `rating_comment`,
  1 AS `rated_at`,
  1 AS `reminder_value`,
  1 AS `reminder_unit` */;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'my_party_4'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `event_generate_reminders_hourly` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `event_generate_reminders_hourly` ON SCHEDULE EVERY 1 HOUR STARTS '2026-04-20 14:45:52' ON COMPLETION NOT PRESERVE ENABLE DO CALL sp_generate_task_reminders() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `Event_Monitoring` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `Event_Monitoring` ON SCHEDULE EVERY 6 HOUR STARTS '2026-04-20 14:45:52' ON COMPLETION NOT PRESERVE ENABLE DO CALL Run_Monitoring() */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'my_party_4'
--
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_array_at` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_array_at`(`p_keys` JSON, `p_index` INT ) RETURNS varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN JSON_UNQUOTE(JSON_EXTRACT(p_keys, CONCAT('$[', p_index, ']')));
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_concat_error_msg` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_concat_error_msg`(IN `p_error_msg` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
        IN `p_original_msg` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS text CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    NO SQL
    DETERMINISTIC
BEGIN 
        RETURN IF(p_error_msg IS NULL OR p_error_msg = '', 
            p_original_msg, 
            CONCAT(
                p_error_msg, 
                IF(p_original_msg IS NULL OR p_original_msg = '', 
                    '', 
                    CONCAT(' \n', p_original_msg)
                )
            )
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_event_get_end_date` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_event_get_end_date`(`p_event_date` DATE,
        `p_event_duration` INT,
        `p_event_duration_unit` ENUM('DAY', 'WEEK', 'MONTH') CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS date
    READS SQL DATA
    DETERMINISTIC
BEGIN

        IF p_event_duration_unit = 'DAY' THEN RETURN DATE_ADD(p_event_date , INTERVAL P_event_duration DAY);
        ELSEIF p_event_duration_unit = 'WEEK'THEN RETURN DATE_ADD(p_event_date , INTERVAL P_event_duration WEEK);
        ELSE RETURN DATE_ADD(p_event_date , INTERVAL P_event_duration MONTH); END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_event_get_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_event_get_status`(`p_event_id` INT
    ) RETURNS enum('PENDING','IN_PROGRESS','COMPLETED','CANCELLED','OTHER') CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    READS SQL DATA
    DETERMINISTIC
BEGIN 
        DECLARE v_event_date DATE;
        DECLARE v_event_end_date DATE;
        DECLARE v_deleted_at TIMESTAMP;

        SELECT `event_date`, fn_event_get_end_date(`event_date`, `event_duration`, `event_duration_unit`), `deleted_at` INTO
            v_event_date, v_event_end_date, v_deleted_at FROM `Events` 
            WHERE `event_id` = p_event_id;

        IF v_deleted_at IS NOT NULL  THEN
            RETURN 'CANCELLED';
        ELSEIF NOW() < v_event_date THEN
            RETURN 'PENDING';
        ELSEIF NOW() BETWEEN v_event_date AND v_event_end_date THEN
            RETURN 'IN_PROGRESS';            
        ELSE
            RETURN 'COMPLETED';
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_event_net_profit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_event_net_profit`(`p_event_id` INT
    ) RETURNS decimal(10,2)
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN IFNULL(fn_event_total_income(p_event_id), 0) - IFNULL(fn_event_total_expenses(p_event_id), 0);
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_event_overdue_tasks` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_event_overdue_tasks`(`p_event_id` INT
    ) RETURNS int(11)
    READS SQL DATA
    DETERMINISTIC
BEGIN
        
        RETURN (
            SELECT COUNT(*) 
            FROM `Task_Assigns`
            WHERE `event_id` = p_event_id 
            AND `status` NOT IN ('COMPLETED', 'CANCELLED')
            AND `date_due` < CURDATE()
            AND `deleted_at` IS NULL
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_event_status_is` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_event_status_is`(`p_event_status` ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DELETED') CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        `p_event_id` INT
    ) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN 
        DECLARE v_event_date DATE;
        DECLARE v_event_end_date DATE;
        DECLARE v_deleted_at TIMESTAMP;

        SELECT `event_date`, fn_event_get_end_date(`event_date`, `event_duration`, `event_duration_unit`), `deleted_at` INTO
            v_event_date, v_event_end_date, v_deleted_at FROM `Events` 
            WHERE `event_id` = p_event_id;

        IF p_event_status = 'PENDING' THEN
            RETURN v_event_date > CURDATE();
        ELSEIF p_event_status = 'IN_PROGRESS' THEN
            RETURN v_event_date BETWEEN CURDATE() AND v_event_end_date;
        ELSEIF p_event_status = 'COMPLETED' THEN
            RETURN v_event_end_date < CURDATE();
        ELSE
            RETURN v_deleted_at IS NOT NULL;
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_event_total_expenses` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_event_total_expenses`(`p_event_id` INT
    ) RETURNS decimal(10,2)
    READS SQL DATA
    DETERMINISTIC
BEGIN
        
        RETURN (
            SELECT IFNULL(SUM(`cost`), 0) 
            FROM `Task_Assigns` 
            WHERE `event_id` = p_event_id AND `deleted_at` IS NULL
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_event_total_income` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_event_total_income`(`p_event_id` INT
    ) RETURNS decimal(10,2)
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN (
            SELECT IFNULL(SUM(`amount`), 0) 
            FROM `Incomes` WHERE `event_id` = p_event_id AND `deleted_at` IS NULL
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_getKeyOrIndex_array` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_getKeyOrIndex_array`(`p_index` INT, 
    `p_key` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
    `p_keyOrIndex` ENUM('index','key') CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    NO SQL
    DETERMINISTIC
BEGIN 
        IF p_keyOrIndex = 'index' THEN 
            RETURN CONCAT('$[', p_index, ']'); 
        ELSEIF p_keyOrIndex = 'key' THEN 
            RETURN CONCAT('$.', p_key); 
        END IF; 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid key or index'; 
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_get_avg_supplier_rating_for_coord` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_get_avg_supplier_rating_for_coord`(`p_coordinator_id` INT,
        `p_supplier_id` INT
    ) RETURNS decimal(10,2)
BEGIN
		RETURN (SELECT IFNULL(AVG(rta.rating_value), 0.0) FROM Ratings_Task_Assign rta 
        	WHERE rta.coordinator_id = p_coordinator_id AND 
            rta.user_assign_id = p_supplier_id
         );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_json_get` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_json_get`(`p_details` JSON, `p_key` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci) RETURNS text CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN JSON_UNQUOTE(JSON_EXTRACT(p_details, CONCAT('$.', p_key)));
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_role_exists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_role_exists`(`p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Roles` WHERE `role_name` = p_role_name AND `deleted_at` IS NULL
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_role_has_permission` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_role_has_permission`(`p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
    `p_permission_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Role_Permissions` rp
            WHERE rp.`role_name` = p_role_name AND rp.`permission_name` = p_permission_name
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_user_detail_exists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_user_detail_exists`(`p_user_id` INT,
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN 
        RETURN EXISTS (
            SELECT 1 FROM `User_Detail_Values` 
            WHERE `user_id` = p_user_id AND `detail_name` = p_detail_name
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_user_get_detail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_user_get_detail`(`p_user_id` INT, 
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS text CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN (
            SELECT `detail_value` FROM `User_Detail_Values`
            WHERE `user_id` = p_user_id AND `detail_name` = p_detail_name LIMIT 1
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_user_get_rolename` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_user_get_rolename`(`p_user_conditions` JSON
    ) RETURNS varchar(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    READS SQL DATA
    DETERMINISTIC
BEGIN
        DECLARE v_user_id INT ;
        DECLARE v_full_name VARCHAR(255);
        DECLARE v_phone VARCHAR(20);
        DECLARE v_email VARCHAR(255);
        DECLARE v_password VARCHAR(255);
        DECLARE v_img_url TEXT;
        DECLARE v_role_name VARCHAR(50);
        DECLARE v_deleted_at TIMESTAMP;
        DECLARE is_all_null BOOLEAN;

        SET v_user_id = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.user_id')); 
        SET v_full_name = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.full_name')); 
        SET v_phone = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.phone_number')); 
        SET v_email = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.email')); 
        SET v_password = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.password')); 
        SET v_img_url = JSON_UNQUOTE(JSON_EXTRACT(p_user_conditions, '$.img_url')); 
    
        SET is_all_null =  v_user_id IS NULL AND 
                            v_full_name IS NULL AND 
                            v_phone IS NULL AND 
                            v_email IS NULL AND 
                            v_password IS NULL AND 
                            v_img_url IS NULL;
                            
        SELECT `role_name`, `deleted_at` INTO v_role_name, v_deleted_at FROM `Users` 
            WHERE NOT is_all_null AND (
                (v_user_id IS NULL OR `user_id` = v_user_id) AND 
                (v_full_name IS NULL OR `full_name` = v_full_name) AND 
                (v_phone IS NULL OR `phone_number` = v_phone) AND 
                (v_email IS NULL OR `email` = v_email) AND 
                (v_password IS NULL OR `password` = v_password) AND 
                (v_img_url IS NULL OR `img_url` = v_img_url)
            )
            LIMIT 1;

        IF v_deleted_at IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is deleted';
        END IF;
        RETURN v_role_name;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_user_has_detail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_user_has_detail`(`p_user_conditions` JSON,
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci 
    ) RETURNS tinyint(1)
    READS SQL DATA
BEGIN
        DECLARE v_role_name VARCHAR(50);

        SET v_role_name = fn_user_get_rolename(p_user_conditions);

        IF v_role_name IS NULL THEN
            RETURN FALSE;
        END IF;

        RETURN EXISTS(
            SELECT 1 FROM `Role_Details` rd
            WHERE rd.`role_name` = v_role_name 
            AND rd.`detail_name` = p_detail_name
            AND rd.`deleted_at` IS NULL
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_user_has_role` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_user_has_role`(`p_user_id` INT,
    `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci 
    ) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Users` 
            WHERE `user_id` = p_user_id AND `role_name` = p_role_name AND `deleted_at` IS NULL
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_user_is_actived` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_user_is_actived`(`p_user_id` INT
    ) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN EXISTS (
            SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `is_active` = TRUE AND `deleted_at` IS NULL
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_user_is_deleted` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_user_is_deleted`(`p_user_id` INT
    ) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN
        RETURN EXISTS (
            SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `deleted_at` IS NOT NULL
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP FUNCTION IF EXISTS `fun_role_has_detail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fun_role_has_detail`(`p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS tinyint(1)
    READS SQL DATA
    DETERMINISTIC
BEGIN 
        RETURN EXISTS (
            SELECT 1 FROM `Role_Details` 
            WHERE `detail_name` = p_detail_name AND `role_name` = p_role_name
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Check_Budget_And_Payments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Check_Budget_And_Payments`()
BEGIN
        
        
        INSERT INTO Notifications (`user_id`, `type`, `title`, `message`)
        SELECT 
            e.coordinator_id,
            'BUDGET_OVERSPENT',
            CONCAT('تجاوز الميزانية في حدث: ', e.event_name),
            CONCAT('الميزانية المحددة: ', e.budget, ', إجمالي التكاليف: ', COALESCE(SUM(ta.cost), 0), 
                '. الرجاء التدخل.')
        FROM Events e
        LEFT JOIN Task_Assigns ta ON e.event_id = ta.event_id AND ta.deleted_at IS NULL
        WHERE e.deleted_at IS NULL
        GROUP BY e.event_id, e.coordinator_id, e.event_name, e.budget
        HAVING COALESCE(SUM(ta.cost), 0) > e.budget
        AND NOT EXISTS (
            SELECT 1 FROM Notifications n
            WHERE n.user_id = e.coordinator_id
                AND n.type = 'BUDGET_OVERSPENT'
                AND n.created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
                AND n.message LIKE CONCAT('%', e.event_name, '%')
        );

        
        INSERT INTO Notifications (`user_id`, `type`, `title`, `message`)
        SELECT 
            e.coordinator_id,
            'PAYMENT_INCOMPLETE',
            CONCAT('دفعات غير مكتملة لحدث: ', e.event_name),
            CONCAT('إجمالي التكاليف: ', COALESCE(SUM(ta.cost), 0), 
                ', إجمالي الدفعات: ', COALESCE(SUM(inc.amount), 0),
                '. الحدث ينتهي قريباً (', DATE_ADD(e.event_date, INTERVAL e.event_duration DAY), ').')
        FROM Events e
        LEFT JOIN Task_Assigns ta ON e.event_id = ta.event_id AND ta.deleted_at IS NULL
        LEFT JOIN Incomes inc ON e.event_id = inc.event_id AND inc.deleted_at IS NULL
        WHERE e.deleted_at IS NULL
        AND e.event_duration IS NOT NULL
        AND DATE_ADD(e.event_date, INTERVAL e.event_duration DAY) BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        GROUP BY e.event_id, e.coordinator_id, e.event_name, e.budget, e.event_date, e.event_duration
        HAVING COALESCE(SUM(inc.amount), 0) < COALESCE(SUM(ta.cost), 0)
        AND NOT EXISTS (
            SELECT 1 FROM Notifications n
            WHERE n.user_id = e.coordinator_id
                AND n.type = 'PAYMENT_INCOMPLETE'
                AND n.created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
                AND n.message LIKE CONCAT('%', e.event_name, '%')
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Check_Events_Status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Check_Events_Status`()
BEGIN
        
        INSERT INTO Notifications (`user_id`, `type`, `title`, `message`)
        SELECT 
            e.coordinator_id,
            'EVENT_UPCOMING_END',
            CONCAT('حدث: ', e.event_name, ' على وشك الانتهاء'),
            CONCAT('سينتهي الحدث "', e.event_name, '" في ', 
                DATE_ADD(e.event_date, INTERVAL e.event_duration DAY), 
                '. يرجى مراجعة المهام والميزانية.')
        FROM Events e
        WHERE e.deleted_at IS NULL
        AND e.event_duration IS NOT NULL
        AND DATE_ADD(e.event_date, INTERVAL e.event_duration DAY) BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        AND NOT EXISTS (
            SELECT 1 FROM Notifications n
            WHERE n.user_id = e.coordinator_id
                AND n.type = 'EVENT_UPCOMING_END'
                AND n.created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
                AND n.message LIKE CONCAT('%', e.event_name, '%')
        );

        
        INSERT INTO Notifications (`user_id`, `type`, `title`, `message`)
        SELECT 
            e.coordinator_id,
            'EVENT_EXPIRED',
            CONCAT('حدث: ', e.event_name, ' انتهى وقته'),
            CONCAT('الحدث "', e.event_name, '" قد انتهى في ', 
                DATE_ADD(e.event_date, INTERVAL e.event_duration DAY), 
                '. يرجى مراجعة التقارير النهائية.')
        FROM Events e
        WHERE e.deleted_at IS NULL
        AND e.event_duration IS NOT NULL
        AND DATE_ADD(e.event_date, INTERVAL e.event_duration DAY) < CURDATE()
        AND NOT EXISTS (
            SELECT 1 FROM Notifications n
            WHERE n.user_id = e.coordinator_id
                AND n.type = 'EVENT_EXPIRED'
                AND n.created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
                AND n.message LIKE CONCAT('%', e.event_name, '%')
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Check_Tasks_Deadlines` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Check_Tasks_Deadlines`()
BEGIN
        
        INSERT INTO Notifications (`user_id`, `type`, `title`, `message`)
        SELECT 
            ta.user_assign_id,
            'TASK_UPCOMING',
            CONCAT('مهمة: ', ta.description, ' تستحق قريباً'),
            CONCAT('المهمة المطلوبة للحدث رقم ', ta.event_id, ' تستحق في ', ta.date_due, '. يرجى الإنجاز.')
        FROM Task_Assigns ta
        WHERE ta.deleted_at IS NULL
        AND ta.status NOT IN ('COMPLETED', 'CANCELLED')
        AND ta.date_due BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)
        AND ta.user_assign_id IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM Notifications n
            WHERE n.user_id = ta.user_assign_id
                AND n.type = 'TASK_UPCOMING'
                AND n.created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
                AND n.message LIKE CONCAT('%', ta.task_assign_id, '%')
        );

        
        INSERT INTO Notifications (`user_id`, `type`, `title`, `message`)
        SELECT 
            ta.coordinator_id,
            'TASK_OVERDUE',
            CONCAT('مهمة متأخرة: ', ta.description),
            CONCAT('المهمة رقم ', ta.task_assign_id, ' كان موعدها ', ta.date_due, ' ولم تكتمل بعد.')
        FROM Task_Assigns ta
        WHERE ta.deleted_at IS NULL
        AND ta.status NOT IN ('COMPLETED', 'CANCELLED')
        AND ta.date_due < CURDATE()
        AND NOT EXISTS (
            SELECT 1 FROM Notifications n
            WHERE n.user_id = ta.coordinator_id
                AND n.type = 'TASK_OVERDUE'
                AND n.created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
                AND n.message LIKE CONCAT('%', ta.task_assign_id, '%')
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `Run_Monitoring` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Run_Monitoring`()
BEGIN
        CALL Check_Events_Status();
        CALL Check_Tasks_Deadlines();
        CALL Check_Budget_And_Payments();
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_add_permission_to_role` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_permission_to_role`(
        IN `p_role_name` VARCHAR(50), 
        IN `p_permission_name` VARCHAR(100)
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
        IF NOT EXISTS (SELECT 1 FROM `Roles` WHERE `role_name` = p_role_name AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الدور غير موجود';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM `Permissions` WHERE `permission_name` = p_permission_name AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الصلاحية غير موجودة';
        END IF;
        
        
        INSERT INTO `Role_Permissions` (`role_name`, `permission_name`, `deleted_at`)
        VALUES (p_role_name, p_permission_name, NULL)
        ON DUPLICATE KEY UPDATE `deleted_at` = NULL;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'permission_added',
            'إضافة صلاحية لدور',
            CONCAT('تم إضافة الصلاحية "', p_permission_name, '" إلى دور "', p_role_name, '"')
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_add_task_rating` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_task_rating`(
        IN `p_task_assign_id` INT,
        IN `p_coordinator_id` INT,
        IN `p_rating_value` INT,
        IN `p_comment` TEXT
    )
BEGIN
        DECLARE v_event_id INT;
        DECLARE v_assigned_user_id INT;
        DECLARE v_task_status VARCHAR(20);
        
        
        SELECT ta.`event_id`, ta.`user_assign_id`, ta.`status`
            INTO v_event_id, v_assigned_user_id, v_task_status
                FROM `Task_Assigns` ta
                    WHERE ta.`task_assign_id` = p_task_assign_id
                        AND ta.`deleted_at` IS NULL;
        
        IF v_task_status IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المهمة غير موجودة';
        END IF;
        
        IF v_task_status != 'COMPLETED' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تقييم مهمة غير مكتملة';
        END IF;
        
        
        IF NOT EXISTS (
            SELECT 1 FROM `Events` e
            WHERE e.`event_id` = v_event_id 
            AND e.`coordinator_id` = p_coordinator_id
            AND e.`deleted_at` IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية تقييم هذه المهمة';
        END IF;
        
        
        
        IF EXISTS (SELECT 1 FROM `Ratings_Task_Assign` WHERE `task_assign_id` = p_task_assign_id AND `deleted_at` IS NULL) THEN
            
            UPDATE `Ratings_Task_Assign` 
            SET `rating_value` = p_rating_value,
                `rating_comment` = p_comment,
                `updated_at` = NOW()
            WHERE `task_assign_id` = p_task_assign_id;
            
            
            IF v_assigned_user_id IS NOT NULL THEN
                INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
                VALUES (
                    v_assigned_user_id,
                    'UPDATE_RATING',
                    'تعديل تقييم',
                    CONCAT('تم تعديل تقييم مهمتك ليصبح ', p_rating_value, ' نجوم.')
                );
            END IF;
        ELSE
            
            INSERT INTO `Ratings_Task_Assign` (`task_assign_id`, `coordinator_id`, `user_assign_id`, `rating_value`, `rating_comment`)
            VALUES (p_task_assign_id, p_coordinator_id, v_assigned_user_id, p_rating_value, p_comment);
            
            
            IF v_assigned_user_id IS NOT NULL THEN
                INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
                VALUES (
                    v_assigned_user_id,
                    'NEW_RATING',
                    'تقييم جديد',
                    CONCAT('تم تقييم مهمتك بـ ', p_rating_value, ' نجوم.')
                );
            END IF;
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_add_task_reminder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_task_reminder`(
        IN `p_user_id` INT,                 
        IN `p_task_assign_id` INT,
        IN `p_reminder_type` VARCHAR(255),
        IN `p_reminder_value` INT,
        IN `p_reminder_unit` VARCHAR(255)
    )
BEGIN
        DECLARE v_task_coordinator INT;
        DECLARE v_task_assignee INT;
        
        
        SELECT `coordinator_id`, `user_assign_id` INTO v_task_coordinator, v_task_assignee
        FROM `Task_Assigns` WHERE `task_assign_id` = p_task_assign_id AND `deleted_at` IS NULL;
        
        IF v_task_coordinator IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المهمة غير موجودة';
        END IF;
        
        
        IF p_user_id != v_task_coordinator AND p_user_id != v_task_assignee THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية إضافة تذكير لهذه المهمة';
        END IF;
        
        
        IF p_reminder_type IS NOT NULL AND p_reminder_type != 'none' AND p_reminder_value IS NOT NULL AND p_reminder_unit IS NOT NULL THEN
            INSERT INTO `Task_Reminders` (`task_assign_id`, `user_id`, `reminder_type`, `reminder_value`, `reminder_unit`)
            VALUES (p_task_assign_id, p_user_id, p_reminder_type, p_reminder_value, p_reminder_unit);
            
            
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (p_user_id,
                'ADD_REMINDER',
                'إضافة تذكير',
                'تم إضافة تذكير لمهمتك بنجاح.'
            );
            
            SELECT LAST_INSERT_ID() AS reminder_id;
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_admin_dashboard_stats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_admin_dashboard_stats`()
BEGIN
        SELECT 
            
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'admin' AND `deleted_at` IS NULL) as total_admins,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'coordinator' AND `deleted_at` IS NULL) as total_coordinators,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'supplier' AND `deleted_at` IS NULL) as total_suppliers,
            
            
            (SELECT COUNT(*) FROM `Users` WHERE `deleted_at` IS NULL) as total_users,
            (SELECT COUNT(*) FROM `Users` WHERE `is_active` = TRUE AND `deleted_at` IS NULL) as active_users,
            (SELECT COUNT(*) FROM `Users` WHERE `is_active` = FALSE AND `deleted_at` IS NULL) as inactive_users,
            
            
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'coordinator' AND `is_active` = TRUE AND `deleted_at` IS NULL) as active_coordinators,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'coordinator' AND `is_active` = FALSE AND `deleted_at` IS NULL) as inactive_coordinators,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'supplier' AND `is_active` = TRUE AND `deleted_at` IS NULL) as active_suppliers,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'supplier' AND `is_active` = FALSE AND `deleted_at` IS NULL) as inactive_suppliers,

            
            (SELECT COUNT(*) FROM `Services` WHERE `deleted_at` IS NULL) as total_services,
            
            
            (SELECT COUNT(*) FROM `Service_Requests` WHERE `deleted_at` IS NULL) as total_suggestions,
            (SELECT COUNT(*) FROM `Service_Requests` WHERE `status` = 'PENDING' AND `deleted_at` IS NULL) as pending_suggestions,
            (SELECT COUNT(*) FROM `Service_Requests` WHERE `status` = 'APPROVED' AND `deleted_at` IS NULL) as approved_suggestions,
            (SELECT COUNT(*) FROM `Service_Requests` WHERE `status` = 'REJECTED' AND `deleted_at` IS NULL) as rejected_suggestions;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_assign_service_to_supplier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_assign_service_to_supplier`(
        IN `p_supplier_id` INT,
        IN `p_service_id` INT
    )
BEGIN
        DECLARE v_supplier_name VARCHAR(255);
        DECLARE v_service_name VARCHAR(100);
        
        SELECT `full_name` INTO v_supplier_name FROM `Users` WHERE `user_id` = p_supplier_id;
        SELECT `service_name` INTO v_service_name FROM `Services` WHERE `service_id` = p_service_id;
        
        IF EXISTS (
            SELECT 1 FROM `Supplier_Services` 
            WHERE `supplier_id` = p_supplier_id 
            AND `service_id` = p_service_id 
            AND `deleted_at` IS NOT NULL
        ) THEN
            UPDATE `Supplier_Services` SET `deleted_at` = NULL WHERE `supplier_id` = p_supplier_id AND `service_id` = p_service_id;
        ELSE
            INSERT IGNORE INTO `Supplier_Services` (`supplier_id`, `service_id`)
                VALUES (p_supplier_id, p_service_id);
        END IF;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_supplier_id,
            'assign_service',
            'إسناد خدمة',
            CONCAT('تم إسناد الخدمة "', v_service_name, '" إليك')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'assign_service',
            'إسناد خدمة لمورد',
            CONCAT('تم إسناد الخدمة "', v_service_name, '" إلى المورد "', v_supplier_name, '" (رقم ', p_supplier_id, ')')
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_change_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_change_password`(
        IN `p_user_id` INT,
        IN `p_old_password` VARCHAR(255),
        IN `p_new_password` VARCHAR(255)
    )
BEGIN
        IF EXISTS(
            SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `password` = p_old_password
        ) THEN
            UPDATE `Users` SET `password` = p_new_password, `updated_at` = NOW()
                WHERE `user_id` = p_user_id;
                
            
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (p_user_id,
                'change_password',
                'تغيير كلمة المرور',
                CONCAT('تم تغيير كلمة المرور الخاصة بحسابك بتاريخ ', NOW())
            );
            
            
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (1,
                'change_password',
                'تغيير كلمة مرور',
                CONCAT('قام المستخدم رقم ', p_user_id, ' بتغيير كلمة المرور الخاصة به')
            );

            CALL sp_get_user_by_id(p_user_id);
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'كلمة المرور القديمة غير صحيحة.';
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_client` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_client`(
        IN `p_coordinator_id` INT,
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_address` TEXT,
        IN `p_with_out` BOOLEAN
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN 
        DECLARE v_creator_user_role VARCHAR(50);
        DECLARE v_creator_name VARCHAR(255);
        DECLARE v_creator_email VARCHAR(255);
        DECLARE v_client_id INT;
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        SELECT `role_name`, `full_name`, `email`
        INTO v_creator_user_role, v_creator_name, v_creator_email
        FROM `Users` 
        WHERE `user_id` = p_coordinator_id 
        AND `role_name` IN ('coordinator', 'admin')
        AND `deleted_at` IS NULL; 
        
        IF v_creator_user_role IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن إنشاء العميل إلا عن طريق حساب منسق أو مدير';
        END IF;
        
        
        IF EXISTS(
            SELECT 1 FROM `Clients` 
            WHERE `coordinator_id` = p_coordinator_id 
            AND (`email` = p_email OR `phone_number` = p_phone_number)
            AND `deleted_at` IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا العميل موجود مسبقا لهذا المنسق';
        END IF;
        
        
        START TRANSACTION;
        
        INSERT INTO `Clients`(`coordinator_id`, `creator_user_role`, `full_name`, `phone_number`, `img_url`, `email`, `address`)
        VALUES (p_coordinator_id, v_creator_user_role, p_full_name, p_phone_number, p_img_url, p_email, p_address);
        SET v_client_id = LAST_INSERT_ID();
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_coordinator_id,
            'create_client', 
            'عميل جديد', 
            CONCAT(
                'لقد قمت بإضافة عميل جديد\n', 
                'رقم العميل: ', v_client_id, '\n',
                'إسم العميل: ', p_full_name, '\n',
                'رقم هاتفه: ', p_phone_number, '\n',
                IF(p_email IS NULL OR p_email = '', '', CONCAT('البريد: ', p_email, '\n')),
                IF(p_address IS NULL OR p_address = '', '', CONCAT('العنوان: ', p_address))
            )
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'create_client', 
            'عميل جديد', 
            CONCAT(
                'لقد قام ', IF(v_creator_user_role = 'admin', 'المدير ', 'المنسق '),
                v_creator_name, ' "', v_creator_email, '" بإضافة عميل جديد\n\n',
                'رقم العميل: ', v_client_id, '\n',
                'إسم العميل: ', p_full_name, '\n',
                'رقم هاتفه: ', p_phone_number, '\n',
                IF(p_email IS NULL OR p_email = '', '', CONCAT('البريد: ', p_email, '\n')),
                IF(p_address IS NULL OR p_address = '', '', CONCAT('العنوان: ', p_address))
            )
        );
        
        COMMIT;
        IF p_with_out THEN SELECT * FROM `Clients` WHERE `client_id` = v_client_id; END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_coordinator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_coordinator`(
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_is_active` BOOLEAN,
        IN `p_email` VARCHAR(255),
        IN `p_password` VARCHAR(255),
        IN `p_with_out` BOOLEAN
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN 
        DECLARE v_user_id INT;
        DECLARE v_user_creator_email VARCHAR(255);
        DECLARE v_user_creator_pass VARCHAR(255);
        SELECT `email`, `password` INTO v_user_creator_email, v_user_creator_pass 
        FROM `Users` WHERE `user_id` = 1 AND `deleted_at` IS NULL;
        
        CALL sp_create_user(
            v_user_creator_email, v_user_creator_pass, 'coordinator', p_full_name,
            p_phone_number, p_is_active, p_img_url, p_email, p_password, '{}', v_user_id, p_with_out
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_event` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_event`(
        IN `p_client_id` INT,
        IN `p_coordinator_id` INT,
        IN `p_event_name` VARCHAR(255),
        IN `p_description` TEXT,
        IN `p_img_url` TEXT,
        IN `p_event_date` DATE,
        IN `p_location` VARCHAR(255),
        IN `p_budget` DECIMAL(10,2),
        IN `p_event_duration` INT,
        IN `p_event_duration_unit` ENUM('DAY', 'WEEK', 'MONTH')
    )
BEGIN
        
        IF NOT EXISTS (SELECT 1 FROM `Clients` WHERE `client_id` = p_client_id AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'العميل غير موجود';
        END IF;
        IF NOT fn_user_has_role(p_coordinator_id, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'يجب أن يكون المنسق من دور coordinator';
        END IF;
        
        
        
        INSERT INTO `Events` (
            `client_id`, `coordinator_id`, `event_name`, `description`, `img_url`, 
            `event_date`, `location`, `budget`, `event_duration`, `event_duration_unit`
        ) VALUES (
            p_client_id, p_coordinator_id, p_event_name, p_description, p_img_url,
            p_event_date, p_location, p_budget, p_event_duration, p_event_duration_unit
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (1, 'create_event', 'حدث جديد', CONCAT('تم إنشاء حدث جديد "', p_event_name, '" بواسطة المنسق ', p_coordinator_id));
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (p_coordinator_id, 'create_event', 'حدث جديد', CONCAT('لقد قمت بإنشاء حدث جديد "', p_event_name, '"'));
        
        SELECT * FROM `vw_events_detailed` WHERE `event_id` = LAST_INSERT_ID();
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_income` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_income`(
        IN `p_event_id` INT,
        IN `p_amount` DECIMAL(10,2),
        IN `p_description` TEXT,
        IN `p_payment_date` DATE,
        IN `p_payment_method` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        IN `p_url_image` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        IN `with_out` BOOLEAN
    )
BEGIN
        DECLARE v_coordinator_id INT;
        DECLARE v_event_name VARCHAR(255);
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        SELECT `coordinator_id`, `event_name` INTO v_coordinator_id, v_event_name
        FROM `Events` WHERE `event_id` = p_event_id;

        INSERT INTO `Incomes` (`event_id`, `amount`, `description`, `payment_date`, `payment_method`, `url_image`)
            VALUES (p_event_id, p_amount, p_description, p_payment_date, p_payment_method, p_url_image);
            
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (v_coordinator_id, 'create_income', 'دفعة جديدة', CONCAT('تم إنشاء دفعة جديدة بقيمة ', p_amount, ' للحدث "', v_event_name, '"'));
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (1, 'create_income', 'دفعة جديدة', CONCAT('تم إنشاء دفعة جديدة بقيمة ', p_amount, ' للحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id));

        IF with_out = TRUE THEN
            SELECT * FROM `Incomes` WHERE `income_id` = LAST_INSERT_ID();
        END IF;
        
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_income_from_json` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_income_from_json`(
        IN `p_event_id` INT,
        IN `p_income_json` JSON
    )
BEGIN
        CALL sp_create_income(
            p_event_id, 
            JSON_UNQUOTE(JSON_EXTRACT(p_income_json, '$.amount')),
            JSON_UNQUOTE(JSON_EXTRACT(p_income_json, '$.description')),
            JSON_UNQUOTE(JSON_EXTRACT(p_income_json, '$.payment_date')), 
            JSON_UNQUOTE(JSON_EXTRACT(p_income_json, '$.payment_method')), 
            JSON_UNQUOTE(JSON_EXTRACT(p_income_json, '$.url_image')), 
            FALSE
        );
       
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_service` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_service`(IN `p_user_creator_email` VARCHAR(255), IN `p_user_creator_pass` VARCHAR(255), IN `p_service_name` VARCHAR(100), IN `p_description` TEXT, IN `p_with_out` TINYINT)
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN 
        DECLARE v_service_id INT;
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        
        IF p_user_creator_email IS NOT NULL AND p_user_creator_pass IS NOT NULL THEN
            CALL sp_throw_if_account_not_admin(p_user_creator_email, p_user_creator_pass, 'admin');
        END IF;
        
        START TRANSACTION;

        INSERT INTO `Services` (`service_name`, `description`) 
            VALUES (p_service_name, p_description);
        SET v_service_id = LAST_INSERT_ID();
        

        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'create_service', 
            'خدمة جديدة', 
            CONCAT(
                'لقد قام المدير "', COALESCE(p_user_creator_email, 'admin'), '" بإضافة خدمة جديدة\n' , 
                'رقم الخدمة: ', v_service_id, '\n',
                'إسم الخدمة: ', p_service_name, '\n',
                'الوصف: ', COALESCE(p_description, 'لا يوجد وصف')
            )
        );
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        	SELECT `user_id`, 'create_service', 'إضافة خدمة جديدة', CONCAT('تم إضافة خدمة جديدة بالنظام: "', p_service_name, '"') 
        FROM `Users` WHERE `deleted_at` IS NULL AND `user_id` != 1;

        IF p_with_out IS NULL OR p_with_out = TRUE THEN
            SELECT * FROM `Services` WHERE `service_id` = v_service_id;
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_supplier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_supplier`(
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_is_active` BOOLEAN,
        IN `p_email` VARCHAR(255),
        IN `p_password` VARCHAR(255),
        IN `p_address` TEXT,
        IN `p_notes` TEXT,
        IN `p_services` JSON,
        IN `p_with_out` BOOLEAN
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN 
        DECLARE v_user_id INT;
        DECLARE v_service_id INT;
        DECLARE v_user_creator_email VARCHAR(255);
        DECLARE v_user_creator_pass VARCHAR(255);
        DECLARE v_total INT DEFAULT 0;
        DECLARE v_i INT DEFAULT 0;
        DECLARE v_details JSON;
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

        SELECT `email`, `password` INTO v_user_creator_email, v_user_creator_pass 
        FROM `Users` WHERE `user_id` = 1 AND `deleted_at` IS NULL;
        
        
        SET v_details = JSON_OBJECT();
        IF p_address IS NOT NULL THEN
            SET v_details = JSON_SET(v_details, '$.address', p_address);
        END IF;
        IF p_notes IS NOT NULL THEN
            SET v_details = JSON_SET(v_details, '$.notes', p_notes);
        END IF;
        
        START TRANSACTION;

        CALL sp_create_user(
            v_user_creator_email, v_user_creator_pass, 'supplier', p_full_name,
            p_phone_number, p_is_active, p_img_url, p_email, p_password, v_details, v_user_id, p_with_out
        );

        IF p_services IS NOT NULL THEN
            SET v_total = JSON_LENGTH(p_services);
            
            WHILE v_i < v_total DO
                SET v_service_id = JSON_UNQUOTE(JSON_EXTRACT(p_services, CONCAT('$[', v_i, ']')));
                IF v_service_id IS NOT NULL THEN 
                    INSERT INTO `Supplier_Services` (`supplier_id`, `service_id`) VALUES (v_user_id, v_service_id);
                END IF;
                SET v_i = v_i + 1;
            END WHILE; 
        END IF;
        COMMIT;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_task` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_task`(
        IN `p_event_id` INT,
        IN `p_service_id` INT,
        IN `p_type_task` VARCHAR(255),
        IN `p_status` VARCHAR(20),
        IN `p_date_start` DATE,
        IN `p_date_due` DATE,
        IN `p_user_assign_id` INT,
        IN `p_description` TEXT,
        IN `p_cost` DECIMAL(10,2),
        INOUT `p_task_assign_id` INT
    )
BEGIN 
        DECLARE v_coordinator_id INT;
        DECLARE v_coordinator_name VARCHAR(255);
        DECLARE v_coordinator_phone VARCHAR(20);
        DECLARE v_coordinator_email VARCHAR(255);
        DECLARE v_event_name VARCHAR(255);
        DECLARE v_assign_name VARCHAR(255);
        DECLARE v_assign_email VARCHAR(255);
        DECLARE v_budget DECIMAL(10,2);
        DECLARE v_total_expenses DECIMAL(10,2);

        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

        
        SELECT `coordinator_id`, `coordinator_name`, `coordinator_phone`, `coordinator_email`, `event_name`,
                `budget`, `total_expenses`
            INTO v_coordinator_id, v_coordinator_name, v_coordinator_phone, v_coordinator_email, v_event_name,
                    v_budget, v_total_expenses 
        FROM `vw_events_detailed` 
        WHERE `event_id` = p_event_id AND `deleted_at` IS NULL;

        
        SELECT `full_name`, `email` INTO v_assign_name, v_assign_email 
        FROM `Users` WHERE `user_id` = p_user_assign_id AND `deleted_at` IS NULL;

        
        IF p_user_assign_id IS NOT NULL AND NOT (fn_user_has_role(p_user_assign_id, 'coordinator') OR fn_user_has_role(p_user_assign_id, 'supplier')) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن إسناد المهام إلا لموردين أو منسقين';
        END IF;
        IF v_coordinator_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الحدث غير موجود أو لا يملك منسق';
        END IF;
        IF v_assign_email IS NULL AND p_user_assign_id IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المستخدم المكلف غير موجود';
        END IF;

        
        IF p_user_assign_id = v_coordinator_id THEN 
        	SET p_service_id = NULL; 
            SET p_user_assign_id = NULL; 
        END IF;
        INSERT INTO `Task_Assigns` (
            `event_id`, `service_id`, `coordinator_id`, `type_task`, `status`,
            `date_start`, `date_due`, `user_assign_id`, `description`,
            `cost`
            ) VALUES (
                p_event_id, p_service_id, v_coordinator_id, p_type_task, IFNULL(p_status, 'PENDING'),
                p_date_start, p_date_due, p_user_assign_id, p_description,
                p_cost
            );
            SET p_task_assign_id = LAST_INSERT_ID();

        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (1,
                'create_task_assign', 
                'مهمة جديدة', 
                CONCAT(
                    'لقد قام المنسق ', v_coordinator_name, ' "', v_coordinator_email, '" بإسناد مهمة جديدة ',
                    IF(p_user_assign_id = v_coordinator_id, 'لنفسه\n', CONCAT('للمورد ', v_assign_name, ' "', v_assign_email, '"\n')),
                    'في مناسبة ', v_event_name, '\n',
                    'نوع المهمة: ', p_type_task, 
                    IF(p_service_id IS NULL, '', 
                        CONCAT(' في خدمة "', (SELECT IFNULL( `service_name`, '') FROM `Services` WHERE `service_id` = p_service_id), '"')
                    )
                )
            );

        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (v_coordinator_id,
                'create_task_assign', 
                'مهمة جديدة', 
                CONCAT(
                    'لقد قمت بإسناد مهمة جديدة ',
                    IF(p_user_assign_id = v_coordinator_id, 'لنفسك\n', CONCAT('للمورد ', v_assign_name, ' "', v_assign_email, '"\n')),
                    'في مناسبة ', v_event_name, '\n',
                    'نوع المهمة: ', p_type_task,
                    IF(p_service_id IS NULL, '', 
                        CONCAT(' في خدمة "', (SELECT IFNULL( `service_name`, '') FROM `Services` WHERE `service_id` = p_service_id), '"')
                    )
                )
            );

        
        IF p_user_assign_id IS NOT NULL AND p_user_assign_id != v_coordinator_id THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
                VALUES (p_user_assign_id,
                    'create_task_assign', 
                    'مهمة جديدة', 
                    CONCAT(
                        'تم تعيينك لمهمة جديدة من قبل المنسق ', v_coordinator_name, ' "', v_coordinator_email, '"\n',
                        'في مناسبة ', v_event_name, '\n',
                        'نوع المهمة: ', p_type_task,
                        IF(p_service_id IS NULL, '', 
                        CONCAT(' في خدمة "', (SELECT IFNULL( `service_name`, '') FROM `Services` WHERE `service_id` = p_service_id), '"')
                    )
                    )
                );
        END IF;

        
        IF v_total_expenses + p_cost > v_budget THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
                VALUES (v_coordinator_id,
                    'alert', 
                    'ميزانية تجاوزت الحد', 
                    CONCAT('تجاوزت مصروفات ', v_event_name, ' الميزانية المحددة')
                );
        END IF;
        SELECT p_task_assign_id as task_assign_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_task_from_json` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_task_from_json`(
        IN `p_event_id` INT,
        IN `p_task_json` JSON,
        INOUT `p_task_assign_id` INT
    )
BEGIN 
        CALL sp_create_task(
            p_event_id, 
            JSON_UNQUOTE(JSON_EXTRACT(p_task_json, '$.service_id')),
            JSON_UNQUOTE(JSON_EXTRACT(p_task_json, '$.type_task')),
            IFNULL(JSON_UNQUOTE(JSON_EXTRACT(p_task_json, '$.status')), 'PENDING'),
            JSON_UNQUOTE(JSON_EXTRACT(p_task_json, '$.date_start')), 
            JSON_UNQUOTE(JSON_EXTRACT(p_task_json, '$.date_due')), 
            JSON_UNQUOTE(JSON_EXTRACT(p_task_json, '$.user_assign_id')), 
            JSON_UNQUOTE(JSON_EXTRACT(p_task_json, '$.description')),
            IFNULL(JSON_UNQUOTE(JSON_EXTRACT(p_task_json, '$.cost')), 0), 
            p_task_assign_id
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_user`(
        IN `p_user_creator_email` VARCHAR(255),
        IN `p_user_creator_pass` VARCHAR(255),
        IN `p_role_name` VARCHAR(50),
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_is_active` BOOLEAN,
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_password` VARCHAR(255),
        IN `p_details` JSON,
        OUT `p_user_id` INT,
        IN `p_with_out` BOOLEAN
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN 
        DECLARE v_detail_name VARCHAR(255);
        DECLARE v_detail_value TEXT;
        DECLARE v_i INT DEFAULT 0;
        DECLARE v_keys JSON;
        DECLARE v_total INT DEFAULT 0;
        DECLARE v_error_msg TEXT;
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        
        CALL sp_throw_if_account_not_admin(p_user_creator_email, p_user_creator_pass, p_role_name);
        
        START TRANSACTION;
        
        
        IF EXISTS(SELECT 1 FROM `Users` WHERE `email` = p_email AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا البريد موجود مسبقا';
        END IF;
        IF EXISTS(SELECT 1 FROM `Users` WHERE `phone_number` = p_phone_number AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا الهاتف موجود مسبقا';
        END IF;
        
        
        INSERT INTO `Users` (`role_name`, `full_name`, `phone_number`, `is_active`, `img_url`, `email`, `password`)
        VALUES (p_role_name, p_full_name, p_phone_number, p_is_active, p_img_url, p_email, p_password);
        SET p_user_id = LAST_INSERT_ID();
        
        
        IF p_details IS NOT NULL AND JSON_VALID(p_details) THEN
            SET v_keys = JSON_KEYS(p_details);
            SET v_total = JSON_LENGTH(v_keys);
            
            WHILE v_i < v_total DO
                SET v_detail_name = JSON_UNQUOTE(JSON_EXTRACT(v_keys, CONCAT('$[', v_i, ']')));
                SET v_detail_value = JSON_UNQUOTE(JSON_EXTRACT(p_details, CONCAT('$.', v_detail_name)));
                
                IF NOT fun_role_has_detail(v_detail_name, p_role_name) THEN  
                    SET v_error_msg = CONCAT('الحقل "', v_detail_name, ' => ', v_detail_value, '" غير مسموح به في دور هذا الحساب');
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
                END IF;
                
                INSERT INTO `User_Detail_Values` (`user_id`, `detail_name`, `detail_value`)
                    VALUES (p_user_id, v_detail_name, v_detail_value)
                    ON DUPLICATE KEY UPDATE
                    `user_id` = VALUES(`user_id`),
                    `detail_name` = VALUES(`detail_name`),
                    `detail_value` = VALUES(`detail_value`);
                SET v_i = v_i + 1;
            END WHILE;
        END IF;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            CONCAT('create_', p_role_name, '_user'), 
            CONCAT('إشتراك ', 
                CASE p_role_name
                    WHEN 'coordinator' THEN 'منسق'
                    WHEN 'supplier' THEN 'مورد'
                    ELSE p_role_name
                END, 
                ' جديد'
            ), 
            CONCAT(
                'تمت عملية إشتراك بحساب ', 
                CASE p_role_name
                    WHEN 'coordinator' THEN 'منسق'
                    WHEN 'supplier' THEN 'مورد'
                    ELSE p_role_name
                END, 
                ' جديد\n',
                'رقم الحساب: ', p_user_id, '\n',
                'الإسم: ', p_full_name, '\n',
                'رقم الهاتف: ', p_phone_number, '\n',
                'البريد: ', p_email, 
                IF(p_is_active, '', '\nيرجى الموافقة عليه لتفعيله')
            )
        );
        
        COMMIT;
        IF p_with_out THEN CALL sp_get_user_by_id(p_user_id); END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_all_events_of_coordinator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_all_events_of_coordinator`(IN `p_coordinator_id` INT)
BEGIN
        DECLARE v_event_id INT;
        DECLARE v_done INT DEFAULT FALSE;

        DECLARE events_cursor CURSOR FOR
            SELECT  `event_id` FROM `Events`
                WHERE `coordinator_id` = p_coordinator_id AND `deleted_at` IS NULL;
    
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

        OPEN events_cursor;
        
            events_loop: LOOP
                FETCH events_cursor INTO v_event_id;
                IF v_done THEN LEAVE events_loop; END IF;
                CALL sp_delete_event(v_event_id); 
            END LOOP events_loop;
        
        CLOSE events_cursor;   
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_all_incomes_of_event` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_all_incomes_of_event`(IN `p_event_id` INT)
BEGIN
        DECLARE v_income_id INT;
        DECLARE v_done INT DEFAULT FALSE;

        DECLARE incomes_cursor CURSOR FOR
            SELECT  `income_id` FROM `Incomes`
                WHERE `event_id` = p_event_id AND `deleted_at` IS NULL;
    
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

        OPEN incomes_cursor;
            incomes_loop: LOOP
                FETCH incomes_cursor INTO v_income_id;
                IF v_done THEN LEAVE incomes_loop; END IF;
                CALL sp_delete_income(v_income_id); 
            END LOOP incomes_loop;
        
        CLOSE incomes_cursor;   
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_all_ratings_of_task` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_all_ratings_of_task`(IN `p_task_assign_id` INT)
BEGIN
        DECLARE v_rating_id INT;
        DECLARE v_done INT DEFAULT FALSE;

        DECLARE ratings_cursor CURSOR FOR
            SELECT  `rating_id` FROM `Ratings_Task_Assign`
                WHERE `task_assign_id` = p_task_assign_id AND `deleted_at` IS NULL;
    
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

        OPEN ratings_cursor;
        
            ratings_loop: LOOP
                FETCH ratings_cursor INTO v_rating_id;
                IF v_done THEN LEAVE ratings_loop; END IF;
                CALL sp_delete_task_rating(v_rating_id); 
            END LOOP ratings_loop;
        
        CLOSE ratings_cursor;   
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_all_reminders_of_task` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_all_reminders_of_task`(IN `p_task_assign_id` INT)
BEGIN
        DECLARE v_reminder_id INT;
        DECLARE v_user_id INT;
        DECLARE v_done INT DEFAULT FALSE;

        DECLARE reminders_cursor CURSOR FOR
            SELECT  `reminder_id`, `user_id` FROM `Task_Reminders`
                WHERE `task_assign_id` = p_task_assign_id AND `deleted_at` IS NULL;
    
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

        OPEN reminders_cursor;
        
            reminders_loop: LOOP
                FETCH reminders_cursor INTO v_reminder_id, v_user_id;
                IF v_done THEN LEAVE reminders_loop; END IF;
                CALL sp_delete_task_reminder(v_reminder_id, v_user_id); 
            END LOOP reminders_loop;
        
        CLOSE reminders_cursor;   
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_all_tasks_of_event` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_all_tasks_of_event`(IN `p_event_id` INT)
BEGIN
        DECLARE v_task_assign_id INT;
        DECLARE v_done INT DEFAULT FALSE;

        DECLARE tasks_cursor CURSOR FOR
            SELECT  `task_assign_id` FROM `Task_Assigns`
                WHERE `event_id` = p_event_id AND `deleted_at` IS NULL;
    
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

        OPEN tasks_cursor;
        
            tasks_loop: LOOP
                FETCH tasks_cursor INTO v_task_assign_id;
                IF v_done THEN LEAVE tasks_loop; END IF;
                CALL sp_delete_task(v_task_assign_id); 
            END LOOP tasks_loop;
        
        CLOSE tasks_cursor;   
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_event` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_event`(IN `p_event_id` INT)
BEGIN
        DECLARE v_coordinator_id INT;
        DECLARE v_event_name VARCHAR(255);
        
        SELECT `coordinator_id`, `event_name` INTO v_coordinator_id, v_event_name
            FROM `Events` WHERE `event_id` = p_event_id;
        
        UPDATE `Events` SET `deleted_at` = NOW() WHERE `event_id` = p_event_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (v_coordinator_id,
                'delete_event',
                'حذف حدث',
                CONCAT('تم حذف الحدث "', v_event_name, '" (رقم ', p_event_id, ')')
            );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (1,
                'delete_event',
                'حذف حدث',
                CONCAT('تم حذف الحدث "', v_event_name, '" (رقم ', p_event_id, ') بواسطة المنسق رقم ', v_coordinator_id)
            );
        
        UPDATE `Task_Assigns` SET `deleted_at` = NOW() WHERE `event_id` = p_event_id;
        UPDATE `Incomes` SET `deleted_at` = NOW() WHERE `event_id` = p_event_id;

        
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_fcm_token` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_fcm_token`(
    IN `p_user_id` INT,
    IN `p_token` TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    
    DELETE FROM `User_FCM_Tokens` 
    WHERE `user_id` = `p_user_id` AND `token` = `p_token`;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_income` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_income`(IN `p_income_id` INT)
BEGIN
        DECLARE v_event_id INT;
        DECLARE v_coordinator_id INT;
        DECLARE v_event_name VARCHAR(255);
        
        SELECT e.`event_id`, e.`coordinator_id`, e.`event_name` 
        INTO v_event_id, v_coordinator_id, v_event_name
        FROM `Incomes` i JOIN `Events` e ON i.`event_id` = e.`event_id`
        WHERE i.`income_id` = p_income_id;
        
        UPDATE `Incomes` SET `deleted_at` = CURRENT_TIMESTAMP WHERE `income_id` = p_income_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (v_coordinator_id,
            'delete_income',
            'حذف دفعة',
            CONCAT('تم حذف الدفعة رقم ', p_income_id, ' للحدث "', v_event_name, '"')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'delete_income',
            'حذف دفعة',
            CONCAT('تم حذف الدفعة رقم ', p_income_id, ' للحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id)
        );
        
        SELECT p_income_id AS income_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_service` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_service`(IN `p_service_id` INT)
BEGIN
        DECLARE v_service_name VARCHAR(100);
        SELECT `service_name` INTO v_service_name FROM `Services` WHERE `service_id` = p_service_id;
        
        UPDATE `Services` SET `deleted_at` = CURRENT_TIMESTAMP WHERE `service_id` = p_service_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'delete_service',
            'حذف خدمة',
            CONCAT('تم حذف الخدمة "', v_service_name, '" (رقم ', p_service_id, ')')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        SELECT `user_id`, 'delete_service', 'حذف خدمة', CONCAT('تم إزالة الخدمة من النظام: "', v_service_name, '"') 
        FROM `Users` WHERE `deleted_at` IS NULL AND `user_id` != 1;
        
        SELECT p_service_id AS service_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_task` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_task`(IN `p_task_assign_id` INT)
BEGIN
        DECLARE v_user_assign_id INT;
        DECLARE v_coordinator_id INT;
        DECLARE v_event_name VARCHAR(255);
        
        SELECT ta.`user_assign_id`, ta.`coordinator_id`, e.`event_name`
            INTO v_user_assign_id, v_coordinator_id, v_event_name
                FROM `Task_Assigns` ta JOIN `Events` e ON ta.`event_id` = e.`event_id`
                    WHERE ta.`task_assign_id` = p_task_assign_id;
        
        UPDATE `Task_Assigns` SET 
                `deleted_at` = CURRENT_TIMESTAMP,
                `status` = 'CANCELLED' 
                WHERE `task_assign_id` = p_task_assign_id;
        
        
        IF v_user_assign_id IS NOT NULL THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (v_user_assign_id,
                'delete_task',
                'حذف مهمة',
                CONCAT('تم حذف المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '"')
            );
        END IF;
        
        IF v_coordinator_id != v_user_assign_id THEN
            
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
                VALUES (v_coordinator_id,
                    'delete_task',
                    'حذف مهمة',
                    CONCAT('تم حذف المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '"')
                );
        END IF;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'delete_task',
            'حذف مهمة',
            CONCAT('تم حذف المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id)
        );
        
        CALL sp_delete_all_reminders_of_task(p_task_assign_id);
        CALL sp_delete_all_ratings_of_task(p_task_assign_id);
        
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_task_rating` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_task_rating`(
        IN `p_rating_id` INT
    )
BEGIN
        DECLARE v_assigned_user_id INT;
        DECLARE v_rating_value INT;
        
        
        SELECT r.rating_value, t.user_assign_id INTO v_rating_value, v_assigned_user_id
        FROM `Ratings_Task_Assign` r
        JOIN `Task_Assigns` t ON r.task_assign_id = t.task_assign_id
        WHERE r.rating_id = p_rating_id;
        
        UPDATE `Ratings_Task_Assign` SET deleted_at = NOW() WHERE `rating_id` = p_rating_id;
        
        
        IF v_assigned_user_id IS NOT NULL THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (v_assigned_user_id,
                'DELETE_RATING',
                'حذف تقييم',
                CONCAT('تم حذف تقييم مهمتك بـ ', v_rating_value, ' نجوم.')
            );
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_task_reminder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_task_reminder`(
        IN `p_user_id` INT,
        IN `p_reminder_id` INT
    )
BEGIN
        DECLARE v_reminder_user INT;
        
        SELECT `user_id` INTO v_reminder_user FROM `Task_Reminders` WHERE `reminder_id` = p_reminder_id AND `deleted_at` IS NULL;
        
        IF v_reminder_user IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'التذكير غير موجود';
        END IF;
        
        IF p_user_id != v_reminder_user AND NOT fn_user_has_role(p_user_id, 'admin') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية حذف هذا التذكير';
        END IF;
        
        UPDATE `Task_Reminders` SET `deleted_at` = NOW() WHERE `reminder_id` = p_reminder_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (v_reminder_user,
            'DELETE_REMINDER',
            'حذف تذكير',
            'تم حذف تذكير المهمة الخاص بك بنجاح.'
        );
        
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_user`(IN `p_user_id` INT)
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
        DECLARE v_user_email VARCHAR(255);
        DECLARE v_user_name VARCHAR(255);
        DECLARE v_role_name VARCHAR(50);
        
        SELECT `email`, `full_name`, `role_name` INTO v_user_email, v_user_name, v_role_name
            FROM `Users` WHERE `user_id` = p_user_id;
        
        IF NOT EXISTS (SELECT 1 FROM `Users` WHERE `user_id` = p_user_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'حساب غير موجود';
        END IF;
        IF fn_user_is_deleted(p_user_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا الحساب محذوف بالفعل';
        END IF;
        
        UPDATE `Users` SET `deleted_at` = NOW() WHERE `user_id` = p_user_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'delete_user',
            'حذف حساب',
            CONCAT('تم حذف حساب المستخدم: ', v_user_name, ' (', v_user_email, ') - الدور: ', v_role_name)
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_user_id,
            'delete_user',
            'تم حذف حسابك',
            CONCAT('تم حذف حسابك بتاريخ ', NOW(), '. إذا كان هذا خطأ، يرجى التواصل مع المدير.')
        );
        
        
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_events_detailed` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_events_detailed`(
        IN `p_coordinator_id` INT
    )
BEGIN 
        SELECT 
            e.*,
            (e.`deleted_at` IS NOT NULL) AS `is_deleted`,
            fn_event_get_status(e.`event_id`) AS `status`,
            c.`full_name` AS `client_name`,
            c.`phone_number` AS `client_phone`,
            c.`email` AS `client_email`,
            c.`img_url` AS `client_img`,

            co.`full_name` AS `coordinator_name`,
            co.`phone_number` AS `coordinator_phone`,
            co.`email` AS `coordinator_email`,

            COALESCE((SELECT SUM(inc.`amount`) FROM `Incomes` inc WHERE inc.`event_id` = e.`event_id` AND inc.`deleted_at` IS NULL), 0) AS `total_income`,
            COALESCE((SELECT SUM(ta.`cost`) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`deleted_at` IS NULL), 0) AS `total_expenses`,
            (SELECT COUNT(*) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`coordinator_id` = p_coordinator_id AND ta.`deleted_at` IS NULL) AS `total_tasks`,
            (SELECT COUNT(*) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`coordinator_id` = p_coordinator_id AND ta.`status` = 'COMPLETED' AND ta.`deleted_at` IS NULL) AS `completed_tasks`,
            CONCAT(
                ROUND(
                    100 * (SELECT COUNT(*) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`status` = 'COMPLETED' AND ta.`deleted_at` IS NULL) 
                    / NULLIF((SELECT COUNT(*) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`deleted_at` IS NULL), 0), 
                2), '%'
            ) AS `completion_percentage`
        FROM `Events` e
        LEFT JOIN `Users` co ON e.`coordinator_id` = co.`user_id`
        LEFT JOIN `Clients` c ON e.`client_id` = c.`client_id`
        WHERE e.`coordinator_id` = p_coordinator_id AND c.`coordinator_id` = p_coordinator_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_generate_task_reminders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_generate_task_reminders`()
    MODIFIES SQL DATA
    COMMENT 'يقوم بإنشاء تذكيرات للمهام بناءً على إعدادات التذكير في جدول Task_Reminders'
BEGIN
        DECLARE v_reminder_id INT;
        DECLARE v_task_assign_id INT;
        DECLARE v_user_id INT;
        DECLARE v_event_id INT;
        DECLARE v_event_name VARCHAR(255);
        DECLARE v_date_due DATE;
        DECLARE v_reminder_type ENUM('INTERVAL', 'BEFORE_DUE');
        DECLARE v_reminder_value INT;
        DECLARE v_reminder_unit ENUM('MINUTE', 'HOUR', 'DAY');
        DECLARE v_reminder_datetime DATETIME;
        DECLARE v_title VARCHAR(255);
        DECLARE v_message TEXT;
        DECLARE v_done BOOLEAN DEFAULT FALSE;
        
        
        DECLARE reminder_cursor CURSOR FOR
            SELECT 
                r.`reminder_id`,
                r.`task_assign_id`,
                r.`user_id`,
                ta.`event_id`,
                e.`event_name`,
                ta.`date_due`,
                r.`reminder_type`,
                r.`reminder_value`,
                r.`reminder_unit`
            FROM `Task_Reminders` r
            INNER JOIN `Task_Assigns` ta ON r.`task_assign_id` = ta.`task_assign_id`
            INNER JOIN `Events` e ON ta.`event_id` = e.`event_id`
            WHERE r.`is_active` = TRUE
            AND r.`deleted_at` IS NULL
            AND ta.`status` NOT IN ('COMPLETED', 'CANCELLED')
            AND ta.`deleted_at` IS NULL
            AND e.`deleted_at` IS NULL
            AND ta.`date_due` IS NOT NULL;
        
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
        
        OPEN reminder_cursor;
        
        reminder_loop: LOOP
            FETCH reminder_cursor INTO v_reminder_id, v_task_assign_id, v_user_id, v_event_id, v_event_name, 
                                    v_date_due, v_reminder_type, v_reminder_value, v_reminder_unit;
            
            IF v_done THEN LEAVE reminder_loop; END IF;
            
            
            IF v_reminder_type = 'BEFORE_DUE' THEN
                SET v_reminder_datetime = CASE v_reminder_unit
                    WHEN 'MINUTE' THEN DATE_SUB(CONCAT(v_date_due, ' 00:00:00'), INTERVAL v_reminder_value MINUTE)
                    WHEN 'HOUR' THEN DATE_SUB(CONCAT(v_date_due, ' 00:00:00'), INTERVAL v_reminder_value HOUR)
                    WHEN 'DAY' THEN DATE_SUB(v_date_due, INTERVAL v_reminder_value DAY)
                END;
            ELSE 
                SET v_reminder_datetime = CASE v_reminder_unit
                    WHEN 'MINUTE' THEN DATE_SUB(NOW(), INTERVAL v_reminder_value MINUTE)
                    WHEN 'HOUR' THEN DATE_SUB(NOW(), INTERVAL v_reminder_value HOUR)
                    WHEN 'DAY' THEN DATE_SUB(NOW(), INTERVAL v_reminder_value DAY)
                END;
            END IF;
            
            SET v_title = CONCAT('تذكير بالمهمة #', v_task_assign_id);
            SET v_message = CONCAT(
                'المهمة: ', 
                IFNULL((SELECT `description` FROM `Task_Assigns` WHERE `task_assign_id` = v_task_assign_id), 'غير محددة'),
                '\nالحدث: ', v_event_name,
                '\nتاريخ الاستحقاق: ', DATE_FORMAT(v_date_due, '%Y-%m-%d'),
                '\nنوع التذكير: ', IF(v_reminder_type = 'BEFORE_DUE', 'قبل الموعد', 'دوري'),
                '\nتم التذكير في: ', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
            );
            
            
            IF v_reminder_type = 'BEFORE_DUE' THEN
                INSERT INTO `Notifications` (
                    `user_id`, 
                    `type`, 
                    `title`, 
                    `message`, 
                    `created_at`
                )
                SELECT 
                    v_user_id,
                    'TASK_REMINDER_BEFORE_DUE',
                    v_title,
                    v_message,
                    NOW()
                WHERE NOT EXISTS (
                    SELECT 1 FROM `Notifications` n
                    WHERE n.`user_id` = v_user_id
                        AND n.`type` = 'TASK_REMINDER_BEFORE_DUE'
                        AND n.`title` = v_title
                        AND DATE(n.`created_at`) = CURDATE()
                )
                AND NOW() >= v_reminder_datetime;
            ELSE
                INSERT INTO `Notifications` (
                    `user_id`, 
                    `type`, 
                    `title`, 
                    `message`, 
                    `created_at`
                )
                SELECT 
                    v_user_id,
                    'TASK_REMINDER_INTERVAL',
                    v_title,
                    v_message,
                    NOW()
                WHERE NOT EXISTS (
                    SELECT 1 FROM `Notifications` n
                    WHERE n.`user_id` = v_user_id
                        AND n.`type` = 'TASK_REMINDER_INTERVAL'
                        AND n.`title` = v_title
                        AND DATE(n.`created_at`) = CURDATE()
                )
                AND NOW() >= v_reminder_datetime;
            END IF;
            
        END LOOP reminder_loop;
        
        CLOSE reminder_cursor;   
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_supplier_event_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_supplier_event_details`(
    IN `p_supplier_id` INT,
    IN `p_event_id` INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `Task_Assigns` WHERE `event_id` = p_event_id AND `user_assign_id` = p_supplier_id AND `deleted_at` IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية لعرض هذه المناسبة';
    END IF;
    
    SELECT 
        e.`event_id`,
        e.`event_name`,
        e.`description`,
        e.`event_date`,
        e.`location`,
        e.`img_url`,
        e.`event_duration`,
        e.`event_duration_unit`,
        e.`coordinator_id`,
        e.`client_id`,
        u.`full_name` AS coordinator_name,
        u.`phone_number` AS coordinator_phone,
        u.`email` AS coordinator_email,
        u.`img_url` AS coordinator_img,
        c.`name` AS client_name,
        c.`phone_number` AS client_phone,
        c.`email` AS client_email,
        c.`img_url` AS client_img,
        0.0 AS budget,
        'PENDING' AS event_status,
        0.0 AS total_expenses,
        0.0 AS total_incomes,
        0.0 AS remaining_budget,
        0 AS total_tasks,
        0 AS completed_tasks,
        0 AS pending_tasks,
        0 AS in_progress_tasks,
        0 AS cancelled_tasks,
        0 AS under_review_tasks,
        0 AS rejected_tasks,
        0 AS total_suppliers,
        '0%' AS completion_percentage,
        0.0 AS avg_task_rating
    FROM `Events` e
    LEFT JOIN `Users` u ON e.`coordinator_id` = u.`user_id`
    LEFT JOIN `Clients` c ON e.`client_id` = c.`client_id`
    WHERE e.`event_id` = p_event_id AND e.`deleted_at` IS NULL;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_task_reminders` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_task_reminders`(
        IN `p_user_id` INT,
        IN `p_task_assign_id` INT
    )
BEGIN
        
        IF NOT EXISTS (
            SELECT 1 FROM `Task_Assigns` 
            WHERE `task_assign_id` = p_task_assign_id 
            AND (`coordinator_id` = p_user_id OR `user_assign_id` = p_user_id)
            AND `deleted_at` IS NULL
        ) AND NOT fn_user_has_role(p_user_id, 'admin') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية عرض تذكيرات هذه المهمة';
        END IF;
        
        SELECT * FROM `Task_Reminders`
        WHERE `task_assign_id` = p_task_assign_id AND `deleted_at` IS NULL
        ORDER BY `created_at` DESC;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_by_email` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_by_email`(IN `p_email` VARCHAR(255))
BEGIN 
        DECLARE v_user_id INT;
        
        SELECT `user_id` INTO v_user_id 
        FROM `Users` 
        WHERE `email` = p_email AND `deleted_at` IS NULL;
        
        IF v_user_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المستخدم غير موجود';
        END IF;
        
        CALL sp_get_user_by_id(v_user_id);
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_user_by_id` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_by_id`(IN `p_user_id` INT)
BEGIN 
        DECLARE v_role_name VARCHAR(50);
        
        SELECT `role_name` INTO v_role_name 
        FROM `Users` 
        WHERE `user_id` = p_user_id AND `deleted_at` IS NULL;
        
        IF v_role_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المستخدم غير موجود';
        END IF;
        
        CASE v_role_name
            WHEN 'admin' THEN
                SELECT * FROM `vw_get_all_admins` WHERE `user_id` = p_user_id;
            WHEN 'coordinator' THEN
                SELECT * FROM `vw_get_all_coordinators` WHERE `user_id` = p_user_id;
            WHEN 'supplier' THEN
                SELECT * FROM `vw_get_all_suppliers` WHERE `user_id` = p_user_id;
            ELSE
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'دور المستخدم غير معروف';
        END CASE;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_home_stats_coordinator` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_home_stats_coordinator`(
    IN `p_coordinator_id` INT
    )
BEGIN
        
        SELECT
            (SELECT COUNT(*) FROM `Events` WHERE `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS total_events,
            (SELECT COUNT(*) FROM `Events` WHERE fn_event_status_is('PENDING', `event_id`) AND `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS pending_events,
            (SELECT COUNT(*) FROM `Events` WHERE fn_event_status_is('IN_PROGRESS', `event_id`) AND `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS in_progress_events,
            (SELECT COUNT(*) FROM `Events` WHERE fn_event_status_is('COMPLETED', `event_id`) AND `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS completed_events,
            (SELECT COUNT(*) FROM `Events` WHERE `deleted_at` IS NOT NULL AND `coordinator_id` = p_coordinator_id) AS cancelled_events,

            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `coordinator_id` = p_coordinator_id) AS total_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'PENDING'  AND `coordinator_id` = p_coordinator_id) AS pending_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'IN_PROGRESS' AND `coordinator_id` = p_coordinator_id) AS in_progress_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'COMPLETED'  AND `coordinator_id` = p_coordinator_id) AS completed_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'UNDER_REVIEW'  AND `coordinator_id` = p_coordinator_id) AS under_review_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'CANCELLED'  AND `coordinator_id` = p_coordinator_id) AS cancelled_tasks,

            (SELECT COUNT(*) FROM `Clients` WHERE  `deleted_at` IS NULL AND `coordinator_id` = p_coordinator_id) AS total_clients
            
            ;
            
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_home_stats_supplier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_home_stats_supplier`(
    IN `p_supplier_id` INT
    )
BEGIN
        
        SELECT
            (SELECT COUNT(DISTINCT e.`event_id`) FROM `Task_Assigns` t JOIN `Events` e ON t.event_id = e.event_id WHERE t.`user_assign_id` = p_supplier_id AND e.`deleted_at` IS NULL) AS total_events,
            (SELECT COUNT(DISTINCT e.`event_id`) FROM `Task_Assigns` t JOIN `Events` e ON t.event_id = e.event_id WHERE t.`user_assign_id` = p_supplier_id AND e.`deleted_at` IS NULL AND fn_event_status_is('PENDING', e.`event_id`)) AS pending_events,
            (SELECT COUNT(DISTINCT e.`event_id`) FROM `Task_Assigns` t JOIN `Events` e ON t.event_id = e.event_id WHERE t.`user_assign_id` = p_supplier_id AND e.`deleted_at` IS NULL AND fn_event_status_is('IN_PROGRESS', e.`event_id`)) AS in_progress_events,
            (SELECT COUNT(DISTINCT e.`event_id`) FROM `Task_Assigns` t JOIN `Events` e ON t.event_id = e.event_id WHERE t.`user_assign_id` = p_supplier_id AND e.`deleted_at` IS NULL AND fn_event_status_is('COMPLETED', e.`event_id`)) AS completed_events,
            (SELECT COUNT(DISTINCT e.`event_id`) FROM `Task_Assigns` t JOIN `Events` e ON t.event_id = e.event_id WHERE t.`user_assign_id` = p_supplier_id AND e.`deleted_at` IS NOT NULL) AS cancelled_events,

            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `user_assign_id` = p_supplier_id) AS total_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'PENDING'  AND `user_assign_id` = p_supplier_id) AS pending_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'IN_PROGRESS' AND `user_assign_id` = p_supplier_id) AS in_progress_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'COMPLETED'  AND `user_assign_id` = p_supplier_id) AS completed_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'UNDER_REVIEW'  AND `user_assign_id` = p_supplier_id) AS under_review_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'CANCELLED'  AND `user_assign_id` = p_supplier_id) AS cancelled_tasks,
            (SELECT COUNT(*) FROM `Task_Assigns` WHERE `status` = 'REJECTED'  AND `user_assign_id` = p_supplier_id) AS rejected_tasks
            ;
            
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_login_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_login_user`(IN `p_email` VARCHAR(255))
BEGIN 
        DECLARE v_user_id INT;
        DECLARE v_user_is_active BOOLEAN;
        DECLARE v_user_deleted_at TIMESTAMP;
        DECLARE v_user_password_hash VARCHAR(255);
        
        SELECT `user_id`, `is_active`, `deleted_at`, `password` 
        INTO v_user_id, v_user_is_active, v_user_deleted_at, v_user_password_hash 
        FROM `Users` WHERE `email` = p_email;
        
        IF v_user_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'البريد الإلكتروني غير مسجل';
        END IF;
        
        IF v_user_deleted_at IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الحساب محذوف';
        END IF;
        
        IF NOT v_user_is_active THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الحساب غير مفعل';
        END IF;

        CALL sp_get_user_by_id(v_user_id);
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_monthly_income` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_monthly_income`(
        IN `p_coordinator_id` INT,
        IN `p_limit` INT
    )
BEGIN
        SET p_limit = IFNULL(p_limit, 12);
        SELECT
            DATE_FORMAT(inc.`payment_date`, '%Y-%m') AS `month`,
            SUM(inc.`amount`) AS total_income
            FROM `Incomes` inc JOIN `Events` e ON inc.`event_id` = e.`event_id` WHERE e.`coordinator_id` = p_coordinator_id 
            GROUP BY DATE_FORMAT(inc.`payment_date`, '%Y-%m')
            ORDER BY month DESC
        LIMIT p_limit;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_register` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_register`(
        IN `p_role_name` VARCHAR(50),
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_password` VARCHAR(255),
        IN `p_details` JSON,
        IN `p_with_out` BOOLEAN
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN 
        DECLARE v_user_id INT;
        DECLARE v_user_creator_email VARCHAR(255);
        DECLARE v_user_creator_pass VARCHAR(255);
        SELECT `email`, `password` INTO v_user_creator_email, v_user_creator_pass 
        FROM `Users` WHERE `user_id` = 1 AND `deleted_at` IS NULL;
        CALL sp_create_user(
            v_user_creator_email,
            v_user_creator_pass,
            p_role_name, p_full_name, p_phone_number, TRUE, p_img_url, 
            p_email, p_password, p_details, v_user_id, p_with_out
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_remove_permission_from_role` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_remove_permission_from_role`(
        IN `p_role_name` VARCHAR(50), 
        IN `p_permission_name` VARCHAR(100)
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
        UPDATE `Role_Permissions` 
        SET `deleted_at` = NOW()
        WHERE `role_name` = p_role_name AND `permission_name` = p_permission_name;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'permission_removed',
            'إزالة صلاحية من دور',
            CONCAT('تم إزالة الصلاحية "', p_permission_name, '" من دور "', p_role_name, '"')
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_remove_service_from_supplier` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_remove_service_from_supplier`(
    IN `p_supplier_id` INT,
    IN `p_service_id` INT
    )
BEGIN
        DECLARE v_supplier_name VARCHAR(255);
        DECLARE v_service_name VARCHAR(100);
        
        SELECT `full_name` INTO v_supplier_name FROM `Users` WHERE `user_id` = p_supplier_id;
        SELECT `service_name` INTO v_service_name FROM `Services` WHERE `service_id` = p_service_id;
        
        UPDATE `Supplier_Services` SET `deleted_at` = CURRENT_TIMESTAMP 
        WHERE `supplier_id` = p_supplier_id AND `service_id` = p_service_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_supplier_id,
            'remove_service',
            'إزالة خدمة',
            CONCAT('تم إزالة الخدمة "', v_service_name, '" من خدماتك')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'remove_service',
            'إزالة خدمة من مورد',
            CONCAT('تم إزالة الخدمة "', v_service_name, '" من المورد "', v_supplier_name, '" (رقم ', p_supplier_id, ')')
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_report_coordinator_events_summary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_report_coordinator_events_summary`(
        IN `p_coordinator_id` INT
    )
BEGIN
        DECLARE v_coordinator_name VARCHAR(255);
        DECLARE v_coordinator_email VARCHAR(255);
        DECLARE v_coordinator_phone VARCHAR(20);
        DECLARE v_coordinator_img TEXT;
        
        
        SELECT `full_name`, `email`, `phone_number`, `img_url`
        INTO v_coordinator_name, v_coordinator_email, v_coordinator_phone, v_coordinator_img
        FROM `vw_get_all_coordinators` 
        WHERE `user_id` = p_coordinator_id 
        AND `deleted_at` IS NULL;
        
        IF v_coordinator_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المنسق غير موجود أو ليس لديه صلاحية';
        END IF;
        
        SELECT 
            p_coordinator_id AS coordinator_id,
            v_coordinator_name AS coordinator_name,
            v_coordinator_email AS coordinator_email,
            v_coordinator_phone AS coordinator_phone,
            v_coordinator_img AS coordinator_img,
            
            COUNT(*) AS total_events,
            SUM(CASE WHEN fn_event_status_is('COMPLETED', e.`event_id`) THEN 1 ELSE 0 END) AS completed_events,
            SUM(CASE WHEN fn_event_status_is('PENDING', e.`event_id`) THEN 1 ELSE 0 END) AS pending_events,
            SUM(CASE WHEN fn_event_status_is('IN_PROGRESS',e.`event_id`) THEN 1 ELSE 0 END) AS in_progress_events,
            SUM(CASE WHEN fn_event_status_is('DELETED', e.`event_id`) THEN 1 ELSE 0 END) AS deleted_events,
            COALESCE(SUM(e.`budget`), 0) AS total_budget,
            COALESCE(SUM(ta.`cost`), 0) AS total_expenses,
            COALESCE(SUM(i.`amount`), 0) AS total_incomes
        FROM `Events` e
        LEFT JOIN `Task_Assigns` ta ON e.`event_id` = ta.`event_id`
        LEFT JOIN `Incomes` i ON e.`event_id` = i.`event_id`
        WHERE e.`coordinator_id` = p_coordinator_id
        AND e.`deleted_at` IS NULL;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_report_event_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_report_event_details`(
        IN `p_coordinator_id` INT,
        IN `p_event_id` INT
    )
BEGIN
        DECLARE v_coordinator_name VARCHAR(255);
        DECLARE v_coordinator_email VARCHAR(255);
        DECLARE v_coordinator_phone VARCHAR(20);
        DECLARE v_coordinator_img TEXT;
        
        
        SELECT `full_name`, `email`, `phone_number`, `img_url`
        INTO v_coordinator_name, v_coordinator_email, v_coordinator_phone, v_coordinator_img
        FROM `Users` 
        WHERE `user_id` = p_coordinator_id 
        AND `deleted_at` IS NULL
        AND `role_name` IN ('coordinator', 'admin');
        
        IF v_coordinator_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المنسق غير موجود أو ليس لديه صلاحية';
        END IF;
        
        
        IF NOT EXISTS (
            SELECT 1 FROM `Events` 
            WHERE `event_id` = p_event_id 
            AND `coordinator_id` = p_coordinator_id 
            AND `deleted_at` IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الحدث غير موجود أو لا يخص هذا المنسق';
        END IF;
        
        SELECT 
            p_coordinator_id AS coordinator_id,
            v_coordinator_name AS coordinator_name,
            v_coordinator_email AS coordinator_email,
            v_coordinator_phone AS coordinator_phone,
            v_coordinator_img AS coordinator_img,
            
            e.`event_name`,
            e.`img_url` AS event_img,
            e.`budget`,
            fn_event_status(e.`event_id`) AS event_status,
            
            COALESCE(ta_stats.total_tasks, 0) AS total_tasks,
            COALESCE(ta_stats.completed_tasks, 0) AS completed_tasks,
            COALESCE(ta_stats.pending_tasks, 0) AS pending_tasks,
            COALESCE(ta_stats.in_progress_tasks, 0) AS in_progress_tasks,
            COALESCE(ta_stats.cancelled_tasks, 0) AS cancelled_tasks,
            COALESCE(ta_stats.under_review_tasks, 0) AS under_review_tasks,
            
            COALESCE(ta_stats.cancelled_tasks, 0) AS rejected_tasks,
            
            COALESCE(ta_stats.total_cost, 0) AS total_expenses,
            COALESCE(i.total_income, 0) AS total_incomes,
            (e.`budget` - COALESCE(ta_stats.total_cost, 0)) AS remaining_budget,
            
            COALESCE(ta_stats.total_suppliers, 0) AS total_suppliers,
            CONCAT(ROUND(COALESCE(ta_stats.completion_percentage, 0), 2), '%') AS completion_percentage,
            COALESCE(rt.avg_rating, 0) AS avg_task_rating
            
        FROM `Events` e
        LEFT JOIN (
            SELECT 
                ta.`event_id`,
                COUNT(*) AS total_tasks,
                SUM(CASE WHEN ta.`status` = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_tasks,
                SUM(CASE WHEN ta.`status` = 'PENDING' THEN 1 ELSE 0 END) AS pending_tasks,
                SUM(CASE WHEN ta.`status` = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress_tasks,
                SUM(CASE WHEN ta.`status` = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_tasks,
                SUM(CASE WHEN ta.`status` = 'UNDER_REVIEW' THEN 1 ELSE 0 END) AS under_review_tasks,
                SUM(ta.`cost`) AS total_cost,
                COUNT(DISTINCT ta.`user_assign_id`) AS total_suppliers,
                ROUND(100 * SUM(CASE WHEN ta.`status` = 'COMPLETED' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS completion_percentage
            FROM `Task_Assigns` ta
            WHERE ta.`deleted_at` IS NULL
            GROUP BY ta.`event_id`
        ) ta_stats ON e.`event_id` = ta_stats.`event_id`
        LEFT JOIN (
            SELECT 
                i.`event_id`,
                SUM(i.`amount`) AS total_income
            FROM `Incomes` i
            WHERE i.`deleted_at` IS NULL
            GROUP BY i.`event_id`
        ) i ON e.`event_id` = i.`event_id`
        LEFT JOIN (
            SELECT 
                ta.`event_id`,
                AVG(r.`rating_value`) AS avg_rating
            FROM `Ratings_Task_Assign` r
            JOIN `Task_Assigns` ta ON r.`task_assign_id` = ta.`task_assign_id`
            WHERE r.`deleted_at` IS NULL AND ta.`deleted_at` IS NULL
            GROUP BY ta.`event_id`
        ) rt ON e.`event_id` = rt.`event_id`
        WHERE e.`event_id` = p_event_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_report_stats` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_report_stats`(
        IN `p_coordinator_id` INT
    )
BEGIN
        SELECT
            (SELECT COUNT(*) FROM `Events` WHERE 
                NOT fn_event_status_is('COMPLETED', `event_id`) AND 
                `deleted_at` IS NULL AND 
                `coordinator_id` = p_coordinator_id
            ) AS active_events,
            (SELECT IFNULL(SUM(inc.`amount`), 0) FROM `Incomes` inc JOIN `Events` e ON inc.`event_id` = e.`event_id` WHERE e.`coordinator_id` = p_coordinator_id) AS total_revenue,
            (SELECT IFNULL(SUM(`cost`), 0) FROM `Task_Assigns` WHERE `coordinator_id` = p_coordinator_id) AS total_expenses;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_report_suppliers_summary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_report_suppliers_summary`(
        IN `p_coordinator_id` INT
    )
BEGIN
        DECLARE v_coordinator_name VARCHAR(255);
        DECLARE v_coordinator_email VARCHAR(255);
        DECLARE v_coordinator_phone VARCHAR(20);
        DECLARE v_coordinator_img TEXT;
        
        SELECT `full_name`, `email`, `phone_number`, `img_url`
        INTO v_coordinator_name, v_coordinator_email, v_coordinator_phone, v_coordinator_img
        FROM `Users` 
        WHERE `user_id` = p_coordinator_id 
        AND `deleted_at` IS NULL
        AND `role_name` IN ('coordinator', 'admin');
        
        IF v_coordinator_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المنسق غير موجود أو ليس لديه صلاحية';
        END IF;
        
        SELECT 
            p_coordinator_id AS coordinator_id,
            v_coordinator_name AS coordinator_name,
            v_coordinator_email AS coordinator_email,
            v_coordinator_phone AS coordinator_phone,
            v_coordinator_img AS coordinator_img,
            
            COUNT(DISTINCT ta.`user_assign_id`) AS total_suppliers_assigned
            
        FROM `Task_Assigns` ta
        WHERE ta.`coordinator_id` = p_coordinator_id
        AND ta.`deleted_at` IS NULL
        AND ta.`user_assign_id` IS NOT NULL;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_report_supplier_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_report_supplier_details`(
        IN `p_coordinator_id` INT,
        IN `p_supplier_id` INT
    )
BEGIN
        DECLARE v_coordinator_name VARCHAR(255);
        DECLARE v_coordinator_email VARCHAR(255);
        DECLARE v_coordinator_phone VARCHAR(20);
        DECLARE v_coordinator_img TEXT;
        
        
        SELECT `full_name`, `email`, `phone_number`, `img_url`
        INTO v_coordinator_name, v_coordinator_email, v_coordinator_phone, v_coordinator_img
        FROM `Users` 
        WHERE `user_id` = p_coordinator_id 
        AND `deleted_at` IS NULL
        AND `role_name` IN ('coordinator', 'admin');
        
        IF v_coordinator_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المنسق غير موجود أو ليس لديه صلاحية';
        END IF;
        
        
        IF NOT EXISTS (
            SELECT 1 FROM `Users` 
            WHERE `user_id` = p_supplier_id 
            AND `role_name` = 'supplier' 
            AND `deleted_at` IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المورد غير موجود';
        END IF;
        
        
        SELECT 
            u.`full_name` AS supplier_name,
            u.`img_url` AS supplier_img,
            u.`email` AS supplier_email,
            u.`phone_number` AS supplier_phone,
            
            COALESCE(ta_stats.total_tasks, 0) AS total_tasks,
            COALESCE(ta_stats.completed_tasks, 0) AS completed_tasks,
            COALESCE(ta_stats.in_progress_tasks, 0) AS in_progress_tasks,
            COALESCE(ta_stats.pending_tasks, 0) AS pending_tasks,
            COALESCE(ta_stats.cancelled_tasks, 0) AS cancelled_tasks,
            COALESCE(ta_stats.cancelled_tasks, 0) AS rejected_tasks,  
            COALESCE(ta_stats.under_review_tasks, 0) AS under_review_tasks,
            
            COALESCE(ta_stats.avg_rating, 0) AS avg_rating,
            
            COALESCE(ta_stats.total_cost, 0) AS total_cost,
            COALESCE(ta_stats.completed_cost, 0) AS completed_cost,
            COALESCE(ta_stats.in_progress_cost, 0) AS in_progress_cost,
            COALESCE(ta_stats.pending_cost, 0) AS pending_cost,
            COALESCE(ta_stats.cancelled_cost, 0) AS cancelled_cost,
            COALESCE(ta_stats.cancelled_cost, 0) AS rejected_cost,
            COALESCE(ta_stats.under_review_cost, 0) AS under_review_cost,
            
            COALESCE(event_stats.total_events, 0) AS total_events,
            COALESCE(event_stats.pending_events, 0) AS pending_events,
            COALESCE(event_stats.in_progress_events, 0) AS in_progress_events,
            COALESCE(event_stats.completed_events, 0) AS completed_events,
            COALESCE(event_stats.deleted_events, 0) AS deleted_events,
            
            COALESCE(ss.total_services, 0) AS total_services
            
        INTO 
            @supplier_name, @supplier_img, @supplier_email, @supplier_phone,
            @total_tasks, @completed_tasks, @in_progress_tasks, @pending_tasks, 
            @cancelled_tasks, @rejected_tasks, @under_review_tasks,
            @avg_rating,
            @total_cost, @completed_cost, @in_progress_cost, @pending_cost,
            @cancelled_cost, @rejected_cost, @under_review_cost,
            @total_events, @pending_events, @in_progress_events, @completed_events, @deleted_events,
            @total_services
        FROM `Users` u
        LEFT JOIN (
            SELECT 
                ta.`user_assign_id`,
                COUNT(*) AS total_tasks,
                SUM(CASE WHEN ta.`status` = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_tasks,
                SUM(CASE WHEN ta.`status` = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress_tasks,
                SUM(CASE WHEN ta.`status` = 'PENDING' THEN 1 ELSE 0 END) AS pending_tasks,
                SUM(CASE WHEN ta.`status` = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_tasks,
                SUM(CASE WHEN ta.`status` = 'UNDER_REVIEW' THEN 1 ELSE 0 END) AS under_review_tasks,
                AVG(r.`rating_value`) AS avg_rating,
                SUM(ta.`cost`) AS total_cost,
                SUM(CASE WHEN ta.`status` = 'COMPLETED' THEN ta.`cost` ELSE 0 END) AS completed_cost,
                SUM(CASE WHEN ta.`status` = 'IN_PROGRESS' THEN ta.`cost` ELSE 0 END) AS in_progress_cost,
                SUM(CASE WHEN ta.`status` = 'PENDING' THEN ta.`cost` ELSE 0 END) AS pending_cost,
                SUM(CASE WHEN ta.`status` = 'CANCELLED' THEN ta.`cost` ELSE 0 END) AS cancelled_cost,
                SUM(CASE WHEN ta.`status` = 'UNDER_REVIEW' THEN ta.`cost` ELSE 0 END) AS under_review_cost
            FROM `Task_Assigns` ta
            LEFT JOIN `Ratings_Task_Assign` r ON ta.`task_assign_id` = r.`task_assign_id` AND r.`deleted_at` IS NULL
            WHERE ta.`coordinator_id` = p_coordinator_id
            AND ta.`deleted_at` IS NULL
            AND ta.`user_assign_id` = p_supplier_id
            GROUP BY ta.`user_assign_id`
        ) ta_stats ON u.`user_id` = ta_stats.`user_assign_id`
        LEFT JOIN (
            SELECT 
                ta.`user_assign_id`,
                COUNT(DISTINCT e.`event_id`) AS total_events,
                SUM(CASE WHEN fn_event_status(e.`event_id`) = 'PENDING' THEN 1 ELSE 0 END) AS pending_events,
                SUM(CASE WHEN fn_event_status(e.`event_id`) = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress_events,
                SUM(CASE WHEN fn_event_status(e.`event_id`) = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_events,
                SUM(CASE WHEN fn_event_status(e.`event_id`) = 'DELETED' THEN 1 ELSE 0 END) AS deleted_events
            FROM `Task_Assigns` ta
            JOIN `Events` e ON ta.`event_id` = e.`event_id`
            WHERE ta.`coordinator_id` = p_coordinator_id
            AND ta.`deleted_at` IS NULL
            AND ta.`user_assign_id` = p_supplier_id
            AND e.`deleted_at` IS NULL
            GROUP BY ta.`user_assign_id`
        ) event_stats ON u.`user_id` = event_stats.`user_assign_id`
        LEFT JOIN (
            SELECT 
                ss.`supplier_id`,
                COUNT(DISTINCT ss.`service_id`) AS total_services
            FROM `Supplier_Services` ss
            WHERE ss.`deleted_at` IS NULL
            GROUP BY ss.`supplier_id`
        ) ss ON u.`user_id` = ss.`supplier_id`
        WHERE u.`user_id` = p_supplier_id;
        
        
        SELECT 
            p_coordinator_id AS coordinator_id,
            v_coordinator_name AS coordinator_name,
            v_coordinator_email AS coordinator_email,
            v_coordinator_phone AS coordinator_phone,
            v_coordinator_img AS coordinator_img,
            
            @supplier_name AS supplier_name,
            @supplier_img AS supplier_img,
            @supplier_email AS supplier_email,
            @supplier_phone AS supplier_phone,
            
            @total_tasks AS total_tasks,
            @completed_tasks AS completed_tasks,
            @in_progress_tasks AS in_progress_tasks,
            @pending_tasks AS pending_tasks,
            @cancelled_tasks AS cancelled_tasks,
            @rejected_tasks AS rejected_tasks,
            @under_review_tasks AS under_review_tasks,
            
            @avg_rating AS avg_rating,
            
            @total_cost AS total_cost,
            @completed_cost AS completed_cost,
            @in_progress_cost AS in_progress_cost,
            @pending_cost AS pending_cost,
            @cancelled_cost AS cancelled_cost,
            @rejected_cost AS rejected_cost,
            @under_review_cost AS under_review_cost,
            
            @total_events AS total_events,
            @pending_events AS pending_events,
            @in_progress_events AS in_progress_events,
            @completed_events AS completed_events,
            @deleted_events AS deleted_events,
            
            @total_services AS total_services;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_report_tasks_summary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_report_tasks_summary`(
        IN `p_coordinator_id` INT
    )
BEGIN
        DECLARE v_coordinator_name VARCHAR(255);
        DECLARE v_coordinator_email VARCHAR(255);
        DECLARE v_coordinator_phone VARCHAR(20);
        DECLARE v_coordinator_img TEXT;
        
        SELECT `full_name`, `email`, `phone_number`, `img_url`
        INTO v_coordinator_name, v_coordinator_email, v_coordinator_phone, v_coordinator_img
        FROM `Users` 
        WHERE `user_id` = p_coordinator_id 
        AND `deleted_at` IS NULL
        AND `role_name` IN ('coordinator', 'admin');
        
        IF v_coordinator_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المنسق غير موجود أو ليس لديه صلاحية';
        END IF;
        
        SELECT 
            p_coordinator_id AS coordinator_id,
            v_coordinator_name AS coordinator_name,
            v_coordinator_email AS coordinator_email,
            v_coordinator_phone AS coordinator_phone,
            v_coordinator_img AS coordinator_img,
            
            COUNT(*) AS total_tasks,
            SUM(CASE WHEN ta.`status` = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_tasks,
            SUM(CASE WHEN ta.`status` = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS in_progress_tasks,
            SUM(CASE WHEN ta.`status` = 'PENDING' THEN 1 ELSE 0 END) AS pending_tasks,
            SUM(CASE WHEN ta.`status` = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_tasks,
            SUM(CASE WHEN ta.`status` = 'UNDER_REVIEW' THEN 1 ELSE 0 END) AS under_review_tasks,
            COALESCE(SUM(ta.`cost`), 0) AS total_expenses,
            
            COUNT(DISTINCT CASE WHEN r.`rating_id` IS NOT NULL THEN ta.`task_assign_id` END) AS rated_tasks,
            COUNT(DISTINCT CASE WHEN r.`rating_id` IS NULL THEN ta.`task_assign_id` END) AS unrated_tasks,
            COALESCE(AVG(r.`rating_value`), 0) AS avg_rating
            
        FROM `Task_Assigns` ta
        LEFT JOIN `Ratings_Task_Assign` r ON ta.`task_assign_id` = r.`task_assign_id` AND r.`deleted_at` IS NULL
        WHERE ta.`coordinator_id` = p_coordinator_id
        AND ta.`deleted_at` IS NULL;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_report_task_details` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_report_task_details`(
        IN `p_coordinator_id` INT,
        IN `p_task_assign_id` INT
    )
BEGIN
        DECLARE v_coordinator_name VARCHAR(255);
        DECLARE v_coordinator_email VARCHAR(255);
        DECLARE v_coordinator_phone VARCHAR(20);
        DECLARE v_coordinator_img TEXT;
        
        SELECT `full_name`, `email`, `phone_number`, `img_url`
        INTO v_coordinator_name, v_coordinator_email, v_coordinator_phone, v_coordinator_img
        FROM `Users` 
        WHERE `user_id` = p_coordinator_id 
        AND `deleted_at` IS NULL
        AND `role_name` IN ('coordinator', 'admin');
        
        IF v_coordinator_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المنسق غير موجود أو ليس لديه صلاحية';
        END IF;
        
        
        IF NOT EXISTS (
            SELECT 1 FROM `Task_Assigns` 
            WHERE `task_assign_id` = p_task_assign_id 
            AND `coordinator_id` = p_coordinator_id 
            AND `deleted_at` IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المهمة غير موجودة أو لا تخص هذا المنسق';
        END IF;
        
        SELECT 
            p_coordinator_id AS coordinator_id,
            v_coordinator_name AS coordinator_name,
            v_coordinator_email AS coordinator_email,
            v_coordinator_phone AS coordinator_phone,
            v_coordinator_img AS coordinator_img,
            
            ta.`description` AS task_name,
            ta.`status` AS task_status,
            s.`service_name` AS service_name,
            u.`full_name` AS supplier_name,
            u.`img_url` AS supplier_img,
            u.`email` AS supplier_email,
            u.`phone_number` AS supplier_phone,
            ta.`cost`,
            r.`rating_value` AS rating
            
        FROM `Task_Assigns` ta
        LEFT JOIN `Services` s ON ta.`service_id` = s.`service_id` AND s.`deleted_at` IS NULL
        LEFT JOIN `Users` u ON ta.`user_assign_id` = u.`user_id` AND u.`deleted_at` IS NULL
        LEFT JOIN `Ratings_Task_Assign` r ON ta.`task_assign_id` = r.`task_assign_id` AND r.`deleted_at` IS NULL
        WHERE ta.`task_assign_id` = p_task_assign_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_restore_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_restore_user`(IN `p_user_id` INT)
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
        DECLARE v_user_email VARCHAR(255);
        DECLARE v_user_name VARCHAR(255);
        DECLARE v_role_name VARCHAR(50);
        
        SELECT `email`, `full_name`, `role_name` INTO v_user_email, v_user_name, v_role_name
        FROM `Users` WHERE `user_id` = p_user_id;
        
        IF NOT EXISTS (SELECT 1 FROM `Users` WHERE `user_id` = p_user_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'حساب غير موجود';
        END IF;
        IF NOT fn_user_is_deleted(p_user_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا الحساب ليس محذوفاً';
        END IF;
        
        UPDATE `Users` SET `deleted_at` = NULL WHERE `user_id` = p_user_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'restore_user',
            'استعادة حساب',
            CONCAT('تم استعادة حساب المستخدم: ', v_user_name, ' (', v_user_email, ') - الدور: ', v_role_name)
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_user_id,
            'restore_user',
            'تم استعادة حسابك',
            CONCAT('تم استعادة حسابك بتاريخ ', NOW(), '. يمكنك الآن تسجيل الدخول.')
        );
        
        SELECT p_user_id AS user_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_set_error_msg_or_def` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_set_error_msg_or_def`(
        IN `p_error_msg` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
        IN `p_default_msg` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        IN `p_show_error` BOOLEAN
    )
BEGIN 
        IF p_show_error = TRUE THEN
            IF p_error_msg IS NULL OR p_error_msg = '' THEN
                SET p_default_msg = IF(p_default_msg IS NULL OR p_default_msg = '', 'حدث خطأ غير معروف', p_default_msg);
                RESIGNAL SET MESSAGE_TEXT = p_default_msg;
            END IF;
            RESIGNAL SET MESSAGE_TEXT = p_error_msg;
        END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_set_user_active` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_set_user_active`(IN `p_user_id` INT, IN `p_active` BOOLEAN, IN `p_with_out` BOOLEAN)
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
        DECLARE v_error_msg TEXT;
        DECLARE v_user_name VARCHAR(255);
        DECLARE v_user_email VARCHAR(255);
        
        SELECT `full_name`, `email` INTO v_user_name, v_user_email
        FROM `Users` WHERE `user_id` = p_user_id AND `deleted_at` IS NULL;
        
        IF NOT EXISTS (SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'حساب غير موجود';
        END IF;
        IF EXISTS (SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `is_active` = p_active) THEN
            SET v_error_msg = IF(p_active = TRUE, 'هذا الحساب مفعل بالفعل', 'هذا الحساب غير مفعل بالفعل');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
        END IF;
        
        UPDATE `Users` SET `is_active` = p_active WHERE `user_id` = p_user_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            IF(p_active, 'activate_user', 'deactivate_user'),
            IF(p_active, 'تفعيل حساب', 'تعطيل حساب'),
            CONCAT('تم ', IF(p_active, 'تفعيل', 'تعطيل'), ' حساب المستخدم: ', v_user_name, ' (', v_user_email, ')')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_user_id,
            IF(p_active, 'activate_user', 'deactivate_user'),
            IF(p_active, 'تم تفعيل حسابك', 'تم تعطيل حسابك'),
            CONCAT('تم ', IF(p_active, 'تفعيل', 'تعطيل'), ' حسابك بتاريخ ', NOW(), '.')
        );
        
        IF p_with_out THEN SELECT p_user_id AS user_id; END IF;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_throw_if_account_not_admin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_throw_if_account_not_admin`(
        IN `p_user_creator_email` VARCHAR(255),
        IN `p_user_creator_pass` VARCHAR(255),
        IN `p_permission_role` ENUM('admin', 'coordinator', 'supplier')
    )
BEGIN
        DECLARE v_user_id INT;
        
        
        
        
        SELECT `user_id` INTO v_user_id 
            FROM `Users` 
            WHERE `email` = p_user_creator_email 
            AND `password` = p_user_creator_pass 
            AND `role_name` = 'admin'
            AND `deleted_at` IS NULL;
        
        IF v_user_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن الإنشاء إلا عن طريق حساب مدير';
        END IF;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_client` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_client`(
        IN `p_coordinator_id` INT,
        IN `p_client_id` INT,
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_address` TEXT
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN 
        DECLARE v_creator_user_role VARCHAR(50);
        DECLARE v_creator_name VARCHAR(255);
        DECLARE v_creator_email VARCHAR(255);
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        SELECT `role_name`, `full_name`, `email`
            INTO v_creator_user_role, v_creator_name, v_creator_email
                FROM `Users` 
                    WHERE `user_id` = p_coordinator_id 
                        AND `role_name` IN ('coordinator', 'admin')
                        AND `deleted_at` IS NULL; 
        
        IF v_creator_user_role IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تعديل بيانات العميل إلا عن طريق حساب منسق أو مدير';
        END IF;
        
        
        START TRANSACTION;
        

        UPDATE `Clients` SET 
            `full_name` = COALESCE(p_full_name, `full_name`), 
            `phone_number` = COALESCE(p_phone_number, `phone_number`), 
            `img_url` = COALESCE(p_img_url, `img_url`), 
            `email` = COALESCE(p_email, `email`), 
            `address` = COALESCE(p_address, `address`),
            `updated_at` = NOW()
        WHERE `client_id` = p_client_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_coordinator_id,
            'update_client', 
            'تحديث بيانات عميل', 
            CONCAT(
                'لقد قمت بتحديث بيانات العميل\n', 
                'إسم العميل: ', p_full_name, '\n',
                'رقم هاتفه: ', p_phone_number, '\n',
                IF(p_email IS NULL OR p_email = '', '', CONCAT('البريد: ', p_email, '\n')),
                IF(p_address IS NULL OR p_address = '', '', CONCAT('العنوان: ', p_address))
            )
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'update_client', 
            'تحديث بيانات عميل', 
            CONCAT(
                'لقد قام ', IF(v_creator_user_role = 'admin', 'المدير ', 'المنسق '),
                v_creator_name, ' "', v_creator_email, '" بتحديث بيانات العميل\n\n',
                'رقم العميل: ', p_client_id, '\n',
                'إسم العميل: ', p_full_name, '\n',
                'رقم هاتفه: ', p_phone_number, '\n',
                IF(p_email IS NULL OR p_email = '', '', CONCAT('البريد: ', p_email, '\n')),
                IF(p_address IS NULL OR p_address = '', '', CONCAT('العنوان: ', p_address))
            )
        );
        
        COMMIT;
        SELECT * FROM `Clients` WHERE `client_id` = p_client_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_event` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_event`(
        IN `p_event_id` INT,
        IN `p_event_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        IN `p_description` TEXT,
        IN `p_img_url` TEXT,
        IN `p_event_date` DATE,
        IN `p_location` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        IN `p_budget` DECIMAL(10,2),
        IN `p_event_duration` INT,
        IN `p_event_duration_unit` ENUM('DAY', 'WEEK', 'MONTH')
    )
BEGIN
        DECLARE v_coordinator_id INT;
        DECLARE v_old_name VARCHAR(255);
        
        SELECT `coordinator_id`, `event_name` INTO v_coordinator_id, v_old_name
        FROM `Events` WHERE `event_id` = p_event_id;

        UPDATE `Events`
            SET `event_name` = IFNULL(p_event_name, `event_name`),
                `description` = IFNULL(p_description, `description`),
                `event_date` = IFNULL(STR_TO_DATE(p_event_date, '%Y-%m-%dT%H:%i:%s.%fZ'), `event_date`),
                `location` = IFNULL(p_location, `location`),
                `budget` = IFNULL(p_budget, `budget`),
                `event_duration` = IFNULL(p_event_duration, `event_duration`),
                `event_duration_unit` = IFNULL(p_event_duration_unit, `event_duration_unit`),
                `img_url` = IFNULL(p_img_url, `img_url`),
                `updated_at` = NOW()
            WHERE `event_id` = p_event_id;
        
         
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (v_coordinator_id,
            'update_event',
            'تحديث حدث',
            CONCAT('تم تحديث بيانات الحدث "', IFNULL(p_event_name, v_old_name), '" (رقم ', p_event_id, ')')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'update_event',
            'تحديث حدث',
            CONCAT('تم تحديث بيانات الحدث "', IFNULL(p_event_name, v_old_name), '" (رقم ', p_event_id, ') بواسطة المنسق رقم ', v_coordinator_id)
        );
        SELECT * FROM `Events` WHERE `event_id` = p_event_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_income` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_income`(
        IN `p_income_id` INT,
        IN `p_amount` DECIMAL(10,2),
        IN `p_description` TEXT,
        IN `p_payment_date` DATE,
        IN `p_payment_method` VARCHAR(50),
        IN `p_url_image` VARCHAR(255)
    )
BEGIN
        DECLARE v_event_id INT;
        DECLARE v_coordinator_id INT;
        DECLARE v_event_name VARCHAR(255);
        
        SELECT e.`event_id`, e.`coordinator_id`, e.`event_name` 
        INTO v_event_id, v_coordinator_id, v_event_name
        FROM `Incomes` i JOIN `Events` e ON i.`event_id` = e.`event_id`
        WHERE i.`income_id` = p_income_id;
        
        UPDATE `Incomes`
            SET `amount` = IFNULL(p_amount, `amount`),
                `description` = IFNULL(p_description, `description`),
                `payment_date` = IFNULL(p_payment_date, `payment_date`),
                `payment_method` = IFNULL(p_payment_method, `payment_method`),
                `url_image` = IFNULL(p_url_image, `url_image`),
                `updated_at` = NOW()
            WHERE `income_id` = p_income_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (v_coordinator_id,
            'update_income',
            'تحديث دفعة',
            CONCAT('تم تحديث بيانات الدفعة رقم ', p_income_id, ' للحدث "', v_event_name, '"')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'update_income',
            'تحديث دفعة',
            CONCAT('تم تحديث بيانات الدفعة رقم ', p_income_id, ' للحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id)
        );
        
        SELECT * FROM `Incomes` WHERE `income_id` = p_income_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_service` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_service`(
        IN `p_service_id` INT,
        IN `p_service_name` VARCHAR(100),
        IN `p_description` TEXT
    )
BEGIN
        DECLARE v_old_name VARCHAR(100);
        SELECT `service_name` INTO v_old_name FROM `Services` WHERE `service_id` = p_service_id;
        
        UPDATE `Services`
            SET `service_name` = IFNULL(p_service_name, `service_name`),
                `description` = IFNULL(p_description, `description`),
                `updated_at` = NOW()
            WHERE `service_id` = p_service_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'update_service',
            'تحديث خدمة',
            CONCAT('تم تحديث بيانات الخدمة "', IFNULL(p_service_name, v_old_name), '" (رقم ', p_service_id, ')')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        SELECT `user_id`, 'update_service', 'تحديث خدمة', CONCAT('تم تحديث بيانات الخدمة: "', IFNULL(p_service_name, v_old_name), '"') 
        FROM `Users` WHERE `deleted_at` IS NULL AND `user_id` != 1;
        
        SELECT * FROM `Services` WHERE `service_id` = p_service_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_task` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_task`( 
    IN `p_task_assign_id` INT,
    IN `p_type_task` VARCHAR(255),
    IN `p_status` VARCHAR(50),
    IN `p_date_start` DATE,
    IN `p_date_due` DATE,
    IN `p_description` TEXT,
    IN `p_cost` DECIMAL(10,2),
    IN `p_notes` TEXT,
    IN `p_url_image` VARCHAR(255)
    )
BEGIN
        DECLARE v_user_assign_id INT;
        DECLARE v_coordinator_id INT;
        DECLARE v_event_id INT;
        DECLARE v_event_name VARCHAR(255);
        
        SELECT `user_assign_id`, `coordinator_id`, `event_id` 
        INTO v_user_assign_id, v_coordinator_id, v_event_id
        FROM `Task_Assigns` WHERE `task_assign_id` = p_task_assign_id;
        
        SELECT `event_name` INTO v_event_name FROM `Events` WHERE `event_id` = v_event_id;
        
        START TRANSACTION;
        
        UPDATE `Task_Assigns`
            SET `type_task` = IFNULL(p_type_task, `type_task`),
                `status` = IFNULL(p_status, `status`),
                `date_start` = IFNULL(p_date_start, `date_start`),
                `date_due` = IFNULL(p_date_due, `date_due`),
                `description` = IFNULL(p_description, `description`),
                `cost` = IFNULL(p_cost, `cost`),
                `notes` = IFNULL(p_notes, `notes`),
                `url_image` = IFNULL(p_url_image, `url_image`),
                `updated_at` = NOW()
            WHERE `task_assign_id` = p_task_assign_id;
            
        
        IF v_user_assign_id IS NOT NULL THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (v_user_assign_id,
                'update_task',
                'تحديث مهمة',
                CONCAT('تم تحديث بيانات المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '"')
            );
        END IF;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (v_coordinator_id,
            'update_task',
            'تحديث مهمة',
            CONCAT('تم تحديث بيانات المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '"')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'update_task',
            'تحديث مهمة',
            CONCAT('تم تحديث بيانات المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id)
        );
            
        COMMIT;
        
        SELECT * FROM `vw_tasks_full` WHERE `task_assign_id` = p_task_assign_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_task_reminder` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_task_reminder`(
        IN `p_user_id` INT,
        IN `p_reminder_id` INT,
        IN `p_reminder_type` ENUM('INTERVAL', 'BEFORE_DUE'),
        IN `p_reminder_value` INT,
        IN `p_reminder_unit` ENUM('MINUTE', 'HOUR', 'DAY'),
        IN `p_is_active` BOOLEAN
    )
BEGIN
        DECLARE v_reminder_user INT;
        
        
        SELECT `user_id` INTO v_reminder_user FROM `Task_Reminders` WHERE `reminder_id` = p_reminder_id AND `deleted_at` IS NULL;
        
        IF v_reminder_user IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'التذكير غير موجود';
        END IF;
        
        
        IF p_user_id != v_reminder_user AND NOT fn_user_has_role(p_user_id, 'admin') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية تعديل هذا التذكير';
        END IF;
        
        UPDATE `Task_Reminders`
        SET `reminder_type` = COALESCE(p_reminder_type, `reminder_type`),
            `reminder_value` = COALESCE(p_reminder_value, `reminder_value`),
            `reminder_unit` = COALESCE(p_reminder_unit, `reminder_unit`),
            `is_active` = COALESCE(p_is_active, `is_active`),
            `updated_at` = NOW()
        WHERE `reminder_id` = p_reminder_id;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (v_reminder_user,
            'UPDATE_REMINDER',
            'تحديث تذكير',
            'تم تحديث إعدادات تذكير المهمة الخاص بك بنجاح.'
        );
        
        SELECT p_reminder_id AS reminder_id;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_task_status` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_task_status`(
        IN `p_user_update_id` INT,
        IN `p_task_assign_id` INT,
        IN `p_new_status` VARCHAR(50),
        IN `p_notes` TEXT,
        IN `p_url_image` TEXT
    )
BEGIN
        DECLARE v_old_status VARCHAR(20);
        DECLARE v_event_id INT;
        DECLARE v_coordinator_id INT;
        DECLARE v_user_assign_id INT;
        DECLARE v_event_name VARCHAR(255);
        DECLARE v_user_name VARCHAR(255);
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        
        SELECT `status`, `event_id`, `coordinator_id`, `user_assign_id`
            INTO v_old_status, v_event_id, v_coordinator_id, v_user_assign_id
                FROM `Task_Assigns` 
                    WHERE `task_assign_id` = p_task_assign_id AND `deleted_at` IS NULL;
        
        IF v_old_status IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المهمة غير موجودة';
        END IF;
        
        
        SELECT `event_name` INTO v_event_name FROM `Events` WHERE `event_id` = v_event_id;
        
        
        SELECT `full_name` INTO v_user_name FROM `Users` WHERE `user_id` = p_user_update_id;
        
        
        IF p_user_update_id = v_coordinator_id THEN
            
            IF v_user_assign_id != v_coordinator_id AND v_old_status != 'UNDER_REVIEW' AND p_new_status != 'COMPLETED' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن للمنسق تحديث حالة مهمة مكلف بها مورد';
            END IF;
            
            IF v_old_status IN ('COMPLETED', 'CANCELLED') THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تغيير حالة مهمة مكتملة أو ملغية';
            END IF;
        ELSEIF p_user_update_id = v_user_assign_id THEN
            
            IF v_old_status = 'PENDING' AND p_new_status NOT IN ('IN_PROGRESS', 'REJECTED') THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'يجب تغيير الحالة من PENDING إلى IN_PROGRESS أو REJECTED';
            ELSEIF v_old_status = 'IN_PROGRESS' AND p_new_status NOT IN ('UNDER_REVIEW', 'COMPLETED') THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'يجب تغيير الحالة من IN_PROGRESS إلى UNDER_REVIEW أو COMPLETED';
            ELSEIF v_old_status = 'UNDER_REVIEW' AND p_new_status NOT IN ('IN_PROGRESS', 'COMPLETED') THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'يجب تغيير الحالة من UNDER_REVIEW إلى IN_PROGRESS أو COMPLETED';
            ELSEIF v_old_status IN ('COMPLETED', 'CANCELLED') THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تغيير حالة مهمة مكتملة أو ملغية';
            END IF;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية لتحديث حالة هذه المهمة';
        END IF;
        
        
        IF v_old_status = p_new_status THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الحالة الجديدة هي نفس الحالة القديمة';
        END IF;
        
        START TRANSACTION;
        
        
        UPDATE `Task_Assigns`
            SET `status` = p_new_status,
                `notes` = IF(p_notes IS NOT NULL, CONCAT(IFNULL(`notes`, ''), '\n', p_notes), `notes`),
                `date_completion` = IF(p_new_status = 'COMPLETED', NOW(), `date_completion`),
                `updated_at` = NOW(),
                `url_image` = IFNULL(p_url_image, `url_image`)
            WHERE `task_assign_id` = p_task_assign_id;
        
        
        
        
        
        
        SET @status_ar = CASE p_new_status
            WHEN 'PENDING' THEN 'معلقة'
            WHEN 'IN_PROGRESS' THEN 'قيد التنفيذ'
            WHEN 'UNDER_REVIEW' THEN 'قيد المراجعة'
            WHEN 'COMPLETED' THEN 'مكتملة'
            WHEN 'CANCELLED' THEN 'ملغية'
            ELSE 'مرفوضة'
        END;
        
        SET @old_status_ar = CASE v_old_status
            WHEN 'PENDING' THEN 'معلقة'
            WHEN 'IN_PROGRESS' THEN 'قيد التنفيذ'
            WHEN 'UNDER_REVIEW' THEN 'قيد المراجعة'
            WHEN 'COMPLETED' THEN 'مكتملة'
            WHEN 'CANCELLED' THEN 'ملغية'
            ELSE 'مرفوضة'
        END;
        
        SET @message_text = CONCAT(
            'تم تغيير حالة المهمة رقم ', p_task_assign_id, 
            ' في الحدث "', v_event_name, '" من "', @old_status_ar, '" إلى "', @status_ar, '"',
            IF(p_notes IS NOT NULL, CONCAT('\nملاحظات: ', p_notes), ''),
            IF(p_url_image IS NOT NULL, '\nتم إضافة صورة جديدة للمهمة.', '')
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (p_user_update_id, 
                CONCAT('TASK_STATUS_', p_new_status),
                CONCAT('تحديث حالة مهمة #', p_task_assign_id),
                CONCAT('لقد قمت بتغيير حالة المهمة إلى "', @status_ar, '".\n', @message_text));
        
        
        IF v_coordinator_id != p_user_update_id THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (v_coordinator_id, 
                    CONCAT('TASK_STATUS_', p_new_status),
                    CONCAT('تحديث حالة مهمة #', p_task_assign_id),
                    CONCAT('قام ', IFNULL(v_user_name, 'غير معروف'), ' بتغيير حالة المهمة إلى "', @status_ar, '".\n', @message_text));
        END IF;
        
        
        IF v_user_assign_id IS NOT NULL AND v_user_assign_id != p_user_update_id THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (v_user_assign_id, 
                    CONCAT('TASK_STATUS_', p_new_status),
                    CONCAT('تحديث حالة مهمة #', p_task_assign_id),
                    CONCAT('تم تغيير حالة مهمتك إلى "', @status_ar, '" بواسطة ', v_user_name, '.\n', @message_text));
        END IF;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (1, 
                CONCAT('TASK_STATUS_', p_new_status),
                CONCAT('تحديث حالة مهمة #', p_task_assign_id),
                CONCAT('قام ', IFNULL(v_user_name, 'غير معروف'), ' (رقم ', p_user_update_id, ') بتغيير حالة المهمة رقم ', p_task_assign_id, 
                       ' في الحدث "', IFNULL(v_event_name, 'غير معروف'), '" من "', @old_status_ar, '" إلى "', @status_ar, '"'));
        
        
        IF p_new_status IN ('COMPLETED', 'CANCELLED') THEN
            SET @status_text = IF(p_new_status = 'COMPLETED', 'إكمال', 'إلغاء');
            
            
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (v_coordinator_id, 
                    CONCAT('TASK_', p_new_status),
                    CONCAT('تم ', @status_text, ' مهمة'),
                    CONCAT('المهمة رقم ', p_task_assign_id, ' في الحدث "', IFNULL(v_event_name, 'غير معروف'), '" قد ', IF(p_new_status='COMPLETED', 'اكتملت', 'ألغيت'), '.'));
            
            
            IF v_user_assign_id IS NOT NULL AND v_user_assign_id != v_coordinator_id THEN
                INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
                VALUES (v_user_assign_id, 
                        CONCAT('TASK_', p_new_status),
                        CONCAT('تم ', @status_text, ' مهمة'),
                        CONCAT('المهمة رقم ', p_task_assign_id, ' في الحدث "', IFNULL(v_event_name, 'غير معروف'), '" قد ', IF(p_new_status='COMPLETED', 'اكتملت', 'ألغيت'), '.'));
            END IF;
        END IF;
        
        COMMIT;
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_user`(
        IN `p_user_creator_email` VARCHAR(255),
        IN `p_user_creator_pass` VARCHAR(255),
        IN `p_user_id` INT,
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_password` VARCHAR(255),
        IN `p_details` JSON
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
        DECLARE v_role_name VARCHAR(50);
        DECLARE v_detail_name VARCHAR(255);
        DECLARE v_detail_value TEXT;
        DECLARE v_i INT DEFAULT 0;
        DECLARE v_keys JSON;
        DECLARE v_total INT DEFAULT 0;
        DECLARE v_error_msg TEXT;
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        
        SELECT `role_name` INTO v_role_name 
        FROM `Users` 
        WHERE `user_id` = p_user_id AND `deleted_at` IS NULL;
        
        IF v_role_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المستخدم غير موجود';
        END IF;
        
        
        CALL sp_throw_if_account_not_admin(p_user_creator_email, p_user_creator_pass, v_role_name);
        
        
        IF EXISTS(SELECT 1 FROM `Users` WHERE `user_id` != p_user_id AND `email` = p_email AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا البريد موجود مسبقا';
        END IF;
        IF EXISTS(SELECT 1 FROM `Users` WHERE `user_id` != p_user_id AND `phone_number` = p_phone_number AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا الهاتف يمتلكه شخص آخر';
        END IF;
        
        START TRANSACTION;
        
        
        UPDATE `Users` SET 
            `full_name` = COALESCE(p_full_name, `full_name`),
            `phone_number` = COALESCE(p_phone_number, `phone_number`),
            `img_url` = COALESCE(p_img_url, `img_url`),
            `email` = COALESCE(p_email, `email`),
            `password` = COALESCE(p_password, `password`),
            `updated_at` = NOW()
        WHERE `user_id` = p_user_id;
        
        
        IF p_details IS NOT NULL AND JSON_VALID(p_details) THEN
            SET v_keys = JSON_KEYS(p_details);
            SET v_total = JSON_LENGTH(v_keys);
            
            WHILE v_i < v_total DO
                SET v_detail_name = JSON_UNQUOTE(JSON_EXTRACT(v_keys, CONCAT('$[', v_i, ']')));
                SET v_detail_value = JSON_UNQUOTE(JSON_EXTRACT(p_details, CONCAT('$.', v_detail_name)));
                
                IF NOT fn_user_detail_exists(p_user_id, v_detail_name) THEN
                    IF NOT fun_role_has_detail(v_detail_name, v_role_name) THEN 
                        SET v_error_msg = CONCAT('الحقل "', v_detail_name, '" غير مسموح به في دور هذا الحساب');
                        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
                    END IF;
                    INSERT INTO `User_Detail_Values` (`user_id`, `detail_name`, `detail_value`)
                    VALUES (p_user_id, v_detail_name, v_detail_value);
                ELSE
                    UPDATE `User_Detail_Values`
                    SET `detail_value` = v_detail_value, `updated_at` = NOW()
                    WHERE `user_id` = p_user_id AND `detail_name` = v_detail_name;
                END IF;
                SET v_i = v_i + 1;
            END WHILE;
        END IF;
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            CONCAT('update_', v_role_name, '_user'), 
            CONCAT('تحديث حساب ', 
                CASE v_role_name
                    WHEN 'coordinator' THEN 'منسق'
                    WHEN 'supplier' THEN 'مورد'
                    ELSE v_role_name
                END
            ), 
            CONCAT(
                'تمت عملية تحديث حساب ', 
                CASE v_role_name
                    WHEN 'coordinator' THEN 'المنسق'
                    WHEN 'supplier' THEN 'المورد'
                    ELSE v_role_name
                END,
                '\nرقم الحساب: ', p_user_id, '\n',
                'الإسم: ', COALESCE(p_full_name, (SELECT `full_name` FROM `Users` WHERE `user_id` = p_user_id)), '\n',
                'رقم الهاتف: ', COALESCE(p_phone_number, (SELECT `phone_number` FROM `Users` WHERE `user_id` = p_user_id)), '\n',
                'البريد: ', COALESCE(p_email, (SELECT `email` FROM `Users` WHERE `user_id` = p_user_id))
            )
        );
        
        
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_user_id,
            CONCAT('update_', v_role_name, '_user'), 
            'تم تحديث حسابك', 
            CONCAT(
                'تمت عملية تحديث حسابك بنجاح \n', 
                'الإسم: ', COALESCE(p_full_name, (SELECT `full_name` FROM `Users` WHERE `user_id` = p_user_id)), '\n',
                'رقم الهاتف: ', COALESCE(p_phone_number, (SELECT `phone_number` FROM `Users` WHERE `user_id` = p_user_id)), '\n',
                'البريد: ', COALESCE(p_email, (SELECT `email` FROM `Users` WHERE `user_id` = p_user_id))
            )
        );
        
        COMMIT;
        CALL sp_get_user_by_id(p_user_id);
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_user_byadmin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_user_byadmin`(
        IN `p_user_id` INT,
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_password` VARCHAR(255),
        IN `p_details` JSON
    )
    MODIFIES SQL DATA
    DETERMINISTIC
BEGIN
        DECLARE v_email VARCHAR(255);
        DECLARE v_pass VARCHAR(255);
        SELECT `email`, `password` INTO v_email, v_pass FROM `Users` WHERE `user_id` = 1;
        CALL sp_update_user(
            v_email, v_pass, p_user_id, p_full_name, p_phone_number, p_img_url, p_email, p_password, p_details
        );
    END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_upsert_fcm_token` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_upsert_fcm_token`(
    IN `p_user_id` INT,
    IN `p_token` TEXT,
    IN `p_device_type` VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    
    INSERT INTO `User_FCM_Tokens` (`user_id`, `token`, `device_type`)
    VALUES (`p_user_id`, `p_token`, `p_device_type`)
    ON DUPLICATE KEY UPDATE 
        `user_id` = VALUES(`user_id`),
        `device_type` = VALUES(`device_type`),
        `updated_at` = CURRENT_TIMESTAMP;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `vw_clients_detailed`
--

/*!50001 DROP VIEW IF EXISTS `vw_clients_detailed`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_clients_detailed` AS select `c`.`client_id` AS `client_id`,`c`.`coordinator_id` AS `coordinator_id`,`c`.`creator_user_role` AS `creator_user_role`,`c`.`full_name` AS `client_name`,`c`.`phone_number` AS `client_phone`,`c`.`img_url` AS `img_url`,`c`.`email` AS `email`,`c`.`address` AS `address`,`c`.`created_at` AS `created_at`,`c`.`updated_at` AS `updated_at`,`c`.`deleted_at` AS `deleted_at`,ifnull(count(distinct `e`.`event_id`),0) AS `total_events`,ifnull(count(distinct `t`.`task_assign_id`),0) AS `total_tasks`,ifnull(sum(case when `t`.`status` = 'COMPLETED' then 1 else 0 end),0) AS `completed_tasks`,ifnull(sum(case when `t`.`status` = 'PENDING' then 1 else 0 end),0) AS `pending_tasks`,ifnull(sum(case when `t`.`status` = 'CANCELLED' then 1 else 0 end),0) AS `cancelled_tasks`,ifnull(sum(`t`.`cost`),0.0) AS `total_spent` from ((`Clients` `c` left join `Events` `e` on(`c`.`client_id` = `e`.`client_id` and `e`.`deleted_at` is null)) left join `Task_Assigns` `t` on(`e`.`event_id` = `t`.`event_id` and `t`.`deleted_at` is null)) where `c`.`deleted_at` is null group by `c`.`client_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_events_detailed`
--

/*!50001 DROP VIEW IF EXISTS `vw_events_detailed`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_events_detailed` AS select `e`.`event_id` AS `event_id`,`e`.`coordinator_id` AS `coordinator_id`,`e`.`client_id` AS `client_id`,`e`.`event_name` AS `event_name`,`e`.`description` AS `description`,`e`.`location` AS `location`,`e`.`img_url` AS `img_url`,`e`.`budget` AS `budget`,`e`.`event_date` AS `event_date`,`e`.`event_duration` AS `event_duration`,`e`.`event_duration_unit` AS `event_duration_unit`,`e`.`created_at` AS `created_at`,`e`.`updated_at` AS `updated_at`,`e`.`deleted_at` AS `deleted_at`,`e`.`is_deleted` AS `is_deleted`,`e`.`status` AS `status`,`e`.`coordinator_name` AS `coordinator_name`,`e`.`coordinator_phone` AS `coordinator_phone`,`e`.`coordinator_email` AS `coordinator_email`,`e`.`total_income` AS `total_income`,`e`.`total_expenses` AS `total_expenses`,`e`.`total_tasks` AS `total_tasks`,`e`.`completed_tasks` AS `completed_tasks`,`e`.`completion_percentage` AS `completion_percentage`,`c`.`full_name` AS `client_name`,`c`.`phone_number` AS `client_phone`,`c`.`email` AS `client_email`,`c`.`img_url` AS `client_img` from (`vw_events_detailed_with_coor` `e` join `Clients` `c` on(`e`.`client_id` = `c`.`client_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_events_detailed_with_coor`
--

/*!50001 DROP VIEW IF EXISTS `vw_events_detailed_with_coor`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_events_detailed_with_coor` AS select `e`.`event_id` AS `event_id`,`e`.`coordinator_id` AS `coordinator_id`,`e`.`client_id` AS `client_id`,`e`.`event_name` AS `event_name`,`e`.`description` AS `description`,`e`.`location` AS `location`,`e`.`img_url` AS `img_url`,`e`.`budget` AS `budget`,`e`.`event_date` AS `event_date`,`e`.`event_duration` AS `event_duration`,`e`.`event_duration_unit` AS `event_duration_unit`,`e`.`created_at` AS `created_at`,`e`.`updated_at` AS `updated_at`,`e`.`deleted_at` AS `deleted_at`,`e`.`deleted_at` is not null AS `is_deleted`,`fn_event_get_status`(`e`.`event_id`) AS `status`,`co`.`full_name` AS `coordinator_name`,`co`.`phone_number` AS `coordinator_phone`,`co`.`email` AS `coordinator_email`,coalesce((select sum(`inc`.`amount`) from `Incomes` `inc` where `inc`.`event_id` = `e`.`event_id` and `inc`.`deleted_at` is null),0) AS `total_income`,coalesce((select sum(`ta`.`cost`) from `Task_Assigns` `ta` where `ta`.`event_id` = `e`.`event_id` and `ta`.`deleted_at` is null),0) AS `total_expenses`,(select count(0) from `Task_Assigns` `ta` where `ta`.`event_id` = `e`.`event_id` and `ta`.`deleted_at` is null) AS `total_tasks`,(select count(0) from `Task_Assigns` `ta` where `ta`.`event_id` = `e`.`event_id` and `ta`.`status` = 'COMPLETED' and `ta`.`deleted_at` is null) AS `completed_tasks`,concat(round(100 * (select count(0) from `Task_Assigns` `ta` where `ta`.`event_id` = `e`.`event_id` and `ta`.`status` = 'COMPLETED' and `ta`.`deleted_at` is null) / nullif((select count(0) from `Task_Assigns` `ta` where `ta`.`event_id` = `e`.`event_id` and `ta`.`deleted_at` is null),0),2),'%') AS `completion_percentage` from (`Events` `e` join `Users` `co` on(`e`.`coordinator_id` = `co`.`user_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_get_all_admins`
--

/*!50001 DROP VIEW IF EXISTS `vw_get_all_admins`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_get_all_admins` AS select `u`.`user_id` AS `user_id`,`u`.`role_name` AS `role_name`,`u`.`full_name` AS `full_name`,`u`.`phone_number` AS `phone_number`,`u`.`img_url` AS `img_url`,`u`.`email` AS `email`,`u`.`password` AS `password`,`u`.`is_active` AS `is_active`,`u`.`created_at` AS `created_at`,`u`.`updated_at` AS `updated_at`,`u`.`deleted_at` AS `deleted_at`,`u`.`deleted_at` is not null AS `is_deleted` from `Users` `u` where `u`.`role_name` = 'admin' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_get_all_coordinators`
--

/*!50001 DROP VIEW IF EXISTS `vw_get_all_coordinators`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_get_all_coordinators` AS select `u`.`user_id` AS `user_id`,`u`.`role_name` AS `role_name`,`u`.`full_name` AS `full_name`,`u`.`phone_number` AS `phone_number`,`u`.`img_url` AS `img_url`,`u`.`email` AS `email`,`u`.`password` AS `password`,`u`.`is_active` AS `is_active`,`u`.`created_at` AS `created_at`,`u`.`updated_at` AS `updated_at`,`u`.`deleted_at` AS `deleted_at`,`u`.`deleted_at` is not null AS `is_deleted` from `Users` `u` where `u`.`role_name` = 'coordinator' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_get_all_suppliers`
--

/*!50001 DROP VIEW IF EXISTS `vw_get_all_suppliers`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_get_all_suppliers` AS select `u`.`user_id` AS `user_id`,`u`.`role_name` AS `role_name`,`u`.`full_name` AS `full_name`,`u`.`phone_number` AS `phone_number`,`u`.`img_url` AS `img_url`,`u`.`email` AS `email`,`u`.`password` AS `password`,`u`.`is_active` AS `is_active`,`u`.`created_at` AS `created_at`,`u`.`updated_at` AS `updated_at`,`u`.`deleted_at` AS `deleted_at`,`u`.`deleted_at` is not null AS `is_deleted`,`fn_user_get_detail`(`u`.`user_id`,'address') AS `address` from `Users` `u` where `u`.`role_name` = 'supplier' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_get_all_suppliers_and_services`
--

/*!50001 DROP VIEW IF EXISTS `vw_get_all_suppliers_and_services`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_get_all_suppliers_and_services` AS select `ser`.`service_id` AS `service_id`,`sup`.`user_id` AS `supplier_id`,`ser`.`service_name` AS `service_name`,`ser`.`description` AS `service_description`,`sup`.`role_name` AS `role_name`,`sup`.`full_name` AS `full_name`,`sup`.`phone_number` AS `phone_number`,`sup`.`email` AS `email`,`sup`.`password` AS `password`,`sup`.`img_url` AS `img_url`,`sup`.`is_active` AS `is_active`,`sup`.`address` AS `address`,case when `ss`.`service_id` is not null and `ss`.`deleted_at` is null then 1 else 0 end AS `supplier_has_service`,`ser`.`deleted_at` is not null AS `service_is_deleted`,`sup`.`is_deleted` AS `supplier_is_deleted`,`ser`.`created_at` AS `service_created_at`,`ser`.`updated_at` AS `service_updated_at`,`ser`.`deleted_at` AS `service_deleted_at`,`sup`.`created_at` AS `supplier_created_at`,`sup`.`updated_at` AS `supplier_updated_at`,`sup`.`deleted_at` AS `supplier_deleted_at` from ((`Services` `ser` join `vw_get_all_suppliers` `sup`) left join `Supplier_Services` `ss` on(`ss`.`service_id` = `ser`.`service_id` and `ss`.`supplier_id` = `sup`.`user_id`)) order by `ser`.`service_id`,`sup`.`user_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_notifications`
--

/*!50001 DROP VIEW IF EXISTS `vw_notifications`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_notifications` AS select `n`.`notification_id` AS `notification_id`,`n`.`user_id` AS `user_id`,`n`.`type` AS `type`,`n`.`title` AS `title`,`n`.`message` AS `message`,`n`.`is_read` AS `is_read`,`n`.`created_at` AS `created_at`,`n`.`updated_at` AS `updated_at`,`n`.`deleted_at` AS `deleted_at`,case when `fn_user_has_role`(`n`.`user_id`,'coordinator') then 'Coordinator' when `fn_user_has_role`(`n`.`user_id`,'supplier') then 'Supplier' else 'admin' end AS `recipient_type`,`u`.`full_name` AS `recipient_name` from (`Notifications` `n` left join `Users` `u` on(`n`.`user_id` = `u`.`user_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_task_reminders_details`
--

/*!50001 DROP VIEW IF EXISTS `vw_task_reminders_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_task_reminders_details` AS select `r`.`reminder_id` AS `reminder_id`,`r`.`task_assign_id` AS `task_assign_id`,`r`.`user_id` AS `user_id`,`u`.`full_name` AS `user_name`,`u`.`email` AS `user_email`,`r`.`reminder_type` AS `reminder_type`,`r`.`reminder_value` AS `reminder_value`,`r`.`reminder_unit` AS `reminder_unit`,`r`.`is_active` AS `is_active`,`r`.`created_at` AS `created_at`,`ta`.`description` AS `task_description`,`ta`.`status` AS `task_status`,`ta`.`date_due` AS `date_due`,`e`.`event_name` AS `event_name`,`e`.`event_date` AS `event_date` from (((`Task_Reminders` `r` join `Users` `u` on(`r`.`user_id` = `u`.`user_id`)) join `Task_Assigns` `ta` on(`r`.`task_assign_id` = `ta`.`task_assign_id`)) join `Events` `e` on(`ta`.`event_id` = `e`.`event_id`)) where `r`.`deleted_at` is null */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_tasks_full`
--

/*!50001 DROP VIEW IF EXISTS `vw_tasks_full`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_tasks_full` AS select `ta`.`task_assign_id` AS `task_assign_id`,`ta`.`event_id` AS `event_id`,`ta`.`type_task` AS `type_task`,`ta`.`notes` AS `notes`,`ta`.`service_id` AS `service_id`,`ta`.`user_assign_id` AS `user_assign_id`,`ta`.`coordinator_id` AS `coordinator_id`,`ta`.`status` AS `status`,`ta`.`description` AS `description`,`ta`.`cost` AS `cost`,`ta`.`url_image` AS `url_image`,`ta`.`date_start` AS `date_start`,`ta`.`date_due` AS `date_due`,`ta`.`date_completion` AS `date_completion`,`ta`.`created_at` AS `created_at`,`ta`.`updated_at` AS `updated_at`,`ta`.`deleted_at` AS `deleted_at`,`e`.`event_name` AS `event_name`,`creator`.`full_name` AS `task_creator_name`,case when `fn_user_has_role`(`ta`.`user_assign_id`,'coordinator') then 'coordinator' when `fn_user_has_role`(`ta`.`user_assign_id`,'supplier') then 'supplier' else 'unknown' end AS `assignment_type`,`assignee`.`full_name` AS `assigne_name`,`r`.`rating_value` AS `rating_value`,`r`.`rating_comment` AS `rating_comment`,`r`.`rated_at` AS `rated_at`,`rm`.`reminder_value` AS `reminder_value`,`rm`.`reminder_unit` AS `reminder_unit` from (((((`Task_Assigns` `ta` left join `Events` `e` on(`ta`.`event_id` = `e`.`event_id`)) left join `Users` `creator` on(`ta`.`coordinator_id` = `creator`.`user_id`)) left join `Users` `assignee` on(`ta`.`user_assign_id` = `assignee`.`user_id`)) left join `Ratings_Task_Assign` `r` on(`ta`.`task_assign_id` = `r`.`task_assign_id`)) left join `Task_Reminders` `rm` on(`ta`.`task_assign_id` = `rm`.`task_assign_id`)) where `ta`.`deleted_at` is null */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-04-20 15:18:59
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.5-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: my_party_4
-- ------------------------------------------------------
-- Server version	11.8.5-MariaDB-3 from Debian

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Dumping data for table `Roles`
--

LOCK TABLES `Roles` WRITE;
/*!40000 ALTER TABLE `Roles` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `Roles` VALUES
('admin','2026-04-20 11:45:51',NULL,NULL),
('coordinator','2026-04-20 11:45:51',NULL,NULL),
('supplier','2026-04-20 11:45:51',NULL,NULL);
/*!40000 ALTER TABLE `Roles` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `Permissions`
--

LOCK TABLES `Permissions` WRITE;
/*!40000 ALTER TABLE `Permissions` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `Permissions` VALUES
('assign_task','2026-04-20 11:45:52',NULL,NULL),
('create_admin_user','2026-04-20 11:45:52',NULL,NULL),
('create_client','2026-04-20 11:45:52',NULL,NULL),
('create_coordinator_user','2026-04-20 11:45:52',NULL,NULL),
('create_event','2026-04-20 11:45:52',NULL,NULL),
('create_income','2026-04-20 11:45:52',NULL,NULL),
('create_service','2026-04-20 11:45:52',NULL,NULL),
('create_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('create_task','2026-04-20 11:45:52',NULL,NULL),
('delete_admin_user','2026-04-20 11:45:52',NULL,NULL),
('delete_client','2026-04-20 11:45:52',NULL,NULL),
('delete_coordinator_user','2026-04-20 11:45:52',NULL,NULL),
('delete_event','2026-04-20 11:45:52',NULL,NULL),
('delete_income','2026-04-20 11:45:52',NULL,NULL),
('delete_service','2026-04-20 11:45:52',NULL,NULL),
('delete_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('delete_task','2026-04-20 11:45:52',NULL,NULL),
('edit_admin_user','2026-04-20 11:45:52',NULL,NULL),
('edit_client','2026-04-20 11:45:52',NULL,NULL),
('edit_coordinator_user','2026-04-20 11:45:52',NULL,NULL),
('edit_event','2026-04-20 11:45:52',NULL,NULL),
('edit_income','2026-04-20 11:45:52',NULL,NULL),
('edit_service','2026-04-20 11:45:52',NULL,NULL),
('edit_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('edit_task','2026-04-20 11:45:52',NULL,NULL),
('rate_task','2026-04-20 11:45:52',NULL,NULL),
('view_admin_user','2026-04-20 11:45:52',NULL,NULL),
('view_client','2026-04-20 11:45:52',NULL,NULL),
('view_coordinator_user','2026-04-20 11:45:52',NULL,NULL),
('view_event','2026-04-20 11:45:52',NULL,NULL),
('view_income','2026-04-20 11:45:52',NULL,NULL),
('view_reports','2026-04-20 11:45:52',NULL,NULL),
('view_service','2026-04-20 11:45:52',NULL,NULL),
('view_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('view_task','2026-04-20 11:45:52',NULL,NULL);
/*!40000 ALTER TABLE `Permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `Role_Details`
--

LOCK TABLES `Role_Details` WRITE;
/*!40000 ALTER TABLE `Role_Details` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `Role_Details` VALUES
('address','supplier','2026-04-20 11:45:51',NULL,NULL),
('bio','coordinator','2026-04-20 11:45:51',NULL,NULL),
('bio','supplier','2026-04-20 11:45:51',NULL,NULL),
('city','coordinator','2026-04-20 11:45:51',NULL,NULL),
('city','supplier','2026-04-20 11:45:51',NULL,NULL),
('company_name','supplier','2026-04-20 11:45:51',NULL,NULL),
('experience_years','coordinator','2026-04-20 11:45:51',NULL,NULL),
('license','supplier','2026-04-20 11:45:51',NULL,NULL),
('notes','supplier','2026-04-20 11:45:51',NULL,NULL),
('rating_internal','supplier','2026-04-20 11:45:51',NULL,NULL);
/*!40000 ALTER TABLE `Role_Details` ENABLE KEYS */;
UNLOCK TABLES;
commit;

--
-- Dumping data for table `Role_Permissions`
--

LOCK TABLES `Role_Permissions` WRITE;
/*!40000 ALTER TABLE `Role_Permissions` DISABLE KEYS */;
set autocommit=0;
INSERT INTO `Role_Permissions` VALUES
('admin','assign_task','2026-04-20 11:45:52',NULL,NULL),
('admin','create_admin_user','2026-04-20 11:45:52',NULL,NULL),
('admin','create_client','2026-04-20 11:45:52',NULL,NULL),
('admin','create_coordinator_user','2026-04-20 11:45:52',NULL,NULL),
('admin','create_event','2026-04-20 11:45:52',NULL,NULL),
('admin','create_income','2026-04-20 11:45:52',NULL,NULL),
('admin','create_service','2026-04-20 11:45:52',NULL,NULL),
('admin','create_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('admin','create_task','2026-04-20 11:45:52',NULL,NULL),
('admin','delete_admin_user','2026-04-20 11:45:52',NULL,NULL),
('admin','delete_client','2026-04-20 11:45:52',NULL,NULL),
('admin','delete_coordinator_user','2026-04-20 11:45:52',NULL,NULL),
('admin','delete_event','2026-04-20 11:45:52',NULL,NULL),
('admin','delete_income','2026-04-20 11:45:52',NULL,NULL),
('admin','delete_service','2026-04-20 11:45:52',NULL,NULL),
('admin','delete_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('admin','delete_task','2026-04-20 11:45:52',NULL,NULL),
('admin','edit_admin_user','2026-04-20 11:45:52',NULL,NULL),
('admin','edit_client','2026-04-20 11:45:52',NULL,NULL),
('admin','edit_coordinator_user','2026-04-20 11:45:52',NULL,NULL),
('admin','edit_event','2026-04-20 11:45:52',NULL,NULL),
('admin','edit_income','2026-04-20 11:45:52',NULL,NULL),
('admin','edit_service','2026-04-20 11:45:52',NULL,NULL),
('admin','edit_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('admin','edit_task','2026-04-20 11:45:52',NULL,NULL),
('admin','rate_task','2026-04-20 11:45:52',NULL,NULL),
('admin','view_admin_user','2026-04-20 11:45:52',NULL,NULL),
('admin','view_client','2026-04-20 11:45:52',NULL,NULL),
('admin','view_coordinator_user','2026-04-20 11:45:52',NULL,NULL),
('admin','view_event','2026-04-20 11:45:52',NULL,NULL),
('admin','view_income','2026-04-20 11:45:52',NULL,NULL),
('admin','view_reports','2026-04-20 11:45:52',NULL,NULL),
('admin','view_service','2026-04-20 11:45:52',NULL,NULL),
('admin','view_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('admin','view_task','2026-04-20 11:45:52',NULL,NULL),
('coordinator','assign_task','2026-04-20 11:45:52',NULL,NULL),
('coordinator','create_client','2026-04-20 11:45:52',NULL,NULL),
('coordinator','create_event','2026-04-20 11:45:52',NULL,NULL),
('coordinator','delete_client','2026-04-20 11:45:52',NULL,NULL),
('coordinator','delete_event','2026-04-20 11:45:52',NULL,NULL),
('coordinator','edit_client','2026-04-20 11:45:52',NULL,NULL),
('coordinator','edit_event','2026-04-20 11:45:52',NULL,NULL),
('coordinator','rate_task','2026-04-20 11:45:52',NULL,NULL),
('coordinator','view_reports','2026-04-20 11:45:52',NULL,NULL),
('supplier','create_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('supplier','delete_supplier_user','2026-04-20 11:45:52',NULL,NULL),
('supplier','edit_supplier_user','2026-04-20 11:45:52',NULL,NULL);
/*!40000 ALTER TABLE `Role_Permissions` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-04-20 15:18:59
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.5-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: my_party_4
-- ------------------------------------------------------
-- Server version	11.8.5-MariaDB-3 from Debian

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Dumping data for table `Users`
--
-- WHERE:  role_name='admin'

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
set autocommit=0;
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;
commit;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_before_insert` BEFORE INSERT ON `Users`
    FOR EACH ROW 
    BEGIN
        IF EXISTS (SELECT 1 FROM `Users` WHERE `email` = NEW.`email`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists for another user';
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_before_update` BEFORE UPDATE ON `Users`
    FOR EACH ROW
    BEGIN
        IF NEW.`email` != OLD.`email` THEN
            IF EXISTS (SELECT 1 FROM `Users` WHERE `email` = NEW.`email` AND `user_id` != NEW.`user_id`) THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists for another user';
            END IF;
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_users_after_update` AFTER UPDATE ON `Users`
    FOR EACH ROW
    BEGIN 
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL AND OLD.role_name = 'coordinator' THEN 
            CALL sp_delete_all_events_of_coordinator(OLD.user_id);
        END IF;
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-04-20 15:18:59
