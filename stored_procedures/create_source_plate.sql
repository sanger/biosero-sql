DELIMITER $$

CREATE PROCEDURE `biosero_uat`.`createSourcePlateWellRecord` (
  IN barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN coordinate VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN sample_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN rna_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  IN lab_id VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
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
  VALUES (barcode,
    coordinate,
    sample_id,
    rna_id,
    lab_id,
    now(),
    now()
  );
END$$

DELIMITER ;