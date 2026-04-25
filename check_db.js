const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkMysqlConfig() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'my_party_4'
    });

    console.log('--- MySQL System Variables ---');
    const [binlogFormat] = await connection.query("SHOW VARIABLES LIKE 'binlog_format'");
    console.log('binlog_format:', binlogFormat[0]?.Value);

    const [binlogChecksum] = await connection.query("SHOW VARIABLES LIKE 'binlog_checksum'");
    console.log('binlog_checksum:', binlogChecksum[0]?.Value);

    const [logBin] = await connection.query("SHOW VARIABLES LIKE 'log_bin'");
    console.log('log_bin:', logBin[0]?.Value);

    console.log('\n--- Database Tables ---');
    const [tables] = await connection.query("SHOW TABLES");
    console.log('Tables in', process.env.DB_NAME, ':', tables.map(t => Object.values(t)[0]));

    await connection.end();
}

checkMysqlConfig().catch(console.error);
