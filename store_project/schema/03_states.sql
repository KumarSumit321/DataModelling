-- Different sql for different tables
USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `states`;
CREATE TABLE `states` (
  `state_id` char(2) NOT NULL,
  `name` varchar(50) NOT NULL,
  `tax_rate` decimal(4,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`state_id`)
);

INSERT INTO `states` (`state_id`, `name`, `tax_rate`) VALUES
('WA', 'Washington', 6.50),
('OR', 'Oregon', 0.00),
('CA', 'California', 7.25);

-- Procedure: Update state tax easily
DELIMITER //
DROP PROCEDURE IF EXISTS `sp_update_state_tax`//
CREATE PROCEDURE `sp_update_state_tax`(
    IN p_state_id CHAR(2),
    IN p_new_tax_rate DECIMAL(4,2)
)
BEGIN
    UPDATE states 
    SET tax_rate = p_new_tax_rate 
    WHERE state_id = p_state_id;
END//
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;
