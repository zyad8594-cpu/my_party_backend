-- مراقبة المناسبات (انتهاء أو اقتراب الانتهاء)
DELIMITER $$
CREATE PROCEDURE Check_Events_Status()
    BEGIN
        -- إشعارات للمناسبات التي ستنتهي خلال 7 أيام (يوشك على الانتهاء)
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

        -- إشعارات للمناسبات التي انتهت بالفعل
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
    END$$
DELIMITER ;

-- مراقبة الميزانية والدفعات
DELIMITER $$
CREATE PROCEDURE Check_Budget_And_Payments()
    BEGIN
        -- لكل حدث: حساب إجمالي التكاليف (cost) وإجمالي الدفعات (Incomes)
        -- إشعار إذا تجاوزت التكاليف الميزانية
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

        -- إشعار إذا كانت الدفعات أقل من التكاليف والحدث على وشك الانتهاء (خلال 7 أيام)
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
    END$$
DELIMITER ;

-- مراقبة المهام (المواعيد النهائية والتأخير)
DELIMITER $$
CREATE PROCEDURE Check_Tasks_Deadlines()
    BEGIN
        -- المهام المستحقة خلال 3 أيام (للموردين والمنسقين)
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

        -- المهام المتأخرة (للمنسقين)
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
    END$$
DELIMITER ;

-- إجراء شامل لاستدعاء جميع عمليات المراقبة
DELIMITER $$
CREATE PROCEDURE Run_Monitoring()
    BEGIN
        CALL Check_Events_Status();
        CALL Check_Tasks_Deadlines();
        CALL Check_Budget_And_Payments();
    END$$
DELIMITER ;


-- سنقوم بتشغيل الفحص كل 6 ساعات (يمكن تعديل الفاصل حسب الحاجة).
CREATE EVENT IF NOT EXISTS Event_Monitoring
    ON SCHEDULE EVERY 6 HOUR
    STARTS CURRENT_TIMESTAMP
    DO
        CALL Run_Monitoring();

-- إنشاء حدث لتشغيل التذكيرات كل ساعة
CREATE EVENT `event_generate_reminders_hourly`
    ON SCHEDULE EVERY 1 HOUR
    STARTS CURRENT_TIMESTAMP
    DO CALL sp_generate_task_reminders();

DELIMITER $$
CREATE PROCEDURE `sp_upsert_fcm_token`(
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
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_fcm_token`(
    IN `p_user_id` INT,
    IN `p_token` TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    
    DELETE FROM `User_FCM_Tokens` 
    WHERE `user_id` = `p_user_id` AND `token` = `p_token`;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_get_supplier_event_details`(
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
END $$
DELIMITER ;

-- =====================================================
-- العرض التفصيلي للعملاء
-- =====================================================
CREATE OR REPLACE VIEW `vw_clients_detailed` AS
SELECT 
    c.client_id,
    c.coordinator_id,
    c.creator_user_role,
    c.full_name AS client_name,
    c.phone_number AS client_phone,
    c.img_url,
    c.email,
    c.address,
    c.created_at,
    c.updated_at,
    c.deleted_at,
    IFNULL(COUNT(DISTINCT e.event_id), 0) AS total_events,
    IFNULL(COUNT(DISTINCT t.task_assign_id), 0) AS total_tasks,
    IFNULL(SUM(CASE WHEN t.status = 'COMPLETED' THEN 1 ELSE 0 END), 0) AS completed_tasks,
    IFNULL(SUM(CASE WHEN t.status = 'PENDING' THEN 1 ELSE 0 END), 0) AS pending_tasks,
    IFNULL(SUM(CASE WHEN t.status = 'CANCELLED' THEN 1 ELSE 0 END), 0) AS cancelled_tasks,
    IFNULL(SUM(t.cost), 0.0) AS total_spent
FROM 
    `Clients` c
LEFT JOIN 
    `Events` e ON c.client_id = e.client_id AND e.deleted_at IS NULL
LEFT JOIN 
    `Task_Assigns` t ON e.event_id = t.event_id AND t.deleted_at IS NULL
WHERE c.deleted_at IS NULL
GROUP BY 
    c.client_id;