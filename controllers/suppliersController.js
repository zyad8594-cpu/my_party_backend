const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');

/**
 * Unique Supplier actions (Service assignments and search by service)
 */

/**
 * Service Assignments
 */
exports.assignServiceToSupplier = async (req, res) => {
    const { supplier_id, service_id } = req.body;
    try {
        await pool.execute('CALL sp_assign_service_to_supplier(?, ?)', [supplier_id, service_id]);
        return ApiResponse.success(res, null, 'تم تعيين الخدمة بنجاح', 201);
    } catch (err) {
        console.error('Error in assignServiceToSupplier:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.removeServiceFromSupplier = async (req, res) => {
    const { supplier_id, service_id } = req.body;
    try {
        await pool.execute('CALL sp_remove_service_from_supplier(?, ?)', [supplier_id, service_id]);
        return ApiResponse.success(res, null, 'تم إزالة الخدمة بنجاح');
    } catch (err) {
        console.error('Error in removeServiceFromSupplier:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Public/Listings by Service
 */
exports.getAllByServiceId = async (req, res) => {
    try {
        const [rows] = await pool.execute(
            'SELECT sp.* FROM Supplier_Services ss JOIN vw_get_all_suppliers sp ON ss.supplier_id = sp.user_id WHERE ss.service_id = ? AND sp.is_deleted = 0',
            [req.params.serviceId]
        );
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getAllByServiceId:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Supplier Evaluation
 */
exports.getSuppliersWithCoordinatorRating = async (req, res) => {
   try {
       const [suppliersResult] = await pool.execute('CALL sp_get_suppliers_with_coordinator_rating(?)', [req.params.coordinatorId]);
       const supplierList = suppliersResult[0] || [];

       for (const supplier of supplierList) {
           const [services] = await pool.execute(
               'SELECT sv.* FROM Supplier_Services ss JOIN Services sv ON ss.service_id = sv.service_id WHERE ss.supplier_id = ?',
               [supplier.user_id]
           );
           supplier.services = services;
       }
       return ApiResponse.success(res, supplierList);
   } catch (err) {
       console.error('Error in getSuppliersWithCoordinatorRating:', err);
       return ApiResponse.error(res, err.message);
   }
};

/**
 * Service/Supplier combinations
 */
exports.getByIdAndServiceId = async (req, res) => {
    try {
        const [rows] = await pool.execute(
            'SELECT sp.* FROM Supplier_Services ss JOIN vw_get_all_suppliers sp ON ss.supplier_id = sp.user_id WHERE ss.supplier_id = ? AND ss.service_id = ?',
            [req.params.id, req.params.serviceId]
        );
        if (rows.length === 0) return ApiResponse.error(res, 'المورد أو الخدمة غير موجود', 404);
        return ApiResponse.success(res, rows[0]);
    } catch (err) {
        console.error('Error in getByIdAndServiceId:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.getMyServices = async(req, res) =>{
    try {
        const [rows] = await pool.execute(
            'SELECT * FROM vw_get_all_suppliers_and_services WHERE supplier_id = ? AND service_is_deleted = 0 AND supplier_is_deleted = 0',
            [req.user.user_id]
        );
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getMyServices:', err);
        return ApiResponse.error(res, err.message);
    }
}

exports.clearAllServices = async (req, res) => {
    try {
        await pool.execute('DELETE FROM Supplier_Services WHERE supplier_id = ?', [req.params.id]);
        return ApiResponse.success(res, null, 'تم حذف جميع الخدمات من المورد بنجاح');
    } catch (err) {
        console.error('Error in clearAllServices:', err);
        return ApiResponse.error(res, err.message);
    }
};
