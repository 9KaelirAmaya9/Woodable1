const db = require('../config/database');

// Helper function to create slugs
function createSlug(name) {
    return name.toLowerCase()
        .replace(/[áàäâ]/g, 'a')
        .replace(/[éèëê]/g, 'e')
        .replace(/[íìïî]/g, 'i')
        .replace(/[óòöô]/g, 'o')
        .replace(/[úùüû]/g, 'u')
        .replace(/ñ/g, 'n')
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
}

// New categories to add
const newCategories = [
    { name: 'Taquitos', description: 'Soft tacos - smaller portion', display_order: 2 },
    { name: 'Desayunos Mexicanos', description: 'Mexican breakfast plates', display_order: 1 },
    { name: 'Side Orders', description: 'Side dishes and extras', display_order: 11 },
    { name: 'Weekend Specials', description: 'Available on weekends only', display_order: 12 },
    { name: 'Kids Menu', description: 'Kid-friendly meals', display_order: 13 },
    { name: 'Licuados', description: 'Smoothies and blended drinks', display_order: 14 },
    { name: 'Jugos Frescos', description: 'Fresh juices', display_order: 15 },
    { name: 'Aguas Frescas', description: 'Fresh flavored waters', display_order: 16 }
];

// Menu items to add (organized by category)
const menuItems = {
    'Taquitos': [
        { name: 'Taquito Al Pastor', description: 'Marinated pork soft taco', price: 2.00, image_url: '/images/menu/taquito-pastor.jpg' },
        { name: 'Taquito Carnitas', description: 'Fried pork soft taco', price: 2.00, image_url: '/images/menu/taquito-carnitas.jpg' },
        { name: 'Taquito Suadero', description: 'Beef brisket soft taco', price: 2.00, image_url: '/images/menu/taquito-suadero.jpg' },
        { name: 'Taquito Enchilada', description: 'Spicy pork soft taco', price: 2.00, image_url: '/images/menu/taquito-enchilada.jpg' },
        { name: 'Taquito Longaniza', description: 'Beef sausage soft taco', price: 2.00, image_url: '/images/menu/taquito-longaniza.jpg' },
        { name: 'Taquito Buche', description: 'Beef stomach soft taco', price: 2.00, image_url: '/images/menu/taquito-buche.jpg' },
        { name: 'Taquito Bistec', description: 'Bistec soft taco', price: 2.00, image_url: '/images/menu/taquito-bistec.jpg' },
        { name: 'Taquito Cueritos', description: 'Pork skin soft taco', price: 2.00, image_url: '/images/menu/taquito-cueritos.jpg' },
        { name: 'Taquito Pollo Asado', description: 'Grilled chicken soft taco', price: 2.00, image_url: '/images/menu/taquito-pollo.jpg' },
        { name: 'Taquito Cecina', description: 'Salted beef soft taco', price: 2.00, image_url: '/images/menu/taquito-cecina.jpg' }
    ],
    'Desayunos Mexicanos': [
        { name: 'Desayuno Ricos Tacos', description: 'Eggs with meat, rice and beans', price: 16.00, image_url: '/images/menu/huevos-mexicana.jpg' },
        { name: 'Huevos con Jamon', description: 'Eggs with ham, rice and beans', price: 12.00, image_url: '/images/menu/huevos-mexicana.jpg' },
        { name: 'Huevos con Chorizo', description: 'Eggs with chorizo, rice and beans', price: 12.00, image_url: '/images/menu/huevos-mexicana.jpg' },
        { name: 'Huevos a la Mexicana', description: 'Mexican style eggs with rice and beans', price: 12.00, image_url: '/images/menu/huevos-mexicana.jpg' },
        { name: 'Huevos con Salchicha', description: 'Eggs with sausage, rice and beans', price: 12.00, image_url: '/images/menu/huevos-mexicana.jpg' },
        { name: 'Huevos Rancheros', description: 'Ranch style eggs with rice and beans', price: 12.00, image_url: '/images/menu/huevos-rancheros.jpg' },
        { name: 'Chilaquiles Regulares', description: 'Tortilla chips in salsa', price: 11.85, image_url: '/images/menu/chilaquiles-cecina.jpg' },
        { name: 'Chilaquiles con Huevos', description: 'Chilaquiles with eggs', price: 14.99, image_url: '/images/menu/chilaquiles-cecina.jpg' },
        { name: 'Chilaquiles con Carne y Huevos', description: 'Chilaquiles with meat and eggs', price: 17.99, image_url: '/images/menu/chilaquiles-cecina.jpg' }
    ],
    'Tacos': [
        { name: 'Taco de Suadero', description: 'Beef brisket taco', price: 3.00, image_url: '/images/menu/suadero-taco.jpg' },
        { name: 'Taco de Enchilada', description: 'Spicy pork taco', price: 3.00, image_url: '/images/menu/enchilada-taco.jpg' },
        { name: 'Taco de Longaniza', description: 'Beef sausage taco', price: 3.00, image_url: '/images/menu/longaniza-taco.jpg' },
        { name: 'Taco de Buche', description: 'Beef stomach taco', price: 3.00, image_url: '/images/menu/taquito-buche.jpg' },
        { name: 'Taco de Bistec', description: 'Bistec taco', price: 3.00, image_url: '/images/menu/carne-asada-taco.jpg' },
        { name: 'Taco de Cueritos', description: 'Pork skin taco', price: 3.00, image_url: '/images/menu/cueritos-taco.jpg' },
        { name: 'Taco de Cecina', description: 'Salted beef taco', price: 3.00, image_url: '/images/menu/cecina-taco.jpg' },
        { name: 'Taco de Cabeza', description: 'Beef head taco', price: 3.00, image_url: '/images/menu/carne-asada-taco.jpg' },
        { name: 'Taco de Oreja', description: 'Ear taco', price: 3.00, image_url: '/images/menu/oreja-taco.jpg' },
        { name: 'Taco de Chicharron', description: 'Pork rind taco', price: 3.00, image_url: '/images/menu/carne-asada-taco.jpg' },
        { name: 'Taco de Picadillo', description: 'Ground beef taco', price: 3.00, image_url: '/images/menu/picadillo-taco.jpg' },
        { name: 'Tacos Placeros', description: 'Special style tacos', price: 6.00, image_url: '/images/menu/tacos-plazeros.jpg' },
        { name: 'Tacos Orientales', description: 'Oriental style tacos', price: 3.00, image_url: '/images/menu/tacos-orientales.jpg' }
    ],
    'Tortas': [
        { name: 'Torta de Birria', description: 'Birria sandwich', price: 9.00, image_url: '/images/menu/torta-birria.jpg' },
        { name: 'Torta Milaneza de Res', description: 'Breaded steak sandwich', price: 9.00, image_url: '/images/menu/torta-milaneza-res.jpg' },
        { name: 'Torta Milaneza de Pollo', description: 'Breaded chicken sandwich', price: 9.00, image_url: '/images/menu/torta-milaneza-pollo.jpg' },
        { name: 'Torta Pierna Adobada', description: 'Seasoned leg pork sandwich', price: 9.00, image_url: '/images/menu/torta-pierna.jpg' },
        { name: 'Torta Pollo Asado', description: 'Grilled chicken sandwich', price: 9.00, image_url: '/images/menu/torta-pollo.jpg' },
        { name: 'Torta Chuleta', description: 'Fried pork chop sandwich', price: 9.00, image_url: '/images/menu/torta-chuleta.jpg' },
        { name: 'Torta Salchicha y Huevo', description: 'Sausage with egg sandwich', price: 9.00, image_url: '/images/menu/torta-salchicha.jpg' },
        { name: 'Torta Chorizo con Huevo', description: 'Mexican sausage with egg sandwich', price: 9.00, image_url: '/images/menu/torta-chorizo.jpg' },
        { name: 'Torta Tinga', description: 'Tinga sandwich', price: 9.00, image_url: '/images/menu/torta-tinga.jpg' },
        { name: 'Torta Cecina', description: 'Salted beef sandwich', price: 9.00, image_url: '/images/menu/torta-cecina.jpg' },
        { name: 'Torta Arabe', description: 'Arab style sandwich', price: 9.00, image_url: '/images/menu/torta-arabe.jpg' },
        { name: 'Torta Carnitas', description: 'Fried pork sandwich', price: 9.00, image_url: '/images/menu/torta-carnitas.jpg' }
    ],
    'Burritos': [
        { name: 'Burrito de Birria', description: 'Birria burrito', price: 11.00, image_url: '/images/menu/torta-birria.jpg' },
        { name: 'Burrito Bistec', description: 'Steak burrito', price: 11.00, image_url: '/images/menu/carne-asada-taco.jpg' },
        { name: 'Burrito Chorizo', description: 'Mexican sausage burrito', price: 11.00, image_url: '/images/menu/torta-chorizo.jpg' },
        { name: 'Burrito Lengua', description: 'Beef tongue burrito', price: 11.00, image_url: '/images/menu/lengua-taco.jpg' },
        { name: 'Burrito Al Pastor', description: 'Marinated pork burrito', price: 11.00, image_url: '/images/menu/taquito-pastor.jpg' },
        { name: 'Burrito Arabe', description: 'Arab style burrito', price: 11.00, image_url: '/images/menu/torta-arabe.jpg' },
        { name: 'Burrito Cecina', description: 'Salted beef burrito', price: 11.00, image_url: '/images/menu/cecina-taco.jpg' },
        { name: 'Burrito Mole', description: 'Mole burrito', price: 11.00, image_url: '/images/menu/mole-poblano.jpg' }
    ],
    'Tostadas': [
        { name: 'Tostada de Birria', description: 'Birria tostada', price: 3.50, image_url: '/images/menu/pastor-tostada.jpg' },
        { name: 'Tostada Al Pastor', description: 'Marinated pork tostada', price: 3.50, image_url: '/images/menu/pastor-tostada.jpg' },
        { name: 'Tostada Lengua', description: 'Beef tongue tostada', price: 5.00, image_url: '/images/menu/lengua-tostada.jpg' },
        { name: 'Tostada Cabeza', description: 'Beef head tostada', price: 3.50, image_url: '/images/menu/carnitas-tostada.jpg' },
        { name: 'Tostada Suadero', description: 'Beef brisket tostada', price: 3.50, image_url: '/images/menu/suadero-tostada.jpg' },
        { name: 'Tostada Carnitas', description: 'Fried pork tostada', price: 3.50, image_url: '/images/menu/carnitas-tostada.jpg' },
        { name: 'Tostada Enchilada', description: 'Spicy pork tostada', price: 3.50, image_url: '/images/menu/enchilada-tostada.jpg' },
        { name: 'Tostada Longaniza', description: 'Beef sausage tostada', price: 3.50, image_url: '/images/menu/longaniza-tostada.jpg' },
        { name: 'Tostada Bistec', description: 'Bistec tostada', price: 3.50, image_url: '/images/menu/carnitas-tostada.jpg' },
        { name: 'Tostada Pollo', description: 'Chicken tostada', price: 3.50, image_url: '/images/menu/pollo-tostada.jpg' },
        { name: 'Tostada Pata de Res', description: 'Beef foot tostada', price: 4.50, image_url: '/images/menu/pata-tostada.jpg' },
        { name: 'Tostada Picadillo', description: 'Ground beef tostada', price: 3.50, image_url: '/images/menu/picadillo-tostada.jpg' },
        { name: 'Tostada de Camarones', description: 'Shrimp tostada', price: 4.50, image_url: '/images/menu/camarones-tostada.jpg' },
        { name: 'Tostada Cecina', description: 'Salted beef tostada', price: 3.50, image_url: '/images/menu/cecina-tostada.jpg' },
        { name: 'Tostada Vegetariana', description: 'Vegetarian tostada', price: 3.50, image_url: '/images/menu/vegetariana-tostada.jpg' }
    ],
    'Platillos Principales': [
        { name: 'Pechuga Asada', description: 'Grilled chicken breast with rice and beans', price: 14.00, image_url: '/images/menu/pechuga-asada.jpg' },
        { name: 'Cecina Platillo', description: 'Salted beef with rice and beans', price: 14.00, image_url: '/images/menu/cecina-platillo.jpg' },
        { name: 'Carne Enchilada Platillo', description: 'Spicy pork with rice and beans', price: 14.00, image_url: '/images/menu/carne-enchilada-platillo.jpg' },
        { name: 'Camarones Empanizados', description: 'Breaded shrimp with rice and beans', price: 14.99, image_url: '/images/menu/camarones-empanizados.jpg' },
        { name: 'Filete de Pescado Asado', description: 'Grilled fish fillet with rice and beans', price: 14.00, image_url: '/images/menu/filete-pescado.jpg' },
        { name: 'Filete de Pescado Empanizado', description: 'Breaded fish fillet with rice and beans', price: 16.00, image_url: '/images/menu/filete-pescado.jpg' },
        { name: 'Arrachera', description: 'Skirt steak with rice and beans', price: 18.00, image_url: '/images/menu/carne-asada-platillo.jpg' },
        { name: 'Alambre', description: 'Mixed meat with peppers and onions', price: 25.00, image_url: '/images/menu/fajitas.jpg' },
        { name: 'Cecina con Nopales', description: 'Salted beef with cactus', price: 16.00, image_url: '/images/menu/cecina-platillo.jpg' },
        { name: 'Bistec de Pollo a la Mexicana', description: 'Mexican style chicken with rice and beans', price: 13.99, image_url: '/images/menu/pollo-mexicana.jpg' },
        { name: 'Coctel de Camarones', description: 'Shrimp cocktail', price: 14.99, image_url: '/images/menu/coctel-camarones.jpg' },
        { name: 'Milaneza de Pollo', description: 'Breaded chicken with rice and beans', price: 16.00, image_url: '/images/menu/torta-milaneza-pollo.jpg' },
        { name: 'Milaneza de Res', description: 'Breaded beef with rice and beans', price: 17.00, image_url: '/images/menu/torta-milaneza-res.jpg' },
        { name: 'Camarones al Mojo de Ajo', description: 'Garlic shrimp with rice and beans', price: 14.99, image_url: '/images/menu/camarones-mojo.jpg' }
    ],
    'Sopas': [
        { name: 'Caldo de Res', description: 'Beef soup', price: 15.00, image_url: '/images/menu/pancita.jpg' },
        { name: 'Birria de Res', description: 'Beef birria soup', price: 13.99, image_url: '/images/menu/torta-birria.jpg' },
        { name: 'Mole de Olla', description: 'Mole pot soup', price: 15.00, image_url: '/images/menu/mole-poblano.jpg' },
        { name: 'Pozole Chica', description: 'Small pozole', price: 7.00, image_url: '/images/menu/pozole.jpg' },
        { name: 'Pozole Grande', description: 'Large pozole', price: 10.00, image_url: '/images/menu/pozole.jpg' },
        { name: 'Pancita Chica', description: 'Small tripe soup', price: 7.00, image_url: '/images/menu/pancita.jpg' },
        { name: 'Pancita Grande', description: 'Large tripe soup', price: 10.00, image_url: '/images/menu/pancita.jpg' }
    ],
    'Antojitos Mexicanos': [
        { name: 'Flautas', description: 'Fried rolled tacos', price: 10.00, image_url: '/images/menu/tacos-dorados.jpg' },
        { name: 'Nachos', description: 'Tortilla chips with toppings', price: 13.00, image_url: '/images/menu/nachos.jpg' },
        { name: 'Super Quesadilla', description: 'Large quesadilla', price: 14.00, image_url: '/images/menu/quesadilla.jpg' },
        { name: 'Quesadilla Todo', description: 'Quesadilla with everything', price: 8.00, image_url: '/images/menu/quesadilla-toda.jpg' }
    ],
    'Side Orders': [
        { name: 'Nopales', description: 'Cactus side', price: 4.00, image_url: '/images/menu/nopales.jpg' },
        { name: 'Pico de Gallo', description: 'Fresh salsa', price: 4.00, image_url: '/images/menu/pico-de-gallo.jpg' },
        { name: 'Guacamole con Chips', description: 'Guacamole with chips', price: 4.00, image_url: '/images/menu/guacamole-chips.jpg' },
        { name: 'Chips & Salsa', description: 'Chips and salsa', price: 4.00, image_url: '/images/menu/guacamole-chips.jpg' }
    ],
    'Weekend Specials': [
        { name: 'Barbacoa', description: 'Weekend special - slow cooked meat', price: 15.00, image_url: '/images/menu/torta-birria.jpg' },
        { name: 'Consome de Chivo', description: 'Goat consomme', price: 15.00, image_url: '/images/menu/pancita.jpg' },
        { name: 'Sopa de Mariscos', description: 'Seafood soup', price: 18.00, image_url: '/images/menu/coctel-camarones.jpg' }
    ],
    'Kids Menu': [
        { name: 'Tenders & Fries', description: 'Chicken tenders with fries', price: 12.00, image_url: '/images/menu/chicken-tenders-fries.jpg' },
        { name: 'Chicken Quesadilla Kids', description: 'Kid-sized chicken quesadilla', price: 12.00, image_url: '/images/menu/quesadilla-fries.jpg' },
        { name: '5 Wings & Fries', description: 'Five chicken wings with fries', price: 12.00, image_url: '/images/menu/fried-chicken-fries.jpg' },
        { name: 'Nuggets & Fries', description: 'Chicken nuggets with fries', price: 12.00, image_url: '/images/menu/nuggets-fries.jpg' },
        { name: 'Salchi-Papas', description: 'Hot dog with fries', price: 12.00, image_url: '/images/menu/salchipapas.jpg' }
    ],
    'Licuados': [
        { name: 'Licuado Regular', description: 'Regular smoothie', price: 8.00, image_url: '/images/menu/licuado-fresa.jpg' },
        { name: 'Licuado Preparado', description: 'Prepared smoothie', price: 10.00, image_url: '/images/menu/licuado-fresa.jpg' },
        { name: 'Licuado Pina Colada', description: 'Pina colada smoothie', price: 10.00, image_url: '/images/menu/pina-colada.jpg' }
    ],
    'Jugos Frescos': [
        { name: 'Jugo de Naranja', description: 'Fresh orange juice', price: 5.00, image_url: '/images/menu/jugo-naranja.jpg' },
        { name: 'Limonada', description: 'Fresh lemonade', price: 4.00, image_url: '/images/menu/limonada.jpg' }
    ],
    'Aguas Frescas': [
        { name: 'Agua Fresca Chica', description: 'Small flavored water', price: 2.00, image_url: '/images/menu/pina-colada.jpg' },
        { name: 'Agua Fresca Grande', description: 'Large flavored water', price: 3.00, image_url: '/images/menu/pina-colada.jpg' }
    ]
};

async function runMigration() {
    try {
        console.log('🚀 Starting menu migration...\n');

        // Step 1: Add new categories
        console.log('Step 1: Adding new categories...');
        for (const cat of newCategories) {
            const slug = createSlug(cat.name);
            const existing = await db.query(
                'SELECT id FROM categories WHERE name = $1',
                [cat.name]
            );

            if (existing.rows.length === 0) {
                await db.query(
                    'INSERT INTO categories (name, slug, description, display_order, is_active) VALUES ($1, $2, $3, $4, true)',
                    [cat.name, slug, cat.description, cat.display_order]
                );
                console.log(`  ✓ Added category: ${cat.name}`);
            } else {
                console.log(`  - Category already exists: ${cat.name}`);
            }
        }

        // Step 2: Add menu items
        console.log('\nStep 2: Adding menu items...');
        let totalAdded = 0;

        for (const [categoryName, items] of Object.entries(menuItems)) {
            const categoryResult = await db.query(
                'SELECT id FROM categories WHERE name = $1',
                [categoryName]
            );

            if (categoryResult.rows.length === 0) {
                console.log(`  ⚠ Category not found: ${categoryName}, skipping items`);
                continue;
            }

            const categoryId = categoryResult.rows[0].id;

            for (const item of items) {
                const existing = await db.query(
                    'SELECT id FROM menu_items WHERE category_id = $1 AND name = $2',
                    [categoryId, item.name]
                );

                if (existing.rows.length === 0) {
                    await db.query(
                        'INSERT INTO menu_items (category_id, name, description, price, image_url, is_available) VALUES ($1, $2, $3, $4, $5, true)',
                        [categoryId, item.name, item.description, item.price, item.image_url]
                    );
                    totalAdded++;
                }
            }
            console.log(`  ✓ Processed ${categoryName}: ${items.length} items`);
        }

        // Step 3: Update prices
        console.log('\nStep 3: Updating existing item prices...');
        await db.query('UPDATE menu_items SET price = 35.00 WHERE name = $1', ['Molcajete']);
        await db.query('UPDATE menu_items SET price = 10.00 WHERE name = $1', ['Huarache']);
        console.log('  ✓ Updated prices for Molcajete and Huarache');

        // Step 4: Remove old items without size options
        console.log('\nStep 4: Removing old items without size options...');
        await db.query('DELETE FROM menu_items WHERE name IN ($1, $2) AND price = 10.00', ['Pozole', 'Pancita']);
        console.log('  ✓ Removed old Pozole and Pancita entries');

        // Final stats
        console.log('\n📊 Migration Summary:');
        const totalResult = await db.query('SELECT COUNT(*) as total FROM menu_items');
        console.log(`  Total menu items: ${totalResult.rows[0].total}`);
        console.log(`  New items added: ${totalAdded}`);

        const categoryStats = await db.query(
            'SELECT c.name, COUNT(m.id) as count FROM categories c LEFT JOIN menu_items m ON c.id = m.category_id GROUP BY c.name ORDER BY c.display_order'
        );
        console.log('\n  Items per category:');
        categoryStats.rows.forEach(row => {
            console.log(`    ${row.name}: ${row.count}`);
        });

        console.log('\n✅ Migration completed successfully!');
        process.exit(0);

    } catch (error) {
        console.error('\n❌ Migration failed:', error.message);
        console.error(error);
        process.exit(1);
    }
}

runMigration();
