#!/usr/bin/env node

/**
 * Admin User Setup Script
 * Creates initial admin users for production
 */

require('dotenv').config();
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

const ADMIN_USERS = [
    {
        email: 'albertijan@gmail.com',
        name: 'Alberto Jan',
        role: 'ADMIN'
    },
    {
        email: 'fortosopedro148@gmail.com',
        name: 'Pedro Fortoso',
        role: 'ADMIN'
    }
];

async function setupAdmins() {
    console.log('👤 Setting up admin users...\n');

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // Generate a secure temporary password
        const tempPassword = 'TempAdmin' + Math.random().toString(36).slice(-8) + '!';
        const salt = await bcrypt.genSalt(10);
        const passwordHash = await bcrypt.hash(tempPassword, salt);

        console.log('🔐 Temporary password for all admins:', tempPassword);
        console.log('   ⚠️  IMPORTANT: Change this immediately after first login!\n');

        for (const admin of ADMIN_USERS) {
            // Check if user exists
            const existing = await client.query(
                'SELECT id, role FROM users WHERE email = $1',
                [admin.email]
            );

            if (existing.rows.length > 0) {
                // Update existing user to admin
                await client.query(
                    'UPDATE users SET role = $1 WHERE email = $2',
                    [admin.role, admin.email]
                );
                console.log(`✅ Updated ${admin.email} to ${admin.role} role`);
            } else {
                // Create new admin user
                await client.query(
                    `INSERT INTO users (email, password_hash, name, role, email_verified, auth_provider)
           VALUES ($1, $2, $3, $4, true, 'email')`,
                    [admin.email, passwordHash, admin.name, admin.role]
                );
                console.log(`✅ Created ${admin.email} with ${admin.role} role`);
            }
        }

        await client.query('COMMIT');
        console.log('\n✅ Admin setup complete!');
        console.log('\n📧 Admin users can login with:');
        console.log(`   Email: ${ADMIN_USERS.map(a => a.email).join(' or ')}`);
        console.log(`   Password: ${tempPassword}`);
        console.log('\n⚠️  CRITICAL: Have admins change their passwords immediately!\n');

    } catch (error) {
        await client.query('ROLLBACK');
        console.error('❌ Admin setup failed:', error.message);
        throw error;
    } finally {
        client.release();
        await pool.end();
    }
}

// Run if called directly
if (require.main === module) {
    setupAdmins()
        .then(() => process.exit(0))
        .catch(error => {
            console.error(error);
            process.exit(1);
        });
}

module.exports = { setupAdmins };
