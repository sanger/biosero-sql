-- drop the stored procedure
DROP PROCEDURE IF EXISTS `updateRunState`;

-- create the stored procedure
DELIMITER $$

-- Updates a destination plate well row with a linked control well
CREATE PROCEDURE `updateRunState` (
  IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_system_run_id INT,
  IN input_state ENUM('started','completed','aborted')
)
BEGIN

  UPDATE `automation_system_runs`
  SET
    end_time = CASE input_state
                 WHEN 'completed' THEN now()
                 WHEN 'aborted' THEN now()
                 ELSE end_time
               END,
    state = input_state,
    updated_at = now()
  WHERE automation_system_id = (
    SELECT id FROM `automation_systems`
      WHERE automation_system_name = input_automation_system_name
    )
  AND system_run_id = input_system_run_id
  ;

END$$

DELIMITER ;