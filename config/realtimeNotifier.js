// realtimeNotifier.js
const MySQLEvents = require('@rodrigogs/mysql-events');
const pool = require('./db'); // استيراد اتصال قاعدة البيانات للاستخدام في الـ Fallback

/**
 * تهيئة مراقب قاعدة البيانات لإرسال إشعارات في الزمن الفعلي
 * @param {Function} sendNotificationToClients - الدالة المسؤولة عن إرسال الإشعار عبر WebSocket
 */
async function initRealtimeNotifier(sendNotificationToClients) {
    console.log('🔍 بدء تهيئة مراقب قاعدة البيانات...');
    
    const dbName = process.env.DB_NAME || 'my_party_4';

    try {
        const connectionConfig = {
            port: process.env.PORT || 13941,
            ssl: {
                ca: fs.readFileSync(process.env.DB_SSL_CA || 'ca.pem')
            },
            database: process.env.DB_NAME || 'my_party_4',
            host: process.env.DB_HOST || 'mysql-myparty-zyad8594-myparty.c.aivencloud.com',
            user: process.env.DB_USER || 'avnadmin',
            password: process.env.DB_PASSWORD || 'AVNS_e0cMasOP8rhnQ1hhgm0',
        };

        const instance = new MySQLEvents(connectionConfig, {
            startAtEnd: true,
            excludedSchemas: { mysql: true },
        });

        instance.on(MySQLEvents.EVENTS.CONNECTION_ERROR, (err) => {
            console.error('❌ خطأ في اتصال مراقب قاعدة البيانات:', err.message);
        });

        instance.on(MySQLEvents.EVENTS.ZONGJI_ERROR, (err) => {
            console.error('❌ خطأ في Zongji:', err);
            // في حالة فشل Zongji بسبب الـ Binary Logging، سننتقل للـ Fallback
            // startPollingFallback(sendNotificationToClients, dbName);
        });

        await instance.start();
        console.log('✅ تم تشغيل الـ Binary Log Watcher بنجاح.');

        // المراقبة الأساسية
        const tablesToWatch = ['Notifications', 'notifications'];
        for (const tableName of tablesToWatch) {
            await instance.addTrigger({
                name: `monitor-${tableName}`,
                expression: `${dbName}.${tableName}`, 
                statement: MySQLEvents.STATEMENTS.INSERT,
                onEvent: (event) => {
                    const newNotification = event.affectedRows[0].after;
                    if (newNotification) sendNotificationToClients(newNotification);
                },
            });
        }

    } catch (error) {
        console.warn('⚠️ الـ Binary Logging غير مفعّل في MySQL، سيتم استخدام نظام الـ Polling كبديل.');
        startPollingFallback(sendNotificationToClients, dbName);
    }
}

/**
 * نظام بديل للجلب الدوري في حالة عدم تفعيل الـ Binary Logging في MySQL
 */
async function startPollingFallback(sendNotificationToClients, dbName) {
    console.log('🚀 بدء نظام الـ Fallback (الاستعلام الدوري الذكي)...');
    
    let lastNotificationId = 0;

    // الحصول على آخر معرف إشعار حالي لتجنب إرسال الإشعارات القديمة
    try {
        const [rows] = await pool.query(`SELECT MAX(notification_id) as maxId FROM Notifications`);
        lastNotificationId = rows[0].maxId || 0;
    } catch (err) {
        // تجربة الاسم البديل للجدول
        try {
            const [rows] = await pool.query(`SELECT MAX(notification_id) as maxId FROM notifications`);
            lastNotificationId = rows[0].maxId || 0;
        } catch (e) {}
    }

    // استعلام دوري كل 3 ثوانٍ
    setInterval(async () => {
        try {
            const [newRows] = await pool.query(
                `SELECT * FROM Notifications WHERE notification_id > ? AND deleted_at IS NULL ORDER BY notification_id ASC`,
                [lastNotificationId]
            );

            if (newRows.length > 0) {
                for (const row of newRows) {
                    console.log('� اكتشاف إشعار جديد عبر الـ Fallback:', row.title);
                    sendNotificationToClients(row);
                    lastNotificationId = Math.max(lastNotificationId, row.notification_id);
                }
            }
        } catch (err) {
            // محاولة مع الاسم الصغير للجدول في حالة فشل الكبير
            try {
                const [newRows] = await pool.query(
                    `SELECT * FROM notifications WHERE notification_id > ? AND deleted_at IS NULL ORDER BY notification_id ASC`,
                    [lastNotificationId]
                );
                if (newRows.length > 0) {
                    for (const row of newRows) {
                        sendNotificationToClients(row);
                        lastNotificationId = Math.max(lastNotificationId, row.notification_id);
                    }
                }
            } catch (e) {}
        }
    }, 3000);
}

module.exports = {
    initRealtimeNotifier
};
