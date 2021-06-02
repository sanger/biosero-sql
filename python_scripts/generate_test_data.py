# This script generates test data for the database.
# Check the /config/defaults contains your database connection information.
# You may want to run the reset_database.py script first to create the tables,
# views and stored procedures.

# Set NUMBER_DESTINATION_PLATES_TO_MAKE below to the number of plates you want.
# Run the script at the command line using:
# python3 generate_test_data.py

import datetime
import os
import mysql.connector # use command 'pip install mysql-connector-python'
import json
import random

from config.defaults import *

NUMBER_DESTINATION_PLATES_TO_MAKE = 1
GBG_METHOD_NAME = 'example method name v1.2'
USER_ID = 'ab12'
SYSTEM_NAME = 'CPA'
CONTROL_PLATE_BC = 'DN999999999'

WELL_COORDS = [
    "A1","A2","A3","A4","A5","A6","A7","A8","A9","A10","A11","A12",
    "B1","B2","B3","B4","B5","B6","B7","B8","B9","B10","B11","B12",
    "C1","C2","C3","C4","C5","C6","C7","C8","C9","C10","C11","C12",
    "D1","D2","D3","D4","D5","D6","D7","D8","D9","D10","D11","D12",
    "E1","E2","E3","E4","E5","E6","E7","E8","E9","E10","E11","E12",
    "F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
    "G1","G2","G3","G4","G5","G6","G7","G8","G9","G10","G11","G12",
    "H1","H2","H3","H4","H5","H6","H7","H8","H9","H10","H11","H12"
]

# Create a connection to the database
def create_database_connection():
    db_conn = mysql.connector.connect(
       host=DB_HOST,
       port=DB_PORT,
       user=DB_USER,
       passwd=DB_PWD,
       database=DB_NAME
    )
    return db_conn

# Fetch the configuration details for a specific system
def get_configuration_for_system(system_name) -> dict:
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor(dictionary=True, buffered=True)

        # Call stored procedure with system name as parameter
        args = [system_name]
        cursor.callproc('getConfigurationForSystem', args)

        # Process the result into a dictionary
        dict_result = {}
        for result in cursor.stored_results(): # only one result
            configs = result.fetchall() # array of key value pairs
            for config in configs:
                dict_result.update({config['config_key']: config['config_value']})

        return dict_result

    except Exception as e:
        print(e)
    else:
        print("Fetched configuration for system name %s" % system_name)
    finally:
        cursor.close()
        db_conn.close()

# Insert a run record
def create_run_record(system_name, system_run_id, gbg_method_name, user_id):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with system name as parameter
        args = [system_name, system_run_id, gbg_method_name, user_id]
        cursor.callproc('createRunRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("Created run record for id = %s" % system_run_id)
    finally:
        cursor.close()
        db_conn.close()

# Insert empty wells for the destination plate
def create_empty_destination_plate_wells(system_name, system_run_id, dest_bc, well_coords):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters for each well
        for well_coord in well_coords:
            args = [system_name, system_run_id, dest_bc, well_coord]
            cursor.callproc('createEmptyDestinationPlateWellsRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("Created destination plate %s empty wells" % dest_bc)
    finally:
        cursor.close()
        db_conn.close()

# Insert rows for the control plate
def create_control_plate(system_name, system_run_id, control_plate_barcode, controls):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters for each well
        for control in controls:
            args = [system_name, system_run_id, control_plate_barcode, control['coordinate'], control['control']]
            cursor.callproc('createControlPlateWellsRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("Created control plate %s for run id %s" % (control_plate_barcode, system_run_id))
    finally:
        cursor.close()
        db_conn.close()

# Update the destination plate well after picking a control
def update_destination_plate_well_for_control(system_name, system_run_id, destination_barcode, destination_coordinate, control_barcode, control_coordinate):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters
        args = [system_name, system_run_id, destination_barcode, destination_coordinate, control_barcode, control_coordinate]
        cursor.callproc('updateDestinationPlateWellWithControl', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("Updated destination well %s with picked control from %s coord %s" % (destination_coordinate, control_barcode, control_coordinate))
    finally:
        cursor.close()
        db_conn.close()

# This method is mocking the Sanger barcode creation process for destination plates
def generate_destination_plate_barcode(system_run_id) -> str:
    barcode = "DN%s" % str(system_run_id).zfill(8)
    return barcode

# This method is mocking the Lighthouse barcode creation process for source plates
def generate_source_plate_barcode(system_run_id, src_plate_index) -> str:
    barcode = "DS%s%s" % (str(system_run_id).zfill(5), str(src_plate_index).zfill(4))
    return barcode

# Choose a random coordinate from a list (and removes it from list)
def choose_random_coordinate(well_coords) -> str:
    index = random.randint(0, (len(well_coords) - 1))
    coord = well_coords[index]
    well_coords.remove(coord)
    return coord

# This mocks the LIMS source lookup API call to return a list of pickable samples
# for a source plate
# Sample identifiers are incremented to avoid duplicates
def create_random_pickable_samples(system_run_id, sample_uuid_index):
    num_pickable_samples = random.randint(1, 96)
    pickable_samples = []
    src_well_coords = WELL_COORDS.copy()
    for n in range(num_pickable_samples):
        src_coord = choose_random_coordinate(src_well_coords)
        pickable_samples.append(
            {
                'source_coordinate': src_coord,
                'sample_id': "UUID-S-%s-%s" % (str(system_run_id).zfill(5), str(sample_uuid_index).zfill(8)),
                'rna_id': "RNA-S-%s-%s" % (str(system_run_id).zfill(5), str(sample_uuid_index).zfill(8)),
                'lab_id': 'MK'
            }
        )
        sample_uuid_index += 1

    return pickable_samples

# Insert source plate well rows for each pickable sample
def create_source_plate(source_barcode, pickable_samples):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters for each well
        for pickable_sample in pickable_samples:
            args = [source_barcode, pickable_sample['source_coordinate'], pickable_sample['sample_id'], pickable_sample['rna_id'], pickable_sample['lab_id']]
            cursor.callproc('createSourcePlateWellRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("Created source plate %s with %s pickable samples" % (source_barcode, len(pickable_samples)))
    finally:
        cursor.close()
        db_conn.close()

# Fetch the remaining pickable samples for a source plate
def get_pickable_samples_for_source_plate(barcode):
    pickable_samples = []
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor(dictionary=True, buffered=True)

        # Call stored procedure with source barcode
        args = [barcode]
        print("barcode for proc = %s" % barcode)
        cursor.callproc('getPickableSamplesForSourcePlate', args)

        # Process the result into a dictionary
        for result in cursor.stored_results(): # only one result
            wells = result.fetchall() # array of key value pairs
            for well in wells:
                pickable_samples.append(
                    {
                        'source_coordinate': well['coordinate'],
                        'sample_id': well['sample_id'],
                        'rna_id': well['rna_id'],
                        'lab_id': well['lab_id']
                    }
                )

    except Exception as e:
        print(e)
    else:
        print("Fetched pickable samples for source plate %s" % barcode)
    finally:
        cursor.close()
        db_conn.close()
        return pickable_samples

# Update the destination plate well for a picked source plate well
def update_destination_plate_well_for_source(system_name, system_run_id, destination_barcode, destination_coordinate, source_barcode, source_coordinate):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters
        args = [system_name, system_run_id, destination_barcode, destination_coordinate, source_barcode, source_coordinate]
        cursor.callproc('updateDestinationPlateWellWithSource', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("Updated destination well %s with picked source %s coordinate %s" % (destination_coordinate, source_barcode, source_coordinate))
    finally:
        cursor.close()
        db_conn.close()

# Update the run record at the end of the run
def update_run_record(system_name, system_run_id, new_state):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters
        args = [system_name, system_run_id, new_state]
        cursor.callproc('updateRunState', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("Updated run record id %s with state %s" % (system_run_id, new_state))
    finally:
        cursor.close()
        db_conn.close()

# Fetch the last run id used
def get_last_run_id() -> int:
    last_run_id = 0
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        sql = "SELECT MAX(system_run_id) FROM %s.automation_system_runs;" % DB_NAME
        cursor.execute(sql)

        result = cursor.fetchone()
        if result[0] is not None:
            last_run_id = result[0]

    except Exception as e:
        print(e)
    else:
        print("Fetched last run id %s" % last_run_id)
    finally:
        cursor.close()
        db_conn.close()
        return last_run_id

# Insert a run event record
def create_run_event_record(system_name, system_run_id, event_type, event):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters
        args = [system_name, system_run_id, event_type, event]
        cursor.callproc('createRunEventRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("Created run event type %s with event %s" % (event_type, event))
    finally:
        cursor.close()
        db_conn.close()

# =============
# Script starts here
# =============

partial_source_barcode = ''
sample_uuid_index = 1
for dest_index in range(NUMBER_DESTINATION_PLATES_TO_MAKE):
    print("Processing for destination index %s" % dest_index)
    print("Fetching system configuration")
#   [SP] Fetch config for CPA
    configuration = get_configuration_for_system('CPA')
#   [SP] Create run (run id = run_id_index) and run_configuration rows
    system_run_id = get_last_run_id() + 1
    print("Create a new run record for system_run_id = %s" % system_run_id)
    create_run_record(SYSTEM_NAME, system_run_id, GBG_METHOD_NAME, USER_ID)
#   [SP] Insert destination plate 96 empty rows
    dest_wells = WELL_COORDS.copy()
    dest_bc = generate_destination_plate_barcode(system_run_id)
    create_empty_destination_plate_wells(SYSTEM_NAME, system_run_id, dest_bc, dest_wells)
#   Insert control plate rows using config
#   [SP] Insert controls - from config control coordinates =
#   [{coordinate: <positive coord>, control: 'positive'},{coordinate: <negative coord>, control: 'negative'}
    pos_control_coord = configuration['control_coordinate_positive']
    neg_control_coord = configuration['control_coordinate_negative']
    controls = [{'coordinate': pos_control_coord, 'control': 'positive'},{'coordinate': neg_control_coord, 'control': 'negative'}]
    create_control_plate(SYSTEM_NAME, system_run_id, CONTROL_PLATE_BC, controls)
    print("Control plate coords: Pos in %s, neg in %s" % (pos_control_coord, neg_control_coord))
#   Update destination plate rows for controls
    pos_control_dest_coord = choose_random_coordinate(dest_wells)
    neg_control_dest_coord = choose_random_coordinate(dest_wells)
#   For Positive
#   [SP] Update destination with pos control - dest coord = random coord from (empty wells - excluded wells from config)
    update_destination_plate_well_for_control(SYSTEM_NAME, system_run_id, dest_bc, pos_control_dest_coord, CONTROL_PLATE_BC, pos_control_coord)
#   For Negative
#   [SP] Update destination with neg control - dest coord = random coord from (empty wells - excluded wells from config)
    update_destination_plate_well_for_control(SYSTEM_NAME, system_run_id, dest_bc, neg_control_dest_coord, CONTROL_PLATE_BC, neg_control_coord)

    src_plate_index = 0
    pickable_samples = []
    current_source_barcode = ''
    destination_completed = False
#   loop until destination has no empty wells remaining
    while not destination_completed:
#       get the next pickable source wells
        if len(pickable_samples) == 0:
            if partial_source_barcode == '':
#               mock LIMS lookup - create list of pickable samples of random size 1-96
#               e.g. has_plate_map: true, pickable_samples: [{source_coordinate: A1, sample_id: S000001, rna_id: R00001, lab_id: MK}]
                src_plate_index += 1
                current_source_barcode = generate_source_plate_barcode(system_run_id, src_plate_index)
                pickable_samples = create_random_pickable_samples(system_run_id, sample_uuid_index)
#               [SP] Insert new source rows (pickable_samples)
                create_source_plate(current_source_barcode, pickable_samples)
            else:
#               a partial source has been left over from a previous run
                print("Using partial source %s" % partial_source_barcode)
#               [SP] Select source info for partial_source_barcode (returns pickable_samples)
                current_source_barcode = partial_source_barcode
                print("current_source_barcode = %s" % current_source_barcode)
                pickable_samples = get_pickable_samples_for_source_plate(current_source_barcode)
#                 print(pickable_samples)
                partial_source_barcode = ''

        for pickable_sample in pickable_samples:
            if len(dest_wells) > 0:
#                 print("Length destination wells = %s" % len(dest_wells))
#               [SP] Update destination plate row at coord empty wells[0] to source[src_index]
                update_destination_plate_well_for_source(SYSTEM_NAME, system_run_id, dest_bc, dest_wells.pop(0), current_source_barcode, pickable_sample['source_coordinate'])
            else:
#               destination is full
                destination_completed = True
#               check, source plate may be partial
                if pickable_samples.index(pickable_sample) < (len(pickable_samples) - 1):
#                   source is a partial, store barcode for next run cycle
                    partial_source_barcode = current_source_barcode
                    num_rem_samples = (len(pickable_samples) - pickable_samples.index(pickable_sample) + 1)
                    print("Partial source %s recorded with %s pickable samples remaining" % (partial_source_barcode, num_rem_samples))
                break
#       reset pickable samples for next source
        pickable_samples = []

#   Run complete, destination full

#   Add an example event to test the run event stored procedure
    event_type = "info"
    event = '{"code":"200","message":"run completed","other":"some information"}'
    create_run_event_record(SYSTEM_NAME, system_run_id, event_type, event)

#   [SP] Update run log to completed at the end of the run
    new_state = "completed"
    update_run_record(SYSTEM_NAME, system_run_id, new_state)

print("--------------------")
print("Data setup completed")
print("--------------------")
