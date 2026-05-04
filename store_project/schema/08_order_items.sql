-- Different sql for different tables
USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(4,2) NOT NULL,
  PRIMARY KEY (`order_id`,`product_id`),
  KEY `fk_order_items_products_idx` (`product_id`),
  CONSTRAINT `fk_order_items_orders` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_products` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE CASCADE
);

INSERT INTO `order_items` (`order_id`, `product_id`, `quantity`, `unit_price`) VALUES
(1, 2, 2, 15.50),
(1, 4, 1, 10.99),
(2, 3, 1, 45.00),
(3, 1, 1, 25.99);

-- Trigger: Apply Bulk Discount
-- 10% discount if quantity > 10
DELIMITER //
DROP TRIGGER IF EXISTS `trg_apply_bulk_discount`//
CREATE TRIGGER `trg_apply_bulk_discount`
BEFORE INSERT ON `order_items`
FOR EACH ROW
BEGIN
    IF NEW.quantity > 10 THEN
        SET NEW.unit_price = NEW.unit_price * 0.90;
    END IF;
END//
DELIMITER ;

-- View: Customer Order Summary
DROP VIEW IF EXISTS `vw_customer_order_summary`;
CREATE VIEW `vw_customer_order_summary` AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent,
    MAX(o.order_date) AS latest_order_date
FROM `customers` c
LEFT JOIN `orders` o ON c.customer_id = o.customer_id
LEFT JOIN `order_items` oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, full_name;

-- View: Shipper Volume
DROP VIEW IF EXISTS `vw_shipper_volume`;
CREATE VIEW `vw_shipper_volume` AS
SELECT 
    s.shipper_id,
    s.name,
    COUNT(o.order_id) AS total_orders_shipped
FROM `shippers` s
LEFT JOIN `orders` o ON s.shipper_id = o.shipper_id
GROUP BY s.shipper_id, s.name;

-- View: Category Performance
DROP VIEW IF EXISTS `vw_category_performance`;
CREATE VIEW `vw_category_performance` AS
SELECT 
    cat.category_id,
    cat.name AS category_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM `categories` cat
LEFT JOIN `products` p ON cat.category_id = p.category_id
LEFT JOIN `order_items` oi ON p.product_id = oi.product_id
GROUP BY cat.category_id, cat.name;

-- Procedure: Place a new order
DELIMITER //
DROP PROCEDURE IF EXISTS `sp_place_order`//
CREATE PROCEDURE `sp_place_order`(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_unit_price DECIMAL(4,2);
    DECLARE v_current_stock INT;
    
    START TRANSACTION;
    
    SELECT quantity_in_stock, unit_price 
    INTO v_current_stock, v_unit_price 
    FROM products 
    WHERE product_id = p_product_id;
    
    IF v_current_stock < p_quantity THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for the requested product.';
    ELSE
        INSERT INTO orders (customer_id, order_date, status) 
        VALUES (p_customer_id, CURDATE(), 1);
        
        SET v_order_id = LAST_INSERT_ID();
        
        INSERT INTO order_items (order_id, product_id, quantity, unit_price) 
        VALUES (v_order_id, p_product_id, p_quantity, v_unit_price);
        
        UPDATE products 
        SET quantity_in_stock = quantity_in_stock - p_quantity 
        WHERE product_id = p_product_id;
        
        -- Add points to customer (1 point per item ordered)
        UPDATE customers
        SET points = points + p_quantity
        WHERE customer_id = p_customer_id;
        
        COMMIT;
    END IF;
END//
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;
