const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');

/**
 * Get all notifications for the authenticated user
 */
exports.getNotifications = async (req, res) => {
    try {
        const [rows] = await pool.execute('SELECT * FROM Notifications WHERE `user_id` = ? AND `deleted_at` IS NULL', [req.user.user_id]);
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getNotifications:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Check for new notifications since a specific date
 */
exports.getLastNotifications = async (req, res) => {
    try {
        const [rows] = await pool.execute("SELECT * FROM Notifications WHERE `user_id` = ? AND `created_at` > ? AND `deleted_at` IS NULL", [req.user.user_id, req.params.date]);
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getLastNotifications:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Delete a specific notification (Hard Delete)
 */
exports.deleteNotification = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.execute('DELETE FROM Notifications WHERE notification_id = ? AND user_id = ?', [id, req.user.user_id]);
        return ApiResponse.success(res, null, 'تم حذف الإشعار بنجاح');
    } catch (err) {
        console.error('Error in deleteNotification:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Clear all notifications for the user
 */
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
 * Mark a notification as read
 */
exports.markAsRead = async (req, res) => {
   const { id } = req.params;
   try {
       await pool.execute('UPDATE Notifications SET is_read = 1 WHERE notification_id = ? AND user_id = ?', [id, req.user.user_id]);
       return ApiResponse.success(res, null, 'تم وضع علامة على الإشعار كمقروء');
   } catch (err) {
       console.error('Error in markAsRead:', err);
       return ApiResponse.error(res, err.message);
   }
};




