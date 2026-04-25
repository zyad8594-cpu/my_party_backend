const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');
const { serverBasecPath } = require('../config/constents');

/**
 * Get all clients assigned to the coordinator
 */
exports.getAllClients = async (req, res) => {
    try {
        const [clients] = await pool.execute('SELECT * FROM `vw_clients_detailed` WHERE `coordinator_id` = ?', [req.user.user_id]);
        console.log({user_id: req.user.user_id});
        return ApiResponse.success(res, clients);
    } catch (err) {
        console.error('Error in getAllClients:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get client by ID
 */
exports.getClientById = async (req, res) => {
    try {
        const [client] = await pool.execute('SELECT * FROM `vw_clients_detailed` WHERE `client_id` = ? LIMIT 1', [req.params.id]);
        if (client.length === 0) return ApiResponse.error(res, 'العميل غير موجود', 404);
        return ApiResponse.success(res, client[0]);
    } catch (err) {
        console.error('Error in getClientById:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Create a new client record
 */
exports.createClient = async (req, res) => {
    const { full_name, phone_number, email, address } = req.body;
    let img_url = req.body.img_url? `${serverBasecPath}/${req.body.img_url}` : null;
    

    try {
        const [result] = await pool.execute(
            `CALL sp_create_client(?, ?, ?, ?, ?, ?, TRUE)`, 
            [req.user.user_id, full_name, phone_number, img_url, email, address]
        );
        return ApiResponse.success(res, result[0][0], 'تم إنشاء العميل بنجاح', 201);
    } catch (err) {
        console.error('Error in createClient:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Update client details
 */
exports.updateClient = async (req, res) => {
    const { full_name, phone_number, email, address } = req.body;
    let img_url = req.body.img_url? `${serverBasecPath}/${req.body.img_url}` : null;
    try {
        const [result] = await pool.execute(
            `CALL sp_update_client(?, ?, ?, ?, ?, ?, ?)`, 
            [
                req.user.user_id,
                req.params.id, 
                full_name || null, 
                phone_number || null, 
                img_url || null, 
                email || null, 
                address || null
            ]
        );

        return ApiResponse.success(res, result[0][0], 'تم تحديث بيانات العميل بنجاح');
    } catch (err) {
        console.error('Error in updateClient:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Delete client (Soft Delete)
 */
exports.deleteClient = async (req, res) => {
    try {
        await pool.execute('UPDATE Clients SET deleted_at = NOW() WHERE client_id = ?', [req.params.id]);
        return ApiResponse.success(res, null, 'تم حذف العميل بنجاح');
    } catch (err) {
        console.error('Error in deleteClient:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Restore a deleted client
 */
exports.restoreClient = async (req, res) => {
    try {
        await pool.execute('UPDATE Clients SET deleted_at = NULL WHERE client_id = ?', [req.params.id]);
        return ApiResponse.success(res, null, 'تم استعادة العميل بنجاح');
    } catch (err) {
        console.error('Error in restoreClient:', err);
        return ApiResponse.error(res, err.message);
    }
};