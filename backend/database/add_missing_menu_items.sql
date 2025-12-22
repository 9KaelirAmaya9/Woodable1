-- Migration: Add Missing Menu Items for Tostadas and Postres
-- This script adds menu items to the currently empty Tostadas and Postres categories

-- First, ensure we're connected to the right database
\c mydatabase

-- Insert Tostadas (Mexican tostadas - crispy flat tortillas with toppings)
INSERT INTO menu_items (category_id, name, description, price, is_available, spiciness_level) VALUES
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada de Tinga de Pollo', 'Crispy tostada topped with shredded chicken in chipotle sauce, lettuce, crema, and queso fresco', 4.50, true, 2),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada de Ceviche', 'Fresh fish ceviche with lime, tomato, onion, cilantro, and avocado on a crispy tostada', 5.50, true, 1),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada de Frijoles', 'Refried beans, lettuce, tomato, crema, queso fresco, and avocado', 3.50, true, 0),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada de Carne Asada', 'Grilled steak with beans, lettuce, pico de gallo, crema, and guacamole', 5.00, true, 1),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Mixta', 'Combination of beans, chicken, lettuce, tomato, crema, and cheese', 4.75, true, 1)
ON CONFLICT DO NOTHING;

-- Insert Postres (Desserts in Spanish)
INSERT INTO menu_items (category_id, name, description, price, is_available, spiciness_level) VALUES
((SELECT id FROM categories WHERE name = 'Postres'), 'Churros', 'Fried dough pastry dusted with cinnamon sugar, served with chocolate dipping sauce', 5.00, true, 0),
((SELECT id FROM categories WHERE name = 'Postres'), 'Flan', 'Creamy caramel custard with a silky smooth texture', 4.50, true, 0),
((SELECT id FROM categories WHERE name = 'Postres'), 'Pastel de Tres Leches', 'Sponge cake soaked in three types of milk, topped with whipped cream', 5.50, true, 0),
((SELECT id FROM categories WHERE name = 'Postres'), 'Sopapillas', 'Fried pastry pillows drizzled with honey and dusted with cinnamon', 4.00, true, 0),
((SELECT id FROM categories WHERE name = 'Postres'), 'Arroz con Leche', 'Traditional Mexican rice pudding with cinnamon and raisins', 4.00, true, 0),
((SELECT id FROM categories WHERE name = 'Postres'), 'Gelatina', 'Colorful layered gelatin dessert, a Mexican favorite', 3.50, true, 0)
ON CONFLICT DO NOTHING;

-- Verify the data was inserted
SELECT 'Tostadas items added:' as info, COUNT(*) as count 
FROM menu_items 
WHERE category_id = (SELECT id FROM categories WHERE name = 'Tostadas');

SELECT 'Postres items added:' as info, COUNT(*) as count 
FROM menu_items 
WHERE category_id = (SELECT id FROM categories WHERE name = 'Postres');

-- Show all items in these categories
SELECT c.name as category, mi.name as item, mi.price, mi.description
FROM categories c 
LEFT JOIN menu_items mi ON c.id = mi.category_id 
WHERE c.name IN ('Tostadas', 'Postres')
ORDER BY c.name, mi.name;
