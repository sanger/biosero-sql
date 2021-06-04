-- drop the stored procedure
DROP PROCEDURE IF EXISTS `getConfigurationForSystem`;

-- create the stored procedure
DELIMITER $$

-- Fetches the configuration key value pairs for the specified system
CREATE PROCEDURE `getConfigurationForSystem` (
  IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
  SELECT conf.config_key, conf.config_value
    FROM `configurations` conf
  JOIN `automation_systems` asys
  ON conf.automation_system_id = asys.id
  WHERE asys.automation_system_name = input_automation_system_name
    ORDER BY conf.id ASC;

END$$

DELIMITER ;
