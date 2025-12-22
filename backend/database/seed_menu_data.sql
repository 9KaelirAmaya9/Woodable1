-- Los Ricos Tacos - Menu Data Seed Script
-- This script populates the database with sample menu items

-- First, ensure we're connected to the right database
\c mydatabase

-- Insert Categories
INSERT INTO categories (name, slug, description, display_order, is_active) VALUES
('Tacos', 'tacos', 'Authentic Mexican tacos with fresh ingredients', 1, true),
('Burritos', 'burritos', 'Large flour tortilla filled with your choice of meat and toppings', 2, true),
('Quesadillas', 'quesadillas', 'Grilled tortilla with melted cheese and fillings', 3, true),
('Sides', 'sides', 'Delicious sides to complement your meal', 4, true),
('Drinks', 'drinks', 'Refreshing beverages', 5, true),
('Desserts', 'desserts', 'Sweet treats to finish your meal', 6, true)
ON CONFLICT (slug) DO NOTHING;

-- Insert Tacos
INSERT INTO menu_items (category_id, name, description, price, is_available, spiciness_level) VALUES
((SELECT id FROM categories WHERE slug = 'tacos'), 'Carne Asada Taco', 'Grilled steak with onions, cilantro, and salsa verde', 3.50, true, 1),
((SELECT id FROM categories WHERE slug = 'tacos'), 'Al Pastor Taco', 'Marinated pork with pineapple, onions, and cilantro', 3.50, true, 2),
((SELECT id FROM categories WHERE slug = 'tacos'), 'Pollo Asado Taco', 'Grilled chicken with lettuce, tomato, and sour cream', 3.25, true, 1),
((SELECT id FROM categories WHERE slug = 'tacos'), 'Carnitas Taco', 'Slow-cooked pork with onions, cilantro, and lime', 3.50, true, 1),
((SELECT id FROM categories WHERE slug = 'tacos'), 'Fish Taco', 'Beer-battered fish with cabbage slaw and chipotle mayo', 4.00, true, 1),
((SELECT id FROM categories WHERE slug = 'tacos'), 'Veggie Taco', 'Grilled vegetables with black beans, cheese, and guacamole', 3.00, true, 0);

-- Insert Burritos
INSERT INTO menu_items (category_id, name, description, price, is_available, spiciness_level) VALUES
((SELECT id FROM categories WHERE slug = 'burritos'), 'Carne Asada Burrito', 'Grilled steak with rice, beans, cheese, sour cream, and guacamole', 9.50, true, 1),
((SELECT id FROM categories WHERE slug = 'burritos'), 'Chicken Burrito', 'Grilled chicken with rice, beans, lettuce, tomato, and cheese', 8.50, true, 1),
((SELECT id FROM categories WHERE slug = 'burritos'), 'California Burrito', 'Carne asada with fries, cheese, sour cream, and guacamole', 10.00, true, 1),
((SELECT id FROM categories WHERE slug = 'burritos'), 'Bean & Cheese Burrito', 'Refried beans and melted cheese', 6.00, true, 0),
((SELECT id FROM categories WHERE slug = 'burritos'), 'Veggie Burrito', 'Grilled vegetables, rice, black beans, and guacamole', 8.00, true, 0);

-- Insert Quesadillas
INSERT INTO menu_items (category_id, name, description, price, is_available, spiciness_level) VALUES
((SELECT id FROM categories WHERE slug = 'quesadillas'), 'Cheese Quesadilla', 'Melted cheese in a grilled flour tortilla', 6.00, true, 0),
((SELECT id FROM categories WHERE slug = 'quesadillas'), 'Chicken Quesadilla', 'Grilled chicken and melted cheese', 8.00, true, 0),
((SELECT id FROM categories WHERE slug = 'quesadillas'), 'Carne Asada Quesadilla', 'Grilled steak and melted cheese', 9.00, true, 0),
((SELECT id FROM categories WHERE slug = 'quesadillas'), 'Veggie Quesadilla', 'Grilled vegetables and melted cheese', 7.50, true, 0);

-- Insert Sides
INSERT INTO menu_items (category_id, name, description, price, is_available, spiciness_level) VALUES
((SELECT id FROM categories WHERE slug = 'sides'), 'Rice & Beans', 'Mexican rice and refried beans', 3.50, true, 0),
((SELECT id FROM categories WHERE slug = 'sides'), 'Chips & Salsa', 'Crispy tortilla chips with fresh salsa', 4.00, true, 1),
((SELECT id FROM categories WHERE slug = 'sides'), 'Chips & Guacamole', 'Crispy tortilla chips with fresh guacamole', 6.00, true, 0),
((SELECT id FROM categories WHERE slug = 'sides'), 'Elote (Mexican Street Corn)', 'Grilled corn with mayo, cheese, and chili powder', 4.50, true, 2),
((SELECT id FROM categories WHERE slug = 'sides'), 'Nachos', 'Tortilla chips with cheese, beans, jalapeños, and sour cream', 7.00, true, 2);

-- Insert Drinks
INSERT INTO menu_items (category_id, name, description, price, is_available, spiciness_level) VALUES
((SELECT id FROM categories WHERE slug = 'drinks'), 'Horchata', 'Sweet rice milk with cinnamon', 3.00, true, 0),
((SELECT id FROM categories WHERE slug = 'drinks'), 'Jamaica', 'Hibiscus flower tea', 3.00, true, 0),
((SELECT id FROM categories WHERE slug = 'drinks'), 'Tamarindo', 'Tamarind agua fresca', 3.00, true, 0),
((SELECT id FROM categories WHERE slug = 'drinks'), 'Mexican Coke', 'Coca-Cola made with real sugar', 2.50, true, 0),
((SELECT id FROM categories WHERE slug = 'drinks'), 'Jarritos', 'Mexican soda (various flavors)', 2.50, true, 0),
((SELECT id FROM categories WHERE slug = 'drinks'), 'Bottled Water', 'Purified water', 1.50, true, 0);

-- Insert Desserts
INSERT INTO menu_items (category_id, name, description, price, is_available, spiciness_level) VALUES
((SELECT id FROM categories WHERE slug = 'desserts'), 'Churros', 'Fried dough pastry with cinnamon sugar', 5.00, true, 0),
((SELECT id FROM categories WHERE slug = 'desserts'), 'Flan', 'Creamy caramel custard', 4.50, true, 0),
((SELECT id FROM categories WHERE slug = 'desserts'), 'Tres Leches Cake', 'Sponge cake soaked in three types of milk', 5.50, true, 0),
((SELECT id FROM categories WHERE slug = 'desserts'), 'Sopapillas', 'Fried pastry with honey and cinnamon', 4.00, true, 0);

-- Verify the data was inserted
SELECT 'Categories inserted:' as info, COUNT(*) as count FROM categories;
SELECT 'Menu items inserted:' as info, COUNT(*) as count FROM menu_items;

-- Show sample data
SELECT c.name as category, COUNT(mi.id) as item_count 
FROM categories c 
LEFT JOIN menu_items mi ON c.id = mi.category_id 
GROUP BY c.name 
ORDER BY c.display_order;
