-- Complete Menu Migration Script
-- This script adds all missing menu items from the physical menu to match the database
-- Run this script to expand the menu from 60 items to 150+ items

-- ============================================================================
-- STEP 1: Add Missing Categories
-- ============================================================================

INSERT INTO categories (name, description, display_order) VALUES
('Taquitos', 'Soft tacos - smaller portion', 2),
('Desayunos Mexicanos', 'Mexican breakfast plates', 1),
('Side Orders', 'Side dishes and extras', 11),
('Weekend Specials', 'Available on weekends only', 12),
('Kids Menu', 'Kid-friendly meals', 13),
('Licuados', 'Smoothies and blended drinks', 14),
('Jugos Frescos', 'Fresh juices', 15),
('Aguas Frescas', 'Fresh flavored waters', 16)
;

-- ============================================================================
-- STEP 2: Add Missing TAQUITOS (Soft Tacos - $2.00 each)
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Al Pastor', 'Marinated pork soft taco', 2.00, '/images/menu/taquito-pastor.jpg', true),
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Carnitas', 'Fried pork soft taco', 2.00, '/images/menu/taquito-carnitas.jpg', true),
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Suadero', 'Beef brisket soft taco', 2.00, '/images/menu/taquito-suadero.jpg', true),
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Enchilada', 'Spicy pork soft taco', 2.00, '/images/menu/taquito-enchilada.jpg', true),
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Longaniza', 'Beef sausage soft taco', 2.00, '/images/menu/taquito-longaniza.jpg', true),
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Buche', 'Beef stomach soft taco', 2.00, '/images/menu/taquito-buche.jpg', true),
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Bistec', 'Bistec soft taco', 2.00, '/images/menu/taquito-bistec.jpg', true),
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Cueritos', 'Pork skin soft taco', 2.00, '/images/menu/taquito-cueritos.jpg', true),
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Pollo Asado', 'Grilled chicken soft taco', 2.00, '/images/menu/taquito-pollo.jpg', true),
((SELECT id FROM categories WHERE name = 'Taquitos'), 'Taquito Cecina', 'Salted beef soft taco', 2.00, '/images/menu/taquito-cecina.jpg', true)


-- ============================================================================
-- STEP 3: Add Missing DESAYUNOS MEXICANOS (Breakfasts)
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Desayunos Mexicanos'), 'Desayuno Ricos Tacos', 'Eggs with meat, rice and beans', 16.00, '/images/menu/huevos-mexicana.jpg', true),
((SELECT id FROM categories WHERE name = 'Desayunos Mexicanos'), 'Huevos con Jamon', 'Eggs with ham, rice and beans', 12.00, '/images/menu/huevos-mexicana.jpg', true),
((SELECT id FROM categories WHERE name = 'Desayunos Mexicanos'), 'Huevos con Chorizo', 'Eggs with chorizo, rice and beans', 12.00, '/images/menu/huevos-mexicana.jpg', true),
((SELECT id FROM categories WHERE name = 'Desayunos Mexicanos'), 'Huevos a la Mexicana', 'Mexican style eggs with rice and beans', 12.00, '/images/menu/huevos-mexicana.jpg', true),
((SELECT id FROM categories WHERE name = 'Desayunos Mexicanos'), 'Huevos con Salchicha', 'Eggs with sausage, rice and beans', 12.00, '/images/menu/huevos-mexicana.jpg', true),
((SELECT id FROM categories WHERE name = 'Desayunos Mexicanos'), 'Huevos Rancheros', 'Ranch style eggs with rice and beans', 12.00, '/images/menu/huevos-rancheros.jpg', true),
((SELECT id FROM categories WHERE name = 'Desayunos Mexicanos'), 'Chilaquiles Regulares', 'Tortilla chips in salsa', 11.85, '/images/menu/chilaquiles-cecina.jpg', true),
((SELECT id FROM categories WHERE name = 'Desayunos Mexicanos'), 'Chilaquiles con Huevos', 'Chilaquiles with eggs', 14.99, '/images/menu/chilaquiles-cecina.jpg', true),
((SELECT id FROM categories WHERE name = 'Desayunos Mexicanos'), 'Chilaquiles con Carne y Huevos', 'Chilaquiles with meat and eggs', 17.99, '/images/menu/chilaquiles-cecina.jpg', true)


-- ============================================================================
-- STEP 4: Add Missing TACOS (Regular size)
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Suadero', 'Beef brisket taco', 3.00, '/images/menu/suadero-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Enchilada', 'Spicy pork taco', 3.00, '/images/menu/enchilada-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Longaniza', 'Beef sausage taco', 3.00, '/images/menu/longaniza-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Buche', 'Beef stomach taco', 3.00, '/images/menu/taquito-buche.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Bistec', 'Bistec taco', 3.00, '/images/menu/carne-asada-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Cueritos', 'Pork skin taco', 3.00, '/images/menu/cueritos-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Cecina', 'Salted beef taco', 3.00, '/images/menu/cecina-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Cabeza', 'Beef head taco', 3.00, '/images/menu/carne-asada-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Oreja', 'Ear taco', 3.00, '/images/menu/oreja-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Chicharron', 'Pork rind taco', 3.00, '/images/menu/carne-asada-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Taco de Picadillo', 'Ground beef taco', 3.00, '/images/menu/picadillo-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Tacos Placeros', 'Special style tacos', 6.00, '/images/menu/tacos-plazeros.jpg', true),
((SELECT id FROM categories WHERE name = 'Tacos'), 'Tacos Orientales', 'Oriental style tacos', 3.00, '/images/menu/tacos-orientales.jpg', true)


-- ============================================================================
-- STEP 5: Add Missing TORTAS
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta de Birria', 'Birria sandwich', 9.00, '/images/menu/torta-birria.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Milaneza de Res', 'Breaded steak sandwich', 9.00, '/images/menu/torta-milaneza-res.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Milaneza de Pollo', 'Breaded chicken sandwich', 9.00, '/images/menu/torta-milaneza-pollo.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Pierna Adobada', 'Seasoned leg pork sandwich', 9.00, '/images/menu/torta-pierna.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Pollo Asado', 'Grilled chicken sandwich', 9.00, '/images/menu/torta-pollo.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Chuleta', 'Fried pork chop sandwich', 9.00, '/images/menu/torta-chuleta.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Salchicha y Huevo', 'Sausage with egg sandwich', 9.00, '/images/menu/torta-salchicha.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Chorizo con Huevo', 'Mexican sausage with egg sandwich', 9.00, '/images/menu/torta-chorizo.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Tinga', 'Tinga sandwich', 9.00, '/images/menu/torta-tinga.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Cecina', 'Salted beef sandwich', 9.00, '/images/menu/torta-cecina.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Arabe', 'Arab style sandwich', 9.00, '/images/menu/torta-arabe.jpg', true),
((SELECT id FROM categories WHERE name = 'Tortas'), 'Torta Carnitas', 'Fried pork sandwich', 9.00, '/images/menu/torta-carnitas.jpg', true)


-- ============================================================================
-- STEP 6: Add Missing BURRITOS
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Burritos'), 'Burrito de Birria', 'Birria burrito', 11.00, '/images/menu/torta-birria.jpg', true),
((SELECT id FROM categories WHERE name = 'Burritos'), 'Burrito Bistec', 'Steak burrito', 11.00, '/images/menu/carne-asada-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Burritos'), 'Burrito Chorizo', 'Mexican sausage burrito', 11.00, '/images/menu/torta-chorizo.jpg', true),
((SELECT id FROM categories WHERE name = 'Burritos'), 'Burrito Lengua', 'Beef tongue burrito', 11.00, '/images/menu/lengua-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Burritos'), 'Burrito Al Pastor', 'Marinated pork burrito', 11.00, '/images/menu/taquito-pastor.jpg', true),
((SELECT id FROM categories WHERE name = 'Burritos'), 'Burrito Arabe', 'Arab style burrito', 11.00, '/images/menu/torta-arabe.jpg', true),
((SELECT id FROM categories WHERE name = 'Burritos'), 'Burrito Cecina', 'Salted beef burrito', 11.00, '/images/menu/cecina-taco.jpg', true),
((SELECT id FROM categories WHERE name = 'Burritos'), 'Burrito Mole', 'Mole burrito', 11.00, '/images/menu/mole-poblano.jpg', true)


-- ============================================================================
-- STEP 7: Add Missing TOSTADAS
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada de Birria', 'Birria tostada', 3.50, '/images/menu/pastor-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Al Pastor', 'Marinated pork tostada', 3.50, '/images/menu/pastor-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Lengua', 'Beef tongue tostada', 5.00, '/images/menu/lengua-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Cabeza', 'Beef head tostada', 3.50, '/images/menu/carnitas-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Suadero', 'Beef brisket tostada', 3.50, '/images/menu/suadero-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Carnitas', 'Fried pork tostada', 3.50, '/images/menu/carnitas-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Enchilada', 'Spicy pork tostada', 3.50, '/images/menu/enchilada-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Longaniza', 'Beef sausage tostada', 3.50, '/images/menu/longaniza-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Bistec', 'Bistec tostada', 3.50, '/images/menu/carnitas-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Pollo', 'Chicken tostada', 3.50, '/images/menu/pollo-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Pata de Res', 'Beef foot tostada', 4.50, '/images/menu/pata-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Picadillo', 'Ground beef tostada', 3.50, '/images/menu/picadillo-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada de Camarones', 'Shrimp tostada', 4.50, '/images/menu/camarones-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Cecina', 'Salted beef tostada', 3.50, '/images/menu/cecina-tostada.jpg', true),
((SELECT id FROM categories WHERE name = 'Tostadas'), 'Tostada Vegetariana', 'Vegetarian tostada', 3.50, '/images/menu/vegetariana-tostada.jpg', true)


-- ============================================================================
-- STEP 8: Add Missing PLATILLOS PRINCIPALES
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Pechuga Asada', 'Grilled chicken breast with rice and beans', 14.00, '/images/menu/pechuga-asada.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Cecina Platillo', 'Salted beef with rice and beans', 14.00, '/images/menu/cecina-platillo.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Carne Enchilada Platillo', 'Spicy pork with rice and beans', 14.00, '/images/menu/carne-enchilada-platillo.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Camarones Empanizados', 'Breaded shrimp with rice and beans', 14.99, '/images/menu/camarones-empanizados.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Filete de Pescado Asado', 'Grilled fish fillet with rice and beans', 14.00, '/images/menu/filete-pescado.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Filete de Pescado Empanizado', 'Breaded fish fillet with rice and beans', 16.00, '/images/menu/filete-pescado.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Arrachera', 'Skirt steak with rice and beans', 18.00, '/images/menu/carne-asada-platillo.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Alambre', 'Mixed meat with peppers and onions', 25.00, '/images/menu/fajitas.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Cecina con Nopales', 'Salted beef with cactus', 16.00, '/images/menu/cecina-platillo.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Bistec de Pollo a la Mexicana', 'Mexican style chicken with rice and beans', 13.99, '/images/menu/pollo-mexicana.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Coctel de Camarones', 'Shrimp cocktail', 14.99, '/images/menu/coctel-camarones.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Milaneza de Pollo', 'Breaded chicken with rice and beans', 16.00, '/images/menu/torta-milaneza-pollo.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Milaneza de Res', 'Breaded beef with rice and beans', 17.00, '/images/menu/torta-milaneza-res.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Camarones al Mojo de Ajo', 'Garlic shrimp with rice and beans', 14.99, '/images/menu/camarones-mojo.jpg', true),
((SELECT id FROM categories WHERE name = 'Platillos Principales'), 'Camarones Empanizados Platillo', 'Breaded shrimp plate', 14.99, '/images/menu/camarones-empanizados.jpg', true)


-- ============================================================================
-- STEP 9: Add Missing SOPAS
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Sopas'), 'Caldo de Res', 'Beef soup', 15.00, '/images/menu/pancita.jpg', true),
((SELECT id FROM categories WHERE name = 'Sopas'), 'Birria de Res', 'Beef birria soup', 13.99, '/images/menu/torta-birria.jpg', true),
((SELECT id FROM categories WHERE name = 'Sopas'), 'Mole de Olla', 'Mole pot soup', 15.00, '/images/menu/mole-poblano.jpg', true),
((SELECT id FROM categories WHERE name = 'Sopas'), 'Pozole Chica', 'Small pozole', 7.00, '/images/menu/pozole.jpg', true),
((SELECT id FROM categories WHERE name = 'Sopas'), 'Pozole Grande', 'Large pozole', 10.00, '/images/menu/pozole.jpg', true),
((SELECT id FROM categories WHERE name = 'Sopas'), 'Pancita Chica', 'Small tripe soup', 7.00, '/images/menu/pancita.jpg', true),
((SELECT id FROM categories WHERE name = 'Sopas'), 'Pancita Grande', 'Large tripe soup', 10.00, '/images/menu/pancita.jpg', true)


-- Remove old pozole and pancita without size options
DELETE FROM menu_items WHERE name IN ('Pozole', 'Pancita') AND price = 10.00;

-- ============================================================================
-- STEP 10: Add Missing ANTOJITOS MEXICANOS
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Antojitos Mexicanos'), 'Flautas', 'Fried rolled tacos', 10.00, '/images/menu/tacos-dorados.jpg', true),
((SELECT id FROM categories WHERE name = 'Antojitos Mexicanos'), 'Nachos', 'Tortilla chips with toppings', 13.00, '/images/menu/nachos.jpg', true),
((SELECT id FROM categories WHERE name = 'Antojitos Mexicanos'), 'Tacos Placeros Antojito', 'Special style tacos', 11.00, '/images/menu/tacos-plazeros.jpg', true),
((SELECT id FROM categories WHERE name = 'Antojitos Mexicanos'), 'Super Quesadilla Molcajete', 'Large quesadilla', 14.00, '/images/menu/quesadilla.jpg', true),
((SELECT id FROM categories WHERE name = 'Antojitos Mexicanos'), 'Quesadilla Todo', 'Quesadilla with everything', 8.00, '/images/menu/quesadilla-toda.jpg', true),
((SELECT id FROM categories WHERE name = 'Antojitos Mexicanos'), 'Hamburger con Papas', 'Hamburger with fries and soda', 18.00, '/images/menu/quesadilla-fries.jpg', true),
((SELECT id FROM categories WHERE name = 'Antojitos Mexicanos'), 'French Fries', 'French fries', 4.00, '/images/menu/french-fries.jpg', true),
((SELECT id FROM categories WHERE name = 'Antojitos Mexicanos'), 'Chicken Nuggets', 'Chicken nuggets', 6.00, '/images/menu/chicken-nuggets.jpg', true)


-- ============================================================================
-- STEP 11: Add SIDE ORDERS
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Side Orders'), 'Nopales', 'Cactus side', 4.00, '/images/menu/nopales.jpg', true),
((SELECT id FROM categories WHERE name = 'Side Orders'), 'Pico de Gallo', 'Fresh salsa', 4.00, '/images/menu/pico-de-gallo.jpg', true),
((SELECT id FROM categories WHERE name = 'Side Orders'), 'Guacamole con Chips', 'Guacamole with chips', 4.00, '/images/menu/guacamole-chips.jpg', true),
((SELECT id FROM categories WHERE name = 'Side Orders'), 'Chips & Salsa', 'Chips and salsa', 4.00, '/images/menu/guacamole-chips.jpg', true),
((SELECT id FROM categories WHERE name = 'Side Orders'), 'Quesillo', 'Oaxaca cheese', 1.00, '/images/menu/quesillo.jpg', true),
((SELECT id FROM categories WHERE name = 'Side Orders'), 'Crema', 'Sour cream', 1.00, '/images/menu/crema.jpg', true)


-- ============================================================================
-- STEP 12: Add WEEKEND SPECIALS
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Weekend Specials'), 'Barbacoa', 'Weekend special - slow cooked meat', 15.00, '/images/menu/torta-birria.jpg', true),
((SELECT id FROM categories WHERE name = 'Weekend Specials'), 'Consome de Chivo', 'Goat consomme', 15.00, '/images/menu/pancita.jpg', true),
((SELECT id FROM categories WHERE name = 'Weekend Specials'), 'Sopa de Mariscos', 'Seafood soup', 18.00, '/images/menu/coctel-camarones.jpg', true)


-- ============================================================================
-- STEP 13: Add KIDS MENU
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Kids Menu'), 'Tenders & Fries', 'Chicken tenders with fries', 12.00, '/images/menu/chicken-tenders-fries.jpg', true),
((SELECT id FROM categories WHERE name = 'Kids Menu'), 'Chicken Quesadilla Kids', 'Kid-sized chicken quesadilla', 12.00, '/images/menu/quesadilla-fries.jpg', true),
((SELECT id FROM categories WHERE name = 'Kids Menu'), '5 Wings & Fries', 'Five chicken wings with fries', 12.00, '/images/menu/fried-chicken-fries.jpg', true),
((SELECT id FROM categories WHERE name = 'Kids Menu'), 'Nuggets & Fries Kids', 'Chicken nuggets with fries', 12.00, '/images/menu/nuggets-fries.jpg', true),
((SELECT id FROM categories WHERE name = 'Kids Menu'), 'Salchi-Papas', 'Hot dog with fries', 12.00, '/images/menu/salchipapas.jpg', true)


-- ============================================================================
-- STEP 14: Add LICUADOS (Smoothies)
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Licuados'), 'Licuado Regular', 'Regular smoothie', 8.00, '/images/menu/licuado-fresa.jpg', true),
((SELECT id FROM categories WHERE name = 'Licuados'), 'Licuado Preparado', 'Prepared smoothie', 10.00, '/images/menu/licuado-fresa.jpg', true),
((SELECT id FROM categories WHERE name = 'Licuados'), 'Licuado Pina Colada', 'Pina colada smoothie', 10.00, '/images/menu/pina-colada.jpg', true)


-- ============================================================================
-- STEP 15: Add JUGOS FRESCOS (Fresh Juices)
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Jugos Frescos'), 'Jugo de Naranja', 'Fresh orange juice', 5.00, '/images/menu/jugo-naranja.jpg', true),
((SELECT id FROM categories WHERE name = 'Jugos Frescos'), 'Limonada', 'Fresh lemonade', 4.00, '/images/menu/limonada.jpg', true)


-- ============================================================================
-- STEP 16: Add AGUAS FRESCAS
-- ============================================================================

INSERT INTO menu_items (category_id, name, description, price, image_url, available) VALUES
((SELECT id FROM categories WHERE name = 'Aguas Frescas'), 'Agua Fresca Chica', 'Small flavored water', 2.00, '/images/menu/pina-colada.jpg', true),
((SELECT id FROM categories WHERE name = 'Aguas Frescas'), 'Agua Fresca Grande', 'Large flavored water', 3.00, '/images/menu/pina-colada.jpg', true)


-- ============================================================================
-- STEP 17: Update Existing Item Prices to Match Physical Menu
-- ============================================================================

UPDATE menu_items SET price = 35.00 WHERE name = 'Molcajete';
UPDATE menu_items SET price = 10.00 WHERE name = 'Huarache';

-- ============================================================================
-- STEP 18: Update Display Orders for Categories
-- ============================================================================

UPDATE categories SET display_order = 1 WHERE name = 'Desayunos Mexicanos';
UPDATE categories SET display_order = 2 WHERE name = 'Taquitos';
UPDATE categories SET display_order = 3 WHERE name = 'Tacos';
UPDATE categories SET display_order = 4 WHERE name = 'Tortas';
UPDATE categories SET display_order = 5 WHERE name = 'Burritos';
UPDATE categories SET display_order = 6 WHERE name = 'Tostadas';
UPDATE categories SET display_order = 7 WHERE name = 'Platillos Principales';
UPDATE categories SET display_order = 8 WHERE name = 'Antojitos Mexicanos';
UPDATE categories SET display_order = 9 WHERE name = 'Sopas';
UPDATE categories SET display_order = 10 WHERE name = 'Bebidas';
UPDATE categories SET display_order = 11 WHERE name = 'Side Orders';
UPDATE categories SET display_order = 12 WHERE name = 'Weekend Specials';
UPDATE categories SET display_order = 13 WHERE name = 'Kids Menu';
UPDATE categories SET display_order = 14 WHERE name = 'Licuados';
UPDATE categories SET display_order = 15 WHERE name = 'Jugos Frescos';
UPDATE categories SET display_order = 16 WHERE name = 'Aguas Frescas';
UPDATE categories SET display_order = 17 WHERE name = 'Postres';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Count items per category
SELECT c.name as category, COUNT(m.id) as item_count 
FROM categories c 
LEFT JOIN menu_items m ON c.id = m.category_id 
GROUP BY c.name 
ORDER BY c.display_order;

-- Total item count
SELECT COUNT(*) as total_items FROM menu_items;

-- Show all new categories
SELECT * FROM categories ORDER BY display_order;
