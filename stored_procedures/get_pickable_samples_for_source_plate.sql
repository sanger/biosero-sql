-- drop the stored procedure
DROP PROCEDURE IF EXISTS `getPickableSamplesForSourcePlate`;

-- create the stored procedure
DELIMITER $$

-- Fetches the pickable samples for the specified source plate barcode
CREATE PROCEDURE `getPickableSamplesForSourcePlate` (
  IN input_source_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
    SELECT
        dpw.id AS destination_id,
        spw.id,
        spw.barcode,
        spw.coordinate,
        spw.sample_id,
        spw.rna_id,
        spw.lab_id
    FROM
        `source_plate_wells` spw
    LEFT OUTER JOIN `destination_plate_wells` dpw
        ON spw.id = dpw.source_plate_well_id
    WHERE
        spw.barcode = input_source_barcode
        AND dpw.id IS NULL
    ORDER BY spw.id;

END$$

DELIMITER ;
