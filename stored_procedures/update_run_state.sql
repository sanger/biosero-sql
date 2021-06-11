-- drop the stored procedure
DROP PROCEDURE IF EXISTS `updateRunState`;

-- create the stored procedure
DELIMITER $$

-- Updates a destination plate well row with a linked control well
CREATE PROCEDURE `updateRunState` (
  IN input_automation_system_run_id INT,
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
  WHERE id = input_automation_system_run_id
  ;

END$$

DELIMITER ;