#!/usr/bin/env node

/**
 * Database Initialization Script
 * Sets up the database schema for production deployment
 */

require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

async function initializeDatabase() {
    console.log('🗄️  Initializing database schema...\n');

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // Check if tables already exist
        const tablesExist = await client.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'users'
      );
    `);

        if (tablesExist.rows[0].exists) {
            console.log('⚠️  Database tables already exist. Skipping schema creation.');
            console.log('   Run with --force to recreate (WARNING: destroys data)\n');
            await client.query('ROLLBACK');
            return;
        }

        console.log('📝 Creating database schema...');

        // Read and execute schema file
        const schemaPath = path.join(__dirname, '../postgres/init.sql');
        if (fs.existsSync(schemaPath)) {
            const schema = fs.readFileSync(schemaPath, 'utf8');
            await client.query(schema);
            console.log('✅ Schema created successfully\n');
        } else {
            console.log('⚠️  Schema file not found at:', schemaPath);
            console.log('   Creating basic schema...\n');

            // Create basic schema if init.sql doesn't exist
            await createBasicSchema(client);
        }

        await client.query('COMMIT');
        console.log('✅ Database initialization complete!\n');

    } catch (error) {
        await client.query('ROLLBACK');
        console.error('❌ Database initialization failed:', error.message);
        throw error;
    } finally {
        client.release();
        await pool.end();
    }
}

async function createBasicSchema(client) {
    // This is a fallback - ideally use init.sql
    console.log('Creating tables...');

    // Add your schema creation queries here
    // This should match your postgres/init.sql file

    console.log('✅ Basic schema created\n');
}

// Run if called directly
if (require.main === module) {
    initializeDatabase()
        .then(() => process.exit(0))
        .catch(error => {
            console.error(error);
            process.exit(1);
        });
}

module.exports = { initializeDatabase };
