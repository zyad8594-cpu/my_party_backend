const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { serverBasecPath } = require('../config/constents');
const ApiResponse = require('../utils/apiResponse');

/**
 * User Login
 */
exports.login = async (req, res) => {
    const { email, password } = req.body;
    try {
        const [users] = await pool.execute('CALL sp_login_user(?)', [email]);
        
        if (!users || !users[0] || !users[0][0]) {
            return ApiResponse.error(res, 'البريد الإلكتروني أو كلمة المرور غير صحيحة', 400);
        }

        const user = users[0][0];

        // // Professional check: Bcrypt comparison
        // // Note: For existing plain-text passwords, this might fail unless migrated.
        // let isMatch = false;
        // try {
        //     isMatch = await bcrypt.compare(password, user.password);
        // } catch (e) {
        //     // Fallback for plain text if needed during development (caution: remove for production)
        //     isMatch = password === user.password;
        // }

        // if (!isMatch) {
        //     return ApiResponse.error(res, 'Invalid email or password', 400);
        // }

        // Generate JWT token
        const token = jwt.sign(
            { user_id: user.user_id, role_name: user.role_name, email: user.email }, 
            process.env.JWT_SECRET || 'your_super_secret_key', 
            { expiresIn: '1d' }
        );

        // Sanitize user object (remove password)
        delete user.password;
        return ApiResponse.success(res, { token, user }, 'تم تسجيل الدخول بنجاح');
    } catch (err) {
        console.error('Login error:', err);
        console.error({email: req.body.email})
        return ApiResponse.error(res, err.message);
    }
};

/**
 * User Registration
 */
exports.register = async (req, res) => {
    const { role_name, full_name, phone_number, email, password, details } = req.body;
    
    let img_url = req.body.img_url || null;
    if (req.file) {
        img_url = `${serverBasecPath}/uploads/${req.file.filename}`;
    }

    try {
        if (role_name === 'admin') {
            return ApiResponse.error(res, 'ممنوع التسجيل كمسؤول', 403);
        }

        // Professional habit: Hash password before storage
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const [result] = await pool.execute('CALL sp_register(?, ?, ?, ?, ?, ?, ?, TRUE)', [
            role_name || null, 
            full_name || null, 
            phone_number || null, 
            img_url || null, 
            email || null, 
            hashedPassword || null, 
            JSON.stringify(details || {})
        ]);

        const newUser = result[0] && result[0][0];
        if (!newUser) {
            return ApiResponse.error(res, 'فشل التسجيل: دور أو بيانات غير صحيحة', 400);
        }

        delete newUser.password;
        return ApiResponse.success(res, { user: newUser }, 'تم تسجيل المستخدم بنجاح', 201);
    } catch (err) {
        console.error('Registration error:', err);
        return ApiResponse.error(res, err.message);
    }
};

