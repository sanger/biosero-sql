-- drop the stored procedure
DROP PROCEDURE IF EXISTS `createEmptyDestinationPlateWellsRecord`;

-- create the stored procedure
DELIMITER $$

-- Creates an "empty" destination well row in the destination_plate_wells table, "empty" being
-- unpicked, without source_plate_well_id or control_plate_well_id to link it to source or control plates
CREATE PROCEDURE `createEmptyDestinationPlateWellsRecord` (
  IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_system_run_id INT,
  IN input_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci

)
BEGIN
  INSERT INTO `destination_plate_wells` (
    automation_system_run_id,
    barcode,
    coordinate,
    source_plate_well_id,
    control_plate_well_id,
    created_at,
    updated_at
  )
  VALUES (
    ( SELECT id FROM `automation_system_runs`
      WHERE automation_system_id = (
        SELECT id FROM `automation_systems`
          WHERE automation_system_name = input_automation_system_name
        )
      AND system_run_id = input_system_run_id
    ),
    input_barcode,
    input_coordinate,
    NULL,
    NULL,
    now(),
    now()
  );

END$$

DELIMITER ;
