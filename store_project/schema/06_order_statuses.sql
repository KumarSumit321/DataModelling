USE `store_schema`;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `order_statuses`;
CREATE TABLE `order_statuses` (
  `order_status_id` tinyint(4) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`order_status_id`)
);

INSERT INTO `order_statuses` (`order_status_id`, `name`) VALUES
(1, 'Processed'),
(2, 'Shipped'),
(3, 'Cancelled'),
(4, 'Delivered');

-- Procedure: Safely add new status
DELIMITER //
DROP PROCEDURE IF EXISTS `sp_add_new_status`//
CREATE PROCEDURE `sp_add_new_status`(
    IN p_status_id TINYINT,
    IN p_name VARCHAR(50)
)
BEGIN
    INSERT IGNORE INTO order_statuses (order_status_id, name)
    VALUES (p_status_id, p_name);
END//
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;
