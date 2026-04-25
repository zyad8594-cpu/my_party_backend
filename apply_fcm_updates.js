const mysql = require('mysql2/promise');
require('dotenv').config();

async function applyUpdates() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'my_party_4',
        multipleStatements: true
    });

    console.log('--- Applying FCM Database Updates ---');

    try {
        // 1. Add Unique Constraint
        console.log('Adding Unique Constraint to User_FCM_Tokens...');
        try {
            await connection.query('ALTER TABLE User_FCM_Tokens ADD CONSTRAINT `uc_user_token` UNIQUE (`user_id`, `token`(255))');
            console.log('✅ Unique constraint added.');
        } catch (err) {
            if (err.code === 'ER_DUP_KEYNAME') {
                console.log('ℹ️ Unique constraint already exists.');
            } else {
                throw err;
            }
        }

        // 2. Create Stored Procedures
        console.log('Creating Stored Procedures...');
        
        await connection.query('DROP PROCEDURE IF EXISTS `sp_upsert_fcm_token`');
        await connection.query(`
            CREATE PROCEDURE \`sp_upsert_fcm_token\`(
                IN \`p_user_id\` INT,
                IN \`p_token\` TEXT,
                IN \`p_device_type\` VARCHAR(50)
            )
            BEGIN
                DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
                
                INSERT INTO \`User_FCM_Tokens\` (\`user_id\`, \`token\`, \`device_type\`)
                VALUES (\`p_user_id\`, \`p_token\`, \`p_device_type\`)
                ON DUPLICATE KEY UPDATE 
                    \`device_type\` = VALUES(\`device_type\`),
                    \`updated_at\` = CURRENT_TIMESTAMP;
            END
        `);
        console.log('✅ sp_upsert_fcm_token created.');

        await connection.query('DROP PROCEDURE IF EXISTS \`sp_delete_fcm_token\`');
        await connection.query(`
            CREATE PROCEDURE \`sp_delete_fcm_token\`(
                IN \`p_user_id\` INT,
                IN \`p_token\` TEXT
            )
            BEGIN
                DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
                
                DELETE FROM \`User_FCM_Tokens\` 
                WHERE \`user_id\` = \`p_user_id\` AND \`token\` = \`p_token\`;
            END
        `);
        console.log('✅ sp_delete_fcm_token created.');

        console.log('\n🎉 All updates applied successfully!');
    } catch (error) {
        console.error('❌ Error applying updates:', error);
    } finally {
        await connection.end();
    }
}

applyUpdates();
