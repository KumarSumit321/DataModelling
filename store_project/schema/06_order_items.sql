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

-- Insert dummy order items
INSERT INTO `order_items` (`order_id`, `product_id`, `quantity`, `unit_price`) VALUES
(1, 2, 2, 15.50),
(1, 4, 1, 10.99),
(2, 3, 1, 45.00),
(3, 1, 1, 25.99);

-- View: Customer Order Summary
-- Shows each customer's total spent, total items ordered, and latest order date
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

-- Procedure: Place a new order
-- Automates order creation, order item creation, and stock deduction. Includes edge case handling for low stock.
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
    
    -- Start transaction
    START TRANSACTION;
    
    -- Check current stock and get price
    SELECT quantity_in_stock, unit_price 
    INTO v_current_stock, v_unit_price 
    FROM products 
    WHERE product_id = p_product_id;
    
    -- Edge Case: Check if there is enough stock
    IF v_current_stock < p_quantity THEN
        -- Rollback and throw error
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for the requested product.';
    ELSE
        -- 1. Create the new order (default status 1 = Processed)
        INSERT INTO orders (customer_id, order_date, status) 
        VALUES (p_customer_id, CURDATE(), 1);
        
        -- Get the newly created order ID
        SET v_order_id = LAST_INSERT_ID();
        
        -- 2. Add the item to order_items
        INSERT INTO order_items (order_id, product_id, quantity, unit_price) 
        VALUES (v_order_id, p_product_id, p_quantity, v_unit_price);
        
        -- 3. Deduct stock from products
        UPDATE products 
        SET quantity_in_stock = quantity_in_stock - p_quantity 
        WHERE product_id = p_product_id;
        
        COMMIT;
    END IF;
END//

DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;
