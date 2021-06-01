-- drop the stored procedure
DROP PROCEDURE IF EXISTS `biosero_uat`.`createRunRecord`;

-- create the stored procedure
DELIMITER $$

-- Creates a run record row at the start of a workcell run on the automation_system_runs table
-- and a linked row on the configurations table
CREATE PROCEDURE `biosero_uat`.`createRunRecord` (
  IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_system_run_id INT,
  IN input_gbg_method_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_user_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
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

  SET @automationSystemRunId = '';
  SET @input_configuration = (
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


  INSERT INTO `biosero_uat`.`automation_system_runs` (
    automation_system_id,
    system_run_id,
    method,
    user_id,
    start_time,
    state,
    created_at,
    updated_at
  )
  VALUES (
    (
      SELECT id FROM `biosero_uat`.`automation_systems`
      WHERE automation_system_name = input_automation_system_name
    ),
    input_system_run_id,
    input_gbg_method_name,
    input_user_id,
    now(),
    'started',
    now(),
    now()
  );

  SELECT LAST_INSERT_ID() INTO @automationSystemRunId;

  INSERT INTO `biosero_uat`.`run_configurations` (
    automation_system_run_id,
    configuration_used,
    created_at,
    updated_at
  )
  VALUES (
    @automationSystemRunId,
    @input_configuration,
    now(),
    now()
  );

  -- Finish the transaction
  COMMIT;
END$$

DELIMITER ;
