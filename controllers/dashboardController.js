const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');

/**
 * Get comprehensive admin dashboard statistics
 */
exports.getAdminStats = async (req, res) => {
    try {
        const [result] = await pool.execute('CALL sp_admin_dashboard_stats()');
        if (!result[0] || result[0].length === 0) {
            return ApiResponse.error(res, 'لا توجد بيانات', 404);
        }
        return ApiResponse.success(res, result[0][0]);
    } catch (err) {
        console.error('Error in getAdminStats:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get home statistics for coordinator
 */
exports.getHomeStats = async (req, res) => {
   try {
       const [stats] = await pool.execute("CALL sp_home_stats_coordinator(?)", [req.user.user_id]);
       if (!stats[0] || !stats[0][0]) {
           return ApiResponse.error(res, 'لا توجد بيانات', 404);
       }
       return ApiResponse.success(res, stats[0][0]);
   } catch (err) {
       console.error('Error in getHomeStats:', err);
       return ApiResponse.error(res, err.message);
   }
};

/**
 * Get home statistics for supplier
 */
exports.getSupplierHomeStats = async (req, res) => {
   try {
       const [stats] = await pool.execute("CALL sp_home_stats_supplier(?)", [req.user.user_id]);
       if (!stats[0] || !stats[0][0]) {
           return ApiResponse.error(res, 'لا توجد بيانات', 404);
       }
       return ApiResponse.success(res, stats[0][0]);
   } catch (err) {
       console.error('Error in getSupplierHomeStats:', err);
       return ApiResponse.error(res, err.message);
   }
};

/**
 * Get detailed report statistics and monthly trends
 */
exports.getReportStats = async (req, res) => {
   try {
       const [stats] = await pool.execute("CALL sp_report_stats(?)", [req.user.user_id]);
       if (!stats[0] || !stats[0][0]) {
           return ApiResponse.error(res, 'لا توجد بيانات', 404);
       }
       const [monthlyIncome] = await pool.execute("CALL sp_monthly_income(?, ?)", [req.user.user_id, 12]);

       return ApiResponse.success(res, {
           ...stats[0][0],
           monthlyIncome: monthlyIncome[0] || []
       });

   } catch (err) {
       console.error('Error in getReportStats:', err);
       return ApiResponse.error(res, err.message);
   }
};
