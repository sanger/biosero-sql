# CherryTrack SQL

Scripts to create/update the schema required for the cherrytrack database.

## Table of Contents

<!-- toc -->

- [Schema diagram](#schema-diagram)
- [List of tables and views](#list-of-tables-and-views)
- [List of stored procedures](#list-of-stored-procedures)
- [Database creation](#database-creation)
- [Table creation script](#table-creation-script)
- [View creation scripts](#view-creation-scripts)
- [Example SQL](#example-sql)
  * [Configurations](#configurations)
  * [Select unpicked wells for a source barcode e.g. if the source is a partial](#selects-unpicked-wells-for-a-source-barcode-eg-if-the-source-is-a-partial)
  * [Select empty well coordinates in a destination plate barcode](#select-empty-well-coordinates-in-a-destination-plate-barcode)
  * [Example use of views](#example-use-of-views)
- [Python Scripts](#python-scripts)
- [Miscellaneous](#miscellaneous)
  * [Updating the Table of Contents](#updating-the-table-of-contents)

<!-- tocstop -->

## Schema diagram
![Alt text](schema.png?raw=true "CherryTrack Database Schema")

## List of tables and views

DEPRECATED: USE CHERRYTRACK REPOSITORY

Tables
- configurations - one row per configuration key value pair per system
- automation_systems - one row per automation system
- automation_system_runs - one row per run
- run_events - one row per event on a run (error or other)
- run_configurations - one row per run to record the configuration used
- source_plate_wells - one row per pickable sample plate well
- control_plate_wells - one row per pickable control plate well (as defined in configurations table)
- destination_plate_wells - one row per destination plate well

Views
- Run level view - one row per run
- Sample level view - one row per picked sample


Table and view descriptions can be found here: [table_and_view_descriptions.md](table_and_view_descriptions.md).

## List of stored procedures

DEPRECATED: USE CHERRYTRACK REPOSITORY

Stored procedures
- createControlPlateWellsRecord here: [create_control_plate_wells_record.sql](/stored_procedures/create_control_plate_wells_record.sql)
- createEmptyDestinationPlateWellsRecord here: [create_empty_destination_plate_wells_record.sql](/stored_procedures/create_empty_destination_plate_wells_record.sql)
- createRunRecord here: [create_run_record.sql](/stored_procedures/create_run_record.sql)
- createRunEventRecord here: [create_run_event_record.sql](/stored_procedures/create_run_event_record.sql)
- createSourcePlateWellRecord here: [create_source_plate_well_record.sql](/stored_procedures/create_source_plate_well_record.sql)
- getConfigurationForSystem here: [get_configuration_for_system.sql](/stored_procedures/get_configuration_for_system.sql)
- getDetailsForDestinationPlate here: [get_details_for_destination_plate.sql](/stored_procedures/get_details_for_destination_plate.sql)
- getPickableSamplesForSourcePlate here: [get_pickable_samples_for_source_plate.sql](/stored_procedures/get_pickable_samples_for_source_plate.sql)
- updateDestinationPlateWellWithControl here: [update_destination_plate_well_with_control.sql](/stored_procedures/update_destination_plate_well_with_control.sql)
- updateDestinationPlateWellWithSource here: [update_destination_plate_well_with_source.sql](/stored_procedures/update_destination_plate_well_with_source.sql)
- updateRunState here: [update_run_state.sql](/stored_procedures/update_run_state.sql')

## Database creation

DEPRECATED: USE CHERRYTRACK REPOSITORY

The easiest way to create the database (and associated views and stored procedures) is via the python scripts here: [Python Scripts](#python-scripts)

Alternatively you can use the database creation scripts are found in [database_script.sql](database_script.sql). NB. Change the 'database name' placeholder.

## Table creation script

DEPRECATED: USE CHERRYTRACK REPOSITORY

The required table creation scripts are found in [tables_script.sql](tables_script.sql).

## View creation scripts

DEPRECATED: USE CHERRYTRACK REPOSITORY

The required view creation scripts are found in:
- [view_run_level_view.sql](views/view_run_level_view.sql)
- [view_sample_level_view.sql](views/view_sample_level_view.sql)

## Example SQL

### Configurations
See example insert sql script here:
- [configurations_insert_example.sql](example_queries/configurations_insert_example.sql)

This example select query fetches the configuration key value pairs for a workcell called 'CPA':

```sql
SELECT asys.automation_system_name, conf.config_key, conf.config_value, conf.description, conf.created_at
FROM `configurations` conf
JOIN `automation_systems` asys
  ON conf.automation_system_id = asys.id
WHERE asys.automation_system_name = 'CPA';
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
    spw.barcode = <source_barcode>
    AND dpw.id IS NULL
ORDER BY spw.id;
```

### Select empty well coordinates in a destination plate barcode

```sql
SELECT dpw.coordinate
FROM `destination_plate_wells` dpw
WHERE
    barcode = '<destination plate barcode>'
    AND source_plate_well_id IS NULL
    AND control_plate_well_id IS NULL
ORDER BY dpw.id;
```

### Example usage queries for use case 1 from the URS

This use case picks a positive and negative control from a Control plate, and then from 2 Source plates (with 1 and 93 pickable samples) to create a full destination plate.

See file [use_case_1.sql](example_queries/use_case_1.sql)

### Example use of views

- Example select from Run level View

```sql
SELECT
    *
FROM
    `run_level_view`
WHERE
    automation_system_run_id = 1
;
```

- Example select from Sample level View

```sql
SELECT
    *
FROM
    `sample_level_view`
WHERE
    automation_system_run_id = 1
ORDER BY automation_system_run_id, destination_barcode, destination_coordinate
;
```

## Python Scripts

### Environment

Scripts in this repo depend on certain pip packages to be installed.  To facilitate this, a pipenv environment has been configured to run the scripts in.  From the root of the repo:

```shell
pipenv install
pipenv shell
```

Within this shell, you can navigate to the `python_scripts` directory to run them.

### List of scripts

A python script has been included to demonstrate use of the stored procedures during a typical run to create test data here:
[generate_test_data.py](/python_scripts/generate_test_data.py).

A python script has been included to act as an integration test for both use of the stored procedures and calls to the lighthouse API during a typical run here: [generate_test_data.py](/python_scripts/integration_test_with_api.py)

DEPRECATED: USE CHERRYTRACK REPOSITORY

A python script has been included to reset the database(CARE!) here:
[reset_database.py](/python_scripts/reset_database.py).

## Miscellaneous

### Updating the Table of Contents

To update the table of contents after adding things to this README you can use the
[markdown-toc](https://github.com/jonschlinkert/markdown-toc) node module. To run:

```shell
npx markdown-toc -i README.md
```
