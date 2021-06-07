-- drop the stored procedure
DROP PROCEDURE IF EXISTS `createRunEventRecord`;

-- create the stored procedure
DELIMITER $$

CREATE PROCEDURE `createRunEventRecord` (
  IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_system_run_id INT,
  IN input_type ENUM('info','warning','error'),
  IN input_event JSON
)
BEGIN
  INSERT INTO `run_events` (
    automation_system_run_id,
    type,
    event,
    created_at,
    updated_at
  )
  VALUES (
    (
      SELECT id FROM `automation_system_runs`
      WHERE automation_system_id = (
        SELECT id FROM `automation_systems`
          WHERE automation_system_name = input_automation_system_name
      )
      AND system_run_id = input_system_run_id
    ),
    input_type,
    input_event,
    now(),
    now()
  );
END$$

DELIMITER ;