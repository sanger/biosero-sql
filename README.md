# Biosero SQL

Scripts to create/update the schema required for the Sanger/Biosero integration database.

## Table of Contents

<!-- toc -->

- [Database](#database)
- [Tables](#tables)
- [Views](#views)
- [Example SQL](#example-sql)
  * [Configuration](#configuration)
  * [Selects unpicked wells for a source barcode e.g. if the source is a partial](#selects-unpicked-wells-for-a-source-barcode-eg-if-the-source-is-a-partial)
  * [Select empty well coordinates in a destination plate barcode](#select-empty-well-coordinates-in-a-destination-plate-barcode)
  * [Insert new run row](#insert-new-run-row)
  * [Walkthrough](#walkthrough)
- [Miscellaneous](#miscellaneous)
  * [Updating the Table of Contents](#updating-the-table-of-contents)

<!-- tocstop -->

## Database

The required database creation sciprts are found in [database_script.sql](database_script.sql).

## Tables

The required table creation scripts are found in [tables_script.sql](tables_script.sql).

## Views

The required view creation scripts are found in:

- [view_run_level_view.sql](view_run_level_view.sql)
- [view_sample_level_view.sql](view_sample_level_view.sql)

## Example SQL

### Configuration

```sql
SELECT
    id, automation_system_name, config_key, config_value, description, created_at
FROM
    `biosero_uat`.`configurations`
WHERE
    machine_name = 'CPA'
ORDER BY id ASC;
```

Example JSON representation of the configuration for a workcell called 'CPA':

```json
{
    "configuration": {
        "CPA": {
            "version": 1,
            "change_description": "moved the positive control",
            "change_user_id": "ab1",
            "control_coordinate_positive": "A1",
            "control_coordinate_negative": "H12",
            "control_excluded_destination_wells": "B5, B6",
            "bv_barcode_prefixes_control": "DN, DM",
            "bv_barcode_prefixes_destination prefixes": "HT, HS",
            "bv_deck_barcode_control": "DECKC123",
            "bv_deck_barcode_destination": "DECKP123"
        }
    }
}
```

### Select unpicked wells for a source barcode

e.g. if the source is a partial i.e. has rows on source_plate_wells table that are not in the destination_plate_wells table

```sql
SELECT
    spw.id,
    spw.barcode,
    spw.coordinate,
    spw.sample_id,
    spw.rna_id,
    spw.lab_id
FROM
    `biosero_uat`.`source_plate_wells` spw
WHERE
    spw.barcode = '<source plate barcode>'
    AND spw.id NOT IN (
      SELECT dpw.source_plate_well_id
      FROM `biosero_uat`.`destination_plate_wells` dpw
    )
ORDER BY spw.id;
```

### Select empty well coordinates in a destination plate barcode

```sql
SELECT dpw.coordinate
FROM `biosero_uat`.`destination_plate_wells` dpw
WHERE
    barcode = '<destination plate barcode>'
    AND source_plate_well_id IS NULL
    AND control_plate_well_id IS NULL
ORDER BY dpw.id;
```

### Example usage queries for use case 1 from the URS
This use case picks from 2 source plates (with 1 and 93 pickable samples) into a destination plate, completely filling it.

-- select configuration for the workcell
```sql
SELECT id, automation_system_name, config_key, config_value, description, created_at FROM `biosero_uat`.`configurations`
WHERE automation_system_name = 'CPA' ORDER BY id ASC;
```

-- insert new run row
```sql
INSERT INTO `biosero_uat`.`automation_system_runs` (
  automation_system_type,
  automation_system_name,
  system_run_id,
  method,
  user_id,
  start_time,
  state,
  liquid_handler_serial_number,
  configuration_used,
  created_at,
  updated_at
)
VALUES (
  'biosero',
  'CPA',
  '1',
  'cp v1',
  'ab12',
  now(),
  'started',
  'h1000001',
  '{"configuration":{"CPA":{"version":"1","change_description":"moved the positive control","change_user_id":"ab1","control_coordinate_positive":"A1","control_coordinate_negative":"H12","control_excluded_destination_wells":"B5,B6","bv_barcode_prefixes_control":"DN, DM","bv_barcode_prefixes_destination":"HT, HS","bv_deck_barcode_control":"DECKC123","bv_deck_barcode_destination":"DECKP123"}}}',
  now(),
  now()
);
```

-- check destination does not already exist
```sql
SELECT id FROM `biosero_uat`.`destination_plate_wells`
WHERE barcode = 'HT_000001';
```

-- select the id of the run
```sql
SET @a_system_run_id := (SELECT id FROM `biosero_uat`.`automation_system_runs` WHERE automation_system_type = 'biosero' AND system_run_id = 1);
```
-- create empty destination plate
```sql
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
```

-- for positive control, check if it is already present
```sql
SELECT id FROM `biosero_uat`.`control_plate_wells`
WHERE barcode = 'Control01'
AND coordinate = 'A1';
```

-- if not, insert positive control well into control_plate_wells table
```sql
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
```

-- for positive control, insert well into random destination location
```sql
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
```

-- for negative control, check if it is already present
```sql
SELECT id FROM `biosero_uat`.`control_plate_wells`
WHERE barcode = 'Control01'
AND coordinate = 'H12';
```

-- if not, insert negative control well into control_plate_wells table
```sql
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
```

-- for negative control, insert well into random destination location
```sql
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
```

-- check source does not already exist
```sql
SELECT id FROM `biosero_uat`.`source_plate_wells`
WHERE barcode = 'Source01';
```

-- insert new source 1 plate after lookup, with 1 pickable well in D1
```sql
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
```

-- update destination A1 with pick from source 1
```sql
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
```

-- check source does not already exist
```sql
SELECT id
FROM `biosero_uat`.`source_plate_wells`
WHERE barcode = 'Source02';
```

-- insert new source 2 plate after lookup, with 93 pickable wells
```sql
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
```

-- update destination with picks from source 2
```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

```sql
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
```

-- update run history
```sql
UPDATE `biosero_uat`.`automation_system_runs`
SET
  end_time = now(),
  state = 'completed',
  updated_at = now()
WHERE
  automation_system_type = 'biosero'
  AND system_run_id = 1
;
```

### Example use of views

- Example select from Run level View

```sql
SELECT
    *
FROM
    `biosero_uat`.`run_level_view`
WHERE
    automation_system = 'biosero'
    AND run_id = 1;
```

- Example select from Sample level View

```sql
SELECT
    *
FROM
    `biosero_uat`.`sample_level_view`
WHERE
    automation_system = 'biosero'
    AND run_id = 1
ORDER BY run_id , destination_barcode , destination_coordinate;
```

## Miscellaneous

### Updating the Table of Contents

To update the table of contents after adding things to this README you can use the
[markdown-toc](https://github.com/jonschlinkert/markdown-toc) node module. To run:

```shell
npx markdown-toc -i README.md
```
