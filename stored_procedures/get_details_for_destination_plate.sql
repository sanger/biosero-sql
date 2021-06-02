-- drop the stored procedure
DROP PROCEDURE IF EXISTS `biosero_uat`.`getDetailsForDestinationPlate`;

-- create the stored procedure
DELIMITER $$

-- Fetches the details for the specified destination plate barcode using the view
CREATE PROCEDURE `biosero_uat`.`getDetailsForDestinationPlate` (
  IN input_source_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
    SELECT slv.*
    FROM biosero_uat.sample_level_view slv
    WHERE destination_barcode = input_source_barcode
    ;

END$$

DELIMITER ;
