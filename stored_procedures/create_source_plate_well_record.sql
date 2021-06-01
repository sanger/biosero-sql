-- drop the stored procedure
DROP PROCEDURE IF EXISTS `biosero_uat`.`createSourcePlateWellRecord`;

-- create the stored procedure
DELIMITER $$

CREATE PROCEDURE `biosero_uat`.`createSourcePlateWellRecord` (
  IN input_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_sample_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_rna_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN input_lab_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
  INSERT INTO `biosero_uat`.`source_plate_wells` (
    `barcode`,
    `coordinate`,
    `sample_id`,
    `rna_id`,
    `lab_id`,
    `created_at`,
    `updated_at`
  )
  VALUES (
    input_barcode,
    input_coordinate,
    input_sample_id,
    input_rna_id,
    input_lab_id,
    now(),
    now()
  );
END$$

DELIMITER ;