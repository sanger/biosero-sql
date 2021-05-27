DELIMITER $$

CREATE PROCEDURE `biosero_uat`.`createRunRecord` (
  IN input_manufacturer VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_system_run_id INT,
  IN input_gbg_method_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_user_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
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
      WHERE automation_system_manufacturer = input_manufacturer
      AND automation_system_name = input_system_name
    ),
    input_system_run_id,
    input_gbg_method_name,
    input_user_id,
    now(),
    'started',
    now(),
    now()
  );

  INSERT INTO `biosero_uat`.`run_configurations` (
    automation_system_run_id,
    configuration_used,
    created_at,
    updated_at
  )
  VALUES (
    (
      SELECT id FROM `biosero_uat`.`automation_systems`
      WHERE automation_system_name = input_system_name
    ),
    input_configuration,
    now(),
    now()
  );
END$$

DELIMITER ;