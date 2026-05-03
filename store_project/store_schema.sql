DROP DATABASE IF EXISTS `store_schema`;
CREATE DATABASE `store_schema`;
USE `store_schema`;

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `quantity_in_stock` int(11) NOT NULL,
  `unit_price` decimal(4,2) NOT NULL,
  PRIMARY KEY (`product_id`)
);


CREATE TABLE `shippers` (
  `shipper_id` smallint(6) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`shipper_id`)
);


CREATE TABLE `customers` (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `birth_date` date DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `address` varchar(50) NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` char(2) NOT NULL,
  `points` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`customer_id`)
);


CREATE TABLE `order_statuses` (
  `order_status_id` tinyint(4) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`order_status_id`)
);


CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `order_date` date NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '1',
  `comments` varchar(2000) DEFAULT NULL,
  `shipped_date` date DEFAULT NULL,
  `shipper_id` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `fk_orders_customers_idx` (`customer_id`),
  KEY `fk_orders_shippers_idx` (`shipper_id`),
  KEY `fk_orders_order_statuses_idx` (`status`),
  CONSTRAINT `fk_orders_customers` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_order_statuses` FOREIGN KEY (`status`) REFERENCES `order_statuses` (`order_status_id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_shippers` FOREIGN KEY (`shipper_id`) REFERENCES `shippers` (`shipper_id`) ON UPDATE CASCADE
);


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

-- =========================================================================
-- 1. SAMPLE DATA INSERTS
-- =========================================================================

-- Insert dummy products
INSERT INTO `products` (`name`, `quantity_in_stock`, `unit_price`) VALUES
('Foam Roller', 50, 25.99),
('Yoga Mat', 100, 15.50),
('Dumbbells 10kg', 30, 45.00),
('Resistance Bands', 200, 10.99),
('Treadmill', 5, 899.99);

-- Insert dummy shippers
INSERT INTO `shippers` (`name`) VALUES
('FastTrack Logistics'),
('Global Freight'),
('Speedy Delivery');

-- Insert dummy order statuses
INSERT INTO `order_statuses` (`order_status_id`, `name`) VALUES
(1, 'Processed'),
(2, 'Shipped'),
(3, 'Cancelled'),
(4, 'Delivered');

-- Insert dummy customers
INSERT INTO `customers` (`first_name`, `last_name`, `birth_date`, `phone`, `address`, `city`, `state`, `points`) VALUES
('John', 'Doe', '1990-05-14', '555-0101', '123 Elm St', 'Seattle', 'WA', 150),
('Jane', 'Smith', '1985-11-23', '555-0202', '456 Oak Ave', 'Portland', 'OR', 300),
('Bob', 'Johnson', '1978-02-09', '555-0303', '789 Pine Rd', 'San Francisco', 'CA', 50);

-- Insert dummy orders
INSERT INTO `orders` (`customer_id`, `order_date`, `status`, `comments`, `shipped_date`, `shipper_id`) VALUES
(1, '2023-10-01', 4, 'Leave at front door', '2023-10-03', 1),
(2, '2023-10-05', 2, NULL, '2023-10-06', 2),
(3, '2023-10-10', 1, 'Please rush', NULL, NULL);

-- Insert dummy order items
INSERT INTO `order_items` (`order_id`, `product_id`, `quantity`, `unit_price`) VALUES
(1, 2, 2, 15.50),
(1, 4, 1, 10.99),
(2, 3, 1, 45.00),
(3, 1, 1, 25.99);

-- =========================================================================
-- 2. BUSINESS LOGICS (VIEWS, PROCEDURES, TRIGGERS)
-- =========================================================================

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

-- View: Inventory Status
-- Shows current stock levels and the potential revenue of current inventory
DROP VIEW IF EXISTS `vw_inventory_status`;
CREATE VIEW `vw_inventory_status` AS
SELECT 
    product_id,
    name,
    quantity_in_stock,
    unit_price,
    (quantity_in_stock * unit_price) AS potential_revenue
FROM `products`;

-- Procedure: Place a new order
-- Automates order creation, order item creation, and stock deduction
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
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get product price
    SELECT unit_price INTO v_unit_price 
    FROM products 
    WHERE product_id = p_product_id;
    
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
END//

DELIMITER ;

-- Trigger: Restore stock if an order is cancelled
-- When an order status is updated to 3 (Cancelled), restore the product quantity
DELIMITER //

DROP TRIGGER IF EXISTS `trg_after_order_cancel`//
CREATE TRIGGER `trg_after_order_cancel`
AFTER UPDATE ON `orders`
FOR EACH ROW
BEGIN
    IF NEW.status = 3 AND OLD.status != 3 THEN
        -- Increase stock for each item in the cancelled order
        UPDATE products p
        JOIN order_items oi ON p.product_id = oi.product_id
        SET p.quantity_in_stock = p.quantity_in_stock + oi.quantity
        WHERE oi.order_id = NEW.order_id;
    END IF;
END//

DELIMITER ;
