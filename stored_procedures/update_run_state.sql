-- drop the stored procedure
DROP PROCEDURE IF EXISTS `biosero_uat`.`updateRunState`;

-- create the stored procedure
DELIMITER $$

-- Updates a destination plate well row with a linked control well
-- Q. Do we want to pass in end_time as a parameter?
CREATE PROCEDURE `biosero_uat`.`updateRunState` (
  IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_system_run_id INT,
  IN input_state VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN

  UPDATE `biosero_uat`.`automation_system_runs`
  SET
    end_time = now(),
    state = input_state,
    updated_at = now()
  WHERE automation_system_id = (
    SELECT id FROM `biosero_uat`.`automation_systems`
      WHERE automation_system_name = input_automation_system_name
    )
  AND system_run_id = input_system_run_id
  ;

END$$

DELIMITER ;