#!/usr/bin/env node

/**
 * Menu Seeding Script
 * Populates the database with initial menu items
 */

require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

const CATEGORIES = [
    { name: 'TACOS', sort_order: 1 },
    { name: 'SIDES', sort_order: 2 },
    { name: 'DRINKS', sort_order: 3 },
    { name: 'SPECIALS', sort_order: 4 }
];

const MENU_ITEMS = [
    // Tacos
    { category: 'TACOS', name: 'Carne Asada Taco', price: 4.50, description: 'Grilled steak with onions and cilantro' },
    { category: 'TACOS', name: 'Al Pastor Taco', price: 4.25, description: 'Marinated pork with pineapple' },
    { category: 'TACOS', name: 'Chicken Taco', price: 3.75, description: 'Seasoned chicken with fresh toppings' },
    { category: 'TACOS', name: 'Fish Taco', price: 5.00, description: 'Crispy fish with cabbage slaw' },
    { category: 'TACOS', name: 'Carnitas Taco', price: 4.25, description: 'Slow-cooked pork' },
    { category: 'TACOS', name: 'Veggie Taco', price: 3.50, description: 'Grilled vegetables with black beans' },

    // Sides
    { category: 'SIDES', name: 'Rice & Beans', price: 3.00, description: 'Mexican rice and refried beans' },
    { category: 'SIDES', name: 'Chips & Salsa', price: 2.50, description: 'Fresh tortilla chips with house salsa' },
    { category: 'SIDES', name: 'Guacamole', price: 4.00, description: 'Fresh avocado dip' },
    { category: 'SIDES', name: 'Queso Dip', price: 3.50, description: 'Melted cheese dip' },

    // Drinks
    { category: 'DRINKS', name: 'Horchata', price: 3.00, description: 'Sweet rice milk drink' },
    { category: 'DRINKS', name: 'Jamaica', price: 3.00, description: 'Hibiscus tea' },
    { category: 'DRINKS', name: 'Tamarindo', price: 3.00, description: 'Tamarind drink' },
    { category: 'DRINKS', name: 'Soda', price: 2.00, description: 'Coke, Sprite, or Fanta' },
    { category: 'DRINKS', name: 'Water', price: 1.50, description: 'Bottled water' },

    // Specials
    { category: 'SPECIALS', name: 'Taco Combo (3)', price: 11.00, description: 'Three tacos of your choice' },
    { category: 'SPECIALS', name: 'Family Pack', price: 35.00, description: '10 tacos, rice, beans, chips & salsa' }
];

async function seedMenu() {
    console.log('🌮 Seeding menu data...\n');

    const client = await pool.connect();

    try {
        await client.query('BEGIN');

        // Check if menu already exists
        const existing = await client.query('SELECT COUNT(*) FROM menu_items');
        if (parseInt(existing.rows[0].count) > 0) {
            console.log('⚠️  Menu items already exist. Skipping seed.');
            console.log('   Run with --force to recreate (WARNING: destroys existing menu)\n');
            await client.query('ROLLBACK');
            return;
        }

        console.log('📝 Creating categories...');
        const categoryMap = {};

        for (const cat of CATEGORIES) {
            const result = await client.query(
                'INSERT INTO menu_categories (name, sort_order) VALUES ($1, $2) RETURNING id',
                [cat.name, cat.sort_order]
            );
            categoryMap[cat.name] = result.rows[0].id;
            console.log(`   ✅ ${cat.name}`);
        }

        console.log('\n📝 Creating menu items...');
        let itemCount = 0;

        for (const item of MENU_ITEMS) {
            await client.query(
                `INSERT INTO menu_items (category_id, name, description, price, is_available)
         VALUES ($1, $2, $3, $4, true)`,
                [categoryMap[item.category], item.name, item.description, item.price]
            );
            itemCount++;
            console.log(`   ✅ ${item.name} - $${item.price}`);
        }

        await client.query('COMMIT');
        console.log(`\n✅ Menu seeded successfully!`);
        console.log(`   ${CATEGORIES.length} categories`);
        console.log(`   ${itemCount} menu items\n`);

    } catch (error) {
        await client.query('ROLLBACK');
        console.error('❌ Menu seeding failed:', error.message);
        throw error;
    } finally {
        client.release();
        await pool.end();
    }
}

// Run if called directly
if (require.main === module) {
    seedMenu()
        .then(() => process.exit(0))
        .catch(error => {
            console.error(error);
            process.exit(1);
        });
}

module.exports = { seedMenu };
