const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');

/**
 * List all users globally (Admin specialized view)
 */
exports.getAllUsers = async (req, res) => {
    try {
        const [users] = await pool.execute(`
            SELECT u.*, r.role_name
            FROM Users u
            JOIN Roles r ON u.role_id = r.role_id
            WHERE u.deleted_at IS NULL
        `);

        // Format user records explicitly for security and clarity
        const mappedUsers = users.map(user => {
            return {
                user_id: user.user_id,
                email: user.email,
                role: user.role_name,
                full_name: user.full_name,
                phone_number: user.phone_number,
                img_url: user.img_url,
                is_active: user.is_active,
                created_at: user.created_at
            };
        });

        return ApiResponse.success(res, mappedUsers);
    } catch (err) {
        console.error('Error in getAllUsers:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Toggle user activation status (Suspend / Activate)
 */
exports.toggleUserStatus = async (req, res) => {
    const userId = req.params.id;
    const { is_active } = req.body;

    if (typeof is_active !== 'boolean') {
        return ApiResponse.error(res, 'is_active must be a boolean value', 400);
    }

    try {
        const [result] = await pool.execute('UPDATE Users SET is_active = ? WHERE user_id = ?', [is_active, userId]);
        if (result.affectedRows === 0) {
            return ApiResponse.error(res, 'User not found', 404);
        }
        return ApiResponse.success(res, null, `User successfully ${is_active ? 'activated' : 'suspended'}`);
    } catch (err) {
        console.error('Error in toggleUserStatus:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Reassign user role
 */
exports.changeUserRole = async (req, res) => {
    const userId = req.params.id;
    const { role_id } = req.body;

    if (!role_id) {
        return ApiResponse.error(res, 'role_id is required', 400);
    }

    try {
        const [result] = await pool.execute('UPDATE Users SET role_id = ? WHERE user_id = ?', [role_id, userId]);
        if (result.affectedRows === 0) {
            return ApiResponse.error(res, 'User not found', 404);
        }
        return ApiResponse.success(res, null, 'تم تحديث دور المستخدم بنجاح');
    } catch (err) {
        console.error('Error in changeUserRole:', err);
        return ApiResponse.error(res, err.message);
    }
};






