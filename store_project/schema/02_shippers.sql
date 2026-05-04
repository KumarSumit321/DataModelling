USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `shippers`;
CREATE TABLE `shippers` (
  `shipper_id` smallint(6) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`shipper_id`)
);

-- Insert dummy shippers
INSERT INTO `shippers` (`name`) VALUES
('FastTrack Logistics'),
('Global Freight'),
('Speedy Delivery');

SET FOREIGN_KEY_CHECKS = 1;
