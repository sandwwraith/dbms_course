BEGIN;
SET CONSTRAINTS ALL DEFERRED;
DROP TABLE IF EXISTS RecipeProducts CASCADE;
DROP TABLE IF EXISTS Recipes CASCADE;
DROP TABLE IF EXISTS Products CASCADE;
DROP TABLE IF EXISTS Menu CASCADE;
DROP TABLE IF EXISTS Supplies CASCADE;
DROP TABLE IF EXISTS Producers CASCADE;
DROP TABLE IF EXISTS Holdings CASCADE;
DROP TABLE IF EXISTS Workers CASCADE;
DROP TABLE IF EXISTS Restaurants CASCADE;
DROP TABLE IF EXISTS OrderItems CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS OfferItems CASCADE;
DROP TABLE IF EXISTS Offers CASCADE;
DROP TYPE IF EXISTS ORDERSTATUS;
COMMIT;

CREATE TABLE Menu (
  id        INT           NOT NULL PRIMARY KEY,
  name      VARCHAR(100)  NOT NULL UNIQUE,
  price     MONEY         NOT NULL CHECK (price > 0 :: MONEY),
  weight    DECIMAL(5, 1) NOT NULL CHECK (weight > 0),
  calories  INT           NOT NULL CHECK (calories > 0),
  recipe_id INT           NOT NULL
);

CREATE TABLE Recipes (
  id         INT  NOT NULL PRIMARY KEY,
  steps      TEXT NOT NULL,
  item_id    INT  NOT NULL UNIQUE REFERENCES Menu (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE,
  product_id INT  NOT NULL
);

ALTER TABLE Menu
  ADD FOREIGN KEY (recipe_id)
REFERENCES Recipes (id) ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE TABLE Products (
  id        INT          NOT NULL PRIMARY KEY,
  name      VARCHAR(100) NOT NULL UNIQUE,
  recipe_id INT          NOT NULL
);

CREATE TABLE RecipeProducts (
  product_id INT NOT NULL REFERENCES Products (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  recipe_id  INT NOT NULL REFERENCES Recipes (id) ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY (product_id, recipe_id)
);


ALTER TABLE Recipes
  ADD FOREIGN KEY (product_id, id)
REFERENCES RecipeProducts (product_id, recipe_id) ON DELETE NO ACTION ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE Products
  ADD FOREIGN KEY (id, recipe_id)
REFERENCES RecipeProducts (product_id, recipe_id) ON DELETE NO ACTION ON UPDATE CASCADE DEFERRABLE;

--

CREATE TABLE Producers (
  id      INT          NOT NULL PRIMARY KEY,
  name    VARCHAR(100) NOT NULL,
  contact VARCHAR(100) NOT NULL
);

CREATE TABLE Supplies (
  producer_id INT   NOT NULL REFERENCES Producers (id) ON DELETE CASCADE ON UPDATE CASCADE,
  product_id  INT   NOT NULL REFERENCES Products (id) ON DELETE CASCADE ON UPDATE CASCADE,
  price       MONEY NOT NULL CHECK (price > 0 :: MONEY),
  PRIMARY KEY (producer_id, product_id)
);

--

CREATE TABLE Restaurants (
  id      INT          NOT NULL PRIMARY KEY,
  address VARCHAR(100) NOT NULL UNIQUE,
  contact VARCHAR(100) NOT NULL
);

CREATE TABLE Holdings (
  restaurant_id INT NOT NULL REFERENCES Restaurants (id) ON DELETE CASCADE ON UPDATE CASCADE,
  product_id    INT NOT NULL REFERENCES Products (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  count         INT NOT NULL CHECK (count >= 0)
);

CREATE TABLE Workers (
  id            INT          NOT NULL PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  passport      CHAR(10)     NOT NULL UNIQUE,
  wage          MONEY        NOT NULL CHECK (wage > 0 :: MONEY),
  phone         CHAR(12)     NOT NULL,
  restaurant_id INT          NOT NULL REFERENCES Restaurants (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

--
CREATE TYPE ORDERSTATUS AS ENUM ('cooking', 'ready', 'grabbed');
CREATE TABLE Orders (
  id            BIGINT      NOT NULL PRIMARY KEY,
  displayName   VARCHAR(10) NOT NULL,
  total         MONEY       NOT NULL CHECK (total > 0 :: MONEY),
  createdAt     TIMESTAMP   NOT NULL,
  status        ORDERSTATUS NOT NULL,
  item_id       INT         NOT NULL,
  restaurant_id INT         NOT NULL REFERENCES Restaurants (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE OrderItems (
  order_id BIGINT NOT NULL REFERENCES Orders (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED,
  item_id  INT    NOT NULL REFERENCES Menu (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantity INT    NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (order_id, item_id)
);

ALTER TABLE Orders
  ADD FOREIGN KEY (id, item_id)
REFERENCES OrderItems (order_id, item_id) ON DELETE NO ACTION ON UPDATE CASCADE DEFERRABLE INITIALLY DEFERRED;

--
CREATE TABLE Offers (
  id        INT   NOT NULL PRIMARY KEY,
  total     MONEY NOT NULL CHECK (total > 0 :: MONEY),
  name      VARCHAR(100),
  promocode CHAR(10) UNIQUE,
  item_id   INT   NOT NULL
);

CREATE TABLE OfferItems (
  offer_id INT NOT NULL REFERENCES Offers (id) ON DELETE CASCADE ON UPDATE CASCADE,
  item_id  INT NOT NULL REFERENCES Menu (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  quantity INT NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (offer_id, item_id)
);

ALTER TABLE Offers
  ADD FOREIGN KEY (id, item_id)
REFERENCES OfferItems (offer_id, item_id) ON DELETE NO ACTION ON UPDATE CASCADE DEFERRABLE;

--

DROP INDEX IF EXISTS product_recipe_idx1;
DROP INDEX IF EXISTS product_recipe_idx2;
DROP INDEX IF EXISTS worker_name_idx;
DROP INDEX IF EXISTS promocode_idx;
CREATE INDEX product_recipe_idx1
  ON Products (recipe_id);
CREATE INDEX product_recipe_idx2
  ON Recipes (product_id);
CREATE INDEX worker_name_idx
  ON Workers (name);

CREATE UNIQUE INDEX promocode_idx
  ON Offers (promocode)
  WHERE promocode IS NOT NULL;



