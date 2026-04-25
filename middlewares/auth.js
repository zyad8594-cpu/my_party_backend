const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'] || req.headers['Authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) {
        if(req.baseUrl == '/api/services' && req.originalUrl == '/api/services' && req.method == 'GET')
            return next();
        return res.status(401).json({ message: 'تم رفض الوصول. لم يتم تقديم Token.'});
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_super_secret_key');
        req.user = decoded; // Contains user info from token (id, role, etc.)
        next();
    } catch (err) {
        res.status(403).json({ message: 'Invalid token.' });
    }
};

const authorizeRole = (roles) => {
    return (req, res, next) => {
        // if (!req.user || !roles.includes(req.user.user_type) && !roles.includes(req.user.role_name)) {
        if (!req.user || !roles.includes(req.user.role_name)) {
            if(!(req.baseUrl == '/api/suppliers' && `${req.originalUrl}`.startsWith('/api/suppliers/') && req.method == 'GET'))
            {
                return res.status(403).json({ message: 'تم رفض الوصول. ليس لديك إذن..' + `\n${roles}` });
            }
        }
        next();
    };
};

module.exports = { authenticateToken, authorizeRole };
