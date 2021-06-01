-- drop the stored procedure
DROP PROCEDURE IF EXISTS `biosero_uat`.`createControlPlateWellsRecord`;

-- create the stored procedure
DELIMITER $$

-- Creates a control well row in the control_plate_wells table, linked to the current
-- run record
CREATE PROCEDURE `biosero_uat`.`createControlPlateWellsRecord` (
  IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_system_run_id INT,
  IN input_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_control VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
  INSERT INTO `biosero_uat`.`control_plate_wells` (
    automation_system_run_id,
    barcode,
    coordinate,
    control,
    created_at,
    updated_at
  )
  VALUES (
    (
      SELECT id FROM `biosero_uat`.`automation_system_runs`
      WHERE automation_system_id = (
        SELECT id FROM `biosero_uat`.`automation_systems`
          WHERE automation_system_name = input_automation_system_name
        )
      AND system_run_id = input_system_run_id
    ),
    input_barcode,
    input_coordinate,
    input_control,
    now(),
    now()
  );

END$$

DELIMITER ;
