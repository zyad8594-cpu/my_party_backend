DELIMITER $$
CREATE PROCEDURE `sp_approve_service_request`(
    IN `p_request_id` INT,
    IN `p_service_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
    IN `p_description` TEXT,
    IN `p_admin_email` VARCHAR(100)
)
DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
BEGIN 
    DECLARE v_service_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;

    UPDATE `Service_Requests` SET `status` = 'APPROVED' WHERE `id` = p_request_id;

    INSERT INTO `Services` (`service_name`, `description`) 
        VALUES (p_service_name, p_description);
    SET v_service_id = LAST_INSERT_ID();

    INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
    VALUES (1,
        'create_service', 
        'خدمة جديدة (من مقترح)', 
        CONCAT(
            'لقد قام المدير "', COALESCE(p_admin_email, 'admin'), '" بإعتماد خدمة جديدة\n' , 
            'رقم الخدمة: ', v_service_id, '\n',
            'إسم الخدمة: ', p_service_name, '\n',
            'الوصف: ', COALESCE(p_description, 'لا يوجد وصف')
        )
    );
    
    INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        SELECT `user_id`, 'create_service', 'إضافة خدمة جديدة', CONCAT('تم إضافة خدمة جديدة بالنظام: "', p_service_name, '"') 
        FROM `Users` WHERE `deleted_at` IS NULL AND `user_id` != 1;

    COMMIT;

    SELECT * FROM `Services` WHERE `service_id` = v_service_id;
END$$
DELIMITER ;
