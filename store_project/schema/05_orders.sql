USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `orders`;
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

-- Insert dummy orders
INSERT INTO `orders` (`customer_id`, `order_date`, `status`, `comments`, `shipped_date`, `shipper_id`) VALUES
(1, '2023-10-01', 4, 'Leave at front door', '2023-10-03', 1),
(2, '2023-10-05', 2, NULL, '2023-10-06', 2),
(3, '2023-10-10', 1, 'Please rush', NULL, NULL);

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

SET FOREIGN_KEY_CHECKS = 1;
