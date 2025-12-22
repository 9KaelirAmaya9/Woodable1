#!/usr/bin/env node

/**
 * Script to update menu item image URLs for items missing photos
 * Run this after adding the actual image files to react-app/public/images/menu/
 */

const db = require('../config/database');

const imageUpdates = [
    // Tostadas
    { name: 'Tostada de Ceviche', image_url: '/images/menu/tostada-ceviche.jpg' },
    { name: 'Tostada de Frijoles', image_url: '/images/menu/tostada-frijoles.jpg' },
    { name: 'Tostada de Carne Asada', image_url: '/images/menu/tostada-carne-asada.jpg' },
    { name: 'Tostada Mixta', image_url: '/images/menu/tostada-mixta.jpg' },
    { name: 'Tostada de Tinga de Pollo', image_url: '/images/menu/tostada-tinga.jpg' },

    // Desserts
    { name: 'Churros', image_url: '/images/menu/churros.jpg' },
    { name: 'Flan', image_url: '/images/menu/flan.jpg' },
    { name: 'Sopapillas', image_url: '/images/menu/sopapillas.jpg' },
    { name: 'Pastel de Tres Leches', image_url: '/images/menu/tres-leches.jpg' },
    { name: 'Gelatina', image_url: '/images/menu/gelatina.jpg' },
    { name: 'Arroz con Leche', image_url: '/images/menu/arroz-con-leche.jpg' }
];

async function updateImages() {
    try {
        console.log('🖼️  Updating menu item images...\n');

        let updated = 0;
        let notFound = 0;

        for (const item of imageUpdates) {
            const result = await db.query(
                'UPDATE menu_items SET image_url = $1 WHERE name = $2 RETURNING id, name',
                [item.image_url, item.name]
            );

            if (result.rows.length > 0) {
                console.log(`✅ Updated: ${item.name} -> ${item.image_url}`);
                updated++;
            } else {
                console.log(`⚠️  Not found: ${item.name}`);
                notFound++;
            }
        }

        console.log(`\n📊 Summary:`);
        console.log(`   Updated: ${updated}`);
        console.log(`   Not found: ${notFound}`);
        console.log(`\n✅ Image URLs updated successfully!`);

        process.exit(0);
    } catch (error) {
        console.error('❌ Error updating images:', error.message);
        process.exit(1);
    }
}

updateImages();
