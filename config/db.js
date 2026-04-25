const fs = require('fs');
const mysql = require('mysql2/promise');
require('dotenv').config();
 
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'mysql-myparty-zyad8594-myparty.c.aivencloud.com',
    port: process.env.DB_PORT || process.env.PORT || 13941,
    user: process.env.DB_USER || 'avnadmin',
    password: process.env.DB_PASSWORD || 'AVNS_e0cMasOP8rhnQ1hhgm0',
    database: process.env.DB_NAME || 'my_party_4',
    waitForConnections: true,
    connectTimeout: 30000,
    connectionLimit: 10,
    queueLimit: 0,
    ssl: {
        ca: fs.readFileSync(process.env.DB_SSL_CA || 'ca.pem')
    }
});

module.exports = pool;
