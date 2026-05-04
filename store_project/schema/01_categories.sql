-- Different sql for different tables
USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`category_id`)
);

INSERT INTO `categories` (`name`) VALUES
('Fitness Equipment'),
('Accessories'),
('Electronics');

SET FOREIGN_KEY_CHECKS = 1;
