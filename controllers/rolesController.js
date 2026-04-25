const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');

/**
 * List all roles with their associated permissions
 */
exports.getRoles = async (req, res) => {
    try {
        const [roles] = await pool.execute('SELECT * FROM Roles');
       
        for (let role of roles) {
            const [permissions] = await pool.execute(`
                SELECT p.*
                FROM Permissions p
                JOIN Role_Permissions rp ON p.permission_name = rp.permission_name
                WHERE rp.role_name = ?
            `, [role.role_name]);
            role.permissions = permissions;
        }
        return ApiResponse.success(res, roles);
    } catch (err) {
        console.error('Error in getRoles:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Create a new system role
 */
exports.createRole = async (req, res) => {
    const { role_name } = req.body;
    if (!role_name) return ApiResponse.error(res, 'Role name is required', 400);

    try {
        await pool.execute('INSERT INTO Roles (role_name) VALUES (?)', [role_name]);
        return ApiResponse.success(res, { role_name }, 'تم إنشاء الدور بنجاح', 201);
    } catch (err) {
        console.error('Error in createRole:', err);
        if (err.code === 'ER_DUP_ENTRY') {
            return ApiResponse.error(res, 'الدور موجود بالفعل', 400);
        }
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Assign and synchronize permissions for a specific role
 */
exports.assignPermissionsToRole = async (req, res) => {
    const roleName = req.params.name;
    const { permission_names } = req.body;

    if (!Array.isArray(permission_names)) {
        return ApiResponse.error(res, 'permission_names must be an array', 400);
    }

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Reset existing permissions
        await connection.execute('DELETE FROM Role_Permissions WHERE role_name = ?', [roleName]);

        // 2. Assign new permissions using SP in loop or bulk insert
        for (const pName of permission_names) {
            await connection.execute('CALL sp_add_permission_to_role(?, ?)', [roleName, pName]);
        }

        await connection.commit();
        return ApiResponse.success(res, null, 'تم تحديث الأذونات بنجاح للدور');
    } catch (err) {
        await connection.rollback();
        console.error('Error in assignPermissionsToRole:', err);
        return ApiResponse.error(res, err.message);
    } finally {
        connection.release();
    }
};

/**
 * Delete a role
 */
exports.deleteRole = async (req, res) => {
    const roleName = req.params.name;
    try {
        await pool.execute('DELETE FROM Roles WHERE role_name = ?', [roleName]);
        return ApiResponse.success(res, null, 'تم حذف الدور بنجاح');
    } catch (err) {
        console.error('Error in deleteRole:', err);
        if (err.code === 'ER_ROW_IS_REFERENCED_2') {
            return ApiResponse.error(res, 'لا يمكن حذف الدور لأنه مرتبط بمستخدمين', 400);
        }
        return ApiResponse.error(res, err.message);
    }
};

/**
 * List all available system permissions
 */
exports.getAllPermissions = async (req, res) => {
    try {
        const [permissions] = await pool.execute('SELECT * FROM Permissions');
        return ApiResponse.success(res, permissions);
    } catch (err) {
        console.error('Error in getAllPermissions:', err);
        return ApiResponse.error(res, err.message);
    }
};







