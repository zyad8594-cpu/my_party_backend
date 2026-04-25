const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');

/**
 * Get all services with their associated suppliers
 */
exports.getAllServices = async (req, res) => {
    try {
        const [services] = await pool.execute('SELECT * FROM Services WHERE deleted_at IS NULL');

        if(req.user && req.user.role_name)
            for (const service of services) {
                const [suppliers] = await pool.execute(
                    (req.user.role_name === 'supplier' ?
                    'SELECT sup.* FROM Supplier_Services ss JOIN vw_get_all_suppliers sup ON ss.supplier_id = sup.user_id WHERE ss.service_id = ?' :
                    `SELECT sup.*,
                        fn_get_avg_supplier_rating_for_coord(?, sup.user_id) AS average_rating
                        FROM Supplier_Services ss 
                        JOIN vw_get_all_suppliers sup ON ss.supplier_id = sup.user_id
                        WHERE ss.service_id = ?`),
                    
                    (req.user.role_name === 'supplier' ?
                    [service.service_id] :
                    [req.user.user_id, service.service_id])
                );
                if(service.service_id === 27){
                    console.log(suppliers);
                }
                service.suppliers = suppliers;
            }
        return ApiResponse.success(res, services);
    } catch (err) {
        console.error('Error in getAllServices:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get service by ID
 */
exports.getServiceById = async (req, res) => {
    try {
        const [rows] = await pool.execute('SELECT * FROM Services WHERE service_id = ? AND deleted_at IS NULL', [req.params.id]);
        if (rows.length === 0) return ApiResponse.error(res, 'Service not found', 404);
        return ApiResponse.success(res, rows[0]);
    } catch (err) {
        console.error('Error in getServiceById:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Create new service (Admin Action)
 */
exports.createService = async (req, res) => {
    const { service_name, description } = req.body;
    try {
        const [result] = await pool.execute(
            'CALL sp_create_service(?, ?, ?, ?, ?)',
            [req.user.email, null, service_name, description, true]
        );
        return ApiResponse.success(res, result[0][0], 'تم إنشاء الخدمة بنجاح', 201);
    } catch (err) {
        console.error('Error in createService:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Update service details
 */
exports.updateService = async (req, res) => {
    const { service_name, description } = req.body;
    try {
        const [result] = await pool.execute(
            'CALL sp_update_service(?, ?, ?)',
            [req.params.id, service_name, description]
        );
        return ApiResponse.success(res, result[0][0], 'تم تحديث الخدمة بنجاح');
    } catch (err) {
        console.error('Error in updateService:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Delete service
 */
exports.deleteService = async (req, res) => {
    try {
        await pool.execute('CALL sp_delete_service(?)', [req.params.id]);
        return ApiResponse.success(res, null, 'تم حذف الخدمة بنجاح');
    } catch (err) {
        console.error('Error in deleteService:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Supplier-Service Relationships
 */
exports.getAllSuppliersAndServices = async(req, res) =>{
    try {
        const [rows] = await pool.execute('SELECT * FROM vw_get_all_suppliers_and_services');
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getAllSuppliersAndServices:', err);
        return ApiResponse.error(res, err.message);
    }
}

exports.getServicesForSupplier = async(req, res) =>{
    try {
        const [rows] = await pool.execute(
            'SELECT * FROM vw_get_all_suppliers_and_services WHERE supplier_id = ? AND service_is_deleted = 0',
            [req.params.supplierId]
        );
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getServicesForSupplier:', err);
        return ApiResponse.error(res, err.message);
    }
}

exports.getSuppliersForService = async(req, res) =>{
    try {
        const [rows] = await pool.execute(
            'SELECT * FROM vw_get_all_suppliers_and_services WHERE service_id = ? AND supplier_is_deleted = 0',
            [req.params.serviceId]
        );
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getSuppliersForService:', err);
        return ApiResponse.error(res, err.message);
    }
}

/**
 * Service Requests from Suppliers
 */
exports.createRequest = async (req, res) => {
    const { service_name, description } = req.body;
    const supplier_id = req.user.user_id;
   
    if (!service_name) return ApiResponse.error(res, 'اسم الخدمة مطلوب', 400);

    try {
        const [result] = await pool.execute(
            'INSERT INTO Service_Requests (supplier_id, service_name, description) VALUES (?, ?, ?)',
            [supplier_id, service_name, description]
        );
        const requestId = result.insertId;
        const [notification] = await pool.execute(
            'INSERT INTO Notifications (user_id, type, title, message) VALUES (?, ?, ?, ?)',
            [req.user.user_id, 'service_request', 'طلب خدمة جديد', `تم إنشاء طلب خدمة جديد باسم ${service_name}`]
        );
        return ApiResponse.success(res, { requestId: requestId }, 'تم إنشاء طلب الخدمة بنجاح', 201);
    } catch (err) {
        console.error('Error in createRequest:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.getAllRequests = async (req, res) => {
    try {
        const [rows] = await pool.execute(`
            SELECT sr.*, 
                   u.full_name as supplier_name, 
                   u.email as supplier_email, 
                   u.phone_number as supplier_phone, 
                   fn_user_get_detail(u.user_id, 'address') as supplier_address, 
                   u.img_url as supplier_img
            FROM Service_Requests sr
            JOIN Users u ON sr.supplier_id = u.user_id
            WHERE sr.deleted_at IS NULL
            ORDER BY sr.created_at DESC
        `);
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getAllRequests:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.getMyRequests = async (req, res) => {
    try {
        const [rows] = await pool.execute(`
            SELECT sr.*, 
                (sr.deleted_at IS NOT NULL) as is_deleted,
                   u.full_name as supplier_name, 
                   u.email as supplier_email, 
                   u.phone_number as supplier_phone, 
                   fn_user_get_detail(u.user_id, 'address') as supplier_address, 
                   u.img_url as supplier_img
            FROM Service_Requests sr
            JOIN Users u ON sr.supplier_id = u.user_id
            WHERE sr.supplier_id = ? AND sr.deleted_at IS NULL
            ORDER BY sr.created_at DESC
        `, [req.user.user_id]);
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getMyRequests:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.updateRequestStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;
    
    if (!['PENDING', 'APPROVED', 'REJECTED'].includes(status)) {
        return ApiResponse.error(res, 'حالة غير صالحة', 400);
    }
   
    try {
        await pool.execute('UPDATE Service_Requests SET status = ? WHERE id = ?', [status, id]);
        return ApiResponse.success(res, null, 'تم تحديث حالة طلب الخدمة بنجاح');
    } catch (err) {
        console.error('Error in updateRequestStatus:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.approveServiceRequest = async (req, res) => {
    const { id } = req.params;
    const { service_name, description } = req.body;
    
    if (!service_name) return ApiResponse.error(res, 'اسم الخدمة مطلوب', 400);

    try {
        const [result] = await pool.execute(
            'CALL sp_approve_service_request(?, ?, ?, ?)',
            [id, service_name, description, req.user.email]
        );
        return ApiResponse.success(res, result[0][0], 'تم إضافة الخدمة واعتماد المقترح بنجاح', 201);
    } catch (err) {
        console.error('Error in approveServiceRequest:', err);
        return ApiResponse.error(res, err.message);
    }
};

exports.withdrawRequest = async (req, res) => {
    const { id } = req.params;
    try {
        const [result] = await pool.execute(
            'UPDATE Service_Requests SET deleted_at = NOW() WHERE id = ? AND supplier_id = ? AND status = "PENDING"',
            [id, req.user.user_id]
        );
        if (result.affectedRows === 0) return ApiResponse.error(res, 'لا يمكن سحب هذا الطلب', 400);
        return ApiResponse.success(res, null, 'تم سحب طلب الخدمة بنجاح');
    } catch (err) {
        console.error('Error in withdrawRequest:', err);
        return ApiResponse.error(res, err.message);
    }
};

