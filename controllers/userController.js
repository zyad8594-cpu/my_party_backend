// backend/controllers/userController.js
const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const ApiResponse = require('../utils/apiResponse');
const { serverBasecPath } = require('../config/constents');

/**
 * Get all users
 */
exports.getAllUsers = async (req, res) => {
    try {
        const [users] = await pool.execute("SELECT user_id, full_name, role_name, email, phone_number, is_active, img_url, created_at FROM Users");
        return ApiResponse.success(res, users);
    } catch (err) {
        console.error('Error in getAllUsers:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get users by role
 */
exports.getAllUsersByRole = async (req, res) => {
    const { role } = req.params;
    try {
        let query = "";
        switch (role.toLowerCase()) {
            case 'coordinator':
                query = "SELECT * FROM vw_get_all_coordinators WHERE is_deleted = 0";
                break;
            case 'supplier':
                query = "SELECT * FROM vw_get_all_suppliers WHERE is_deleted = 0";
                if(req.user && req.user.role_name && req.user.role_name == 'coordinator')
                    query = `SELECT sup.*,
                        fn_get_avg_supplier_rating_for_coord(?, sup.user_id) AS average_rating
                        FROM vw_get_all_suppliers sup WHERE sup.is_deleted = 0`;
                break;
            case 'admin':
                query = "SELECT * FROM vw_get_all_admins";
                break;
            default:
                query = "SELECT * FROM Users WHERE role_name = ? AND deleted_at IS NULL";
        }
        const [users] = await pool.execute(query, 
            !['coordinator', 'supplier', 'admin'].includes(role.toLowerCase()) ?
             [role]:
             (role.toLowerCase() === 'supplier' && req.user && req.user.role_name && req.user.role_name == 'coordinator') ?
                [req.user.user_id]:
            []
                
        );
        
        // If supplier, we might want to attach services (optional based on use case, but for unification we do it)
        if (role.toLowerCase() === 'supplier') {
            for (const supplier of users) {
                const [services] = await pool.execute(
                    'SELECT sv.* FROM Supplier_Services ss JOIN Services sv ON ss.service_id = sv.service_id WHERE ss.supplier_id = ?',
                    [supplier.user_id]
                );
                supplier.services = services;
            }
        }
        
        return ApiResponse.success(res, users);
    } catch (err) {
        console.error('Error in getAllUsersByRole:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get user by ID
 */
exports.getUserById = async (req, res) => {
    try {
        const [result] = await pool.execute('CALL sp_get_user_by_id(?)', [req.params.id]);
        if (!result[0] || result[0].length === 0) return ApiResponse.error(res, 'المستخدم غير موجود', 404);
        
        const user = result[0][0];
        
        // Attach services if supplier
        if (user.role_name === 'supplier') {
            const [services] = await pool.execute(
                'SELECT sv.service_id, sv.service_name FROM Supplier_Services ss JOIN Services sv ON ss.service_id = sv.service_id WHERE ss.supplier_id = ?',
                [req.params.id]
            );
            user.services = services;
        }

        return ApiResponse.success(res, user);
    } catch (err) {
        console.error('Error in getUserById:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Create user (Admin Action)
 */
exports.create = async (req, res) => {
    const { role_name, full_name, phone_number, email, password, is_active, details, address, notes, services } = req.body;
    let img_url = req.body.img_url? `${serverBasecPath}/${req.body.img_url}` : null;

    try {
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password || 'password123', salt);

        let result;
        const isActiveValue = (is_active === true || is_active === 'true' || is_active == 1) ? 1 : (is_active !== undefined ? 0 : 1);

        if (role_name === 'supplier') {
            // Use sp_create_supplier for suppliers
            const [rows] = await pool.execute(
                'CALL sp_create_supplier(?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE)', 
                [
                    full_name, 
                    phone_number, 
                    img_url, 
                    isActiveValue, 
                    email, 
                    hashedPassword,
                    address || null,
                    notes || null,
                    JSON.stringify(services || [])
                ]
            );
            result = rows;
        } else if (role_name === 'coordinator') {
            // Use sp_create_coordinator for coordinators
            const [rows] = await pool.execute(
                'CALL sp_create_coordinator(?, ?, ?, ?, ?, ?, TRUE)', 
                [full_name, phone_number, img_url, isActiveValue, email, hashedPassword]
            );
            result = rows;
        } else {
            // Generic register for others
            const [rows] = await pool.execute('CALL sp_register(?, ?, ?, ?, ?, ?, ?, TRUE)', [
                role_name, 
                full_name, 
                phone_number, 
                img_url, 
                email, 
                hashedPassword, 
                JSON.stringify(details || {})
            ]);
            result = rows;
        }

        const newUserBasic = result[0] && result[0][0];
        if (!newUserBasic) return ApiResponse.error(res, 'فشل إنشاء المستخدم', 400);

        // Fetch full user data to avoid empty cards in UI
        const [fullUserRows] = await pool.execute('CALL sp_get_user_by_id(?)', [newUserBasic.user_id]);
        const fullUser = fullUserRows[0] && fullUserRows[0][0];
        
        if (fullUser && role_name === 'supplier') {
            const [services] = await pool.execute(
                'SELECT sv.service_id, sv.service_name FROM Supplier_Services ss JOIN Services sv ON ss.service_id = sv.service_id WHERE ss.supplier_id = ?',
                [newUserBasic.user_id]
            );
            fullUser.services = services;
        }

        return ApiResponse.success(res, fullUser || { user_id: newUserBasic.user_id }, 'تم إنشاء المستخدم بنجاح', 201);
    } catch (err) {
        console.error('Error in create user:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Update user
 */
exports.update = async (req, res) => {
    const { full_name, phone_number, email, password, details, address, notes, is_active, services } = req.body;
    const targetUserId = req.params.id;
    let img_url = req.body.img_url? `${serverBasecPath}/${req.body.img_url}` : null;
    
    try {
        // Find admin credentials for internal SP call
        const [admin] = await pool.execute('SELECT `email`, `password` FROM `Users` WHERE `role_name` = "admin" AND `deleted_at` IS NULL LIMIT 1');
        if (admin.length === 0) return ApiResponse.error(res, 'Internal configuration error: No admin found', 500);

        let hashedPassword = null;
        if (password) {
            const salt = await bcrypt.genSalt(10);
            hashedPassword = await bcrypt.hash(password, salt);
        }

        // Merge details for suppliers if provided
        let finalDetails = details || {};
        if (address || notes) {
            finalDetails = { ...finalDetails, address: address || null, notes: notes || null };
        }

        const [result] = await pool.execute('CALL sp_update_user(?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            admin[0].email,
            admin[0].password,
            targetUserId,
            full_name || null,
            phone_number || null,
            img_url || null,
            email || null,
            hashedPassword,
            JSON.stringify(finalDetails)
        ]);

        const updatedUser = result[0] && result[0][0];
        if (!updatedUser) return ApiResponse.error(res, 'فشل تحديث بيانات المستخدم', 400);

        // --- NEW: Sync Activity Status if provided and user is admin ---
        if (is_active !== undefined && req.user.role_name === 'admin') {
            const isActiveValue = (is_active === true || is_active === 'true' || is_active == 1) ? 1 : 0;
            await pool.execute('UPDATE Users SET is_active = ? WHERE user_id = ?', [isActiveValue, targetUserId]);
            updatedUser.is_active = isActiveValue;
        }

        // --- NEW: Sync Services if provided (for suppliers) ---
        if (services && Array.isArray(services)) {
            // Check if user is a supplier
            const [userRows] = await pool.execute('SELECT role_name FROM Users WHERE user_id = ?', [targetUserId]);
            if (userRows.length > 0 && userRows[0].role_name === 'supplier') {
                // Clear and re-assign
                await pool.execute('DELETE FROM Supplier_Services WHERE supplier_id = ?', [targetUserId]);
                for (const serviceId of services) {
                    await pool.execute('INSERT INTO Supplier_Services (supplier_id, service_id) VALUES (?, ?)', [targetUserId, serviceId]);
                }
                
                // Fetch updated services list to return
                const [serviceRows] = await pool.execute(
                    'SELECT sv.service_id, sv.service_name FROM Supplier_Services ss JOIN Services sv ON ss.service_id = sv.service_id WHERE ss.supplier_id = ?',
                    [targetUserId]
                );
                updatedUser.services = serviceRows;
            }
        }

        return ApiResponse.success(res, updatedUser, 'تم تحديث بيانات المستخدم بنجاح');
    } catch (err) {
        console.error('Error in update user:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Delete user (Soft Delete)
 */
exports.delete = async (req, res) => {
    try {
        await pool.execute('CALL sp_delete_user(?)', [req.params.id]);
        // Return dummy result since SP won't return one when called via triggers
        return ApiResponse.success(res, { user_id: req.params.id }, 'تم حذف المستخدم بنجاح');
    } catch (err) {
        console.error('Error in delete user:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Set user active status
 */
exports.set_active = async (req, res) => {
    const { is_active } = req.body;
    try {
        const isActiveValue = (is_active === true || is_active === 'true' || is_active == 1) ? 1 : 0;
        // Fixed: Passed 3rd parameter 'true' to sp_set_user_active to return result, and use sp_get_user_by_id unification
        await pool.execute('CALL sp_set_user_active(?, ?, TRUE)', [req.params.id, isActiveValue]);
        
        // Fetch full updated user to return consistent data
        const [rows] = await pool.execute('CALL sp_get_user_by_id(?)', [req.params.id]);
        if (!rows[0] || rows[0].length === 0) return ApiResponse.error(res, 'المستخدم غير موجود', 404);
        
        const updatedUser = rows[0][0];
        
        // Attach services if supplier
        if (updatedUser.role_name === 'supplier') {
            const [services] = await pool.execute(
                'SELECT sv.service_id, sv.service_name FROM Supplier_Services ss JOIN Services sv ON ss.service_id = sv.service_id WHERE ss.supplier_id = ?',
                [req.params.id]
            );
            updatedUser.services = services;
        }

        return ApiResponse.success(res, updatedUser, 'تم تحديث حالة المستخدم بنجاح');
    } catch (err) {
        console.error('Error in set_active:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Change Password
 */
exports.changePassword = async (req, res) => {
    const { oldPassword, newPassword } = req.body;
    const userId = req.params.userId;

    try {
        await pool.execute('CALL sp_change_password(?, ?, ?)', [userId, oldPassword, newPassword]);
        return ApiResponse.success(res, null, 'تم تغيير كلمة المرور بنجاح');
    } catch (err) {
        console.error('Error in changePassword:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Notification Management (Unified)
 */
exports.getNotifications = async (req, res) => {
    try {
        const [rows] = await pool.execute('SELECT * FROM Notifications WHERE user_id = ? AND deleted_at IS NULL', [req.user.user_id]);
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getNotifications:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.deleteNotification = async (req, res) => {
    try {
        await pool.execute('UPDATE Notifications SET deleted_at = NOW() WHERE notification_id = ? AND user_id = ?', 
            [req.params.notificationId, req.user.user_id]);
        return ApiResponse.success(res, null, 'تم حذف الإشعار بنجاح');
    } catch (err) {
        console.error('Error in deleteNotification:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.markAsRead = async (req, res) => {
    try {
        await pool.execute('UPDATE Notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?', 
            [req.params.notificationId, req.user.user_id]);
        return ApiResponse.success(res, null, 'تم تحديد الإشعار كمقروء');
    } catch (err) {
        console.error('Error in markAsRead:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.markAllAsRead = async (req, res) => {
    try {
        await pool.execute('UPDATE Notifications SET is_read = 1 WHERE user_id = ? AND is_read = 0', [req.user.user_id]);
        return ApiResponse.success(res, null, 'تم تحديد جميع الإشعارات كمقروءة');
    } catch (err) {
        console.error('Error in markAllAsRead:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.clearAllNotifications = async (req, res) => {
    try {
        await pool.execute('UPDATE Notifications SET deleted_at = NOW() WHERE user_id = ?', [req.user.user_id]);
        return ApiResponse.success(res, null, 'تم حذف جميع الإشعارات بنجاح');
    } catch (err) {
        console.error('Error in clearAllNotifications:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * FCM Token Updates
 */
exports.updateFCMToken = async (req, res) => {
    const { fcm_token, device_type } = req.body;
    const userId = req.user.user_id;

    if (!fcm_token) return ApiResponse.error(res, 'مطلوب رمز FCM', 400);

    try {
        await pool.execute('CALL sp_upsert_fcm_token(?, ?, ?)', [
            userId, 
            fcm_token, 
            device_type || 'unknown'
        ]);
        return ApiResponse.success(res, null, 'تم تحديث رمز FCM بنجاح');
    } catch (err) {
        console.error('Error in updateFCMToken:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.removeFCMToken = async (req, res) => {
    const { fcm_token } = req.body;
    const userId = req.user.user_id;

    if (!fcm_token) return ApiResponse.error(res, 'مطلوب رمز FCM', 400);

    try {
        await pool.execute('CALL sp_delete_fcm_token(?, ?)', [userId, fcm_token]);
        return ApiResponse.success(res, null, 'تم حذف رمز FCM بنجاح');
    } catch (err) {
        console.error('Error in removeFCMToken:', err);
        return ApiResponse.error(res, err.message);
    }
};
