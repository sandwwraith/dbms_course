-- What workers need to cook now and how
SELECT *
FROM requireditems
  NATURAL JOIN cookbook
WHERE restaurant_id = 1;

-- Most profitable restaurants for last month
WITH report AS (
    SELECT
      r.id         AS id,
      r.address    AS address,
      SUM(o.total) AS sales,
      SUM(w2.wage) AS salary
    FROM restaurants r
      JOIN workers w2 ON r.id = w2.restaurant_id
      JOIN orders o ON r.id = o.restaurant_id
    WHERE o.createdat >= current_timestamp - INTERVAL '1 month'
    GROUP BY r.id
)
SELECT *
FROM report
ORDER BY sales / salary DESC;

-- Cheapest producer for each product
SELECT s.producer_id, p.name, p.contact, s.product_id, p2.name, s.price FROM supplies s
  JOIN producers p ON s.producer_id = p.id
  JOIN products p2 ON s.product_id = p2.id
  WHERE (s.product_id, s.price) in (
    SELECT product_id, MIN(price) FROM supplies GROUP BY product_id
  );

-- Most valuable offers
WITH offerValues AS (
    SELECT
      offers.name,
      offers.total  AS offer_price,
      SUM(m2.price) AS usual_price
    FROM Offers
      JOIN offeritems o ON offers.id = o.offer_id
      JOIN menu m2 ON o.item_id = m2.id
    GROUP BY offers.id
)
SELECT name, (1 - offer_price/usual_price) * 100 AS discount FROM offerValues
ORDER BY discount DESC;

