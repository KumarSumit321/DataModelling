USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `customers`;
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

-- Insert dummy customers
INSERT INTO `customers` (`first_name`, `last_name`, `birth_date`, `phone`, `address`, `city`, `state`, `points`) VALUES
('John', 'Doe', '1990-05-14', '555-0101', '123 Elm St', 'Seattle', 'WA', 150),
('Jane', 'Smith', '1985-11-23', '555-0202', '456 Oak Ave', 'Portland', 'OR', 300),
('Bob', 'Johnson', '1978-02-09', '555-0303', '789 Pine Rd', 'San Francisco', 'CA', 50);

SET FOREIGN_KEY_CHECKS = 1;
