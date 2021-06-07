-- drop the stored procedure
DROP PROCEDURE IF EXISTS `getLastSystemRunId`;

-- create the stored procedure
DELIMITER $$

-- Fetches the last used system run id from the runs table
CREATE PROCEDURE `getLastSystemRunId` (
  OUT output_system_run_id int
)
BEGIN
    SELECT MAX(system_run_id)
    INTO output_system_run_id
    FROM automation_system_runs
    ;
END$$

DELIMITER ;
