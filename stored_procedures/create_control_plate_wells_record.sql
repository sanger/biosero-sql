-- drop the stored procedure
DROP PROCEDURE IF EXISTS `createControlPlateWellsRecord`;

-- create the stored procedure
DELIMITER $$

-- Creates a control well row in the control_plate_wells table, linked to the current
-- run record
CREATE PROCEDURE `createControlPlateWellsRecord` (
  IN input_automation_system_run_id INT,
  IN input_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_control VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
  INSERT INTO `control_plate_wells` (
    automation_system_run_id,
    barcode,
    coordinate,
    control,
    created_at,
    updated_at
  )
  VALUES (
    input_automation_system_run_id,
    input_barcode,
    input_coordinate,
    input_control,
    now(),
    now()
  );

END$$

DELIMITER ;
