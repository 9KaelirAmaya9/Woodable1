# Missing Menu Item Images

## Items Needing Photos

The following 11 menu items exist in the database but are missing image files:

### Tostadas (5 items)
1. **Tostada de Ceviche** → `tostada-ceviche.jpg`
   - Fresh shrimp/fish ceviche on crispy tortilla with avocado, tomatoes, cilantro

2. **Tostada de Frijoles** → `tostada-frijoles.jpg`
   - Refried beans, lettuce, cheese, crema on crispy tortilla

3. **Tostada de Carne Asada** → `tostada-carne-asada.jpg`
   - Grilled steak, beans, lettuce, pico de gallo, guacamole

4. **Tostada Mixta** → `tostada-mixta.jpg`
   - Mixed meats (chicken & beef), beans, lettuce, cheese, toppings

5. **Tostada de Tinga de Pollo** → `tostada-tinga.jpg`
   - Shredded chicken in chipotle sauce, beans, lettuce, cheese

### Desserts (6 items)
6. **Churros** → `churros.jpg`
   - Fried dough pastries with cinnamon sugar, chocolate sauce

7. **Flan** → `flan.jpg`
   - Caramel custard dessert

8. **Sopapillas** → `sopapillas.jpg`
   - Fried pastry puffs with honey and cinnamon

9. **Pastel de Tres Leches** → `tres-leches.jpg`
   - Three milk cake, moist sponge cake

10. **Gelatina** → `gelatina.jpg`
    - Colorful Mexican jello dessert

11. **Arroz con Leche** → `arroz-con-leche.jpg`
    - Rice pudding with cinnamon

---

## How to Add Images

### Option 1: Use AI Image Generation (When Rate Limit Resets)
Wait a few minutes and run:
```bash
# I can generate these images for you when the rate limit resets
```

### Option 2: Download Stock Photos
1. Search for high-quality food photography for each item
2. Save images with the exact filenames listed above
3. Place in: `react-app/public/images/menu/`
4. Run the update script:
   ```bash
   docker exec base2_backend node /app/database/update_missing_images.js
   ```

### Option 3: Take Your Own Photos
If you have access to these dishes:
1. Take high-quality photos (good lighting, clean background)
2. Resize to ~800x600px
3. Save as JPG with filenames above
4. Place in `react-app/public/images/menu/`
5. Run update script

---

## Recommended Image Sources

**Free Stock Photo Sites:**
- Unsplash.com (search "mexican food [item name]")
- Pexels.com
- Pixabay.com

**Search Terms:**
- "tostada ceviche mexican food"
- "churros mexican dessert"
- "flan caramel custard"
- "tres leches cake"
- etc.

---

## Update Script

Once images are in place, run:
```bash
cd /Users/jancarlosinc/Desktop/Coding/Axonic/Woodable1
docker cp backend/database/update_missing_images.js base2_backend:/app/database/
docker exec base2_backend node /app/database/update_missing_images.js
```

This will update the database to point to the new image files.
