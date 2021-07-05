-- DEPRECATED: USE CHERRYTRACK REPOSITORY
-- drop the stored procedure
DROP PROCEDURE IF EXISTS `createRunRecord`;

-- create the stored procedure
DELIMITER $$

-- Creates a run record row at the start of a workcell run on the automation_system_runs table
-- and a linked row on the configurations table
CREATE PROCEDURE `createRunRecord` (
  IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_gbg_method_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_user_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  OUT output_automation_system_run_id INT
)
BEGIN
  -- Rollback if there is any error
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      SHOW ERRORS;
      ROLLBACK;
    END;

  -- Start of any writing operations
  START TRANSACTION;

  SET @configuration_for_system = (
    SELECT JSON_ARRAYAGG(
      JSON_OBJECT(
        'config_key', config_key,
        'config_value', config_value
      )
    )
    FROM configurations
    INNER JOIN automation_systems
      ON automation_systems.id = configurations.automation_system_id
    WHERE automation_systems.automation_system_name = input_automation_system_name
  );


  INSERT INTO `automation_system_runs` (
    automation_system_id,
    method,
    user_id,
    start_time,
    state,
    created_at,
    updated_at
  )
  VALUES (
    (
      SELECT id FROM `automation_systems`
      WHERE automation_system_name = input_automation_system_name
    ),
    input_gbg_method_name,
    input_user_id,
    now(),
    'started',
    now(),
    now()
  );

  SELECT LAST_INSERT_ID() INTO output_automation_system_run_id;

  INSERT INTO `run_configurations` (
    automation_system_run_id,
    configuration_used,
    created_at,
    updated_at
  )
  VALUES (
    output_automation_system_run_id,
    @configuration_for_system,
    now(),
    now()
  );

  -- Finish the transaction
  COMMIT;
END$$

DELIMITER ;
