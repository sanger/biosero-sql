-- Sample Level View
CREATE VIEW `biosero_uat`.`sample_level_view` AS
    SELECT
        asys.automation_system_manufacturer,
        asys.automation_system_name,
        asysr.system_run_id,
        asysr.method,
        dpw.barcode AS destination_barcode,
        dpw.coordinate AS destination_coordinate,
        (CASE
            WHEN spw.barcode is not null THEN 'sample'
            WHEN cpw.barcode is not null THEN 'control'
            ELSE 'empty'
        END) AS well_content_type,
        spw.barcode AS source_barcode,
        spw.coordinate AS source_coordinate,
        spw.rna_id,
        spw.lab_id,
        spw.sample_id,
        cpw.barcode AS control_barcode,
        cpw.coordinate AS control_coordinate,
        cpw.control
    FROM
        `biosero_uat`.`automation_system_runs` asysr
            JOIN `biosero_uat`.`automation_systems` asys
                ON asysr.automation_system_id = asys.id
            INNER JOIN
        `biosero_uat`.`destination_plate_wells` dpw ON dpw.automation_system_run_id = asysr.id
            LEFT OUTER JOIN
        `biosero_uat`.`source_plate_wells` spw ON spw.id = dpw.source_plate_well_id
            LEFT OUTER JOIN
        `biosero_uat`.`control_plate_wells` cpw ON cpw.id = dpw.control_plate_well_id
;
