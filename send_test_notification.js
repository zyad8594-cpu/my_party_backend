const mysql = require('mysql2/promise');
require('dotenv').config();

async function sendTestNotification() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || 'root',
        database: process.env.DB_NAME || 'my_party_4'
    });

    const userId = 2; // أحمد (المنسق)
    const title = 'إشعار فور 8';
    const message = 'تم الاتصال بالهاتف بنجاح! هذا اختبار للإشعارات الفورية عبر الـ Socket.';
    const type = 'SYSTEM_TEST';

    console.log(`--- Sending Test Notification to User ${userId} ---`);

    try {
        const [result] = await connection.query(
            'INSERT INTO Notifications (user_id, title, message, type, is_read) VALUES (?, ?, ?, ?, 0)',
            [userId, title, message, type]
        );
        
        console.log('✅ Notification record inserted with ID:', result.insertId);
        console.log('🕒 The backend will detect this and broadcast it via Socket and FCM within 3 seconds.');
    } catch (error) {
        console.error('❌ Error inserting notification:', error);
    } finally {
        await connection.end();
    }
}

sendTestNotification();
