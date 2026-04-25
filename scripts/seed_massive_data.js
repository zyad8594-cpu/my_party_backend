const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
dotenv.config();

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'root',
    database: process.env.DB_NAME || 'my_party_4',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    multipleStatements: true
});

async function runSeeder() {
    console.log('--- Starting Massive Seeder (V2) ---');
    try {
        console.log('1. Database is assumed to be fresh from database_3.sql');
        
        // Insert Admin
        await pool.query(`INSERT INTO Users (user_id, role_name, full_name, phone_number, email, password, is_active)
            VALUES (1, 'admin', 'System Admin', '1234567890', 'admin@myparty.com', '123456', 1)`);
        
        console.log('2. Generating 20+ Coordinators & Suppliers...');
        let coordIds = [];
        let suppIds = [];
        for (let i = 1; i <= 25; i++) {
            // Coordinator
            let coordRes = await pool.query('CALL sp_register(?, ?, ?, ?, ?, ?, ?, ?)', [
                'coordinator', `Coordinator ${i}`, `966500000${100+i}`, null, `coord${i}@test.com`, '123456', '{}', true
            ]);
            coordIds.push(coordRes[0][0][0].user_id);

            // Supplier
            let suppRes = await pool.query('CALL sp_register(?, ?, ?, ?, ?, ?, ?, ?)', [
                'supplier', `Supplier ${i}`, `966500000${200+i}`, null, `supp${i}@test.com`, '123456', '{}', true
            ]);
            suppIds.push(suppRes[0][0][0].user_id);
        }

        console.log('3. Generating 25+ Services...');
        let serviceIds = [];
        for (let i = 1; i <= 30; i++) {
            let res = await pool.query('INSERT INTO Services (service_name, description) VALUES (?, ?)', [
                `خدمة #${i} - ${['تجهيز', 'تصوير', 'موسيقى', 'قاعات', 'هدايا'][i % 5]}`, `وصف مفصل للخدمة رقم ${i}`
            ]);
            serviceIds.push(res[0].insertId);
        }

        console.log('4. Assigning services to suppliers...');
        for(let s_id of suppIds) {
            // Give each supplier 2-3 random services
            for(let j=0; j<3; j++) {
                let srv = serviceIds[Math.floor(Math.random() * serviceIds.length)];
                await pool.query('INSERT IGNORE INTO Supplier_Services (supplier_id, service_id) VALUES (?, ?)', [s_id, srv]);
            }
        }

        console.log('5. Generating 25+ Clients...');
        let clientIds = [];
        for (let i = 1; i <= 30; i++) {
            let coord = coordIds[Math.floor(Math.random() * coordIds.length)];
            let res = await pool.query('CALL sp_create_client(?, ?, ?, ?, ?, ?, ?)', [
                coord, `العميل ${i}`, `55000${100+i}`, null, `client${i}@test.com`, `الرياض - حي الياسمين ${i}`, true
            ]);
            clientIds.push(res[0][0][0].client_id);
        }

        console.log('6. Generating 40+ Events...');
        let eventIds = [];
        for (let i = 1; i <= 45; i++) {
            let coord = coordIds[Math.floor(Math.random() * coordIds.length)];
            let client = clientIds[Math.floor(Math.random() * clientIds.length)];
            let budget = (Math.floor(Math.random() * 90) + 10) * 1000; // 10k to 100k
            let targetDate = new Date();
            targetDate.setDate(targetDate.getDate() + (Math.floor(Math.random() * 120) - 30)); // random dates +/- 
            let formattedDate = targetDate.toISOString().split('T')[0];
            
            let res = await pool.query('CALL sp_create_event(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                client, coord, `مناسبة رقم ${i} (${['زواج', 'تخرج', 'ميلاد'][i % 3]})`, `وصف للحدث رقم ${i}`, null, formattedDate, 'فندق الفورسيزونز', budget, 1, 'DAY'
            ]);
            let event_id = res[0][0][0].event_id;
            eventIds.push(event_id);
        }

        console.log('7. Generating Tasks (150+ tasks)...');
        const taskStatuses = ['PENDING', 'IN_PROGRESS', 'UNDER_REVIEW', 'COMPLETED', 'REJECTED', 'CANCELLED'];
        
        // Fetch valid pairs from Supplier_Services to avoid FK errors
        let [validPairs] = await pool.query('SELECT supplier_id, service_id FROM Supplier_Services');
        
        for (let ev of eventIds) {
            let numOfTasks = Math.floor(Math.random() * 4) + 3; // 3 to 6 tasks per event
            for (let t = 0; t < numOfTasks; t++) {
                let pair = validPairs[Math.floor(Math.random() * validPairs.length)];
                let c_date = new Date().toISOString().split('T')[0];
                let d_date = new Date(); d_date.setDate(d_date.getDate() + 10);
                let due_date = d_date.toISOString().split('T')[0];
                let cost = Math.floor(Math.random() * 8000) + 1000;
                let status = taskStatuses[Math.floor(Math.random() * taskStatuses.length)];
                
                await pool.query('SET @out_task_id = 0');
                await pool.query('CALL sp_create_task(?, ?, ?, ?, ?, ?, ?, ?, ?, @out_task_id)', [
                    ev, pair.service_id, 'مهمة برمجية '+t, status, c_date, due_date, pair.supplier_id, 'وصف المهمة الاختبارية المكثفة', cost
                ]);
            }
        }
        
        console.log('8. Generating 35+ Service Requests...');
        const suggStatuses = ['PENDING', 'APPROVED', 'REJECTED'];
        for(let i=1; i<=40; i++) {
            let supp = suppIds[Math.floor(Math.random() * suppIds.length)];
            let sname = `خدمة مقترحة #${i}`;
            let sdesc = `نود إضافة هذه الخدمة لتسهيل العمل على الموردين ${i}`;
            let status = suggStatuses[Math.floor(Math.random() * suggStatuses.length)];
            await pool.query('INSERT INTO Service_Requests (supplier_id, service_name, description, status) VALUES (?, ?, ?, ?)', [
                 supp, sname, sdesc, status
            ]);
        }

        console.log('--- Massive Seeding V2 Completed Successfully! ---');

    } catch (err) {
        console.error('Error seeding data:', err);
    } finally {
        process.exit(0);
    }
}

runSeeder();
