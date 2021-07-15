-- drop the stored procedure
DROP PROCEDURE IF EXISTS `doesSourcePlateExist`;

-- create the stored procedure
DELIMITER $$

-- Determines if a source plate exists
CREATE PROCEDURE `doesSourcePlateExist` (
  IN input_source_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
)
BEGIN
    SELECT EXISTS(
      SELECT id
      FROM `source_plate_wells`
      WHERE barcode = input_source_barcode
    );
END$$

DELIMITER ;
