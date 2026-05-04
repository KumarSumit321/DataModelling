USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `quantity_in_stock` int(11) NOT NULL,
  `unit_price` decimal(4,2) NOT NULL,
  PRIMARY KEY (`product_id`)
);

-- Insert dummy products
INSERT INTO `products` (`name`, `quantity_in_stock`, `unit_price`) VALUES
('Foam Roller', 50, 25.99),
('Yoga Mat', 100, 15.50),
('Dumbbells 10kg', 30, 45.00),
('Resistance Bands', 200, 10.99),
('Treadmill', 5, 899.99);

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

SET FOREIGN_KEY_CHECKS = 1;
