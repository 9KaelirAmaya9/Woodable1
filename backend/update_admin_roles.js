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

async function setupAdmins() {
    const adminEmails = ['albertijan@gmail.com', 'fortosopedro148@gmail.com'];
    const defaultPassword = 'password123';

    try {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            const salt = await bcrypt.genSalt(10);
            const hash = await bcrypt.hash(defaultPassword, salt);

            // 1. Ensure allow-listed admins exist and have ADMIN role
            for (const email of adminEmails) {
                const res = await client.query('SELECT * FROM users WHERE email = $1', [email]);

                if (res.rows.length === 0) {
                    console.log(`Creating admin user: ${email}`);
                    await client.query(
                        `INSERT INTO users (email, password_hash, role, name, email_verified, auth_provider)
                     VALUES ($1, $2, 'ADMIN', 'Admin User', true, 'email')`,
                        [email, hash]
                    );
                } else {
                    console.log(`Updating existing user to ADMIN: ${email}`);
                    await client.query(
                        'UPDATE users SET role = $1 WHERE email = $2',
                        ['ADMIN', email]
                    );
                }
            }

            // 2. Demote any other admins to CUSTOMER
            // We use ANY($1) to exclude the validated emails
            console.log('Revoking admin role from unauthorized users...');
            const revokeRes = await client.query(
                `UPDATE users 
             SET role = 'CUSTOMER' 
             WHERE role = 'ADMIN' 
             AND email != ALL($1)`,
                [adminEmails]
            );

            console.log(`Demoted ${revokeRes.rowCount} users from ADMIN to CUSTOMER.`);

            await client.query('COMMIT');
            console.log('Admin access update complete.');
            console.log(`New admins: ${adminEmails.join(', ')}`);
            console.log(`Default password: ${defaultPassword}`);

        } catch (err) {
            await client.query('ROLLBACK');
            console.error('Error updating admins:', err);
        } finally {
            client.release();
        }
    } catch (err) {
        console.error('Database connection error:', err);
    } finally {
        pool.end();
    }
}

setupAdmins();
