DROP DATABASE IF EXISTS `my_party_4`;


CREATE DATABASE IF NOT EXISTS `my_party_4`
    DEFAULT CHARACTER SET utf8mb4 -- نوع الترميز
    COLLATE utf8mb4_general_ci; -- نوع الترتيب
USE `my_party_4`;


-- =====================================================
-- إنشاء الجداول الأساسية
-- =====================================================


-- جدول الأدوار (تم إضافة عمود deleted_at)
CREATE TABLE IF NOT EXISTS `Roles` (
    `role_name` VARCHAR(50) NOT NULL PRIMARY KEY, -- اسم الدور
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الدور
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الدور
    `deleted_at` TIMESTAMP NULL DEFAULT NULL -- تاريخ حذف الدور
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- إضافة الأدوار
INSERT IGNORE INTO `Roles` (`role_name`) VALUES
    ('admin'), ('coordinator'), ('supplier');


-- جدول تفاصيل الأدوار (الحقول المسموح بها لكل دور)
CREATE TABLE IF NOT EXISTS `Role_Details` (
    `detail_name` VARCHAR(255) NOT NULL, -- اسم التفصيل
    `role_name` VARCHAR(50) NOT NULL, -- اسم الدور
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء التفصيل
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث التفصيل
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`detail_name`, `role_name`), -- مفتاح أساسي
    FOREIGN KEY (`role_name`) REFERENCES `Roles`(`role_name`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف الدور يتم حذف التفاصيل
    INDEX `idx_role_name` (`role_name`) -- فهرس على اسم الدور
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- إضافة التفاصيل لكل دور
INSERT IGNORE INTO `Role_Details` (`detail_name`, `role_name`) VALUES
    ('address', 'supplier'), 
    ('notes', 'supplier'),
    ('company_name', 'supplier'),
    ('license', 'supplier'),
    ('rating_internal', 'supplier'),
    ('city', 'supplier'),
    ('bio', 'supplier'),
    ('city', 'coordinator'),
    ('bio', 'coordinator'),
    ('experience_years', 'coordinator');


-- جدول الصلاحيات
CREATE TABLE IF NOT EXISTS `Permissions` (
    `permission_name` VARCHAR(100) NOT NULL PRIMARY KEY, -- اسم الصلاحية
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الصلاحية
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الصلاحية
    `deleted_at` TIMESTAMP NULL DEFAULT NULL -- تاريخ حذف الصلاحية
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- إضافة الصلاحيات
INSERT IGNORE INTO `Permissions` (`permission_name`) VALUES
    ('view_admin_user'), ('create_admin_user'), ('edit_admin_user'), ('delete_admin_user'),
    ('view_coordinator_user'), ('create_coordinator_user'), ('edit_coordinator_user'), ('delete_coordinator_user'),
    ('view_supplier_user'), ('create_supplier_user'), ('edit_supplier_user'), ('delete_supplier_user'),
    ('view_service'), ('create_service'), ('edit_service'), ('delete_service'),


    ('view_client'), ('create_client'), ('edit_client'), ('delete_client'),
    ('view_task'), ('create_task'), ('edit_task'), ('delete_task'), ('assign_task'), ('rate_task'),
    ('view_event'), ('create_event'), ('edit_event'), ('delete_event'),
    ('view_income'), ('create_income'), ('edit_income'), ('delete_income'),
     ('view_reports');


-- جدول صلاحيات الأدوار
CREATE TABLE IF NOT EXISTS `Role_Permissions` (
    `role_name` VARCHAR(50) NOT NULL, -- اسم الدور
    `permission_name` VARCHAR(100) NOT NULL, -- اسم الصلاحية
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الصلاحية
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الصلاحية
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`role_name`, `permission_name`), -- مفتاح أساسي
    FOREIGN KEY (`role_name`) REFERENCES `Roles`(`role_name`) ON DELETE CASCADE ON UPDATE CASCADE, -- مفتاح خارجي عند حذف الدور يتم حذف الصلاحيات
    FOREIGN KEY (`permission_name`) REFERENCES `Permissions`(`permission_name`) ON DELETE CASCADE ON UPDATE CASCADE, -- مفتاح خارجي عند حذف الصلاحية يتم حذف الصلاحيات
    INDEX `idx_permission_name` (`permission_name`) -- فهرس على اسم الصلاحية
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- إضافة كل الصلاحيات للادمن
INSERT IGNORE INTO `Role_Permissions` (`role_name`, `permission_name`)
    SELECT r.`role_name`, p.`permission_name`
        FROM `Roles` r CROSS JOIN `Permissions` p
        WHERE r.`role_name` = 'admin' AND p.`deleted_at` IS NULL;


-- إضافة الصلاحيات لكل دور
INSERT IGNORE INTO `Role_Permissions` (`role_name`, `permission_name`)
    VALUES
       
        ('coordinator', 'create_client'), ('coordinator', 'edit_client'), ('coordinator', 'delete_client'),
        ('coordinator', 'create_event'), ('coordinator', 'edit_event'), ('coordinator', 'delete_event'),
        ('coordinator', 'assign_task'), ('coordinator', 'rate_task'), ('coordinator', 'view_reports'),


        ('supplier', 'create_supplier_user'), ('supplier', 'edit_supplier_user'), ('supplier', 'delete_supplier_user');


-- جدول المستخدمين الأساسي
CREATE TABLE IF NOT EXISTS `Users` (
    `user_id` INT PRIMARY KEY AUTO_INCREMENT, -- رقم المستخدم
    `role_name` VARCHAR(50) NOT NULL, -- اسم الدور


    `full_name` VARCHAR(255) NOT NULL, -- اسم المستخدم
    `phone_number` VARCHAR(20) NULL UNIQUE DEFAULT NULL, -- رقم الهاتف
    `img_url` TEXT NULL DEFAULT NULL, -- رابط الصورة
    `email` VARCHAR(255) NOT NULL UNIQUE, -- البريد الإلكتروني
    `password` VARCHAR(255) NOT NULL, -- كلمة المرور


    `is_active` BOOLEAN DEFAULT FALSE, -- هل المستخدم نشط
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء المستخدم
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث المستخدم
    `deleted_at` TIMESTAMP NULL DEFAULT NULL, -- تاريخ حذف المستخدم
    FOREIGN KEY (`role_name`) REFERENCES `Roles`(`role_name`), -- مفتاح خارجي عند حذف الدور يتم حذف المستخدمين
    INDEX `idx_role_name` (`role_name`), -- فهرس على اسم الدور
    INDEX `idx_is_active` (`is_active`) -- فهرس على حالة المستخدم
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- جدول صلاحيات المستخدم
CREATE TABLE IF NOT EXISTS `User_Permissions`(
        `user_id` INT NOT NULL,
        `permission_name` VARCHAR(100) NOT NULL,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
        `deleted_at` TIMESTAMP NULL DEFAULT NULL,
       
        PRIMARY KEY (`user_id`, `permission_name`),
        FOREIGN KEY(`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY(`permission_name`) REFERENCES `Permissions`(`permission_name`) ON DELETE CASCADE ON UPDATE CASCADE
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- جدول قيم تفاصيل المستخدم
CREATE TABLE IF NOT EXISTS `User_Detail_Values` (
    `user_id` INT NOT NULL, -- معرف المستخدم
    `detail_name` VARCHAR(255) NOT NULL, -- اسم التفصيل
    `detail_value` TEXT NULL, -- قيمة التفصيل


    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء التفصيل
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث التفصيل
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,


    PRIMARY KEY (`user_id`, `detail_name`), -- مفتاح أساسي
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف المستخدم يتم حذف التفاصيل
    FOREIGN KEY (`detail_name`) REFERENCES `Role_Details`(`detail_name`) ON DELETE CASCADE,
    INDEX `idx_detail_name` (`detail_name`), -- فهرس على اسم التفصيل
    INDEX `idx_user_id` (`user_id`) -- فهرس على معرف المستخدم
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- جدول المستخدمين الأساسي
CREATE TABLE IF NOT EXISTS `Clients` (
    `client_id` INT PRIMARY KEY AUTO_INCREMENT, -- رقم العميل
    `coordinator_id` INT NOT NULL,
    `creator_user_role` VARCHAR(50) NOT NULL CHECK(`creator_user_role` IN ('coordinator', 'admin')),
    `full_name` VARCHAR(255) NOT NULL, -- اسم العميل
    `phone_number` VARCHAR(20) NOT NULL, -- رقم الهاتف
    `img_url` TEXT NULL DEFAULT NULL, -- رابط الصورة
    `email` VARCHAR(255) NULL DEFAULT NULL, -- البريد الإلكتروني
    `address` TEXT NULL DEFAULT NULL,


    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء العميل
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث العميل
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,


    FOREIGN KEY(`coordinator_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `uc_client_phone_in_coordinator_creator` UNIQUE(`coordinator_id`, `phone_number`),
    CONSTRAINT `uc_client_email_in_coordinator_creator` UNIQUE(`coordinator_id`, `email`)
   
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- جدول الأحداث (Events)
CREATE TABLE IF NOT EXISTS `Events` (
    `event_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف الحدث
    `coordinator_id` INT NOT NULL, -- معرف المنسق  
    `client_id` INT NOT NULL, -- معرف العميل


    `event_name` VARCHAR(255) NOT NULL, -- اسم الحدث
    `description` TEXT NULL, -- وصف الحدث
    `location` VARCHAR(255) NULL, -- موقع الحدث
    `img_url` TEXT NULL DEFAULT NULL,
    `budget` DECIMAL(10,2) DEFAULT 0.00, -- ميزانية الحدث
    `event_date` DATE NOT NULL, -- تاريخ الحدث
    `event_duration` INT NULL DEFAULT NULL,
    `event_duration_unit` ENUM('DAY', 'WEEK', 'MONTH') DEFAULT 'WEEK',


    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الحدث
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الحدث
    `deleted_at` TIMESTAMP NULL, -- تاريخ حذف الحدث
    FOREIGN KEY (`client_id`) REFERENCES `Clients`(`client_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف العميل يتم حذف الحدث
    FOREIGN KEY (`coordinator_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف المنسق يتم حذف الحدث
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- جدول الإيرادات
CREATE TABLE IF NOT EXISTS `Incomes` (
    `income_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف الإيراد
    `event_id` INT NOT NULL, -- معرف الحدث
    `amount` DECIMAL(10,2) NOT NULL, -- قيمة الإيراد
    `payment_method` VARCHAR(50) NULL, -- طريقة الدفع
    `payment_date` DATE NOT NULL, -- تاريخ الدفع
    `url_image` VARCHAR(255) NULL, -- رابط الصورة
    `description` TEXT NULL, -- وصف الإيراد
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الإيراد
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الإيراد
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (`event_id`) REFERENCES `Events`(`event_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف الحدث يتم حذف الإيراد
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- جدول الخدمات
CREATE TABLE IF NOT EXISTS `Services` (
    `service_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف الخدمة
    `service_name` VARCHAR(100) NOT NULL, -- اسم الخدمة
    `description` TEXT NULL, -- وصف الخدمة
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الخدمة
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الخدمة
    `deleted_at` TIMESTAMP NULL DEFAULT NULL
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- جدول خدمات الموردين
CREATE TABLE IF NOT EXISTS `Supplier_Services` (
    `supplier_id` INT NOT NULL, -- معرف المورد
    `service_id` INT NOT NULL, -- معرف الخدمة
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`supplier_id`, `service_id`), -- مفتاح أساسي
    FOREIGN KEY (`supplier_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف المورد يتم حذف الخدمة
    FOREIGN KEY (`service_id`) REFERENCES `Services`(`service_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف الخدمة يتم حذف الخدمة
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- جدول المهام
CREATE TABLE IF NOT EXISTS `Task_Assigns` (
    `task_assign_id` INT PRIMARY KEY AUTO_INCREMENT,
    `event_id` INT NOT NULL, -- نقلت من جدول Tasks
    `type_task` VARCHAR(255), -- نقلت من جدول Tasks
    `notes` TEXT NULL, -- نقلت من جدول Tasks


    `service_id` INT NULL DEFAULT NULL,
    `user_assign_id` INT NULL DEFAULT NULL,
    `coordinator_id` INT NOT NULL, -- المنسق الذي قام بالتعيين


    `status` ENUM('PENDING', 'IN_PROGRESS', 'UNDER_REVIEW', 'COMPLETED', 'CANCELLED', 'REJECTED') DEFAULT 'PENDING',
    `description` TEXT NULL,
    `cost` DECIMAL(10,2) DEFAULT 0.00,
    `url_image` VARCHAR(255) NULL,
    `date_start` DATE NULL,
    `date_due` DATE NULL,
    `date_completion` TIMESTAMP NULL,


    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,


    FOREIGN KEY (`event_id`) REFERENCES `Events`(`event_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`service_id`) REFERENCES `Supplier_Services`(`service_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`user_assign_id`) REFERENCES `Supplier_Services`(`supplier_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`coordinator_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,


    INDEX `idx_event_id` (`event_id`),
    INDEX `idx_user_assign_id` (`user_assign_id`),
    INDEX `idx_coordinator_id` (`coordinator_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- جدول تقييم المهام
CREATE TABLE IF NOT EXISTS `Ratings_Task_Assign` (
    `rating_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف التقييم
    `task_assign_id` INT NOT NULL, -- معرف المهمة (مرتبط بـ Task_Assigns)
    `coordinator_id` INT NOT NULL, -- معرف المنسق
    `user_assign_id` INT NOT NULL,
   
    `rating_value` INT NOT NULL CHECK (`rating_value` BETWEEN 1 AND 5), -- قيمة التقييم
    `rating_comment` TEXT NULL DEFAULT NULL, -- تعليق التقييم
    `rated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ التقييم


    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء التقييم
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث التقييم
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (`task_assign_id`) REFERENCES `Task_Assigns`(`task_assign_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف تعيين المهمة يتم حذف التقييم
    FOREIGN KEY (`coordinator_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE, -- مفتاح خارجي عند حذف المنسق يتم حذف التقييم


    CONSTRAINT `uc_coordinator_rate` UNIQUE(`coordinator_id`, `task_assign_id`),
    CONSTRAINT `check_different_users` CHECK (`user_assign_id` != `coordinator_id`)
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب


-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS `Notifications` (
    `notification_id` INT PRIMARY KEY AUTO_INCREMENT, -- معرف الإشعار
     `user_id` INT NOT NULL, -- معرف المستخدم
    `type` VARCHAR(255) NOT NULL, -- نوع الإشعار
    `title` VARCHAR(255) NOT NULL, -- عنوان الإشعار
    `message` TEXT NOT NULL, -- رسالة الإشعار
    `is_read` BOOLEAN DEFAULT FALSE, -- حالة قراءة الإشعار
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- تاريخ إنشاء الإشعار
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP, -- تاريخ تحديث الإشعار
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE -- مفتاح خارجي عند حذف المستخدم يتم حذف الإشعار
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

CREATE TABLE IF NOT EXISTS `Service_Requests` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `supplier_id` INT NOT NULL,
        `service_name` VARCHAR(100) NOT NULL,
        `description` TEXT,
        `status` ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        `deleted_at` TIMESTAMP NULL DEFAULT NULL,
        FOREIGN KEY (`supplier_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE
    )
    ENGINE=InnoDB -- نوع المحرك
    DEFAULT -- الافتراضي
    CHARSET=utf8mb4 -- نوع الترميز
    COLLATE=utf8mb4_general_ci; -- نوع الترتيب

-- إنشاء جدول تذكيرات المهام
CREATE TABLE IF NOT EXISTS `Task_Reminders` (
    `reminder_id` INT PRIMARY KEY AUTO_INCREMENT,
    `task_assign_id` INT NOT NULL,
    `user_id` INT NOT NULL COMMENT 'المستخدم الذي أنشأ التذكير (منسق أو مورد)',
    `reminder_type` ENUM('INTERVAL', 'BEFORE_DUE') NOT NULL DEFAULT 'BEFORE_DUE',
    `reminder_value` INT NOT NULL,
    `reminder_unit` ENUM('MINUTE', 'HOUR', 'DAY', 'WEEK') NOT NULL DEFAULT 'DAY',
    `is_active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,
   
    FOREIGN KEY (`task_assign_id`) REFERENCES `Task_Assigns`(`task_assign_id`) ON DELETE CASCADE,
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE,
    INDEX `idx_task_assign` (`task_assign_id`),
    INDEX `idx_user` (`user_id`),
    INDEX `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `User_FCM_Tokens` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `token` TEXT NOT NULL,
    `device_type` VARCHAR(50) NULL, -- 'android', 'ios', 'web'
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `Users`(`user_id`) ON DELETE CASCADE,
    CONSTRAINT `uc_user_token` UNIQUE (`user_id`, `token`(255)),
    INDEX `idx_user_fcm` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;



-- =====================================================
-- إنشاء الدوال (Functions)
-- =====================================================

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_concat_error_msg`(
        IN `p_error_msg` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
        IN `p_original_msg` TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC NO SQL
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
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fun_role_has_detail`(
        `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN 
        RETURN EXISTS (
            SELECT 1 FROM `Role_Details` 
            WHERE `detail_name` = p_detail_name AND `role_name` = p_role_name
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_role_has_permission`(
    `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
    `p_permission_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
    BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Role_Permissions` rp
            WHERE rp.`role_name` = p_role_name AND rp.`permission_name` = p_permission_name
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_role_exists`(
    `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Roles` WHERE `role_name` = p_role_name AND `deleted_at` IS NULL
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_has_role`(
    `p_user_id` INT,
    `p_role_name` VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci 
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
    BEGIN
        RETURN EXISTS(
            SELECT 1 FROM `Users` 
            WHERE `user_id` = p_user_id AND `role_name` = p_role_name AND `deleted_at` IS NULL
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_get_rolename`(
        `p_user_conditions` JSON
    ) RETURNS VARCHAR(50) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA
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
    END $$
DELIMITER ;


DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_has_detail`(
    `p_user_conditions` JSON,
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci 
    ) RETURNS BOOLEAN NOT DETERMINISTIC READS SQL DATA
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
    END $$
DELIMITER ;


DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_detail_exists`(
    `p_user_id` INT,
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN 
        RETURN EXISTS (
            SELECT 1 FROM `User_Detail_Values` 
            WHERE `user_id` = p_user_id AND `detail_name` = p_detail_name
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost'  FUNCTION `fn_user_get_detail`(
    `p_user_id` INT, 
    `p_detail_name` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN (
            SELECT `detail_value` FROM `User_Detail_Values`
            WHERE `user_id` = p_user_id AND `detail_name` = p_detail_name LIMIT 1
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_is_actived`(
    `p_user_id` INT
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN EXISTS (
            SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `is_active` = TRUE AND `deleted_at` IS NULL
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_user_is_deleted`(
    `p_user_id` INT
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN EXISTS (
            SELECT 1 FROM `Users` WHERE `user_id` = p_user_id AND `deleted_at` IS NOT NULL
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_total_income`(
    `p_event_id` INT
    ) RETURNS DECIMAL(10,2) DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN (
            SELECT IFNULL(SUM(`amount`), 0) 
            FROM `Incomes` WHERE `event_id` = p_event_id AND `deleted_at` IS NULL
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_total_expenses`(
    `p_event_id` INT
    ) RETURNS DECIMAL(10,2) DETERMINISTIC READS SQL DATA
    BEGIN
        -- تصحيح: استخدام الجدول الصحيح Task_Assigns بدلاً من Tasks
        RETURN (
            SELECT IFNULL(SUM(`cost`), 0) 
            FROM `Task_Assigns` 
            WHERE `event_id` = p_event_id AND `deleted_at` IS NULL
        );
    END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_net_profit`(
    `p_event_id` INT
    ) RETURNS DECIMAL(10,2) DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN IFNULL(fn_event_total_income(p_event_id), 0) - IFNULL(fn_event_total_expenses(p_event_id), 0);
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_overdue_tasks`(
    `p_event_id` INT
    ) RETURNS INT DETERMINISTIC READS SQL DATA
    BEGIN
        -- تصحيح: استخدام الجدول الصحيح Task_Assigns
        RETURN (
            SELECT COUNT(*) 
            FROM `Task_Assigns`
            WHERE `event_id` = p_event_id 
            AND `status` NOT IN ('COMPLETED', 'CANCELLED')
            AND `date_due` < CURDATE()
            AND `deleted_at` IS NULL
        );
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_getKeyOrIndex_array`(
    `p_index` INT, 
    `p_key` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci, 
    `p_keyOrIndex` ENUM('index','key') CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC NO SQL
    BEGIN 
        IF p_keyOrIndex = 'index' THEN 
            RETURN CONCAT('$[', p_index, ']'); 
        ELSEIF p_keyOrIndex = 'key' THEN 
            RETURN CONCAT('$.', p_key); 
        END IF; 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid key or index'; 
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost'  FUNCTION `fn_array_at`(`p_keys` JSON, `p_index` INT ) 
    RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN JSON_UNQUOTE(JSON_EXTRACT(p_keys, CONCAT('$[', p_index, ']')));
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost'  FUNCTION `fn_json_get`(`p_details` JSON, `p_key` VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci)
     RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA
    BEGIN
        RETURN JSON_UNQUOTE(JSON_EXTRACT(p_details, CONCAT('$.', p_key)));
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_get_end_date`(
        `p_event_date` DATE,
        `p_event_duration` INT,
        `p_event_duration_unit` ENUM('DAY', 'WEEK', 'MONTH') CHARSET utf8mb4 COLLATE utf8mb4_general_ci
    ) RETURNS DATE DETERMINISTIC READS SQL DATA
    BEGIN

        IF p_event_duration_unit = 'DAY' THEN RETURN DATE_ADD(p_event_date , INTERVAL P_event_duration DAY);
        ELSEIF p_event_duration_unit = 'WEEK'THEN RETURN DATE_ADD(p_event_date , INTERVAL P_event_duration WEEK);
        ELSE RETURN DATE_ADD(p_event_date , INTERVAL P_event_duration MONTH); END IF;
    END $$

CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_status_is`(
        `p_event_status` ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DELETED') CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        `p_event_id` INT
    ) RETURNS BOOLEAN DETERMINISTIC READS SQL DATA
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
    END $$

CREATE DEFINER = 'root'@'localhost' FUNCTION `fn_event_get_status`(
        `p_event_id` INT
    ) RETURNS ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'OTHER') CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA
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
    END $$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_get_avg_supplier_rating_for_coord`(
        `p_coordinator_id` INT,
        `p_supplier_id` INT
    ) RETURNS decimal(10,2)
    BEGIN
		RETURN (SELECT IFNULL(AVG(rta.rating_value), 0.0) FROM Ratings_Task_Assign rta 
        	WHERE rta.coordinator_id = p_coordinator_id AND 
            rta.user_assign_id = p_supplier_id
         );
    END$$
DELIMITER ;

-- =====================================================
-- إنشاء طرق العرض (Views)
-- =====================================================


-- عرض المشرفين
CREATE OR REPLACE VIEW `vw_get_all_admins` AS
    SELECT 
        `u`.*,
        (`u`.`deleted_at` IS NOT NULL) AS `is_deleted`
    FROM `Users` `u` WHERE `u`.`role_name` = 'admin';

-- عرض المنسقين
CREATE OR REPLACE VIEW `vw_get_all_coordinators` AS
    SELECT 
        `u`.*,
        (`u`.`deleted_at` IS NOT NULL) AS `is_deleted`
    FROM `Users` `u` WHERE `u`.`role_name` = 'coordinator';

-- عرض الموردين
CREATE OR REPLACE VIEW `vw_get_all_suppliers` AS
    SELECT 
        `u`.*,
        (`u`.`deleted_at` IS NOT NULL) AS `is_deleted`,
        `fn_user_get_detail`(`u`.`user_id`,'address') AS `address`
        FROM `Users` `u` WHERE `u`.`role_name` = 'supplier';

-- عرض الأحداث مع التفاصيل (استخدام الأعمدة المباشرة)
CREATE OR REPLACE VIEW `vw_events_detailed_with_coor` AS
    SELECT 
        e.*,
        (e.`deleted_at` IS NOT NULL) AS `is_deleted`,
        fn_event_get_status(e.`event_id`) AS `status`,

        co.`full_name` AS `coordinator_name`,
        co.`phone_number` AS `coordinator_phone`,
        co.`email` AS `coordinator_email`,

        COALESCE((SELECT SUM(inc.`amount`) FROM `Incomes` inc WHERE inc.`event_id` = e.`event_id` AND inc.`deleted_at` IS NULL), 0) AS `total_income`,
        COALESCE((SELECT SUM(ta.`cost`) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`deleted_at` IS NULL), 0) AS `total_expenses`,
        (SELECT COUNT(*) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`deleted_at` IS NULL) AS `total_tasks`,
        (SELECT COUNT(*) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`status` = 'COMPLETED' AND ta.`deleted_at` IS NULL) AS `completed_tasks`,
        CONCAT(
            ROUND(
                100 * (SELECT COUNT(*) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`status` = 'COMPLETED' AND ta.`deleted_at` IS NULL) 
                / NULLIF((SELECT COUNT(*) FROM `Task_Assigns` ta WHERE ta.`event_id` = e.`event_id` AND ta.`deleted_at` IS NULL), 0), 
            2), '%'
        ) AS `completion_percentage`
    FROM `Events` e
     JOIN `Users` co ON e.`coordinator_id` = co.`user_id`;

CREATE OR REPLACE VIEW `vw_events_detailed` AS
    SELECT 
        e.*,
        c.`full_name` AS `client_name`,
        c.`phone_number` AS `client_phone`,
        c.`email` AS `client_email`,
        c.`img_url` AS `client_img`
    FROM `vw_events_detailed_with_coor` e
    JOIN `Clients` c ON e.`client_id` = c.`client_id`;
    
-- عرض المهام الكامل (استخدام الأعمدة المباشرة)
CREATE OR REPLACE VIEW `vw_tasks_full` AS
    SELECT 
        ta.*,
        e.`event_name`,
        creator.`full_name` AS `task_creator_name`,
        CASE 
            WHEN fn_user_has_role(ta.`user_assign_id`, 'coordinator') THEN 'coordinator'
            WHEN fn_user_has_role(ta.`user_assign_id`, 'supplier') THEN 'supplier'
            ELSE 'unknown'
        END AS `assignment_type`,
        assignee.`full_name` AS `assigne_name`,
        r.`rating_value`,
        r.`rating_comment`,
        r.`rated_at`,
        rm.`reminder_value`,
        rm.`reminder_unit`
    FROM `Task_Assigns` ta
    LEFT JOIN `Events` e ON ta.`event_id` = e.`event_id`
    LEFT JOIN `Users` creator ON ta.`coordinator_id` = creator.`user_id`
    LEFT JOIN `Users` assignee ON ta.`user_assign_id` = assignee.`user_id`
    LEFT JOIN `Ratings_Task_Assign` r ON ta.`task_assign_id` = r.`task_assign_id`
    LEFT JOIN `Task_Reminders` rm ON ta.`task_assign_id` = rm.`task_assign_id`
    WHERE ta.`deleted_at` IS NULL;

-- عرض الإشعارات (استخدام الأعمدة المباشرة)
CREATE OR REPLACE VIEW `vw_notifications` AS
    SELECT 
        n.*,
        CASE 
            WHEN fn_user_has_role(n.`user_id`, 'coordinator') THEN 'Coordinator'
            WHEN fn_user_has_role(n.`user_id`, 'supplier') THEN 'Supplier'
            ELSE 'admin'
        END AS `recipient_type`,
        u.`full_name` AS `recipient_name`
    FROM `Notifications` n
    LEFT JOIN `Users` u ON n.`user_id` = u.`user_id`;
    
CREATE OR REPLACE VIEW `vw_task_reminders_details` AS
    SELECT
        r.`reminder_id`,
        r.`task_assign_id`,
        r.`user_id`,
        u.`full_name` AS `user_name`,
        u.`email` AS `user_email`,
        r.`reminder_type`,
        r.`reminder_value`,
        r.`reminder_unit`,
        r.`is_active`,
        r.`created_at`,
        ta.`description` AS `task_description`,
        ta.`status` AS `task_status`,
        ta.`date_due`,
        e.`event_name`,
        e.`event_date`
    FROM `Task_Reminders` r
    JOIN `Users` u ON r.`user_id` = u.`user_id`
    JOIN `Task_Assigns` ta ON r.`task_assign_id` = ta.`task_assign_id`
    JOIN `Events` e ON ta.`event_id` = e.`event_id`
    WHERE r.`deleted_at` IS NULL;

CREATE OR REPLACE VIEW `vw_get_all_suppliers_and_services` AS
    SELECT 
        `ser`.`service_id`, 
        `sup`.`user_id` AS `supplier_id`,
        `ser`.`service_name`,
        `ser`.`description` AS `service_description`,
        
        `sup`.`role_name`,
        `sup`.`full_name`,
        `sup`.`phone_number`,
        `sup`.`email`,
        `sup`.`password`,
        `sup`.`img_url`,
        `sup`.`is_active`,
        `sup`.`address`,
        
        (CASE 
            WHEN `ss`.`service_id` IS NOT NULL AND `ss`.`deleted_at` IS NULL 
            THEN 1 ELSE 0 END) AS `supplier_has_service`,
        
        (`ser`.`deleted_at` IS NOT NULL) AS `service_is_deleted`,
        `sup`.`is_deleted` AS `supplier_is_deleted`,
        
        `ser`.`created_at` AS `service_created_at`,
        `ser`.`updated_at` AS `service_updated_at`,
        `ser`.`deleted_at` AS `service_deleted_at`,
        
        `sup`.`created_at` AS `supplier_created_at`,
        `sup`.`updated_at` AS `supplier_updated_at`,
        `sup`.`deleted_at` AS `supplier_deleted_at`
        
    FROM `Services` `ser`
        CROSS JOIN `vw_get_all_suppliers` `sup`
        LEFT JOIN `Supplier_Services` `ss` 
            ON `ss`.`service_id` = `ser`.`service_id`
            AND `ss`.`supplier_id` = `sup`.`user_id`
            
        ORDER BY `ser`.`service_id`, `sup`.`user_id`;

-- =====================================================
-- إنشاء الإجراءات المخزنة (Stored Procedures)
-- =====================================================

DELIMITER $$
CREATE PROCEDURE `sp_set_error_msg_or_def`(
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
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_get_user_by_id`(IN `p_user_id` INT)
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_get_user_by_email`(IN `p_email` VARCHAR(255))
    BEGIN 
        DECLARE v_user_id INT;
        
        SELECT `user_id` INTO v_user_id 
        FROM `Users` 
        WHERE `email` = p_email AND `deleted_at` IS NULL;
        
        IF v_user_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المستخدم غير موجود';
        END IF;
        
        CALL sp_get_user_by_id(v_user_id);
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_login_user`(IN `p_email` VARCHAR(255))
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_throw_if_account_not_admin`(
        IN `p_user_creator_email` VARCHAR(255),
        IN `p_user_creator_pass` VARCHAR(255),
        IN `p_permission_role` ENUM('admin', 'coordinator', 'supplier')
    )
    BEGIN
        DECLARE v_user_id INT;
        -- DECLARE v_permission_name VARCHAR(100);
        -- DECLARE v_error_msg TEXT;
        
        -- الحصول على معرف المستخدم المدير
        SELECT `user_id` INTO v_user_id 
            FROM `Users` 
            WHERE `email` = p_user_creator_email 
            AND `password` = p_user_creator_pass 
            AND `role_name` = 'admin'
            AND `deleted_at` IS NULL;
        
        IF v_user_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن الإنشاء إلا عن طريق حساب مدير';
        END IF;
        
        -- -- اسم الصلاحية المطلوبة: create_{role}_user
        -- SET v_permission_name = CONCAT('create_', p_permission_role, '_user');
        
        -- -- التحقق من أن دور 'admin' لديه هذه الصلاحية
        -- IF NOT EXISTS (
        --     SELECT 1 FROM `Role_Permissions` rp
        --     WHERE rp.`role_name` = 'admin' 
        --     AND rp.`permission_name` = v_permission_name
        --     AND rp.`deleted_at` IS NULL
        -- ) THEN
        --     SET v_error_msg = CONCAT('حساب المدير ليس لديه صلاحية ', v_permission_name);
        --     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
        -- END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_user`(
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
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
    BEGIN 
        DECLARE v_detail_name VARCHAR(255);
        DECLARE v_detail_value TEXT;
        DECLARE v_i INT DEFAULT 0;
        DECLARE v_keys JSON;
        DECLARE v_total INT DEFAULT 0;
        DECLARE v_error_msg TEXT;
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        -- التحقق من صلاحية المدير
        CALL sp_throw_if_account_not_admin(p_user_creator_email, p_user_creator_pass, p_role_name);
        
        START TRANSACTION;
        
        -- التحقق من عدم تكرار البريد أو الهاتف
        IF EXISTS(SELECT 1 FROM `Users` WHERE `email` = p_email AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا البريد موجود مسبقا';
        END IF;
        IF EXISTS(SELECT 1 FROM `Users` WHERE `phone_number` = p_phone_number AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا الهاتف موجود مسبقا';
        END IF;
        
        -- إدراج المستخدم
        INSERT INTO `Users` (`role_name`, `full_name`, `phone_number`, `is_active`, `img_url`, `email`, `password`)
        VALUES (p_role_name, p_full_name, p_phone_number, p_is_active, p_img_url, p_email, p_password);
        SET p_user_id = LAST_INSERT_ID();
        
        -- معالجة التفاصيل الإضافية
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
        
        -- إشعار للمدير (user_id = 1)
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
    END$$

CREATE PROCEDURE `sp_register`(
        IN `p_role_name` VARCHAR(50),
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_password` VARCHAR(255),
        IN `p_details` JSON,
        IN `p_with_out` BOOLEAN
    )
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
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
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_coordinator`(
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_is_active` BOOLEAN,
        IN `p_email` VARCHAR(255),
        IN `p_password` VARCHAR(255),
        IN `p_with_out` BOOLEAN
    )
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
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
    END$$

CREATE PROCEDURE `sp_create_supplier`(
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
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
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
        
        -- بناء JSON للتفاصيل
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_client`(
        IN `p_coordinator_id` INT,
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_address` TEXT,
        IN `p_with_out` BOOLEAN
    )
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
    BEGIN 
        DECLARE v_creator_user_role VARCHAR(50);
        DECLARE v_creator_name VARCHAR(255);
        DECLARE v_creator_email VARCHAR(255);
        DECLARE v_client_id INT;
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        -- الحصول على بيانات المنسق
        SELECT `role_name`, `full_name`, `email`
        INTO v_creator_user_role, v_creator_name, v_creator_email
        FROM `Users` 
        WHERE `user_id` = p_coordinator_id 
        AND `role_name` IN ('coordinator', 'admin')
        AND `deleted_at` IS NULL; 
        
        IF v_creator_user_role IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن إنشاء العميل إلا عن طريق حساب منسق أو مدير';
        END IF;
        
        -- التحقق من عدم وجود عميل بنفس البريد أو الهاتف لنفس المنسق
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
        
        -- إشعار للمنسق
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
        
        -- إشعار للمدير
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_client`(
        IN `p_coordinator_id` INT,
        IN `p_client_id` INT,
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_address` TEXT
    )
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
    BEGIN 
        DECLARE v_creator_user_role VARCHAR(50);
        DECLARE v_creator_name VARCHAR(255);
        DECLARE v_creator_email VARCHAR(255);
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        -- الحصول على بيانات المنسق
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
        
        -- إشعار للمنسق
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
        
        -- إشعار للمدير
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_user`(
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
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
    BEGIN
        DECLARE v_role_name VARCHAR(50);
        DECLARE v_detail_name VARCHAR(255);
        DECLARE v_detail_value TEXT;
        DECLARE v_i INT DEFAULT 0;
        DECLARE v_keys JSON;
        DECLARE v_total INT DEFAULT 0;
        DECLARE v_error_msg TEXT;
        
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        -- الحصول على دور المستخدم قبل التحديث
        SELECT `role_name` INTO v_role_name 
        FROM `Users` 
        WHERE `user_id` = p_user_id AND `deleted_at` IS NULL;
        
        IF v_role_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المستخدم غير موجود';
        END IF;
        
        -- التحقق من صلاحية المدير لتحديث هذا الدور
        CALL sp_throw_if_account_not_admin(p_user_creator_email, p_user_creator_pass, v_role_name);
        
        -- التحقق من عدم تكرار البريد أو الهاتف مع مستخدم آخر
        IF EXISTS(SELECT 1 FROM `Users` WHERE `user_id` != p_user_id AND `email` = p_email AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا البريد موجود مسبقا';
        END IF;
        IF EXISTS(SELECT 1 FROM `Users` WHERE `user_id` != p_user_id AND `phone_number` = p_phone_number AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'هذا الهاتف يمتلكه شخص آخر';
        END IF;
        
        START TRANSACTION;
        
        -- تحديث بيانات المستخدم الأساسية
        UPDATE `Users` SET 
            `full_name` = COALESCE(p_full_name, `full_name`),
            `phone_number` = COALESCE(p_phone_number, `phone_number`),
            `img_url` = COALESCE(p_img_url, `img_url`),
            `email` = COALESCE(p_email, `email`),
            `password` = COALESCE(p_password, `password`),
            `updated_at` = NOW()
        WHERE `user_id` = p_user_id;
        
        -- معالجة التفاصيل الإضافية
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
        
        -- إشعار للمدير
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
        
        -- إشعار للمستخدم نفسه
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
    END$$

CREATE PROCEDURE `sp_update_user_byadmin`(
        IN `p_user_id` INT,
        IN `p_full_name` VARCHAR(255),
        IN `p_phone_number` VARCHAR(20),
        IN `p_img_url` TEXT,
        IN `p_email` VARCHAR(255),
        IN `p_password` VARCHAR(255),
        IN `p_details` JSON
    )
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
    BEGIN
        DECLARE v_email VARCHAR(255);
        DECLARE v_pass VARCHAR(255);
        SELECT `email`, `password` INTO v_email, v_pass FROM `Users` WHERE `user_id` = 1;
        CALL sp_update_user(
            v_email, v_pass, p_user_id, p_full_name, p_phone_number, p_img_url, p_email, p_password, p_details
        );
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_user`(IN `p_user_id` INT)
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
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
        
        -- إشعار للمدير (user_id = 1)
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'delete_user',
            'حذف حساب',
            CONCAT('تم حذف حساب المستخدم: ', v_user_name, ' (', v_user_email, ') - الدور: ', v_role_name)
        );
        
        -- إشعار للمستخدم نفسه (حتى لو كان محذوفاً يمكن إدراج إشعار)
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_user_id,
            'delete_user',
            'تم حذف حسابك',
            CONCAT('تم حذف حسابك بتاريخ ', NOW(), '. إذا كان هذا خطأ، يرجى التواصل مع المدير.')
        );
        
        -- SELECT p_user_id AS user_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_restore_user`(IN `p_user_id` INT)
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
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
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'restore_user',
            'استعادة حساب',
            CONCAT('تم استعادة حساب المستخدم: ', v_user_name, ' (', v_user_email, ') - الدور: ', v_role_name)
        );
        
        -- إشعار للمستخدم
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_user_id,
            'restore_user',
            'تم استعادة حسابك',
            CONCAT('تم استعادة حسابك بتاريخ ', NOW(), '. يمكنك الآن تسجيل الدخول.')
        );
        
        SELECT p_user_id AS user_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_set_user_active`(IN `p_user_id` INT, IN `p_active` BOOLEAN, IN `p_with_out` BOOLEAN)
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
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
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            IF(p_active, 'activate_user', 'deactivate_user'),
            IF(p_active, 'تفعيل حساب', 'تعطيل حساب'),
            CONCAT('تم ', IF(p_active, 'تفعيل', 'تعطيل'), ' حساب المستخدم: ', v_user_name, ' (', v_user_email, ')')
        );
        
        -- إشعار للمستخدم نفسه
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_user_id,
            IF(p_active, 'activate_user', 'deactivate_user'),
            IF(p_active, 'تم تفعيل حسابك', 'تم تعطيل حسابك'),
            CONCAT('تم ', IF(p_active, 'تفعيل', 'تعطيل'), ' حسابك بتاريخ ', NOW(), '.')
        );
        
        IF p_with_out THEN SELECT p_user_id AS user_id; END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_add_permission_to_role`(
        IN `p_role_name` VARCHAR(50), 
        IN `p_permission_name` VARCHAR(100)
    )
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM `Roles` WHERE `role_name` = p_role_name AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الدور غير موجود';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM `Permissions` WHERE `permission_name` = p_permission_name AND `deleted_at` IS NULL) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الصلاحية غير موجودة';
        END IF;
        
        -- إدراج أو استعادة إذا كانت محذوفة
        INSERT INTO `Role_Permissions` (`role_name`, `permission_name`, `deleted_at`)
        VALUES (p_role_name, p_permission_name, NULL)
        ON DUPLICATE KEY UPDATE `deleted_at` = NULL;
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'permission_added',
            'إضافة صلاحية لدور',
            CONCAT('تم إضافة الصلاحية "', p_permission_name, '" إلى دور "', p_role_name, '"')
        );
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_remove_permission_from_role`(
        IN `p_role_name` VARCHAR(50), 
        IN `p_permission_name` VARCHAR(100)
    )
    DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
    BEGIN
        UPDATE `Role_Permissions` 
        SET `deleted_at` = NOW()
        WHERE `role_name` = p_role_name AND `permission_name` = p_permission_name;
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'permission_removed',
            'إزالة صلاحية من دور',
            CONCAT('تم إزالة الصلاحية "', p_permission_name, '" من دور "', p_role_name, '"')
        );
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_task`(
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

        -- الحصول على بيانات الحدث والمنسق
        SELECT `coordinator_id`, `coordinator_name`, `coordinator_phone`, `coordinator_email`, `event_name`,
                `budget`, `total_expenses`
            INTO v_coordinator_id, v_coordinator_name, v_coordinator_phone, v_coordinator_email, v_event_name,
                    v_budget, v_total_expenses 
        FROM `vw_events_detailed` 
        WHERE `event_id` = p_event_id AND `deleted_at` IS NULL;

        -- الحصول على بيانات المستخدم المكلف
        SELECT `full_name`, `email` INTO v_assign_name, v_assign_email 
        FROM `Users` WHERE `user_id` = p_user_assign_id AND `deleted_at` IS NULL;

        -- التحقق من الصلاحيات
        IF p_user_assign_id IS NOT NULL AND NOT (fn_user_has_role(p_user_assign_id, 'coordinator') OR fn_user_has_role(p_user_assign_id, 'supplier')) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن إسناد المهام إلا لموردين أو منسقين';
        END IF;
        IF v_coordinator_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الحدث غير موجود أو لا يملك منسق';
        END IF;
        IF v_assign_email IS NULL AND p_user_assign_id IS NOT NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المستخدم المكلف غير موجود';
        END IF;

        -- إدراج المهمة (بدون حقول التذكير)
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

        -- إشعار للمدير
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

        -- إشعار للمنسق
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

        -- إشعار للمكلف إذا لم يكن هو المنسق نفسه
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

        -- إشعار بتجاوز الميزانية
        IF v_total_expenses + p_cost > v_budget THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
                VALUES (v_coordinator_id,
                    'alert', 
                    'ميزانية تجاوزت الحد', 
                    CONCAT('تجاوزت مصروفات ', v_event_name, ' الميزانية المحددة')
                );
        END IF;
        SELECT p_task_assign_id as task_assign_id;
    END$$
    
CREATE PROCEDURE `sp_create_task_from_json`(
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_income`(
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
            
        -- إشعار للمنسق
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (v_coordinator_id, 'create_income', 'دفعة جديدة', CONCAT('تم إنشاء دفعة جديدة بقيمة ', p_amount, ' للحدث "', v_event_name, '"'));
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (1, 'create_income', 'دفعة جديدة', CONCAT('تم إنشاء دفعة جديدة بقيمة ', p_amount, ' للحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id));

        IF with_out = TRUE THEN
            SELECT * FROM `Incomes` WHERE `income_id` = LAST_INSERT_ID();
        END IF;
        
    END$$

CREATE PROCEDURE `sp_create_income_from_json`(
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
       
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_event`(
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
        -- التحقق من وجود العميل والمنسق
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
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (1, 'create_event', 'حدث جديد', CONCAT('تم إنشاء حدث جديد "', p_event_name, '" بواسطة المنسق ', p_coordinator_id));
        
        -- إشعار للمنسق
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (p_coordinator_id, 'create_event', 'حدث جديد', CONCAT('لقد قمت بإنشاء حدث جديد "', p_event_name, '"'));
        
        SELECT * FROM `vw_events_detailed` WHERE `event_id` = LAST_INSERT_ID();
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_task_status`(
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
        
        -- جلب البيانات الحالية للمهمة
        SELECT `status`, `event_id`, `coordinator_id`, `user_assign_id`
            INTO v_old_status, v_event_id, v_coordinator_id, v_user_assign_id
                FROM `Task_Assigns` 
                    WHERE `task_assign_id` = p_task_assign_id AND `deleted_at` IS NULL;
        
        IF v_old_status IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المهمة غير موجودة';
        END IF;
        
        -- جلب اسم الحدث
        SELECT `event_name` INTO v_event_name FROM `Events` WHERE `event_id` = v_event_id;
        
        -- جلب اسم المستخدم الذي يقوم بالتحديث
        SELECT `full_name` INTO v_user_name FROM `Users` WHERE `user_id` = p_user_update_id;
        
        -- التحقق من صلاحية المستخدم
        IF p_user_update_id = v_coordinator_id THEN
            -- المنسق يمكنه تحديث الحالة فقط إذا كان المكلف هو نفسه (أي المهمة خاصة به)
            IF v_user_assign_id != v_coordinator_id AND v_old_status != 'UNDER_REVIEW' AND p_new_status != 'COMPLETED' THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن للمنسق تحديث حالة مهمة مكلف بها مورد';
            END IF;
            -- لا يمكن تغيير حالة مكتملة أو ملغية
            IF v_old_status IN ('COMPLETED', 'CANCELLED') THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تغيير حالة مهمة مكتملة أو ملغية';
            END IF;
        ELSEIF p_user_update_id = v_user_assign_id THEN
            -- المكلف يمكنه تغيير الحالة وفق تسلسل معين
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
        
        -- إذا لم يتغير الحالة فلا داعي للمتابعة
        IF v_old_status = p_new_status THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'الحالة الجديدة هي نفس الحالة القديمة';
        END IF;
        
        START TRANSACTION;
        
        -- تحديث المهمة
        UPDATE `Task_Assigns`
            SET `status` = p_new_status,
                `notes` = IF(p_notes IS NOT NULL, CONCAT(IFNULL(`notes`, ''), '\n', p_notes), `notes`),
                `date_completion` = IF(p_new_status = 'COMPLETED', NOW(), `date_completion`),
                `updated_at` = NOW(),
                `url_image` = IFNULL(p_url_image, `url_image`)
            WHERE `task_assign_id` = p_task_assign_id;
        
        -- ============================================================
        -- إشعارات عند تغيير الحالة (لجميع الحالات)
        -- ============================================================
        
        -- نص وصفي لتغيير الحالة
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
        
        -- 1. إشعار للمستخدم الذي قام بالتحديث (نفسه)
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (p_user_update_id, 
                CONCAT('TASK_STATUS_', p_new_status),
                CONCAT('تحديث حالة مهمة #', p_task_assign_id),
                CONCAT('لقد قمت بتغيير حالة المهمة إلى "', @status_ar, '".\n', @message_text));
        
        -- 2. إشعار للمنسق (إذا لم يكن هو من قام بالتحديث)
        IF v_coordinator_id != p_user_update_id THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (v_coordinator_id, 
                    CONCAT('TASK_STATUS_', p_new_status),
                    CONCAT('تحديث حالة مهمة #', p_task_assign_id),
                    CONCAT('قام ', IFNULL(v_user_name, 'غير معروف'), ' بتغيير حالة المهمة إلى "', @status_ar, '".\n', @message_text));
        END IF;
        
        -- 3. إشعار للمكلف (إذا كان موجوداً ولم يقم هو بالتحديث)
        IF v_user_assign_id IS NOT NULL AND v_user_assign_id != p_user_update_id THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (v_user_assign_id, 
                    CONCAT('TASK_STATUS_', p_new_status),
                    CONCAT('تحديث حالة مهمة #', p_task_assign_id),
                    CONCAT('تم تغيير حالة مهمتك إلى "', @status_ar, '" بواسطة ', v_user_name, '.\n', @message_text));
        END IF;
        
        -- 4. إشعار للمدير (user_id = 1) دائماً
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (1, 
                CONCAT('TASK_STATUS_', p_new_status),
                CONCAT('تحديث حالة مهمة #', p_task_assign_id),
                CONCAT('قام ', IFNULL(v_user_name, 'غير معروف'), ' (رقم ', p_user_update_id, ') بتغيير حالة المهمة رقم ', p_task_assign_id, 
                       ' في الحدث "', IFNULL(v_event_name, 'غير معروف'), '" من "', @old_status_ar, '" إلى "', @status_ar, '"'));
        
        -- إشعارات خاصة عند الإكمال أو الإلغاء (بالإضافة إلى الإشعارات أعلاه)
        IF p_new_status IN ('COMPLETED', 'CANCELLED') THEN
            SET @status_text = IF(p_new_status = 'COMPLETED', 'إكمال', 'إلغاء');
            
            -- إشعار إضافي للمنسق (بنص مختلف)
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (v_coordinator_id, 
                    CONCAT('TASK_', p_new_status),
                    CONCAT('تم ', @status_text, ' مهمة'),
                    CONCAT('المهمة رقم ', p_task_assign_id, ' في الحدث "', IFNULL(v_event_name, 'غير معروف'), '" قد ', IF(p_new_status='COMPLETED', 'اكتملت', 'ألغيت'), '.'));
            
            -- إشعار إضافي للمكلف إذا لم يكن هو المنسق
            IF v_user_assign_id IS NOT NULL AND v_user_assign_id != v_coordinator_id THEN
                INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
                VALUES (v_user_assign_id, 
                        CONCAT('TASK_', p_new_status),
                        CONCAT('تم ', @status_text, ' مهمة'),
                        CONCAT('المهمة رقم ', p_task_assign_id, ' في الحدث "', IFNULL(v_event_name, 'غير معروف'), '" قد ', IF(p_new_status='COMPLETED', 'اكتملت', 'ألغيت'), '.'));
            END IF;
        END IF;
        
        COMMIT;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_add_task_rating`(
        IN `p_task_assign_id` INT,
        IN `p_coordinator_id` INT,
        IN `p_rating_value` INT,
        IN `p_comment` TEXT
    )
    BEGIN
        DECLARE v_event_id INT;
        DECLARE v_assigned_user_id INT;
        DECLARE v_task_status VARCHAR(20);
        
        -- الحصول على بيانات المهمة
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
        
        -- التحقق من أن المنسق هو منسق الحدث
        IF NOT EXISTS (
            SELECT 1 FROM `Events` e
            WHERE e.`event_id` = v_event_id 
            AND e.`coordinator_id` = p_coordinator_id
            AND e.`deleted_at` IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية تقييم هذه المهمة';
        END IF;
        
        -- إدراج التقييم
        -- التحقق من وجود تقييم مسبق
        IF EXISTS (SELECT 1 FROM `Ratings_Task_Assign` WHERE `task_assign_id` = p_task_assign_id AND `deleted_at` IS NULL) THEN
            -- تحديث التقييم الموجود
            UPDATE `Ratings_Task_Assign` 
            SET `rating_value` = p_rating_value,
                `rating_comment` = p_comment,
                `updated_at` = NOW()
            WHERE `task_assign_id` = p_task_assign_id;
            
            -- إشعار للمكلف بتعديل التقييم
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
            -- إدراج تقييم جديد
            INSERT INTO `Ratings_Task_Assign` (`task_assign_id`, `coordinator_id`, `user_assign_id`, `rating_value`, `rating_comment`)
            VALUES (p_task_assign_id, p_coordinator_id, v_assigned_user_id, p_rating_value, p_comment);
            
            -- إشعار للمكلف بتقييم جديد
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_task_rating`(
        IN `p_rating_id` INT
    )
    BEGIN
        DECLARE v_assigned_user_id INT;
        DECLARE v_rating_value INT;
        
        -- الحصول على المورد المعني والتقييم
        SELECT r.rating_value, t.user_assign_id INTO v_rating_value, v_assigned_user_id
        FROM `Ratings_Task_Assign` r
        JOIN `Task_Assigns` t ON r.task_assign_id = t.task_assign_id
        WHERE r.rating_id = p_rating_id;
        
        UPDATE `Ratings_Task_Assign` SET deleted_at = NOW() WHERE `rating_id` = p_rating_id;
        
        -- إشعار للمورد
        IF v_assigned_user_id IS NOT NULL THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (v_assigned_user_id,
                'DELETE_RATING',
                'حذف تقييم',
                CONCAT('تم حذف تقييم مهمتك بـ ', v_rating_value, ' نجوم.')
            );
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_change_password`(
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
                
            -- إشعار للمستخدم
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (p_user_id,
                'change_password',
                'تغيير كلمة المرور',
                CONCAT('تم تغيير كلمة المرور الخاصة بحسابك بتاريخ ', NOW())
            );
            
            -- إشعار للمدير (اختياري، يمكن إضافته)
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_event`(
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
        
         -- إشعار للمنسق
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (v_coordinator_id,
            'update_event',
            'تحديث حدث',
            CONCAT('تم تحديث بيانات الحدث "', IFNULL(p_event_name, v_old_name), '" (رقم ', p_event_id, ')')
        );
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'update_event',
            'تحديث حدث',
            CONCAT('تم تحديث بيانات الحدث "', IFNULL(p_event_name, v_old_name), '" (رقم ', p_event_id, ') بواسطة المنسق رقم ', v_coordinator_id)
        );
        SELECT * FROM `Events` WHERE `event_id` = p_event_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_task_reminder`(
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
        
        -- إشعار
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (v_reminder_user,
            'DELETE_REMINDER',
            'حذف تذكير',
            'تم حذف تذكير المهمة الخاص بك بنجاح.'
        );
        
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_all_reminders_of_task`(IN `p_task_assign_id` INT)
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
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_all_ratings_of_task`(IN `p_task_assign_id` INT)
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
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_task`(IN `p_task_assign_id` INT)
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
        
        -- إشعار للمكلف
        IF v_user_assign_id IS NOT NULL THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (v_user_assign_id,
                'delete_task',
                'حذف مهمة',
                CONCAT('تم حذف المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '"')
            );
        END IF;
        
        IF v_coordinator_id != v_user_assign_id THEN
            -- إشعار للمنسق
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
                VALUES (v_coordinator_id,
                    'delete_task',
                    'حذف مهمة',
                    CONCAT('تم حذف المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '"')
                );
        END IF;
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'delete_task',
            'حذف مهمة',
            CONCAT('تم حذف المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id)
        );
        
        CALL sp_delete_all_reminders_of_task(p_task_assign_id);
        CALL sp_delete_all_ratings_of_task(p_task_assign_id);
        -- SELECT p_task_assign_id AS task_assign_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_all_incomes_of_event`(IN `p_event_id` INT)
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
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_all_tasks_of_event`(IN `p_event_id` INT)
    BEGIN
        DECLARE v_task_assign_id INT;
        DECLARE v_done INT DEFAULT FALSE;

        -- DECLARE tasks_cursor CURSOR FOR
        --     SELECT  `task_assign_id` FROM `Task_Assigns`
        --         WHERE `event_id` = p_event_id AND `deleted_at` IS NULL;
    
        -- DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

        -- OPEN tasks_cursor;
        
        --     tasks_loop: LOOP
        --         FETCH tasks_cursor INTO v_task_assign_id;
        --         IF v_done THEN LEAVE tasks_loop; END IF;
        --         CALL sp_delete_task(v_task_assign_id); 
        --     END LOOP tasks_loop;
        
        -- CLOSE tasks_cursor;   
        UPDATE `Ratings_Task_Assign` `rta`
            SET `rta`.`deleted_at` = NOW()
            WHERE `rta`.`task_assign_id` IN (SELECT `task_assign_id` FROM `Task_Assigns` WHERE `event_id` = p_event_id) AND
                `rta`.`deleted_at` IS NULL;

        UPDATE `Task_Reminders` `tr`
            SET `tr`.`deleted_at` = NOW()
            WHERE `tr`.`task_assign_id` IN (SELECT `task_assign_id` FROM `Task_Assigns` WHERE `event_id` = p_event_id) AND
                `tr`.`deleted_at` IS NULL;

        UPDATE `Task_Assigns` `ta` 
            SET `ta`.`deleted_at` = NOW() 
            WHERE `ta`.`event_id` = p_event_id AND 
                `ta`.`deleted_at` IS NULL;

        END $$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `sp_delete_event`(IN `p_event_id` INT)
    BEGIN
        DECLARE v_coordinator_id INT;
        DECLARE v_event_name VARCHAR(255);
        
        SELECT `coordinator_id`, `event_name` INTO v_coordinator_id, v_event_name
            FROM `Events` WHERE `event_id` = p_event_id;
        
        UPDATE `Events` SET `deleted_at` = NOW() WHERE `event_id` = p_event_id;
        
        -- إشعار للمنسق
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (v_coordinator_id,
                'delete_event',
                'حذف حدث',
                CONCAT('تم حذف الحدث "', v_event_name, '" (رقم ', p_event_id, ')')
            );
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (1,
                'delete_event',
                'حذف حدث',
                CONCAT('تم حذف الحدث "', v_event_name, '" (رقم ', p_event_id, ') بواسطة المنسق رقم ', v_coordinator_id)
            );
        
        UPDATE `Task_Assigns` SET `deleted_at` = NOW() WHERE `event_id` = p_event_id;
        UPDATE `Incomes` SET `deleted_at` = NOW() WHERE `event_id` = p_event_id;

        -- SELECT p_event_id AS event_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_all_events_of_coordinator`(IN `p_coordinator_id` INT)
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
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_create_service`(
        IN `p_user_creator_email` VARCHAR(255),
        IN `p_user_creator_pass` VARCHAR(255),
        IN `p_service_name` VARCHAR(100) CHARSET utf8mb4 COLLATE utf8mb4_general_ci,
        IN `p_description` TEXT,
        IN `p_with_out` BOOLEAN
    ) DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER 
    BEGIN 
        DECLARE v_service_id INT;
        DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
        
        -- التحقق من صلاحية المدير (اختياري إذا تم تقديمه)
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_service`(
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
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'update_service',
            'تحديث خدمة',
            CONCAT('تم تحديث بيانات الخدمة "', IFNULL(p_service_name, v_old_name), '" (رقم ', p_service_id, ')')
        );
        
        -- إشعار لكافة المستخدمين
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        SELECT `user_id`, 'update_service', 'تحديث خدمة', CONCAT('تم تحديث بيانات الخدمة: "', IFNULL(p_service_name, v_old_name), '"') 
        FROM `Users` WHERE `deleted_at` IS NULL AND `user_id` != 1;
        
        SELECT * FROM `Services` WHERE `service_id` = p_service_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_service`(IN `p_service_id` INT)
    BEGIN
        DECLARE v_service_name VARCHAR(100);
        SELECT `service_name` INTO v_service_name FROM `Services` WHERE `service_id` = p_service_id;
        
        UPDATE `Services` SET `deleted_at` = CURRENT_TIMESTAMP WHERE `service_id` = p_service_id;
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'delete_service',
            'حذف خدمة',
            CONCAT('تم حذف الخدمة "', v_service_name, '" (رقم ', p_service_id, ')')
        );
        
        -- إشعار لكافة المستخدمين
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            SELECT `user_id`, 'delete_service', 'حذف خدمة', CONCAT('تم إزالة الخدمة من النظام: "', v_service_name, '"') 
            FROM `Users` WHERE `deleted_at` IS NULL AND `user_id` != 1;
        
        SELECT p_service_id AS service_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_income`(
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
        
        -- إشعار للمنسق
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (v_coordinator_id,
            'update_income',
            'تحديث دفعة',
            CONCAT('تم تحديث بيانات الدفعة رقم ', p_income_id, ' للحدث "', v_event_name, '"')
        );
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'update_income',
            'تحديث دفعة',
            CONCAT('تم تحديث بيانات الدفعة رقم ', p_income_id, ' للحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id)
        );
        
        SELECT * FROM `Incomes` WHERE `income_id` = p_income_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_delete_income`(IN `p_income_id` INT)
    BEGIN
        DECLARE v_event_id INT;
        DECLARE v_coordinator_id INT;
        DECLARE v_event_name VARCHAR(255);
        
        SELECT e.`event_id`, e.`coordinator_id`, e.`event_name` 
        INTO v_event_id, v_coordinator_id, v_event_name
        FROM `Incomes` i JOIN `Events` e ON i.`event_id` = e.`event_id`
        WHERE i.`income_id` = p_income_id;
        
        UPDATE `Incomes` SET `deleted_at` = CURRENT_TIMESTAMP WHERE `income_id` = p_income_id;
        
        -- إشعار للمنسق
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (v_coordinator_id,
            'delete_income',
            'حذف دفعة',
            CONCAT('تم حذف الدفعة رقم ', p_income_id, ' للحدث "', v_event_name, '"')
        );
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'delete_income',
            'حذف دفعة',
            CONCAT('تم حذف الدفعة رقم ', p_income_id, ' للحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id)
        );
        
        SELECT p_income_id AS income_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_task`( 
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
            
        -- إشعار للمكلف
        IF v_user_assign_id IS NOT NULL THEN
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
            VALUES (v_user_assign_id,
                'update_task',
                'تحديث مهمة',
                CONCAT('تم تحديث بيانات المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '"')
            );
        END IF;
        
        -- إشعار للمنسق
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (v_coordinator_id,
            'update_task',
            'تحديث مهمة',
            CONCAT('تم تحديث بيانات المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '"')
        );
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'update_task',
            'تحديث مهمة',
            CONCAT('تم تحديث بيانات المهمة رقم ', p_task_assign_id, ' في الحدث "', v_event_name, '" بواسطة المنسق ', v_coordinator_id)
        );
            
        COMMIT;
        
        SELECT * FROM `vw_tasks_full` WHERE `task_assign_id` = p_task_assign_id;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_assign_service_to_supplier`(
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
        
        -- إشعار للمورد
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_supplier_id,
            'assign_service',
            'إسناد خدمة',
            CONCAT('تم إسناد الخدمة "', v_service_name, '" إليك')
        );
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'assign_service',
            'إسناد خدمة لمورد',
            CONCAT('تم إسناد الخدمة "', v_service_name, '" إلى المورد "', v_supplier_name, '" (رقم ', p_supplier_id, ')')
        );
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_remove_service_from_supplier`(
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
        
        -- إشعار للمورد
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (p_supplier_id,
            'remove_service',
            'إزالة خدمة',
            CONCAT('تم إزالة الخدمة "', v_service_name, '" من خدماتك')
        );
        
        -- إشعار للمدير
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`) 
        VALUES (1,
            'remove_service',
            'إزالة خدمة من مورد',
            CONCAT('تم إزالة الخدمة "', v_service_name, '" من المورد "', v_supplier_name, '" (رقم ', p_supplier_id, ')')
        );
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_events_detailed` (
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
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_home_stats_coordinator`(
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
            -- (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'supplier' AND `deleted_at` IS NULL) AS total_suppliers
            ;
            
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_home_stats_supplier`(
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
            
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE  `sp_report_stats`(
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
    END $$

CREATE PROCEDURE `sp_monthly_income`(
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
    END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_generate_task_reminders`()
        READS SQL DATA
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
        
        -- مؤشر لتمرير التذكيرات النشطة
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
            
            -- حساب وقت التذكير
            IF v_reminder_type = 'BEFORE_DUE' THEN
                SET v_reminder_datetime = CASE v_reminder_unit
                    WHEN 'MINUTE' THEN DATE_SUB(CONCAT(v_date_due, ' 00:00:00'), INTERVAL v_reminder_value MINUTE)
                    WHEN 'HOUR' THEN DATE_SUB(CONCAT(v_date_due, ' 00:00:00'), INTERVAL v_reminder_value HOUR)
                    WHEN 'DAY' THEN DATE_SUB(v_date_due, INTERVAL v_reminder_value DAY)
                END;
            ELSE -- INTERVAL
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
            
            -- إدراج التذكير في جدول الإشعارات مع منع التكرار اليومي
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_add_task_reminder`(
        IN `p_user_id` INT,                 -- المستخدم المنشئ (منسق أو مورد)
        IN `p_task_assign_id` INT,
        IN `p_reminder_type` VARCHAR(255),
        IN `p_reminder_value` INT,
        IN `p_reminder_unit` VARCHAR(255)
    )
    BEGIN
        DECLARE v_task_coordinator INT;
        DECLARE v_task_assignee INT;
        
        -- التحقق من وجود المهمة
        SELECT `coordinator_id`, `user_assign_id` INTO v_task_coordinator, v_task_assignee
        FROM `Task_Assigns` WHERE `task_assign_id` = p_task_assign_id AND `deleted_at` IS NULL;
        
        IF v_task_coordinator IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المهمة غير موجودة';
        END IF;
        
        -- التحقق من صلاحية المستخدم: فقط المنسق المنشئ أو المورد المسند إليه يمكنه إضافة تذكير
        IF p_user_id != v_task_coordinator AND p_user_id != v_task_assignee THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ليس لديك صلاحية إضافة تذكير لهذه المهمة';
        END IF;
        
        -- إدراج التذكير
        IF p_reminder_type IS NOT NULL AND p_reminder_type != 'none' AND p_reminder_value IS NOT NULL AND p_reminder_unit IS NOT NULL THEN
            INSERT INTO `Task_Reminders` (`task_assign_id`, `user_id`, `reminder_type`, `reminder_value`, `reminder_unit`)
            VALUES (p_task_assign_id, p_user_id, p_reminder_type, p_reminder_value, p_reminder_unit);
            
            -- إشعار
            INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
            VALUES (p_user_id,
                'ADD_REMINDER',
                'إضافة تذكير',
                'تم إضافة تذكير لمهمتك بنجاح.'
            );
            
            SELECT LAST_INSERT_ID() AS reminder_id;
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_update_task_reminder`(
        IN `p_user_id` INT,
        IN `p_reminder_id` INT,
        IN `p_reminder_type` ENUM('INTERVAL', 'BEFORE_DUE'),
        IN `p_reminder_value` INT,
        IN `p_reminder_unit` ENUM('MINUTE', 'HOUR', 'DAY'),
        IN `p_is_active` BOOLEAN
    )
    BEGIN
        DECLARE v_reminder_user INT;
        
        -- الحصول على المستخدم المنشئ للتذكير
        SELECT `user_id` INTO v_reminder_user FROM `Task_Reminders` WHERE `reminder_id` = p_reminder_id AND `deleted_at` IS NULL;
        
        IF v_reminder_user IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'التذكير غير موجود';
        END IF;
        
        -- التحقق من أن المستخدم الحالي هو منشئ التذكير أو مدير
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
        
        -- إشعار
        INSERT INTO `Notifications` (`user_id`, `type`, `title`, `message`)
        VALUES (v_reminder_user,
            'UPDATE_REMINDER',
            'تحديث تذكير',
            'تم تحديث إعدادات تذكير المهمة الخاص بك بنجاح.'
        );
        
        SELECT p_reminder_id AS reminder_id;
    END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `sp_get_task_reminders`(
        IN `p_user_id` INT,
        IN `p_task_assign_id` INT
    )
    BEGIN
        -- التحقق من أن المستخدم له علاقة بالمهمة (منسق أو منفذ)
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_report_coordinator_events_summary`(
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_report_event_details`(
        IN `p_coordinator_id` INT,
        IN `p_event_id` INT
    )
    BEGIN
        DECLARE v_coordinator_name VARCHAR(255);
        DECLARE v_coordinator_email VARCHAR(255);
        DECLARE v_coordinator_phone VARCHAR(20);
        DECLARE v_coordinator_img TEXT;
        
        -- التحقق من وجود المنسق
        SELECT `full_name`, `email`, `phone_number`, `img_url`
        INTO v_coordinator_name, v_coordinator_email, v_coordinator_phone, v_coordinator_img
        FROM `Users` 
        WHERE `user_id` = p_coordinator_id 
        AND `deleted_at` IS NULL
        AND `role_name` IN ('coordinator', 'admin');
        
        IF v_coordinator_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المنسق غير موجود أو ليس لديه صلاحية';
        END IF;
        
        -- التحقق من أن الحدث يخص هذا المنسق
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
            -- لا يوجد حقل "مرفوضة" في Task_Assigns، يمكن اعتبار CANCELLED كمرفوضة
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_report_tasks_summary`(
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_report_task_details`(
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
        
        -- التحقق من أن المهمة تخص هذا المنسق
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_report_suppliers_summary`(
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
    END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE `sp_report_supplier_details`(
        IN `p_coordinator_id` INT,
        IN `p_supplier_id` INT
    )
    BEGIN
        DECLARE v_coordinator_name VARCHAR(255);
        DECLARE v_coordinator_email VARCHAR(255);
        DECLARE v_coordinator_phone VARCHAR(20);
        DECLARE v_coordinator_img TEXT;
        
        -- التحقق من وجود المنسق
        SELECT `full_name`, `email`, `phone_number`, `img_url`
        INTO v_coordinator_name, v_coordinator_email, v_coordinator_phone, v_coordinator_img
        FROM `Users` 
        WHERE `user_id` = p_coordinator_id 
        AND `deleted_at` IS NULL
        AND `role_name` IN ('coordinator', 'admin');
        
        IF v_coordinator_name IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المنسق غير موجود أو ليس لديه صلاحية';
        END IF;
        
        -- التحقق من وجود المورد
        IF NOT EXISTS (
            SELECT 1 FROM `Users` 
            WHERE `user_id` = p_supplier_id 
            AND `role_name` = 'supplier' 
            AND `deleted_at` IS NULL
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'المورد غير موجود';
        END IF;
        
        -- بيانات المورد
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
            COALESCE(ta_stats.cancelled_tasks, 0) AS rejected_tasks,  -- نفس الملغية
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
        
        -- إخراج النتيجة مع بيانات المنسق
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
    END$$
DELIMITER ;

DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_admin_dashboard_stats`$$
CREATE PROCEDURE `sp_admin_dashboard_stats`()
    BEGIN
        SELECT 
            -- User Basic Stats
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'admin' AND `deleted_at` IS NULL) as total_admins,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'coordinator' AND `deleted_at` IS NULL) as total_coordinators,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'supplier' AND `deleted_at` IS NULL) as total_suppliers,
            
            -- User Activation Stats
            (SELECT COUNT(*) FROM `Users` WHERE `deleted_at` IS NULL) as total_users,
            (SELECT COUNT(*) FROM `Users` WHERE `is_active` = TRUE AND `deleted_at` IS NULL) as active_users,
            (SELECT COUNT(*) FROM `Users` WHERE `is_active` = FALSE AND `deleted_at` IS NULL) as inactive_users,
            
            -- Role-specific Activation
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'coordinator' AND `is_active` = TRUE AND `deleted_at` IS NULL) as active_coordinators,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'coordinator' AND `is_active` = FALSE AND `deleted_at` IS NULL) as inactive_coordinators,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'supplier' AND `is_active` = TRUE AND `deleted_at` IS NULL) as active_suppliers,
            (SELECT COUNT(*) FROM `Users` WHERE `role_name` = 'supplier' AND `is_active` = FALSE AND `deleted_at` IS NULL) as inactive_suppliers,

            -- Service Stats
            (SELECT COUNT(*) FROM `Services` WHERE `deleted_at` IS NULL) as total_services,
            
            -- Suggestion Stats
            (SELECT COUNT(*) FROM `Service_Requests` WHERE `deleted_at` IS NULL) as total_suggestions,
            (SELECT COUNT(*) FROM `Service_Requests` WHERE `status` = 'PENDING' AND `deleted_at` IS NULL) as pending_suggestions,
            (SELECT COUNT(*) FROM `Service_Requests` WHERE `status` = 'APPROVED' AND `deleted_at` IS NULL) as approved_suggestions,
            (SELECT COUNT(*) FROM `Service_Requests` WHERE `status` = 'REJECTED' AND `deleted_at` IS NULL) as rejected_suggestions;
    END$$
DELIMITER ;


-- =====================================================
-- إنشاء المحفزات (Triggers)
-- =====================================================


DELIMITER $$
CREATE TRIGGER `trg_users_before_insert` BEFORE INSERT ON `Users`
    FOR EACH ROW 
    BEGIN
        IF EXISTS (SELECT 1 FROM `Users` WHERE `email` = NEW.`email`) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists for another user';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_users_before_update` BEFORE UPDATE ON `Users`
    FOR EACH ROW
    BEGIN
        IF NEW.`email` != OLD.`email` THEN
            IF EXISTS (SELECT 1 FROM `Users` WHERE `email` = NEW.`email` AND `user_id` != NEW.`user_id`) THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already exists for another user';
            END IF;
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_users_after_update` AFTER UPDATE ON `Users`
    FOR EACH ROW
    BEGIN 
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL AND OLD.role_name = 'coordinator' THEN 
            CALL sp_delete_all_events_of_coordinator(OLD.user_id);
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_clientss_before_update` BEFORE UPDATE ON `Clients`
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
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_supplier_services_before_insert` BEFORE INSERT ON `Supplier_Services`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`supplier_id`, 'supplier') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not a supplier';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_supplier_services_before_update` BEFORE UPDATE ON `Supplier_Services`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`supplier_id`, 'supplier') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not a supplier';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_task_assigns_before_insert` BEFORE INSERT ON `Task_Assigns`
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
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_task_assigns_before_update` BEFORE UPDATE ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        IF OLD.`date_due` IS NOT NULL AND OLD.`date_due` < CURDATE() THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن تحديث المهام في الماضي';
        END IF;
        IF NEW.`date_due` IS NOT NULL AND NEW.`date_start` IS NOT NULL AND NEW.`date_due` <= NEW.`date_start` THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'لا يمكن أن يكون تاريخ الانتهاء قبل تاريخ البدء';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_task_assigns_after_update` AFTER UPDATE ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN 
            UPDATE `Task_Reminders` SET `deleted_at` = NOW() WHERE `task_assign_id` = OLD.task_assign_id;
            UPDATE `Ratings_Task_Assign` SET `deleted_at` = NOW() WHERE `task_assign_id` = OLD.task_assign_id;
        END IF; 
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_ratings_task_assign_before_insert` BEFORE INSERT ON `Ratings_Task_Assign`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rater must be a coordinator';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_ratings_task_assign_before_update` BEFORE UPDATE ON `Ratings_Task_Assign`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rater must be a coordinator';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `trg_events_before_insert` BEFORE INSERT ON `Events`
    FOR EACH ROW
    BEGIN
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coordinator must have coordinator role';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_events_before_update` BEFORE UPDATE ON `Events`
    FOR EACH ROW
    BEGIN
        
        IF NOT fn_user_has_role(NEW.`coordinator_id`, 'coordinator') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Coordinator must have coordinator role';
        END IF;
    END $$
DELIMITER ;

DELIMITER $$ 
CREATE TRIGGER `trg_events_after_update` AFTER UPDATE ON `Events`
    FOR EACH ROW
    BEGIN
        IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN 
            UPDATE `Task_Assigns` SET `deleted_at` = NOW() WHERE `event_id` = OLD.event_id;
        END IF;
    END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `trg_task_assigns_before_delete` BEFORE DELETE ON `Task_Assigns`
    FOR EACH ROW
    BEGIN
        -- حذف تذكيرات المهمة (soft delete) قبل حذف المهمة
        UPDATE `Task_Reminders` SET `deleted_at` = NOW() WHERE `task_assign_id` = OLD.`task_assign_id`;
    END$$
DELIMITER ;



-- =====================================================
-- إنشاء الأحداث (Events)
-- =====================================================


-- تفعيل المجدول إذا كان مغلقاً
SET GLOBAL event_scheduler = ON;

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