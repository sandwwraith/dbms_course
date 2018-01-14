BEGIN;
SET CONSTRAINTS ALL DEFERRED;
INSERT INTO products (id, name, recipe_id) VALUES
  (1, 'Котлета (x1)', 1),
  (2, 'Булочка (x1)', 1),
  (3, 'Картофель (100г)', 2)
;
INSERT INTO recipes (id, steps, item_id, product_id) VALUES (
  1, 'Положить котлету в булочку', 1, 1
);
INSERT INTO recipes (id, steps, item_id, product_id) VALUES (
  2, 'Пожарить картофель', 2, 3
);
INSERT INTO recipeproducts VALUES
  (1, 1),
  (2, 1),
  (3, 2)
;
INSERT INTO menu VALUES
  (1, 'Бургер', '8.00', 250, 200, 1),
  (2, 'Картошка фри', '4.00', 100, 100, 2)
;
INSERT INTO producers VALUES
  (1, 'Рефтинская птицефабрика', '88005553535'),
  (2, 'Дикси', '3221488');
INSERT INTO supplies VALUES
  (1, 1, '4'),
  (2, 1, '6'),
  (2, 2, '2'),
  (2, 3, '2')
;
INSERT INTO restaurants VALUES
  (1, 'м. Петроградская', '1112233'),
  (2, 'м. Невский проспект', '3332211');
INSERT INTO holdings VALUES
  (1, 1, 50),
  (1, 2, 3),
  (1, 3, 50),
  (2, 2, 100),
  (2, 1, 100),
  (2, 3, 100)
;
INSERT INTO workers VALUES
  (1, 'Петя', '1234567890', '60', '89991112233', 1),
  (2, 'Вася', '1234567820', '60', '89991112234', 2),
  (3, 'Коля', '1234567840', '60', '89991112235', 2);
INSERT INTO orders VALUES
  (1, 'M-01', '16.00', current_timestamp, 'cooking', 1, 2),
  (2, 'K-02', '10.00', current_timestamp, 'cooking', 1, 1)
;
INSERT INTO orderitems VALUES
  (1, 1, 2),
  (2, 1, 1),
  (2, 2, 1)
;
INSERT INTO Offers VALUES
  (1, '10.00', 'Комбо-обед', NULL, 1),
  (2, '5.00', 'Секретная скидка на бургер', '1337', 1)
;
INSERT INTO offeritems VALUES
  (1, 1, 1),
  (1, 2, 1),
  (2, 1, 1)
;
COMMIT;