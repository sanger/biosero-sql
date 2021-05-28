-- drop the stored procedure
DROP PROCEDURE IF EXISTS `biosero_uat`.`getConfigurationForSystem`;

-- create the stored procedure
DELIMITER $$

-- Fetches the configuration key value pairs for the specified system
CREATE PROCEDURE `biosero_uat`.`getConfigurationForSystem` (
  IN input_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
  SELECT conf.config_key, conf.config_value
    FROM `biosero_uat`.`configurations` conf
  JOIN `biosero_uat`.`automation_systems` asys
  ON conf.automation_system_id = asys.id
  WHERE asys.automation_system_name = input_system_name
    ORDER BY conf.id ASC;

END$$

DELIMITER ;
