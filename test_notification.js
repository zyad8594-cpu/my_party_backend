const mysql = require('mysql2/promise');
require('dotenv').config();

async function testNotification() {
    const email = 'ahmed@myparty.com';
    const password = '123456';
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || 'root',
        database: process.env.DB_NAME || 'my_party_4'
    });

    console.log('--- Triggering Task Update to Test Notifications ---');

    try {
       const [services] = await connection.execute('SELECT * FROM Services');

        for (const service of services) {
            const [suppliers] = await connection.execute(
                'SELECT sup.* FROM Supplier_Services ss JOIN vw_get_all_suppliers sup ON ss.supplier_id = sup.user_id WHERE ss.service_id = ?',
                [service.service_id]
            );
            service.suppliers = {...suppliers};
        }
        console.log(services);
    } catch (error) {
        console.error('❌ Error triggering notification:', error);
    } finally {
        await connection.end();
    }
}

testNotification();
