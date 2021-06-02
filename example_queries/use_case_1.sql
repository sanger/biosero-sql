-- This script assumes that the following scripts have already been run:
--   automation_systems_insert_example.sql
--   configurations_insert_example.sql

-- select configuration for the workcell
SELECT conf.id, asys.automation_system_name, conf.config_key, conf.config_value, conf.description, conf.created_at
FROM `biosero_uat`.`configurations` conf
JOIN `biosero_uat`.`automation_systems` asys
  ON conf.automation_system_id = asys.id
WHERE asys.automation_system_name = 'CPA' ORDER BY conf.id ASC;

-- insert a new run row at the start of the run, with state 'started'
INSERT INTO `biosero_uat`.`automation_system_runs` (
  automation_system_id,
  system_run_id,
  method,
  user_id,
  start_time,
  state,
  created_at,
  updated_at
)
VALUES (
  (
    SELECT id FROM `biosero_uat`.`automation_systems`
    WHERE automation_system_name = 'CPA'
  ),
  '1',
  'cp v1',
  'ab12',
  now(),
  'started',
  now(),
  now()
);

-- insert a row to record the configurations used for this run
INSERT INTO `biosero_uat`.`run_configurations` (
  automation_system_run_id,
  configuration_used,
  created_at,
  updated_at
)
VALUES (
  (SELECT id FROM `biosero_uat`.`automation_system_runs`
  WHERE automation_system_id = (
    SELECT id FROM `biosero_uat`.`automation_systems`
        WHERE automation_system_name = 'CPA'
  )
    AND system_run_id = 1
  ),
  '{"configuration":{"CPA":{"version":"1","change_description":"moved the positive control","change_user_id":"ab1","control_coordinate_positive":"A1","control_coordinate_negative":"H12","control_excluded_destination_wells":"B5,B6","bv_barcode_prefixes_control":"DN, DM","bv_barcode_prefixes_destination":"HT, HS","bv_deck_barcode_control":"DECKC123","bv_deck_barcode_destination":"DECKP123"}}}',
  now(),
  now()
);

-- check the destination plate does not already exist
SELECT id FROM `biosero_uat`.`destination_plate_wells`
WHERE barcode = 'HT_000001';

-- select the id of the run
SET @a_system_run_id := (
  SELECT id
  FROM `biosero_uat`.`automation_system_runs`
  WHERE automation_system_id = (
  SELECT id FROM `biosero_uat`.`automation_systems`
        WHERE automation_system_name = 'CPA'
  )
  AND system_run_id = 1
);

-- create the empty destination plate with 96 wells
INSERT INTO `biosero_uat`.`destination_plate_wells` (
  automation_system_run_id,
  barcode,
  coordinate,
  created_at,
  updated_at
)
VALUES
(@a_system_run_id, 'HT_000001', 'A1', now(), now()),
(@a_system_run_id, 'HT_000001', 'A2', now(), now()),
(@a_system_run_id, 'HT_000001', 'A3', now(), now()),
(@a_system_run_id, 'HT_000001', 'A4', now(), now()),
(@a_system_run_id, 'HT_000001', 'A5', now(), now()),
(@a_system_run_id, 'HT_000001', 'A6', now(), now()),
(@a_system_run_id, 'HT_000001', 'A7', now(), now()),
(@a_system_run_id, 'HT_000001', 'A8', now(), now()),
(@a_system_run_id, 'HT_000001', 'A9', now(), now()),
(@a_system_run_id, 'HT_000001', 'A10', now(), now()),
(@a_system_run_id, 'HT_000001', 'A11', now(), now()),
(@a_system_run_id, 'HT_000001', 'A12', now(), now()),
(@a_system_run_id, 'HT_000001', 'B1', now(), now()),
(@a_system_run_id, 'HT_000001', 'B2', now(), now()),
(@a_system_run_id, 'HT_000001', 'B3', now(), now()),
(@a_system_run_id, 'HT_000001', 'B4', now(), now()),
(@a_system_run_id, 'HT_000001', 'B5', now(), now()),
(@a_system_run_id, 'HT_000001', 'B6', now(), now()),
(@a_system_run_id, 'HT_000001', 'B7', now(), now()),
(@a_system_run_id, 'HT_000001', 'B8', now(), now()),
(@a_system_run_id, 'HT_000001', 'B9', now(), now()),
(@a_system_run_id, 'HT_000001', 'B10', now(), now()),
(@a_system_run_id, 'HT_000001', 'B11', now(), now()),
(@a_system_run_id, 'HT_000001', 'B12', now(), now()),
(@a_system_run_id, 'HT_000001', 'C1', now(), now()),
(@a_system_run_id, 'HT_000001', 'C2', now(), now()),
(@a_system_run_id, 'HT_000001', 'C3', now(), now()),
(@a_system_run_id, 'HT_000001', 'C4', now(), now()),
(@a_system_run_id, 'HT_000001', 'C5', now(), now()),
(@a_system_run_id, 'HT_000001', 'C6', now(), now()),
(@a_system_run_id, 'HT_000001', 'C7', now(), now()),
(@a_system_run_id, 'HT_000001', 'C8', now(), now()),
(@a_system_run_id, 'HT_000001', 'C9', now(), now()),
(@a_system_run_id, 'HT_000001', 'C10', now(), now()),
(@a_system_run_id, 'HT_000001', 'C11', now(), now()),
(@a_system_run_id, 'HT_000001', 'C12', now(), now()),
(@a_system_run_id, 'HT_000001', 'D1', now(), now()),
(@a_system_run_id, 'HT_000001', 'D2', now(), now()),
(@a_system_run_id, 'HT_000001', 'D3', now(), now()),
(@a_system_run_id, 'HT_000001', 'D4', now(), now()),
(@a_system_run_id, 'HT_000001', 'D5', now(), now()),
(@a_system_run_id, 'HT_000001', 'D6', now(), now()),
(@a_system_run_id, 'HT_000001', 'D7', now(), now()),
(@a_system_run_id, 'HT_000001', 'D8', now(), now()),
(@a_system_run_id, 'HT_000001', 'D9', now(), now()),
(@a_system_run_id, 'HT_000001', 'D10', now(), now()),
(@a_system_run_id, 'HT_000001', 'D11', now(), now()),
(@a_system_run_id, 'HT_000001', 'D12', now(), now()),
(@a_system_run_id, 'HT_000001', 'E1', now(), now()),
(@a_system_run_id, 'HT_000001', 'E2', now(), now()),
(@a_system_run_id, 'HT_000001', 'E3', now(), now()),
(@a_system_run_id, 'HT_000001', 'E4', now(), now()),
(@a_system_run_id, 'HT_000001', 'E5', now(), now()),
(@a_system_run_id, 'HT_000001', 'E6', now(), now()),
(@a_system_run_id, 'HT_000001', 'E7', now(), now()),
(@a_system_run_id, 'HT_000001', 'E8', now(), now()),
(@a_system_run_id, 'HT_000001', 'E9', now(), now()),
(@a_system_run_id, 'HT_000001', 'E10', now(), now()),
(@a_system_run_id, 'HT_000001', 'E11', now(), now()),
(@a_system_run_id, 'HT_000001', 'E12', now(), now()),
(@a_system_run_id, 'HT_000001', 'F1', now(), now()),
(@a_system_run_id, 'HT_000001', 'F2', now(), now()),
(@a_system_run_id, 'HT_000001', 'F3', now(), now()),
(@a_system_run_id, 'HT_000001', 'F4', now(), now()),
(@a_system_run_id, 'HT_000001', 'F5', now(), now()),
(@a_system_run_id, 'HT_000001', 'F6', now(), now()),
(@a_system_run_id, 'HT_000001', 'F7', now(), now()),
(@a_system_run_id, 'HT_000001', 'F8', now(), now()),
(@a_system_run_id, 'HT_000001', 'F9', now(), now()),
(@a_system_run_id, 'HT_000001', 'F10', now(), now()),
(@a_system_run_id, 'HT_000001', 'F11', now(), now()),
(@a_system_run_id, 'HT_000001', 'F12', now(), now()),
(@a_system_run_id, 'HT_000001', 'G1', now(), now()),
(@a_system_run_id, 'HT_000001', 'G2', now(), now()),
(@a_system_run_id, 'HT_000001', 'G3', now(), now()),
(@a_system_run_id, 'HT_000001', 'G4', now(), now()),
(@a_system_run_id, 'HT_000001', 'G5', now(), now()),
(@a_system_run_id, 'HT_000001', 'G6', now(), now()),
(@a_system_run_id, 'HT_000001', 'G7', now(), now()),
(@a_system_run_id, 'HT_000001', 'G8', now(), now()),
(@a_system_run_id, 'HT_000001', 'G9', now(), now()),
(@a_system_run_id, 'HT_000001', 'G10', now(), now()),
(@a_system_run_id, 'HT_000001', 'G11', now(), now()),
(@a_system_run_id, 'HT_000001', 'G12', now(), now()),
(@a_system_run_id, 'HT_000001', 'H1', now(), now()),
(@a_system_run_id, 'HT_000001', 'H2', now(), now()),
(@a_system_run_id, 'HT_000001', 'H3', now(), now()),
(@a_system_run_id, 'HT_000001', 'H4', now(), now()),
(@a_system_run_id, 'HT_000001', 'H5', now(), now()),
(@a_system_run_id, 'HT_000001', 'H6', now(), now()),
(@a_system_run_id, 'HT_000001', 'H7', now(), now()),
(@a_system_run_id, 'HT_000001', 'H8', now(), now()),
(@a_system_run_id, 'HT_000001', 'H9', now(), now()),
(@a_system_run_id, 'HT_000001', 'H10', now(), now()),
(@a_system_run_id, 'HT_000001', 'H11', now(), now()),
(@a_system_run_id, 'HT_000001', 'H12', now(), now())
;

-- insert the positive control well into control_plate_wells table
-- using configuration key value pair to determine positive control location
INSERT INTO `biosero_uat`.`control_plate_wells` (
  automation_system_run_id,
  barcode,
  coordinate,
  control,
  created_at,
  updated_at
)
VALUES
(@a_system_run_id, 'Control01', 'A1', 'positive', now(), now())
;

-- for positive control, insert well into random destination location
UPDATE `biosero_uat`.`destination_plate_wells`
SET
  control_plate_well_id = (
    SELECT id FROM `biosero_uat`.`control_plate_wells` cpw
    WHERE cpw.barcode = 'Control01'
    AND cpw.coordinate = 'A1'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B3'
;

-- insert negative control well into control_plate_wells table
-- using configuration key value pair to determine negative control location
INSERT INTO `biosero_uat`.`control_plate_wells` (
  automation_system_run_id,
  barcode,
  coordinate,
  control,
  created_at,
  updated_at
)
VALUES
(@a_system_run_id, 'Control01', 'H12', 'positive', now(), now())
;

-- for negative control, insert well into random destination location
UPDATE `biosero_uat`.`destination_plate_wells`
SET
  control_plate_well_id = (
    SELECT id FROM `biosero_uat`.`control_plate_wells` spw
    WHERE spw.barcode = 'Control01'
    AND spw.coordinate = 'H12'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H2'
;

-- check source does not already exist (it should not in this use case)
SELECT id FROM `biosero_uat`.`source_plate_wells`
WHERE barcode = 'Source01';

-- insert the new source plate after LIMS lookup, with 1 pickable well in D1
INSERT INTO `biosero_uat`.`source_plate_wells` (
  barcode,
  coordinate,
  sample_id,
  rna_id,
  lab_id,
  created_at,
  updated_at
)
VALUES
('Source01', 'D1', 'uuid-s1-0037', 'rna-s1-0037_D1', 'CB', now(), now())
;

-- pick the well, then update destination A1 with pick from source 1
UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source01'
    AND spw.coordinate = 'D1'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A1'
;

-- check the second source plate does not already exist
SELECT id
FROM `biosero_uat`.`source_plate_wells`
WHERE barcode = 'Source02';

-- insert the new source plate after lookup, with 93 pickable wells
INSERT INTO `biosero_uat`.`source_plate_wells` (
    barcode,
    coordinate,
    sample_id,
    rna_id,
    lab_id,
    created_at,
    updated_at
)
VALUES
    ('Source02', 'A1', 'uuid-s2-0001', 'rna-s2-0001_A1', 'CB', now(), now()),
    ('Source02', 'A2', 'uuid-s2-0002', 'rna-s2-0002_A2', 'CB', now(), now()),
    ('Source02', 'A3', 'uuid-s2-0003', 'rna-s2-0003_A3', 'CB', now(), now()),
    ('Source02', 'A4', 'uuid-s2-0004', 'rna-s2-0004_A4', 'CB', now(), now()),
    ('Source02', 'A5', 'uuid-s2-0005', 'rna-s2-0005_A5', 'CB', now(), now()),
    ('Source02', 'A6', 'uuid-s2-0006', 'rna-s2-0006_A6', 'CB', now(), now()),
    ('Source02', 'A7', 'uuid-s2-0007', 'rna-s2-0007_A7', 'CB', now(), now()),
    ('Source02', 'A8', 'uuid-s2-0008', 'rna-s2-0008_A8', 'CB', now(), now()),
    ('Source02', 'A9', 'uuid-s2-0009', 'rna-s2-0009_A9', 'CB', now(), now()),
    ('Source02', 'A10', 'uuid-s2-0010', 'rna-s2-0010_A10', 'CB', now(), now()),
    ('Source02', 'A11', 'uuid-s2-0011', 'rna-s2-0011_A11', 'CB', now(), now()),
    ('Source02', 'A12', 'uuid-s2-0012', 'rna-s2-0012_A12', 'CB', now(), now()),

    ('Source02', 'B2', 'uuid-s2-0014', 'rna-s2-0014_B2', 'CB', now(), now()),
    ('Source02', 'B3', 'uuid-s2-0015', 'rna-s2-0015_B3', 'CB', now(), now()),
    ('Source02', 'B4', 'uuid-s2-0016', 'rna-s2-0016_B4', 'CB', now(), now()),
    ('Source02', 'B5', 'uuid-s2-0017', 'rna-s2-0017_B5', 'CB', now(), now()),
    ('Source02', 'B6', 'uuid-s2-0018', 'rna-s2-0018_B6', 'CB', now(), now()),
    ('Source02', 'B7', 'uuid-s2-0019', 'rna-s2-0019_B7', 'CB', now(), now()),
    ('Source02', 'B8', 'uuid-s2-0020', 'rna-s2-0020_B8', 'CB', now(), now()),
    ('Source02', 'B9', 'uuid-s2-0021', 'rna-s2-0021_B9', 'CB', now(), now()),
    ('Source02', 'B10', 'uuid-s2-0022', 'rna-s2-0022_B10', 'CB', now(), now()),
    ('Source02', 'B11', 'uuid-s2-0023', 'rna-s2-0023_B11', 'CB', now(), now()),
    ('Source02', 'B12', 'uuid-s2-0024', 'rna-s2-0024_B12', 'CB', now(), now()),

    ('Source02', 'C2', 'uuid-s2-0026', 'rna-s2-0026_C2', 'CB', now(), now()),
    ('Source02', 'C3', 'uuid-s2-0027', 'rna-s2-0027_C3', 'CB', now(), now()),
    ('Source02', 'C4', 'uuid-s2-0028', 'rna-s2-0028_C4', 'CB', now(), now()),
    ('Source02', 'C5', 'uuid-s2-0029', 'rna-s2-0029_C5', 'CB', now(), now()),
    ('Source02', 'C6', 'uuid-s2-0030', 'rna-s2-0030_C6', 'CB', now(), now()),
    ('Source02', 'C7', 'uuid-s2-0031', 'rna-s2-0031_C7', 'CB', now(), now()),
    ('Source02', 'C8', 'uuid-s2-0032', 'rna-s2-0032_C8', 'CB', now(), now()),
    ('Source02', 'C9', 'uuid-s2-0033', 'rna-s2-0033_C9', 'CB', now(), now()),
    ('Source02', 'C10', 'uuid-s2-0034', 'rna-s2-0034_C10', 'CB', now(), now()),
    ('Source02', 'C11', 'uuid-s2-0035', 'rna-s2-0035_C11', 'CB', now(), now()),
    ('Source02', 'C12', 'uuid-s2-0036', 'rna-s2-0036_C12', 'CB', now(), now()),

    ('Source02', 'D2', 'uuid-s2-0038', 'rna-s2-0038_D2', 'CB', now(), now()),
    ('Source02', 'D3', 'uuid-s2-0039', 'rna-s2-0039_D3', 'CB', now(), now()),
    ('Source02', 'D4', 'uuid-s2-0040', 'rna-s2-0040_D4', 'CB', now(), now()),
    ('Source02', 'D5', 'uuid-s2-0041', 'rna-s2-0041_D5', 'CB', now(), now()),
    ('Source02', 'D6', 'uuid-s2-0042', 'rna-s2-0042_D6', 'CB', now(), now()),
    ('Source02', 'D7', 'uuid-s2-0043', 'rna-s2-0043_D7', 'CB', now(), now()),
    ('Source02', 'D8', 'uuid-s2-0044', 'rna-s2-0044_D8', 'CB', now(), now()),
    ('Source02', 'D9', 'uuid-s2-0045', 'rna-s2-0045_D9', 'CB', now(), now()),
    ('Source02', 'D10', 'uuid-s2-0046', 'rna-s2-0046_D10', 'CB', now(), now()),
    ('Source02', 'D11', 'uuid-s2-0047', 'rna-s2-0047_D11', 'CB', now(), now()),
    ('Source02', 'D12', 'uuid-s2-0048', 'rna-s2-0048_D12', 'CB', now(), now()),

    ('Source02', 'E1', 'uuid-s2-0049', 'rna-s2-0049_E1', 'CB', now(), now()),
    ('Source02', 'E2', 'uuid-s2-0050', 'rna-s2-0050_E2', 'CB', now(), now()),
    ('Source02', 'E3', 'uuid-s2-0051', 'rna-s2-0051_E3', 'CB', now(), now()),
    ('Source02', 'E4', 'uuid-s2-0052', 'rna-s2-0052_E4', 'CB', now(), now()),
    ('Source02', 'E5', 'uuid-s2-0053', 'rna-s2-0053_E5', 'CB', now(), now()),
    ('Source02', 'E6', 'uuid-s2-0054', 'rna-s2-0054_E6', 'CB', now(), now()),
    ('Source02', 'E7', 'uuid-s2-0055', 'rna-s2-0055_E7', 'CB', now(), now()),
    ('Source02', 'E8', 'uuid-s2-0056', 'rna-s2-0056_E8', 'CB', now(), now()),
    ('Source02', 'E9', 'uuid-s2-0057', 'rna-s2-0057_E9', 'CB', now(), now()),
    ('Source02', 'E10', 'uuid-s2-0058', 'rna-s2-0058_E10', 'CB', now(), now()),
    ('Source02', 'E11', 'uuid-s2-0059', 'rna-s2-0059_E11', 'CB', now(), now()),
    ('Source02', 'E12', 'uuid-s2-0060', 'rna-s2-0060_E12', 'CB', now(), now()),

    ('Source02', 'F1', 'uuid-s2-0061', 'rna-s2-0061_F1', 'CB', now(), now()),
    ('Source02', 'F2', 'uuid-s2-0062', 'rna-s2-0062_F2', 'CB', now(), now()),
    ('Source02', 'F3', 'uuid-s2-0063', 'rna-s2-0063_F3', 'CB', now(), now()),
    ('Source02', 'F4', 'uuid-s2-0064', 'rna-s2-0064_F4', 'CB', now(), now()),
    ('Source02', 'F5', 'uuid-s2-0065', 'rna-s2-0065_F5', 'CB', now(), now()),
    ('Source02', 'F6', 'uuid-s2-0066', 'rna-s2-0066_F6', 'CB', now(), now()),
    ('Source02', 'F7', 'uuid-s2-0067', 'rna-s2-0067_F7', 'CB', now(), now()),
    ('Source02', 'F8', 'uuid-s2-0068', 'rna-s2-0068_F8', 'CB', now(), now()),
    ('Source02', 'F9', 'uuid-s2-0069', 'rna-s2-0069_F9', 'CB', now(), now()),
    ('Source02', 'F10', 'uuid-s2-0070', 'rna-s2-0070_F10', 'CB', now(), now()),
    ('Source02', 'F11', 'uuid-s2-0071', 'rna-s2-0071_F11', 'CB', now(), now()),
    ('Source02', 'F12', 'uuid-s2-0072', 'rna-s2-0072_F12', 'CB', now(), now()),

    ('Source02', 'G1', 'uuid-s2-0073', 'rna-s2-0073_G1', 'CB', now(), now()),
    ('Source02', 'G2', 'uuid-s2-0074', 'rna-s2-0074_G2', 'CB', now(), now()),
    ('Source02', 'G3', 'uuid-s2-0075', 'rna-s2-0075_G3', 'CB', now(), now()),
    ('Source02', 'G4', 'uuid-s2-0076', 'rna-s2-0076_G4', 'CB', now(), now()),
    ('Source02', 'G5', 'uuid-s2-0077', 'rna-s2-0077_G5', 'CB', now(), now()),
    ('Source02', 'G6', 'uuid-s2-0078', 'rna-s2-0078_G6', 'CB', now(), now()),
    ('Source02', 'G7', 'uuid-s2-0079', 'rna-s2-0079_G7', 'CB', now(), now()),
    ('Source02', 'G8', 'uuid-s2-0080', 'rna-s2-0080_G8', 'CB', now(), now()),
    ('Source02', 'G9', 'uuid-s2-0081', 'rna-s2-0081_G9', 'CB', now(), now()),
    ('Source02', 'G10', 'uuid-s2-0082', 'rna-s2-0082_G10', 'CB', now(), now()),
    ('Source02', 'G11', 'uuid-s2-0083', 'rna-s2-0083_G11', 'CB', now(), now()),
    ('Source02', 'G12', 'uuid-s2-0084', 'rna-s2-0084_G12', 'CB', now(), now()),

    ('Source02', 'H1', 'uuid-s2-0085', 'rna-s2-0085_H1', 'CB', now(), now()),
    ('Source02', 'H2', 'uuid-s2-0086', 'rna-s2-0086_H2', 'CB', now(), now()),
    ('Source02', 'H3', 'uuid-s2-0087', 'rna-s2-0087_H3', 'CB', now(), now()),
    ('Source02', 'H4', 'uuid-s2-0088', 'rna-s2-0088_H4', 'CB', now(), now()),
    ('Source02', 'H5', 'uuid-s2-0089', 'rna-s2-0089_H5', 'CB', now(), now()),
    ('Source02', 'H6', 'uuid-s2-0090', 'rna-s2-0090_H6', 'CB', now(), now()),
    ('Source02', 'H7', 'uuid-s2-0091', 'rna-s2-0091_H7', 'CB', now(), now()),
    ('Source02', 'H8', 'uuid-s2-0092', 'rna-s2-0092_H8', 'CB', now(), now()),
    ('Source02', 'H9', 'uuid-s2-0093', 'rna-s2-0093_H9', 'CB', now(), now()),
    ('Source02', 'H10', 'uuid-s2-0094', 'rna-s2-0094_H10', 'CB', now(), now()),
    ('Source02', 'H11', 'uuid-s2-0095', 'rna-s2-0095_H11', 'CB', now(), now()),
    ('Source02', 'H12', 'uuid-s2-0096', 'rna-s2-0096_H12', 'CB', now(), now())
;

-- update the destination plate with the picks from source 2 as they occur
-- (93 similar queries)
UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A1'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A2'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A2'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A3'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A3'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A4'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A4'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A5'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A5'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A6'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A6'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A7'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A7'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A8'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A8'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A9'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A9'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A10'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A10'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A11'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A11'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'A12'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'A12'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B1'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B2'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B2'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B3'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B4'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B4'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B5'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B5'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B6'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B6'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B7'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B7'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B8'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B8'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B9'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B9'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B10'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B10'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B11'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B11'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'B12'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'B12'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C1'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C2'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C2'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C3'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C3'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C4'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C4'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C5'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C5'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C6'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C6'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C7'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C7'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C8'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C8'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C9'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C9'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C10'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C10'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C11'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C11'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'C12'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'C12'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D2'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D1'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D3'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D2'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D4'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D3'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D5'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D4'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D6'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D5'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D7'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D6'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D8'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D7'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D9'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D8'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D10'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D9'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D11'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D10'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'D12'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D11'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E1'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'D12'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E2'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E1'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E3'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E2'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E4'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E3'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E5'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E4'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E6'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E5'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E7'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E6'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E8'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E7'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E9'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E8'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E10'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E9'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E11'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E10'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'E12'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E11'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F1'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'E12'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F2'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F1'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F3'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F2'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F4'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F3'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F5'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F4'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F6'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F5'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F7'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F6'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F8'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F7'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F9'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F8'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F10'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F9'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F11'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F10'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'F12'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F11'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G1'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'F12'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G2'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G1'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G3'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G2'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G4'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G3'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G5'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G4'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G6'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G5'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G7'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G6'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G8'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G7'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G9'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G8'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G10'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G9'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G11'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G10'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'G12'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G11'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H1'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'G12'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H2'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H1'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H3'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H3'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H4'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H4'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H5'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H5'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H6'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H6'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H7'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H7'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H8'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H8'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H9'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H9'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H10'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H10'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H11'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H11'
;

UPDATE `biosero_uat`.`destination_plate_wells`
SET
  source_plate_well_id = (
    SELECT id FROM `biosero_uat`.`source_plate_wells` spw
    WHERE spw.barcode = 'Source02'
    AND spw.coordinate = 'H12'
  ),
  updated_at = now()
WHERE
  barcode = 'HT_000001'
  AND coordinate = 'H12'
;

-- finally, update the run history at the end of the run, setting state and
-- when it completed
UPDATE `biosero_uat`.`automation_system_runs`
SET
  end_time = now(),
  state = 'completed',
  updated_at = now()
WHERE automation_system_id = (
  SELECT id FROM `biosero_uat`.`automation_systems`
    WHERE automation_system_name = 'CPA'
  )
AND system_run_id = 1
;