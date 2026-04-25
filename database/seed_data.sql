-- Seed Data for My Party App (All Quick Login Users)

USE my_party_4;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Task_Assigns;
TRUNCATE TABLE Events;
TRUNCATE TABLE Clients;
TRUNCATE TABLE Supplier_Services;
TRUNCATE TABLE Services;
TRUNCATE TABLE Users;
TRUNCATE TABLE Notifications;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Manually insert the first admin
INSERT INTO `Users` (`user_id`, `role_name`, `full_name`, `phone_number`, `email`, `password`, `is_active`)
VALUES (1, 'admin', 'System Admin', '1234567890', 'admin@myparty.com', '123456', 1);

-- 2. Register all Quick Login coordinators
CALL sp_register('coordinator', 'Ahmed', '001', NULL, 'ahmed@myparty.com', '123456', '{}', FALSE);
CALL sp_register('coordinator', 'Sadalh', '002', NULL, 'sadalh@myparty.com', '123456', '{}', FALSE);
CALL sp_register('coordinator', 'Mona', '003', NULL, 'mona@myparty.com', '123456', '{}', FALSE);
CALL sp_register('coordinator', 'Nidal', '004', NULL, 'nidal@myparty.com', '123456', '{}', FALSE);
CALL sp_register('coordinator', 'Rana', '005', NULL, 'rana@myparty.com', '123456', '{}', FALSE);
CALL sp_register('coordinator', 'Bassem', '006', NULL, 'bassem@myparty.com', '123456', '{}', FALSE);

-- 3. Register all Quick Login suppliers
CALL sp_register('supplier', 'Sami', '007', NULL, 'sami@myparty.com', '123456', '{}', FALSE);
CALL sp_register('supplier', 'Khaled', '008', NULL, 'khaled@myparty.com', '123456', '{}', FALSE);
CALL sp_register('supplier', 'Gram', '009', NULL, 'gram@myparty.com', '123456', '{}', FALSE);
CALL sp_register('supplier', 'Akram', '010', NULL, 'akram@myparty.com', '123456', '{}', FALSE);

-- 4. Services
INSERT INTO `Services` (`service_id`, `service_name`, `description`)
VALUES 
(1, 'Catering', 'Food and drinks services'),
(2, 'Photography', 'Professional photo and video'),
(3, 'Music/DJ', 'Sound system and entertainment');

-- 5. Supplier Services (Assign Sami to Catering)
-- Sami's user_id will be 8 (Admin=1, Ahmed=2, Sadalh=3, Mona=4, Nidal=5, Rana=6, Bassem=7, Sami=8)
INSERT INTO `Supplier_Services` (`supplier_id`, `service_id`)
VALUES (8, 1);

-- 6. Create Client (Owned by Ahmed=2)
CALL sp_create_client(2, 'Ahmad Client', '5566778899', NULL, 'ahmad@client.com', 'Riyadh, Saudi Arabia', FALSE);

-- 7. Create Event
CALL sp_create_event(1, 2, 'Amazing Wedding', 'A grand wedding celebration', NULL, DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'Grand Ballroom', 50000.00, 1, 'DAY');

-- 8. Create Task (Assigned to Sami=8)
SET @task_id = 0;
CALL sp_create_task(1, 1, 'Preparation', 'PENDING', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 8, 'Confirming the menu with catering', 0.00, @task_id);
