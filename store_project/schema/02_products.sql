-- Different sql for different tables
USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `quantity_in_stock` int(11) NOT NULL,
  `unit_price` decimal(4,2) NOT NULL,
  PRIMARY KEY (`product_id`),
  KEY `fk_products_categories_idx` (`category_id`),
  CONSTRAINT `fk_products_categories` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON UPDATE CASCADE
);

INSERT INTO `products` (`category_id`, `name`, `quantity_in_stock`, `unit_price`) VALUES
(1, 'Foam Roller', 50, 25.99),
(2, 'Yoga Mat', 100, 15.50),
(1, 'Dumbbells 10kg', 30, 45.00),
(2, 'Resistance Bands', 200, 10.99),
(3, 'Treadmill', 5, 899.99);

-- Create a table for inventory alerts to log low stock
DROP TABLE IF EXISTS `inventory_alerts`;
CREATE TABLE `inventory_alerts` (
  `alert_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `alert_message` varchar(255) NOT NULL,
  `alert_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`alert_id`)
);

-- Trigger: Low Stock Alert
-- If stock drops below 10, log an alert.
DELIMITER //
DROP TRIGGER IF EXISTS `trg_low_stock_alert`//
CREATE TRIGGER `trg_low_stock_alert`
AFTER UPDATE ON `products`
FOR EACH ROW
BEGIN
    IF NEW.quantity_in_stock < 10 AND OLD.quantity_in_stock >= 10 THEN
        INSERT INTO inventory_alerts (product_id, alert_message)
        VALUES (NEW.product_id, CONCAT('Stock for product ', NEW.name, ' has dropped below 10 units!'));
    END IF;
END//
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;
