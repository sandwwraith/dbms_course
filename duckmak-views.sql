DROP VIEW IF EXISTS CookBook;
DROP VIEW IF EXISTS RequiredItems;

-- Each menu item with recipe and its ingredients
CREATE VIEW CookBook AS
  SELECT
    menu.id                  AS item_id,
    menu.name                AS item_name,
    r.steps                  AS steps,
    string_agg(p.name, ', ') AS ingredients
  FROM menu
    JOIN recipes r ON menu.id = r.item_id
    JOIN recipeproducts r2 ON r.id = r2.recipe_id
    JOIN products p ON r2.product_id = p.id
  GROUP BY menu.id, r.steps;

-- Items that should be cooked according to active orders
CREATE VIEW RequiredItems AS
  SELECT
    m2.id                AS item_id,
    m2.name              AS item_name,
    orders.restaurant_id AS restaurant_id,
    SUM(o.quantity)      AS cnt
  FROM orders
    JOIN orderitems o ON orders.id = o.order_id
    JOIN menu m2 ON o.item_id = m2.id
  WHERE status NOT IN ('ready', 'grabbed')
  GROUP BY m2.id, restaurant_id;

