-- DEPRECATED: USE CHERRYTRACK REPOSITORY
-- drop the stored procedure
DROP PROCEDURE IF EXISTS `createRunEventRecord`;

-- create the stored procedure
DELIMITER $$

CREATE PROCEDURE `createRunEventRecord` (
  IN input_automation_system_run_id INT,
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
    input_automation_system_run_id,
    input_type,
    input_event,
    now(),
    now()
  );
END$$

DELIMITER ;