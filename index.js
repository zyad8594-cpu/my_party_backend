const express = require('express');
const http = require('http');
const cors = require('cors');
const path = require('path');
require('dotenv').config();
const ApiResponse = require('./utils/apiResponse');

const { initSocket, sendNotificationToClients } = require('./config/server');
const { initRealtimeNotifier } = require('./config/realtimeNotifier');
const { speedInsightsMiddleware } = require('./middlewares/speedInsights');

const app = express();
const server = http.createServer(app);
// const PORT = process.env.PORT || 3000;
const PORT =  3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Speed Insights middleware - injects performance tracking into HTML responses
// Note: This only affects HTML responses, not JSON API responses
app.use(speedInsightsMiddleware);

// Use Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/events', require('./routes/events'));
app.use('/api/tasks', require('./routes/tasks'));
app.use('/api/suppliers', require('./routes/suppliers'));
app.use('/api/services', require('./routes/services'));
app.use('/api/coordinators', require('./routes/coordinators'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/clients', require('./routes/clients'));
app.use('/api/incomes', require('./routes/incomes'));
app.use('/api/users', require('./routes/users'));
app.use('/api/dashboard', require('./routes/dashboard'));
app.use('/api/roles', require('./routes/roles'));
app.use('/api/system_users', require('./routes/systemUsers'));
app.use('/api/demo', require('./routes/demo'));

// المسار الأساسي للاختبار
app.get('/', (req, res) => {
    res.json({ message: 'مرحباً بكم في واجهة برمجة تطبيقات My Party Pro مع الإشعارات الفورية' });
});



// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    ApiResponse.error(res, err.message || 'حدث خطأ ما!', err.status || 500, err);
});

// Initialize Real-time Notifications
initSocket(server);
initRealtimeNotifier(sendNotificationToClients).catch(err => {
    console.error('❌ فشل تهيئة مراقب الإشعارات الفورية:', err);
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server is running on http://0.0.0.0:${PORT}`);
});
