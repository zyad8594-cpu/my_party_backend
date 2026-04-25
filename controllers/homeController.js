const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');

/**
 * Get general status overview (Simplified home view)
 */
exports.getAllStatus = async (req, res) => {
    try {
        const [eventCount] = await pool.execute('SELECT COUNT(*) as count FROM Events WHERE deleted_at IS NULL');
        const [clientCount] = await pool.execute('SELECT COUNT(*) as count FROM Clients WHERE deleted_at IS NULL');
        
        return ApiResponse.success(res, {
            total_events: eventCount[0].count,
            total_clients: clientCount[0].count
        });
    } catch (err) {
        console.error('Error in getAllStatus:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get client details (redundant but kept for compatibility with current routes)
 */
exports.getClientById = async (req, res) => {
    try {
        const [client] = await pool.execute('SELECT * FROM vw_clients_detailed WHERE client_id = ? LIMIT 1', [req.params.id]);
        if (client.length === 0) return ApiResponse.error(res, 'Client not found', 404);
        return ApiResponse.success(res, client[0]);
    } catch (err) {
        console.error('Error in getClientById:', err);
        return ApiResponse.error(res, err.message);
    }
};
