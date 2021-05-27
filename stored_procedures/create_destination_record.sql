-- drop the procedure
DROP PROCEDURE `biosero_uat`.`createDestinationPlateWellsRecord`;

-- create the procedure
DELIMITER $$

-- createDestinationPlateWellsRecord(automation_system_manufacturer, automation_system_name, barcode, coordinate, system_run_id)
-- to create "empty" record in destination_plate_wells tables
-- "empty" being without source_plate_well_id or control_plate_well_id
CREATE PROCEDURE `biosero_uat`.`createDestinationPlateWellsRecord` (
	IN input_automation_system_manufacturer VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
	IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
	IN input_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
	IN input_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
	IN input_system_run_id INT
)
BEGIN
  INSERT INTO `biosero_uat`.`destination_plate_wells` (
    automation_system_run_id,
    barcode,
    coordinate,
    source_plate_well_id,
    control_plate_well_id,
    created_at,
    updated_at
  )
  VALUES (
    ( SELECT id FROM `biosero_uat`.`automation_system_runs`
		WHERE automation_system_id = (
			SELECT id FROM `biosero_uat`.`automation_systems`
				WHERE automation_system_manufacturer = input_automation_system_manufacturer
				AND automation_system_name = input_automation_system_name
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


-- call the procedure
CALL `biosero_uat`.`createDestinationPlateWellsRecord`('biosero', 'CPA', 'abarcode', 'A1', 1);
