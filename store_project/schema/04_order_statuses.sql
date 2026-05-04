USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `order_statuses`;
CREATE TABLE `order_statuses` (
  `order_status_id` tinyint(4) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`order_status_id`)
);

-- Insert dummy order statuses
INSERT INTO `order_statuses` (`order_status_id`, `name`) VALUES
(1, 'Processed'),
(2, 'Shipped'),
(3, 'Cancelled'),
(4, 'Delivered');

SET FOREIGN_KEY_CHECKS = 1;
