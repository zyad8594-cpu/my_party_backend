const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '../.env') });

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

const ARABIC_NAMES = [
    'أحمد القحطاني', 'سارة العتيبي', 'محمد الزهراني', 'نورة الشهري', 'عبدالعزيز الفوزان',
    'فاطمة المطيري', 'خالد الدوسري', 'هيا الشمري', 'سلطان السبيعي', 'أمل الخالدي',
    'إبراهيم التميمي', 'مريم العنزي', 'فهد البقمي', 'عبير الحربي', 'يوسف الغامدي',
    'ليلى المالكي', 'منصور الرويلي', 'ريم الشراري', 'تركي السديري', 'جواهر الراشد',
    'ماجد المهنا', 'لطيفة الصالح', 'فيصل المانع', 'مشاعل الناصر', 'نايف الهذلي',
    'رائد الشايع', 'دلال المقبل', 'سامي الحكير', 'نوف العيسى', 'بندر الحكير'
];

const USER_IMAGES = [
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&auto=format&fit=crop'
];

const EVENT_IMAGES = [
    'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1504196606672-aef5c9cefc92?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1478147427282-58a87a120781?q=80&w=800&auto=format&fit=crop'
];

const PROOF_IMAGES = [
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=80&w=500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1507504031003-b417219a0fde?q=80&w=500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1513151233558-d860c5398176?q=80&w=500&auto=format&fit=crop'
];

const RECEIPT_IMAGES = [
    'https://images.unsplash.com/photo-1554224155-1696413565d3?q=80&w=500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1583521214690-73421a1829a9?q=80&w=500&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1586281380349-631523abb524?q=80&w=500&auto=format&fit=crop'
];

const SERVICE_NAMES = [
    'تنسيق زهور طبيعية', 'تصوير فوتوغرافي', 'بوفيه عشاء', 'تجهيز إضاءة',
    'دي جي عالي الجودة', 'تنفيذ كوش أفراح', 'تجهيز ركن قهوة', 'تنسيق هدايا',
    'تأجير طاولات وكراسي', 'خدمة ضيافة', 'دعوات إلكترونية', 'فرقة عرضة',
    'مسرح وشاشات LED', 'بالونات وهليوم', 'تورتة مناسبات'
];

const EVENT_TYPES = [
    'حفل زفاف', 'تخرج', 'عيد ميلاد', 'خطوبة', 'افتتاح معرض',
    'عشاء عمل', 'استقبال مولود', 'ليلة غمرة', 'تكريم موظفين'
];

const LOCATIONS = [
    'الرياض - قاعة نيارة', 'جدة - فندق هيلتون', 'الخبر - منتجع شاطئ الغروب',
    'مكة المكرمة - استراحة الوفاء', 'المدينة المنورة - فندق ميريديان',
    'الدمام - قاعة الأندلس'
];

function getRandom(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
}

function getUniqueImage(arr, index) {
    return arr[index % arr.length];
}

async function runSeeder() {
    console.log('--- Starting Massive Seeder V3 (Enhanced with unique Images) ---');
    try {
        console.log('1. Resetting Admin...');
        await pool.query('INSERT IGNORE INTO Users (user_id, role_name, full_name, phone_number, email, password, is_active) VALUES (1, "admin", "مدير النظام", "0501112223", "admin@myparty.com", "123456", 1)');

        console.log('2. Generating 25 Coordinators with unique profiles...');
        let coordIds = [];
        for (let i = 0; i < 25; i++) {
            let name = ARABIC_NAMES[i % ARABIC_NAMES.length];
            let email = `coord${i + 1}@myparty.com`;
            let res = await pool.query('CALL sp_register(?, ?, ?, ?, ?, ?, ?, ?)', [
                'coordinator', name, `0540000${(100+i)}`, getUniqueImage(USER_IMAGES, i), email, '123456', 
                JSON.stringify({ bio: `منسق خبير في ${getRandom(EVENT_TYPES)}`, city: getRandom(['الرياض', 'جدة']), experience_years: i%5 + 1 }), true
            ]);
            coordIds.push(res[0][0][0].user_id);
        }

        console.log('3. Generating 25 Suppliers with unique profiles...');
        let suppIds = [];
        for (let i = 0; i < 25; i++) {
            let name = `مؤسسة ${ARABIC_NAMES[(i+10)%ARABIC_NAMES.length]} للخدمات`;
            let email = `supp${i + 1}@myparty.com`;
            let res = await pool.query('CALL sp_register(?, ?, ?, ?, ?, ?, ?, ?)', [
                'supplier', name, `0560000${(100+i)}`, getUniqueImage(USER_IMAGES, i+25), email, '123456', 
                JSON.stringify({ company_name: name, city: getRandom(['الرياض', 'الدمام']), address: getRandom(LOCATIONS) }), true
            ]);
            suppIds.push(res[0][0][0].user_id);
        }

        console.log('4. Generating 30 Services...');
        let serviceIds = [];
        for (let i = 0; i < 30; i++) {
            let res = await pool.query('INSERT INTO Services (service_name, description) VALUES (?, ?)', [
                getRandom(SERVICE_NAMES) + ' #' + (i+1), 'خدمات احترافية ومميزة لمناسبتكم السعيدة'
            ]);
            serviceIds.push(res[0].insertId);
        }

        console.log('5. Linking Services...');
        for (let s_id of suppIds) {
            let srvs = [getRandom(serviceIds), getRandom(serviceIds)];
            for(let srv of srvs) await pool.query('INSERT IGNORE INTO Supplier_Services (supplier_id, service_id) VALUES (?, ?)', [s_id, srv]);
        }

        console.log('6. Generating 30 Clients...');
        let clientIds = [];
        for (let i = 0; i < 35; i++) {
            let res = await pool.query('CALL sp_create_client(?, ?, ?, ?, ?, ?, ?)', [
                getRandom(coordIds), ARABIC_NAMES[(i+15)%ARABIC_NAMES.length], `0550000${(200+i)}`, 
                getUniqueImage(USER_IMAGES, i+50), `client${i+1}@test.com`, getRandom(LOCATIONS), true
            ]);
            clientIds.push(res[0][0][0].client_id);
        }

        console.log('7. Generating 50 Events with unique covers...');
        let eventIds = [];
        for (let i = 0; i < 55; i++) {
            let budget = (Math.floor(Math.random() * 50) + 10) * 1000;
            let date = new Date(); date.setDate(date.getDate() + (i-10));
            let res = await pool.query('CALL sp_create_event(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                getRandom(clientIds), getRandom(coordIds), getRandom(EVENT_TYPES) + ' ' + (i+1), 
                'وصف كامل للحدث الخاص والمنظم بدقة عالية رضاءكم غايتنا.', getUniqueImage(EVENT_IMAGES, i),
                date.toISOString().split('T')[0], getRandom(LOCATIONS), budget, 1, 'DAY'
            ]);
            eventIds.push(res[0][0][0].event_id);
        }

        console.log('8. Generating 150+ Tasks with Proof Images for completed tasks...');
        let [validPairs] = await pool.query('SELECT supplier_id, service_id FROM Supplier_Services');
        const statuses = ['PENDING', 'IN_PROGRESS', 'UNDER_REVIEW', 'COMPLETED', 'REJECTED'];
        let taskIds = [];
        const todayLocal = new Date();
        const formattedToday = `${todayLocal.getFullYear()}-${(todayLocal.getMonth() + 1).toString().padStart(2, '0')}-${todayLocal.getDate().toString().padStart(2, '0')}`;

        for (let ev_id of eventIds) {
            for (let t = 0; t < 3; t++) {
                let pair = getRandom(validPairs);
                let status = getRandom(statuses);
                let dueDate = new Date(); dueDate.setDate(dueDate.getDate() + 15);
                let formattedDue = `${dueDate.getFullYear()}-${(dueDate.getMonth() + 1).toString().padStart(2, '0')}-${dueDate.getDate().toString().padStart(2, '0')}`;
                
                await pool.query('SET @tid = 0');
                await pool.query('CALL sp_create_task(?, ?, ?, ?, ?, ?, ?, ?, ?, @tid)', [
                    ev_id, pair.service_id, 'مهمة ' + (t+1), status, formattedToday, 
                    formattedDue, pair.supplier_id, 'تفاصيل المهمة الفنية والمطلوب تنفيذها', (Math.random()*2000+500)
                ]);
                let [tidRes] = await pool.query('SELECT @tid as tid');
                let tid = tidRes[0].tid;
                
                if (status === 'COMPLETED' || status === 'UNDER_REVIEW') {
                    await pool.query('UPDATE Task_Assigns SET url_image = ? WHERE task_assign_id = ?', [getRandom(PROOF_IMAGES), tid]);
                }
            }
        }

        console.log('9. Generating Receipts (Incomes) with Receipt Images...');
        for (let ev_id of eventIds) {
            await pool.query('INSERT INTO Incomes (event_id, amount, payment_method, payment_date, url_image, description) VALUES (?, ?, ?, ?, ?, ?)', [
                ev_id, (Math.random()*5000+1000), 'كاش / شبكة', formattedToday, getRandom(RECEIPT_IMAGES), 'دفعة مقدمة / دفعة كاملة للمناسبة'
            ]);
        }

        console.log('10. Rating and Notifications...');
        let [compTasks] = await pool.query('SELECT task_assign_id, coordinator_id FROM Task_Assigns WHERE status = "COMPLETED"');
        for (let t of compTasks.slice(0, 50)) {
            await pool.query('CALL sp_add_task_rating(?, ?, ?, ?)', [t.task_assign_id, t.coordinator_id, Math.floor(Math.random()*2)+4, 'تقييم ممتاز للعمل المنجز']);
        }

        console.log('--- Massive Enhanced Seeder Completed Successfully! ---');
    } catch (err) {
        console.error('FATAL ERROR DURING SEEDING:', err);
    } finally {
        process.exit(0);
    }
}

runSeeder();
