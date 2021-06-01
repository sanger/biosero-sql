-- drop the stored procedure
DROP PROCEDURE IF EXISTS `biosero_uat`.`updateDestinationPlateWellWithSource`;

-- create the stored procedure
DELIMITER $$

-- Updates a destination plate well row with a linked control well
CREATE PROCEDURE `biosero_uat`.`updateDestinationPlateWellWithSource` (
  IN input_automation_system_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_system_run_id INT,
  IN input_destination_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_destination_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_source_plate_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_source_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN

  UPDATE `biosero_uat`.`destination_plate_wells` dpw
  SET
    dpw.automation_system_run_id = (
      SELECT asr.id FROM `biosero_uat`.`automation_system_runs` asr
      WHERE asr.automation_system_id = (
        SELECT asys.id FROM `biosero_uat`.`automation_systems` asys
          WHERE asys.automation_system_name = input_automation_system_name
        )
      AND asr.system_run_id = input_system_run_id
    ),
    dpw.source_plate_well_id = (
      SELECT spw.id FROM `biosero_uat`.`source_plate_wells` spw
      WHERE spw.barcode = input_source_plate_barcode
      AND spw.coordinate = input_source_coordinate
    ),
    dpw.updated_at = now()
  WHERE dpw.barcode = input_destination_barcode
  AND dpw.coordinate = input_destination_coordinate
  ;

END$$

DELIMITER ;