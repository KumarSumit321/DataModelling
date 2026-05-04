-- Different sql for different tables
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
  `state_id` char(2) NOT NULL,
  `points` int(11) NOT NULL DEFAULT '0',
  `tier` varchar(10) NOT NULL DEFAULT 'Standard',
  PRIMARY KEY (`customer_id`),
  KEY `fk_customers_states_idx` (`state_id`),
  CONSTRAINT `fk_customers_states` FOREIGN KEY (`state_id`) REFERENCES `states` (`state_id`) ON UPDATE CASCADE
);

INSERT INTO `customers` (`first_name`, `last_name`, `birth_date`, `phone`, `address`, `city`, `state_id`, `points`) VALUES
('John', 'Doe', '1990-05-14', '555-0101', '123 Elm St', 'Seattle', 'WA', 150),
('Jane', 'Smith', '1985-11-23', '555-0202', '456 Oak Ave', 'Portland', 'OR', 300),
('Bob', 'Johnson', '1978-02-09', '555-0303', '789 Pine Rd', 'San Francisco', 'CA', 50);

-- Trigger: Update Customer Tier
-- Upgrades tier based on points
DELIMITER //
DROP TRIGGER IF EXISTS `trg_update_customer_tier`//
CREATE TRIGGER `trg_update_customer_tier`
BEFORE UPDATE ON `customers`
FOR EACH ROW
BEGIN
    IF NEW.points >= 1000 THEN
        SET NEW.tier = 'VIP';
    ELSEIF NEW.points >= 500 THEN
        SET NEW.tier = 'Gold';
    ELSEIF NEW.points >= 200 THEN
        SET NEW.tier = 'Silver';
    ELSE
        SET NEW.tier = 'Standard';
    END IF;
END//
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;
