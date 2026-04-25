const pool = require('../config/db');
const ApiResponse = require('../utils/apiResponse');
const { serverBasecPath } = require('../config/constents');

/**
 * Get all tasks for the authenticated user
 */
exports.getAllTasks = async (req, res) => {
    try {
        if (req.user.role_name === 'admin') {
            const [tasks] = await pool.execute(`SELECT * FROM vw_tasks_full`);
            return ApiResponse.success(res, tasks);
        }
        const filterField = req.user.role_name === 'coordinator' ? 'coordinator_id' : 'user_assign_id';
        const [tasks] = await pool.execute(`SELECT * FROM vw_tasks_full WHERE ${filterField} = ?`, [req.user.user_id]);
        return ApiResponse.success(res, tasks);
    } catch (err) {
        console.error('Error in getAllTasks:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get task by ID with role-based visibility
 */
exports.getTaskById = async (req, res) => {
    try {
        const [result] = await pool.execute('CALL sp_report_task_details(?, ?)', [req.user.user_id, req.params.id]);
        if (!result[0] || result[0].length === 0) return ApiResponse.error(res, 'المهمة غير موجودة', 404);
        return ApiResponse.success(res, result[0][0]);
    } catch (err) {
        console.error('Error in getTaskById:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Get all tasks for a specific event
 */
exports.getTasksByEventId = async (req, res) => {
    try {
        const filterField = req.user.role_name === 'coordinator' ? 'coordinator_id' : 'user_assign_id';
        const [rows] = await pool.execute(`SELECT * FROM vw_tasks_full WHERE event_id = ? AND ${filterField} = ?`, [req.params.eventId, req.user.user_id]);
        return ApiResponse.success(res, rows);
    } catch (err) {
        console.error('Error in getTasksByEventId:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Create new task
 */
exports.createTask = async (req, res) => {
    const { 
        event_id, service_id, type_task, status, date_start, date_due, 
        user_assign_id, description, cost, notes, 
        reminder_type, reminder_value, reminder_unit 
    } = req.body;
    
    let url_image = req.body.url_image? `${serverBasecPath}/${req.body.url_image}` : null;

    try {
            
        // 1. Create the task
        const [result] = await pool.execute(
            'CALL sp_create_task(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                event_id || null, 
                service_id || null, 
                type_task || null, 
                status || 'PENDING', 
                date_start || null, 
                date_due || null, 
                user_assign_id || null, 
                description || null, 
                cost || 0, 
                null // p_task_assign_id (INOUT)
            ]
        );

        const taskAssignId = result[0][0] && result[0][0].task_assign_id;

        // 2. Optional: Add Reminder
        if (reminder_type && reminder_type !== 'none' && reminder_value && reminder_unit && taskAssignId) {
            await pool.execute('CALL sp_add_task_reminder(?, ?, ?, ?, ?)', [
                req.user.user_id,
                taskAssignId,
                reminder_type,
                reminder_value,
                reminder_unit
            ]);
        }

        return ApiResponse.success(res, { task_assign_id: taskAssignId }, 'تم إنشاء المهمة بنجاح', 201);
    } catch (err) {
        console.error('Error in createTask:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Update task details
 */
exports.updateTask = async (req, res) => {
    const { type_task, status, date_start, date_due, description, cost, notes } = req.body;
    const taskId = req.params.id;
    let url_image = req.body.url_image? `${serverBasecPath}/${req.body.url_image}` : null;
    try {
        const [result] = await pool.execute(
            'CALL sp_update_task(?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                taskId, 
                type_task || null, 
                status || null, 
                new Date(date_start) || null, 
                new Date(date_due) || null, 
                description || null, 
                cost || null, 
                notes || null, 
                url_image || null
            ]
        );
        return ApiResponse.success(res, result[0][0], 'تم تحديث المهمة بنجاح');
    } catch (err) {
        console.error('Error in updateTask:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Delete task (Soft/Hard depending on SP)
 */
exports.deleteTask = async (req, res) => {
    const { id } = req.params;
    try {
        await pool.execute('UPDATE Task_Assigns SET deleted_at = NOW() WHERE task_assign_id = ?', [id]);
        return ApiResponse.success(res, null, 'تم حذف المهمة بنجاح');
    } catch (err) {
        console.error('Error in deleteTask:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Add a reminder to a task
 */
exports.addTaskReminder = async (req, res) => {
    const { id } = req.params; 
    const { reminder_type, reminder_value, reminder_unit } = req.body;
    const user_id = req.user.user_id;

    if (!reminder_type || !reminder_value || !reminder_unit) {
        if (reminder_type !== 'none') {
            return ApiResponse.error(res, 'Missing or invalid reminder fields', 400);
        }
    }

    try {
        const [result] = await pool.execute(
            'CALL sp_add_task_reminder(?, ?, ?, ?, ?)',
            [user_id, id, reminder_type, reminder_value, reminder_unit]
        );
        const reminderId = result[0][0] && result[0][0].reminder_id;
        return ApiResponse.success(res, { reminderId }, 'تم إنشاء التذكير بنجاح', 201);
    } catch (err) {
        console.error('Error in addTaskReminder:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Update task status (Specifically for assignees)
 */
exports.updateTaskStatus = async (req, res) => {
    const { status, notes, adjustment_amount, adjustment_type } = req.body;
    let url_image = req.body.url_image? `${serverBasecPath}/${req.body.url_image}` : null;
    try {
        await pool.execute('CALL sp_update_task_status(?, ?, ?, ?, ?, ?, ?)', [
            req.user.user_id, 
            +req.params.id, 
            status, 
            notes || null, 
            url_image || null,
            adjustment_amount || 0,
            adjustment_type || 'NONE'
        ]);
        return ApiResponse.success(res, null, 'تم تحديث حالة المهمة بنجاح');
    } catch (err) {
        console.error('Error in updateTaskStatus:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Add evaluation rating to a completed task
 */
exports.addTaskRating = async (req, res) => {
    const { value_rating, comment } = req.body;
    try {
        await pool.execute('CALL sp_add_task_rating(?, ?, ?, ?)', [
            req.params.id, 
            req.user.user_id, 
            value_rating, 
            comment || null
        ]);
        return ApiResponse.success(res, null, 'تم إضافة التقييم بنجاح', 201);
    } catch (err) {
        console.error('Error in addTaskRating:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Update a task reminder
 */
exports.updateTaskReminder = async (req, res) => {
    const { id } = req.params; 
    const { reminder_type, reminder_value, reminder_unit } = req.body;
    const user_id = req.user.user_id;

    if (!reminder_type || !reminder_value || !reminder_unit) {
        return ApiResponse.error(res, 'Missing or invalid fields', 400);
    }

    try {
        const [result] = await pool.execute(
            'UPDATE Task_Reminders SET reminder_type = ?, reminder_value = ?, reminder_unit = ? WHERE task_assign_id = ? AND user_id = ?',
            [reminder_type, reminder_value, reminder_unit, id, user_id]
        );
        if (result.affectedRows === 0) {
            return ApiResponse.error(res, 'التذكير غير موجود أو لم يتم إجراء أي تغيير', 404);
        }
        return ApiResponse.success(res, null, 'تم تحديث التذكير بنجاح');
    } catch (err) {
        console.error('Error in updateTaskReminder:', err);
        return ApiResponse.error(res, err.message);
    }
};

/**
 * Delete a task reminder
 */
exports.deleteTaskReminder = async (req, res) => {
    const { id } = req.params; 
    const user_id = req.user.user_id;

    try {
        const [result] = await pool.execute(
            'DELETE FROM Task_Reminders WHERE task_assign_id = ? AND user_id = ?',
            [id, user_id]
        );
        if (result.affectedRows === 0) {
            return ApiResponse.error(res, 'التذكير غير موجود', 404);
        }
        return ApiResponse.success(res, null, 'تم حذف التذكير بنجاح');
    } catch (err) {
        console.error('Error in deleteTaskReminder:', err);
        return ApiResponse.error(res, err.message);
    }
};

