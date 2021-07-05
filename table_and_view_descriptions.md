# Tables
DEPRECATED: USE CHERRYTRACK REPOSITORY
See [tables_script.sql](tables_script.sql).

## Configurations table
This table contains one row per configuration key value pair for each Biosero system. At the start of a run, the system looks up the latest set of configuration values, then writes a copy of this as JSON into a field in the runs table ‘configuration_used’ field. So there is a record of what configuration was used in that run. The table is likely to have 20-30 rows on it in total. It is done as key and value pairs to avoid have to add/remove columns in future when adding or removing configurations.

## Automation Systems table
This table contains one row per automation system. For Biosero there will be two rows.

## Automation System Runs table
This table contains one row per run that occurs on either of the Biosero systems. That row is inserted at the start of the run with state ‘started’, and should be updated when the state of the run changes to ‘aborted’ or ‘completed’.

## Run events table
This table contains one row per event recorded on the system during a run. Initially this is intended for logging error events, but has been made flexible enough that other types of events could be stored. The details about the event are stored as a JSON value, to allow greater flexibility in the information that can be stored.

## Run configurations table
This table contains one row per run, and records the configurations used in that run as JSON. This is to keep the history of that run.

## Source plate wells table
This table contains one row for each pickable source sample well scanned and retrieved from the LIMS via the lookup API endpoint on either of the Biosero systems. i.e. it does not need to contain empty wells, or pickable samples e.g. a sample source plate with only 5 pickable samples would only have 5 rows (equivalent to the list returned from the LIMS lookup API endpoint).

## Control plate wells table
This table contains one row for each control well defined by the configurations table, for each run on the system. So in each run where the system scans a control plate, the system uses the configuration values of where the positive and negative controls are located, then inserts rows keyed on the run identifier and control plate barcode and coordinates into this table.
This allows physically distinct control plates (the lab uses up an instance of a control plate per run) that have the same barcode (the barcode represents the batch of control solutions, dispensed into multiple control plates given the same barcode label) to have a distinct record. So that should the Lab need to change the coordinate locations of positive and negative controls on the control plates, they can do this by requesting the LIMS team change the coordinates in the configurations table and that will be picked up in the next run.

## Destination plate wells table
This table contains one row for each destination plate well. 96 empty rows are inserted when the destination plate is first scanned, then the rows updated as the destination plate wells are picked into. The rows can be joined to the automation_system_runs table via the automation_system_run_id, to the source_plate_wells table via the source plate well id, and to the control_plate_wells table via the control plate well id.

# Views

## Run level view
See [view_run_level_view.sql](view_run_level_view.sql)

This view contains run level information for use in Sanger Tableau reporting, and essentially selects information from the automation_system_runs table.

## Sample level view
See [view_sample_level_view.sql](view_sample_level_view.sql)

This view contains sample level information for use in Sanger Tableau reporting, and it selects information from multiple tables to primarily show picked samples and controls in destination plates.
