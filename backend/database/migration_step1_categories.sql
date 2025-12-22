-- Step 1: Add new categories
INSERT INTO categories (name, description, display_order) 
SELECT * FROM (VALUES
  ('Taquitos', 'Soft tacos - smaller portion', 2),
  ('Desayunos Mexicanos', 'Mexican breakfast plates', 1),
  ('Side Orders', 'Side dishes and extras', 11),
  ('Weekend Specials', 'Available on weekends only', 12),
  ('Kids Menu', 'Kid-friendly meals', 13),
  ('Licuados', 'Smoothies and blended drinks', 14),
  ('Jugos Frescos', 'Fresh juices', 15),
  ('Aguas Frescas', 'Fresh flavored waters', 16)
) AS v(name, description, display_order)
WHERE NOT EXISTS (
  SELECT 1 FROM categories WHERE categories.name = v.name
);
