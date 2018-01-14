DROP FUNCTION IF EXISTS place_order( BIGINT, CHARACTER VARYING, INT, ITEMPAIR [], INT [] );
DROP TYPE IF EXISTS ITEMPAIR;
CREATE TYPE ITEMPAIR AS (
  itemId   INT,
  quantity INT
);
CREATE OR REPLACE FUNCTION place_order(
  newid BIGINT, newName VARCHAR(100), restaurant INT, items ITEMPAIR [], used_offers INT []
)
  RETURNS VOID AS
$$
DECLARE
  totalOrdered MONEY;
  itm          ITEMPAIR;
  off_id       INT;
  offer        OFFERS;
  any_item     INT;
BEGIN
  totalOrdered := '0.0';
  INSERT INTO orders VALUES (
    newid, newName, '0.1', current_timestamp, 'cooking', 1, restaurant
  );
  FOREACH itm IN ARRAY items LOOP
    totalOrdered := totalOrdered + itm.quantity * (SELECT price
                                                   FROM menu
                                                   WHERE id = itm.itemid);
    any_item := itm.itemid;
    INSERT INTO orderitems (order_id, item_id, quantity) VALUES (
      newid, itm.itemid, itm.quantity
    );
  END LOOP;
  FOREACH off_id IN ARRAY used_offers LOOP
    SELECT *
    INTO offer
    FROM offers o
    WHERE o.id = off_id;
    totalOrdered := totalOrdered + offer.total;
    INSERT INTO orderitems (order_id, item_id, quantity)
      SELECT
        newid,
        ofs.item_id,
        ofs.quantity
      FROM offeritems ofs
      WHERE ofs.offer_id = off_id;
    any_item := offer.item_id;
  END LOOP;
  UPDATE orders
  SET total = totalOrdered, item_id = any_item
  WHERE id = newid;
END;
$$
LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS item_available( INT, INT );
CREATE OR REPLACE FUNCTION item_available(
  restaurant  INT,
  ordered_iid INT
)
  RETURNS BOOLEAN AS
$available$
DECLARE
  cnt INT;
BEGIN
  FOR cnt IN (SELECT holds.count AS cnt
              FROM menu m2
                JOIN recipes r ON m2.id = r.item_id
                JOIN recipeproducts r2 ON r.id = r2.recipe_id
                JOIN holdings holds ON holds.product_id = r2.product_id
              WHERE m2.id = ordered_iid AND holds.restaurant_id = restaurant) LOOP
    IF cnt = 0
    THEN
      RETURN FALSE;
    END IF;
  END LOOP;
  RETURN TRUE;
END;
$available$
LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS f_order_item_check();
CREATE OR REPLACE FUNCTION f_order_item_check(

)
  RETURNS TRIGGER AS $$
DECLARE
  restaurant  INT;
  ordered_iid INT;
BEGIN
  SELECT o.restaurant_id
  INTO restaurant
  FROM orders o
  WHERE o.id = new.order_id;
  ordered_iid := new.item_id;
  IF NOT item_available(restaurant, ordered_iid)
  THEN
    RAISE EXCEPTION 'No more required products in stock % for item % ', restaurant, ordered_iid;
  END IF;
  UPDATE holdings
  SET count = count - 1
  WHERE holdings.restaurant_id = restaurant AND holdings.product_id IN (
    SELECT r2.product_id
    FROM menu m2
      JOIN recipes r ON m2.id = r.item_id
      JOIN recipeproducts r2 ON r.id = r2.recipe_id
    WHERE m2.id = ordered_iid);
  RETURN new;
END;
$$
LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS order_item_check
ON orderitems;
CREATE TRIGGER order_item_check
  AFTER INSERT
  ON orderitems
  FOR EACH ROW EXECUTE PROCEDURE f_order_item_check();

DROP SEQUENCE IF EXISTS OrderSerial;
CREATE SEQUENCE OrderSerial
  START 10;

-- Create new order
SELECT place_order((SELECT nextval('OrderSerial')), 'a', 1, '{}', '{2}' :: INT []);

SELECT item_available(1, 1);