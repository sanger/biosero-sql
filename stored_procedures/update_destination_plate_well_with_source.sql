-- DEPRECATED: USE CHERRYTRACK REPOSITORY
-- drop the stored procedure
DROP PROCEDURE IF EXISTS `updateDestinationPlateWellWithSource`;

-- create the stored procedure
DELIMITER $$

-- Updates a destination plate well row with a linked control well
CREATE PROCEDURE `updateDestinationPlateWellWithSource` (
  IN input_automation_system_run_id INT,
  IN input_destination_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_destination_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_source_plate_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_source_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN

  UPDATE `destination_plate_wells` dpw
  SET
    dpw.automation_system_run_id = input_automation_system_run_id,
    dpw.source_plate_well_id = (
      SELECT spw.id FROM `source_plate_wells` spw
      WHERE spw.barcode = input_source_plate_barcode
      AND spw.coordinate = input_source_coordinate
    ),
    dpw.updated_at = now()
  WHERE dpw.barcode = input_destination_barcode
  AND dpw.coordinate = input_destination_coordinate
  ;

END$$

DELIMITER ;