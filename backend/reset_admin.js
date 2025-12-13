require('dotenv').config();
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'mydatabase',
    user: process.env.DB_USER || 'myuser',
    password: process.env.DB_PASSWORD || 'mypassword',
});

async function resetPassword() {
    const password = 'password123';
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(password, salt);

    console.log('Resetting password for admin@tacos.local...');

    try {
        const res = await pool.query(
            'UPDATE users SET password_hash = $1 WHERE email = $2 RETURNING email',
            [hash, 'admin@tacos.local']
        );
        console.log('Updated users:', res.rows);
    } catch (err) {
        console.error(err);
    } finally {
        pool.end();
    }
}

resetPassword();
