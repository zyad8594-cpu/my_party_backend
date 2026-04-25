const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');
const { serverBasecPath } = require('../config/constents');

/**
 * Get all events for the authenticated coordinator
 */
exports.getAllEvents = async (req, res) => {
    try {
        const [events] = await pool.execute('CALL sp_events_detailed(?)', [req.user.user_id]);
        if (!events[0] || events[0].length === 0) {
            return ApiResponse.success(res, [], 'لا توجد مناسبات');
        }
        return ApiResponse.success(res, events[0]);
    } catch (err) {
        console.error('Error in getAllEvents:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get event by ID
 */
exports.getEventById = async (req, res) => {
    try {
        const [result] = await pool.execute('SELECT * FROM vw_events_detailed WHERE event_id = ?', [+req.params.id]);
        if (!result[0] || result[0].length === 0) return ApiResponse.error(res, 'Event not found', 404);
        return ApiResponse.success(res, result[0]);
    } catch (err) {
        console.error('Error in getEventById:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Create a full event with associated data
 */
exports.createEvent = async (req, res) => {
    const { 
        client_id, event_name, description, event_date, location, 
        budget, event_duration, event_duration_unit, options 
    } = req.body;
    let img_url = req.body.img_url? `${serverBasecPath}/${req.body.img_url}` : null;


    // Map duration unit from Arabic (Flutter) to DB ENUM
    let mapped_unit = 'WEEK'; // Default
    const unit = (event_duration_unit || '').toString();
    if (unit === 'يوم' || unit.toUpperCase() === 'DAY') mapped_unit = 'DAY';
    else if (unit === 'أسبوع' || unit.toUpperCase() === 'WEEK') mapped_unit = 'WEEK';
    else if (unit === 'شهر' || unit.toUpperCase() === 'MONTH') mapped_unit = 'MONTH';

    try {
        const [result] = await pool.execute(
            'CALL sp_create_event(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                client_id, 
                req.user.user_id, 
                event_name, 
                description || null, 
                img_url || null, 
                event_date, 
                location || null, 
                budget || 0.0, 
                event_duration || 1, 
                mapped_unit
            ]
        );
        const newEvent = result[0][0];

        if(options && newEvent && newEvent.event_id > 0){
            if(options.tasks && options.tasks.length > 0){
                options.tasks.forEach(task => {
                    pool.execute(
                        'CALL sp_create_task(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
                        [
                            newEvent.event_id || null, 
                            task.service_id || null, 
                            task.type_task || null, 
                            task.status || 'PENDING', 
                            task.date_start || null, 
                            task.date_due || null, 
                            task.user_assign_id || null, 
                            task.description || null, 
                            task.cost || 0, 
                            task.notes || null, 
                            task.url_image || null,
                            null // p_task_assign_id (INOUT)
                        ]
                    );
                });
            }
            if(options.incomes && options.incomes.length > 0){
                options.incomes.forEach(income => {
                    pool.execute(
                        'CALL sp_create_income(?, ?, ?, ?, ?, ?, TRUE)',
                        [
                            newEvent.event_id, 
                            income.amount, 
                            income.description, 
                            income.payment_date, 
                            income.payment_method, 
                            income.url_image
                        ]
                    );
                });
            }
        }
        JSON.stringify(options || {})
        return ApiResponse.success(res, result[0][0], 'تم إنشاء المناسبة بنجاح', 201);
    } catch (err) {
        console.error('Error in createEvent:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Update event details
 */
exports.updateEvent = async (req, res) => {

    const { event_name, client_id, description, event_date, location, budget, event_duration, event_duration_unit } = req.body;
    const eventId = req.params.id;
    let img_url = req.body.img_url? `${serverBasecPath}/${req.body.img_url}` : null;
    try {
        const [result] = await pool.execute(
            'CALL sp_update_event(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                eventId, 
                client_id || null,
                event_name || null, 
                description || null, 
                img_url || null, 
                event_date && event_date.length > 0 ? new Date(event_date) : null, 
                location || null, 
                budget || null, 
                event_duration || null, 
                event_duration_unit || null 
            ]
        );
        console.log(result[0][0]);
        return ApiResponse.success(res, result[0][0], 'تم تحديث المناسبة بنجاح');
    } catch (err) {
        console.error('Error in updateEvent:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Delete event (Soft delete via SP)
 */
exports.deleteEvent = async (req, res) => {
    try {
        await pool.execute('CALL sp_delete_event(?)', [req.params.id]);
        return ApiResponse.success(res, null, 'تم حذف المناسبة بنجاح');
    } catch (err) {
        console.error('Error in deleteEvent:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Cancel an event with a reason
 */
exports.cancelEvent = async (req, res) => {
    try {
        await pool.execute('CALL sp_delete_event(?)', [req.params.id]);
        return ApiResponse.success(res, null, 'تم إلغاء المناسبة بنجاح');
    } catch (err) {
        console.error('Error in cancelEvent:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Update event status (Placeholder as status is calculated)
 */
exports.updateEventStatus = async (req, res) => {
    // Current schema uses calculated status via fn_event_get_status
    // To 'cancel', we delete. Other statuses depend on date.
    const { status } = req.body;
    if (status === 'CANCELLED') {
        return this.cancelEvent(req, res);
    }
    return ApiResponse.error(res, 'لا يمكن تحديث حالة المناسبة يدوياً (الحالة تعتمد على التاريخ)');
};

