const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');
const { serverBasecPath } = require('../config/constents');

/**
 * Get all incomes for the coordinator's events
 */
exports.getAllIncomes = async (req, res) => {
    try {
        // Since there's no sp_get_all_incomes, we use sp_monthly_income for trend or direct query on view
        const [rows] = await pool.execute(
            'SELECT i.*, e.`event_name` FROM `Incomes` i JOIN `Events` e ON i.`event_id` = e.`event_id` WHERE e.`coordinator_id` = ? AND i.`deleted_at` IS NULL',
            [req.user.user_id]
        );
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getAllIncomes:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get income by ID
 */
exports.getIncomeById = async (req, res) => {
    try {
        const [rows] = await pool.execute(
            'SELECT i.*, e.`event_name` FROM `Incomes` i JOIN `Events` e ON i.`event_id` = e.`event_id` WHERE e.`coordinator_id` = ? AND i.`income_id` = ?', 
            [req.user.user_id, req.params.id]
        );
        if (rows.length === 0) return ApiResponse.error(res, 'الدخل غير موجود', 404);
        return ApiResponse.success(res, rows[0]);
    } catch (err) {
        console.error('Error in getIncomeById:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Create new income record
 */
exports.createIncome = async (req, res) => {
    const { event_id, amount, description, payment_date, payment_method } = req.body;
    let url_image = req.body.url_image? `${serverBasecPath}/${req.body.url_image}` : null;

    try {
        const [result] = await pool.execute(
            'CALL sp_create_income(?, ?, ?, ?, ?, ?, TRUE)',
            [event_id, amount, description, payment_date, payment_method, url_image]
        );
        return ApiResponse.success(res, result[0][0], 'تم إنشاء الدخل بنجاح', 201);
    } catch (err) {
        console.error('Error in createIncome:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Update income record
 */
exports.updateIncome = async (req, res) => {
    const { amount, description, payment_date, payment_method } = req.body;
    const incomeId = req.params.id;
    let url_image = req.body.url_image? `${serverBasecPath}/${req.body.url_image}` : null;

    try {
        const [result] = await pool.execute(
            'CALL sp_update_income(?, ?, ?, ?, ?, ?)', 
            [
                incomeId, 
                amount || null, 
                description || null, 
                payment_date? new Date(payment_date) : null, 
                payment_method || null, 
                url_image || null
            ]
        );
        return ApiResponse.success(res, result[0][0], 'تم تحديث الدخل بنجاح');
    } catch (err) {
        console.error('Error in updateIncome:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Delete income record
 */
exports.deleteIncome = async (req, res) => {
    try {
        await pool.execute('CALL sp_delete_income(?)', [req.params.id]);
        return ApiResponse.success(res, null, 'تم حذف الدخل بنجاح');
    } catch (err) {
        console.error('Error in deleteIncome:', err);
        return ApiResponse.error(res, err.message);
    }
};