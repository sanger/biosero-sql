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
    id, machine_name, name, value, description, created_at
FROM
    `biosero_test`.`configurations`
WHERE
    machine_name = 'Workcell 1'
ORDER BY id ASC;
```

Example JSON representation for workcell 1 configuration:

```json
{
    "configuration": {
        "Workcell 1": {
            "version": 2,
            "change_description": "moved the positive control",
            "changed_by_user": "ab1",
            "positive_control_coordinate": "A1",
            "negative_control_coordinate": "H12",
            "excluded_control_wells": "B5, B6",
            "control_plate_barcode_prefixes": "DN, DM",
            "destination_plate_barcode prefixes": "HT, HS"
        }
    }
}
```

### Selects unpicked wells for a source barcode e.g. if the source is a partial

i.e. has rows on source_plate_wells table that are not in the destination_plate_wells table

```sql
SELECT
    spw.id,
    spw.source_barcode,
    spw.source_coordinate,
    spw.sample_id,
    spw.rna_id,
    spw.lab_id
FROM
    `biosero_test`.`source_plate_wells` spw
WHERE
    spw.source_barcode = '<source plate barcode>'
        AND spw.id NOT IN (SELECT
            dpw.source_plate_well_id
        FROM
            `biosero_test`.`destination_plate_wells` dpw)
ORDER BY spw.id;
```

### Select empty well coordinates in a destination plate barcode

```sql
SELECT
    dpw.destination_coordinate
FROM
    `biosero_test`.`destination_plate_wells` dpw
WHERE
    destination_barcode = '<destination plate barcode>'
        AND source_plate_well_id IS NULL
ORDER BY dpw.id;
```

### Insert new run row

```sql
INSERT INTO `biosero_test`.`runs`
            (run_id,
             automation_system,
             run_method,
             run_start_time,
             run_state,
             run_machine_name,
             run_instrument_serial_number,
             configuration_used,
             created_at,
             updated_at)
VALUES      ( 1,
              'biosero',
              'cp v1',
              Now(),
              'started',
              'Workcell 1',
              'SN_12345678',
              '{"configuration": {"Workcell 1": {"version" : "2","change_description": "moved the positive control","changed_by_user": "ab1","positive_control_coordinate": "A1","negative_control_coordinate": "H12","excluded_control_wells": "B5, B6","control_plate_barcode_prefixes": "DN, DM","destination_plate_barcode prefixes": "HT, HS"}}',
              Now(),
              Now() );
```

### Walkthrough

- Check destination does not already exist

```sql
SELECT
    id
FROM
    `biosero_test`.`destination_plate_wells`
WHERE
    destination_barcode = 'HT_000001';
```

- select the id of the run

```sql
SET @a_run_id := (SELECT id FROM `biosero_test`.`runs` WHERE automation_system = 'biosero' AND run_id = 1);
```

- create empty destination plate

```sql
INSERT INTO `biosero_test`.`destination_plate_wells` ( runs_id, destination_barcode, destination_coordinate, created_at, updated_at )
VALUES (@a_run_id, 'HT_000001', 'A1', now(), now()), (@a_run_id, 'HT_000001', 'A2', now(), now()), (@a_run_id, 'HT_000001', 'A3', now(), now()), (@a_run_id, 'HT_000001', 'A4', now(), now()), (@a_run_id, 'HT_000001', 'A5', now(), now()), (@a_run_id, 'HT_000001', 'A6', now(), now()), (@a_run_id, 'HT_000001', 'A7', now(), now()), (@a_run_id, 'HT_000001', 'A8', now(), now()), (@a_run_id, 'HT_000001', 'A9', now(), now()), (@a_run_id, 'HT_000001', 'A10', now(), now()), (@a_run_id, 'HT_000001', 'A11', now(), now()), (@a_run_id, 'HT_000001', 'A12', now(), now()), (@a_run_id, 'HT_000001', 'B1', now(), now()), (@a_run_id, 'HT_000001', 'B2', now(), now()), (@a_run_id, 'HT_000001', 'B3', now(), now()), (@a_run_id, 'HT_000001', 'B4', now(), now()), (@a_run_id, 'HT_000001', 'B5', now(), now()), (@a_run_id, 'HT_000001', 'B6', now(), now()), (@a_run_id, 'HT_000001', 'B7', now(), now()), (@a_run_id, 'HT_000001', 'B8', now(), now()), (@a_run_id, 'HT_000001', 'B9', now(), now()), (@a_run_id, 'HT_000001', 'B10', now(), now()), (@a_run_id, 'HT_000001', 'B11', now(), now()), (@a_run_id, 'HT_000001', 'B12', now(), now()), (@a_run_id, 'HT_000001', 'C1', now(), now()), (@a_run_id, 'HT_000001', 'C2', now(), now()), (@a_run_id, 'HT_000001', 'C3', now(), now()), (@a_run_id, 'HT_000001', 'C4', now(), now()), (@a_run_id, 'HT_000001', 'C5', now(), now()), (@a_run_id, 'HT_000001', 'C6', now(), now()), (@a_run_id, 'HT_000001', 'C7', now(), now()), (@a_run_id, 'HT_000001', 'C8', now(), now()), (@a_run_id, 'HT_000001', 'C9', now(), now()), (@a_run_id, 'HT_000001', 'C10', now(), now()), (@a_run_id, 'HT_000001', 'C11', now(), now()), (@a_run_id, 'HT_000001', 'C12', now(), now()), (@a_run_id, 'HT_000001', 'D1', now(), now()), (@a_run_id, 'HT_000001', 'D2', now(), now()), (@a_run_id, 'HT_000001', 'D3', now(), now()), (@a_run_id, 'HT_000001', 'D4', now(), now()), (@a_run_id, 'HT_000001', 'D5', now(), now()), (@a_run_id, 'HT_000001', 'D6', now(), now()), (@a_run_id, 'HT_000001', 'D7', now(), now()), (@a_run_id, 'HT_000001', 'D8', now(), now()), (@a_run_id, 'HT_000001', 'D9', now(), now()), (@a_run_id, 'HT_000001', 'D10', now(), now()), (@a_run_id, 'HT_000001', 'D11', now(), now()), (@a_run_id, 'HT_000001', 'D12', now(), now()), (@a_run_id, 'HT_000001', 'E1', now(), now()), (@a_run_id, 'HT_000001', 'E2', now(), now()), (@a_run_id, 'HT_000001', 'E3', now(), now()), (@a_run_id, 'HT_000001', 'E4', now(), now()), (@a_run_id, 'HT_000001', 'E5', now(), now()), (@a_run_id, 'HT_000001', 'E6', now(), now()), (@a_run_id, 'HT_000001', 'E7', now(), now()), (@a_run_id, 'HT_000001', 'E8', now(), now()), (@a_run_id, 'HT_000001', 'E9', now(), now()), (@a_run_id, 'HT_000001', 'E10', now(), now()), (@a_run_id, 'HT_000001', 'E11', now(), now()), (@a_run_id, 'HT_000001', 'E12', now(), now()), (@a_run_id, 'HT_000001', 'F1', now(), now()), (@a_run_id, 'HT_000001', 'F2', now(), now()), (@a_run_id, 'HT_000001', 'F3', now(), now()), (@a_run_id, 'HT_000001', 'F4', now(), now()), (@a_run_id, 'HT_000001', 'F5', now(), now()), (@a_run_id, 'HT_000001', 'F6', now(), now()), (@a_run_id, 'HT_000001', 'F7', now(), now()), (@a_run_id, 'HT_000001', 'F8', now(), now()), (@a_run_id, 'HT_000001', 'F9', now(), now()), (@a_run_id, 'HT_000001', 'F10', now(), now()), (@a_run_id, 'HT_000001', 'F11', now(), now()), (@a_run_id, 'HT_000001', 'F12', now(), now()), (@a_run_id, 'HT_000001', 'G1', now(), now()), (@a_run_id, 'HT_000001', 'G2', now(), now()), (@a_run_id, 'HT_000001', 'G3', now(), now()), (@a_run_id, 'HT_000001', 'G4', now(), now()), (@a_run_id, 'HT_000001', 'G5', now(), now()), (@a_run_id, 'HT_000001', 'G6', now(), now()), (@a_run_id, 'HT_000001', 'G7', now(), now()), (@a_run_id, 'HT_000001', 'G8', now(), now()), (@a_run_id, 'HT_000001', 'G9', now(), now()), (@a_run_id, 'HT_000001', 'G10', now(), now()), (@a_run_id, 'HT_000001', 'G11', now(), now()), (@a_run_id, 'HT_000001', 'G12', now(), now()), (@a_run_id, 'HT_000001', 'H1', now(), now()), (@a_run_id, 'HT_000001', 'H2', now(), now()), (@a_run_id, 'HT_000001', 'H3', now(), now()), (@a_run_id, 'HT_000001', 'H4', now(), now()), (@a_run_id, 'HT_000001', 'H5', now(), now()), (@a_run_id, 'HT_000001', 'H6', now(), now()), (@a_run_id, 'HT_000001', 'H7', now(), now()), (@a_run_id, 'HT_000001', 'H8', now(), now()), (@a_run_id, 'HT_000001', 'H9', now(), now()), (@a_run_id, 'HT_000001', 'H10', now(), now()), (@a_run_id, 'HT_000001', 'H11', now(), now()), (@a_run_id, 'HT_000001', 'H12', now(), now()) ;
```

- for positive control, check if it is already present - (they may initially re-use the control plate barcode)

```sql
SELECT id FROM `biosero_test`.`source_plate_wells` WHERE source_barcode = 'Control01' AND source_coordinate = 'A1';SELECT
    id
FROM
    `biosero_test`.`source_plate_wells`
WHERE
    source_barcode = 'Control01'
        AND source_coordinate = 'A1';
```

- If control well does not exist, insert positive control well into source_plate_wells table

```sql
INSERT INTO `biosero_test`.`source_plate_wells` ( source_barcode, source_coordinate, control, created_at, updated_at )
VALUES ('Control01', 'A1', 'positive', now(), now()) ;
```

- for positive control, insert well into random destination location

```sql
UPDATE `biosero_test`.`destination_plate_wells`
SET
    source_plate_well_id = (SELECT
            id
        FROM
            `biosero_test`.`source_plate_wells` spw
        WHERE
            spw.source_barcode = 'Control01'
                AND spw.source_coordinate = 'A1'),
    updated_at = NOW()
WHERE
    destination_barcode = 'HT_000001'
        AND destination_coordinate = 'B3';
```

- check sample source plate does not already exist

```sql
SELECT
    id
FROM
    `biosero_test`.`source_plate_wells`
WHERE
    source_barcode = 'Source01';
```

- Insert new source plate after LIMS lookup, e.g. with 1 pickable well in D1

```sql
INSERT INTO `biosero_test`.`source_plate_wells` ( source_barcode, source_coordinate, sample_id, rna_id, lab_id, created_at, updated_at )
VALUES ('Source01', 'D1', 'uuid-s1-0037', 'rna-s1-0037_D1', 'CB', now(), now()) ;
```

- Update destination plate well with pick from source plate

```sql
UPDATE `biosero_test`.`destination_plate_wells`
SET
    source_plate_well_id = (SELECT
            id
        FROM
            `biosero_test`.`source_plate_wells` spw
        WHERE
            spw.source_barcode = 'Source01'
                AND spw.source_coordinate = 'D1'),
    updated_at = NOW()
WHERE
    destination_barcode = 'HT_000001'
        AND destination_coordinate = 'A1';
```

- Update run at the end of the run

```sql
UPDATE `biosero_test`.`runs`
SET
    run_end_time = NOW(),
    run_state = 'completed',
    updated_at = NOW()
WHERE
    automation_system = 'biosero'
        AND run_id = 1;
```

## Miscellaneous

### Updating the Table of Contents

To update the table of contents after adding things to this README you can use the
[markdown-toc](https://github.com/jonschlinkert/markdown-toc) node module. To run:

```shell
npx markdown-toc -i README.md
```
