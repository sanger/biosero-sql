# Biosero SQL

Scripts to create/update the schema required for the Sanger/Biosero integration database.

## Table of Contents

<!-- toc -->

- [Schema diagram](#schema-diagram)
- [List of tables and views](#list-of-tables-and-views)
- [Database creation script](#database-creation-script)
- [Table creation script](#table-creation-script)
- [View creation scripts](#view-creation-scripts)
- [Example SQL](#example-sql)
  * [Configurations](#configurations)
  * [Selects unpicked wells for a source barcode e.g. if the source is a partial](#selects-unpicked-wells-for-a-source-barcode-eg-if-the-source-is-a-partial)
  * [Select empty well coordinates in a destination plate barcode](#select-empty-well-coordinates-in-a-destination-plate-barcode)
  * [Insert new run row](#insert-new-run-row)
  * [Walkthrough](#walkthrough)
- [Miscellaneous](#miscellaneous)
  * [Updating the Table of Contents](#updating-the-table-of-contents)

<!-- tocstop -->

## Schema diagram
![Alt text](schema.png?raw=true "Biosero Central Database Schema")

## List of tables and views
Tables
- configurations - one row per configuration key value pair per system
- automation_system_runs - one row per run
- events - one row per event on a run (error or other)
- source_plate_wells - one row per pickable sample plate well
- control_plate_wells - one row per pickable control plate well (as defined in configurations table)
- destination_plate_wells - one row per destination plate well

Views
- Run level view - one row per run
- Sample level view - one row per picked sample


Table and view descriptions can be found here: [table_and_view_descriptions.md](table_and_view_descriptions.md).

## Database creation script

The required database creation scripts are found in [database_script.sql](database_script.sql).

## Table creation script

The required table creation scripts are found in [tables_script.sql](tables_script.sql).

## View creation scripts

The required view creation scripts are found in:
- [view_run_level_view.sql](view_run_level_view.sql)
- [view_sample_level_view.sql](view_sample_level_view.sql)

## Example SQL

### Configurations
This example select query fetches the configuration key value pairs for a workcell called 'CPA':

```sql
SELECT
    id, automation_system_name, config_key, config_value, description, created_at
FROM
    `biosero_uat`.`configurations`
WHERE
    automation_system_name = 'CPA'
;
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

This query selects unpicked source plate wells for a source plate barcode e.g. if the source is a partial i.e. it has rows on the source_plate_wells table that are not in the destination_plate_wells table.

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
This use case picks a positive and negative control from a Control plate, and then from 2 Source plates (with 1 and 93 pickable samples) to create a full destination plate.

See file [use_case_1.sql](use_case_1.sql)

### Example use of views

- Example select from Run level View

```sql
SELECT
    *
FROM
    `biosero_uat`.`run_level_view`
WHERE
    automation_system_type = 'biosero'
    AND automation_system_name = 'CPA'
    AND system_run_id = 1
;
```

- Example select from Sample level View

```sql
SELECT
    *
FROM
    `biosero_uat`.`sample_level_view`
WHERE
    automation_system_type = 'biosero'
    AND automation_system_name = 'CPA'
    AND system_run_id = 1
ORDER BY system_run_id, destination_barcode, destination_coordinate
;
```

## Miscellaneous

### Updating the Table of Contents

To update the table of contents after adding things to this README you can use the
[markdown-toc](https://github.com/jonschlinkert/markdown-toc) node module. To run:

```shell
npx markdown-toc -i README.md
```
