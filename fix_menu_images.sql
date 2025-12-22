-- Fix all menu item image paths to match actual files
-- Main issue: database uses underscores, files use hyphens

-- Platillos Principales
UPDATE menu_items SET image_url = '/images/menu/molcajete.jpg' WHERE id = 1;
UPDATE menu_items SET image_url = '/images/menu/cochinita-pibil.jpg' WHERE id = 2;
UPDATE menu_items SET image_url = '/images/menu/birria-platillo.jpg' WHERE id = 3;
UPDATE menu_items SET image_url = '/images/menu/chiles-rellenos.jpg' WHERE id = 4;
UPDATE menu_items SET image_url = '/images/menu/chuleta-puerco.jpg' WHERE id = 5;
UPDATE menu_items SET image_url = '/images/menu/bistec-encebollado.jpg' WHERE id = 6;
UPDATE menu_items SET image_url = '/images/menu/bistec-mexicana.jpg' WHERE id = 7;
UPDATE menu_items SET image_url = '/images/menu/enchiladas-poblanas.jpg' WHERE id = 8;
UPDATE menu_items SET image_url = '/images/menu/enchiladas-rojas.jpg' WHERE id = 9;
UPDATE menu_items SET image_url = '/images/menu/enchiladas-verdes.jpg' WHERE id = 10;
UPDATE menu_items SET image_url = '/images/menu/chilaquiles-cecina.jpg' WHERE id = 11;
UPDATE menu_items SET image_url = '/images/menu/mojarra-frita.jpg' WHERE id = 12;
UPDATE menu_items SET image_url = '/images/menu/mole-poblano.jpg' WHERE id = 13;
UPDATE menu_items SET image_url = '/images/menu/carne-asada-platillo.jpg' WHERE id = 14;
UPDATE menu_items SET image_url = '/images/menu/camarones-diabla.jpg' WHERE id = 15;
UPDATE menu_items SET image_url = '/images/menu/fajitas.jpg' WHERE id = 16;
UPDATE menu_items SET image_url = '/images/menu/parrilladas.jpg' WHERE id = 17;

-- Antojitos Mexicanos
UPDATE menu_items SET image_url = '/images/menu/sopas-antojito.jpg' WHERE id = 18;
UPDATE menu_items SET image_url = '/images/menu/huarache.jpg' WHERE id = 19;
UPDATE menu_items SET image_url = '/images/menu/quesadilla.jpg' WHERE id = 20;
UPDATE menu_items SET image_url = '/images/menu/cemitas.jpg' WHERE id = 21;
UPDATE menu_items SET image_url = '/images/menu/chalupas.jpg' WHERE id = 22;
UPDATE menu_items SET image_url = '/images/menu/tacos-dorados.jpg' WHERE id = 23;
UPDATE menu_items SET image_url = '/images/menu/guacamole.jpg' WHERE id = 24;

-- Tacos
UPDATE menu_items SET image_url = '/images/menu/carne-asada-taco.jpg' WHERE id = 25;
UPDATE menu_items SET image_url = '/images/menu/al-pastor.jpg' WHERE id = 26;
UPDATE menu_items SET image_url = '/images/menu/birria-taco.jpg' WHERE id = 27;
UPDATE menu_items SET image_url = '/images/menu/carnitas-taco.jpg' WHERE id = 28;
UPDATE menu_items SET image_url = '/images/menu/lengua-taco.jpg' WHERE id = 29;
UPDATE menu_items SET image_url = '/images/menu/tripa-taco.jpg' WHERE id = 30;
UPDATE menu_items SET image_url = '/images/menu/taquito-bistec.jpg' WHERE id = 31;
UPDATE menu_items SET image_url = '/images/menu/pollo-asado-taco.jpg' WHERE id = 32;
UPDATE menu_items SET image_url = '/images/menu/tacos-arabes.jpg' WHERE id = 33;

-- Tortas
UPDATE menu_items SET image_url = '/images/menu/torta-cubana.jpg' WHERE id = 34;
UPDATE menu_items SET image_url = '/images/menu/torta-milaneza-res.jpg' WHERE id = 35;
UPDATE menu_items SET image_url = '/images/menu/torta-pastor.jpg' WHERE id = 36;
UPDATE menu_items SET image_url = '/images/menu/torta-jamon-huevo.jpg' WHERE id = 37;

-- Burritos
UPDATE menu_items SET image_url = '/images/menu/burrito-bistec.jpg' WHERE id = 38;
UPDATE menu_items SET image_url = '/images/menu/burrito-pollo.jpg' WHERE id = 39;
UPDATE menu_items SET image_url = '/images/menu/burrito-carnitas.jpg' WHERE id = 40;
UPDATE menu_items SET image_url = '/images/menu/burrito-vegetariano.jpg' WHERE id = 41;

-- Sopas
UPDATE menu_items SET image_url = '/images/menu/pozole.jpg' WHERE id = 42;
UPDATE menu_items SET image_url = '/images/menu/pancita.jpg' WHERE id = 43;
UPDATE menu_items SET image_url = '/images/menu/caldo-camaron.jpg' WHERE id = 44;

-- Bebidas
UPDATE menu_items SET image_url = '/images/menu/aguas-frescas.jpg' WHERE id = 45;
UPDATE menu_items SET image_url = '/images/menu/aguas-frescas.jpg' WHERE id = 46;
UPDATE menu_items SET image_url = '/images/menu/licuado-fresa.jpg' WHERE id = 47;
UPDATE menu_items SET image_url = '/images/menu/licuado-chocolate.jpg' WHERE id = 48;
UPDATE menu_items SET image_url = '/images/menu/pina-colada.jpg' WHERE id = 49;
