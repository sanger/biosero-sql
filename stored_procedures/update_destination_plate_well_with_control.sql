-- DEPRECATED: USE CHERRYTRACK REPOSITORY
-- drop the stored procedure
DROP PROCEDURE IF EXISTS `updateDestinationPlateWellWithControl`;

-- create the stored procedure
DELIMITER $$

-- Updates a destination plate well row with a linked control well
CREATE PROCEDURE `updateDestinationPlateWellWithControl` (
  IN input_automation_system_run_id INT,
  IN input_destination_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_destination_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_control_plate_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_control_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN

  UPDATE `destination_plate_wells`
  SET
    control_plate_well_id = (
      SELECT id FROM `control_plate_wells` cpw
      WHERE cpw.automation_system_run_id = input_automation_system_run_id
      AND cpw.barcode = input_control_plate_barcode
      AND cpw.coordinate = input_control_coordinate
    ),
    updated_at = now()
  WHERE barcode = input_destination_barcode
  AND coordinate = input_destination_coordinate
  ;

END$$

DELIMITER ;