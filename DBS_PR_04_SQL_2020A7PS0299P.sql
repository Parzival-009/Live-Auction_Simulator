CREATE DATABASE auction;

USE auction;

-- TABLES
CREATE TABLE IF NOT EXISTS user(
	username VARCHAR(50) NOT NULL,
	password VARCHAR(13) NOT NULL,
	PRIMARY KEY(username)
);

CREATE TABLE IF NOT EXISTS items(
	item_id INT NOT NULL AUTO_INCREMENT,
	owner_username VARCHAR(50) NOT NULL,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(200),
	image_url VARCHAR(500),
	base_price INT NOT NULL,
	buy_now_price INT,
	end_date DATETIME NOT NULL,
	available_for_sale BOOLEAN NOT NULL DEFAULT true,
	PRIMARY KEY(item_id),
	FOREIGN KEY(owner_username) REFERENCES user(username)
);

CREATE TABLE IF NOT EXISTS offers(
	offer_id INT NOT NULL AUTO_INCREMENT,
	item_id INT NOT NULL,
	username VARCHAR(50) NOT NULL,
	offer_time DATETIME NOT NULL,
	offer_value INT NOT NULL,
	FOREIGN KEY(username) REFERENCES user(username),
	FOREIGN KEY(item_id) REFERENCES items(item_id),
	PRIMARY KEY(offer_id)
);

CREATE TABLE IF NOT EXISTS soldto(
	item_id INT NOT NULL,
	buyer_username VARCHAR(50) NOT NULL,
	offer_id INT NOT NULL,
	FOREIGN KEY(item_id) REFERENCES items(item_id),
	FOREIGN KEY(buyer_username) REFERENCES user(username),
	FOREIGN KEY(offer_id) REFERENCES offers(offer_id),
	PRIMARY KEY(item_id, buyer_username, offer_id)
);

-- PROCEDUREs
DELIMITER // 
CREATE PROCEDURE itemStatusVerifier() 
BEGIN 
START TRANSACTION;
INSERT INTO soldto(
  item_id, buyer_username, offer_id
) 
SELECT 
  item_id, 
  username, 
  offer_id 
FROM 
  (
    SELECT 
      * 
    FROM 
      items 
    WHERE 
      available_for_sale = 1 
      AND end_date < NOW()
  ) AS recentlyExpiredItems NATURAL 
  JOIN (
    SELECT 
      * 
    FROM 
      offers AS o 
    WHERE 
      offer_value = (
        SELECT 
          MAX(offer_value) 
        FROM 
          offers AS f 
        WHERE 
          f.item_id = o.item_id
      )
  ) AS BidWinner;
UPDATE 
  items 
SET 
  available_for_sale = 0 
WHERE 
  end_date < NOW();
COMMIT;
END // 
DELIMITER ;

DELIMITER // 
CREATE PROCEDURE buyNowProcess(IN itemID INT, IN buyerUsername VARCHAR(50)) 
BEGIN 
  START TRANSACTION;
  SELECT @buyNowPrice := buy_now_price FROM items WHERE item_id=itemID;
  INSERT INTO offers(item_id, username, offer_time, offer_value)
  VALUES (itemID, buyerUsername, NOW(), @buyNowPrice);
  SELECT @offerID := offer_id FROM offers WHERE item_id=itemID AND username=buyerUsername
  AND offer_value = @buyNowPrice;
  SELECT @offerID;
  INSERT INTO soldto(item_id, buyer_username, offer_id)
  VALUES (itemID, buyerUsername, @offerID);
  UPDATE items SET available_for_sale = FALSE WHERE item_id=itemID;
  COMMIT;
END // 
DELIMITER ;

DELIMITER // 
CREATE PROCEDURE getAvailableItems() 
BEGIN 
    SELECT * FROM items WHERE items.end_date > NOW() AND items.available_for_sale = true;
END // 
DELIMITER ;


-- BASIC DATA FOR TESTING
INSERT INTO
	user(username, password)
VALUES
	("Samay", "Samay12345"),
	("Aditya", "Aditya12345"),
	("Aryan", "Aryan12345");
