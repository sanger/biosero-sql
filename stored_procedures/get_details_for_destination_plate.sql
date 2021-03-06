-- DEPRECATED: USE CHERRYTRACK REPOSITORY
-- drop the stored procedure
DROP PROCEDURE IF EXISTS `getDetailsForDestinationPlate`;

-- create the stored procedure
DELIMITER $$

-- Fetches the details for the specified destination plate barcode using the view
CREATE PROCEDURE `getDetailsForDestinationPlate` (
  IN input_destination_barcode VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
)
BEGIN
    SELECT slv.*
    FROM sample_level_view slv
    WHERE destination_barcode = input_destination_barcode
    ;

END$$

DELIMITER ;
