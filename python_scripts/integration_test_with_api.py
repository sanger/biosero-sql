# This script generates performs a test run using source barcodes ALREADY set up via the Crawler test data
# generation script. e.g. [[2, 40], [1, 0], [1, 30]] * repeat
# Check the /config/defaults contains your cherrytrack database and lighthouse API connection information.
# You may want to run the reset_database.py script first to create the tables,
# views and stored procedures.

# Set SOURCE_PLATE_BARCODES below to the list of source plate barcodes you want to use.
# These barcodes MUST be already created in Mongo and lighthouse_samples databases, or
# the barcodes will just be treated as having no plate map data.
# It can handle sources with zero pickable samples, as well as from 1 to 96 samples.
# NB. script does one run (one destination created) so total pickable samples == 94.
# NB. to mock an unrecognised barcode put an empty string '' in the list.
# NB. to mock a no plate map data barcode use any string that isn't a source barcode with data e.g. mybarcode

# Run this script at the command line using:
# python3 integration_test_with_api.py

import datetime
import os
import mysql.connector # use command 'pip install mysql-connector-python'
import json
import random
import uuid
import requests
import sys

from config.defaults import *

# NB. CHANGE THIS SOURCE_PLATE_BARCODES CONSTANT BEFORE RUNNING
# For creating a complete destination and all source events:
# - the 'bc_no_pm' barcode creates a 'no plate map' source event
# - the empty '' barcode creates an 'unrecognised' source event
# - the source with 0 pickable samples creates a 'no pickable samples' source event
# - the last source is not fully used so will create a 'partial' source event
# - the destination is filled and creates a 'completed' destination event
# SOURCE_PLATE_BARCODES = ['<source bc 40 pickable samples>', 'bc_no_pm', '<source bc 40 pickable samples', '<source bc 0 pickable samples>', '', '<source bc 40 pickable samples>']

# for creating a partial destination:
# SOURCE_PLATE_BARCODES = ['<source bc 40 pickable samples>']

SOURCE_PLATE_BARCODES = ['TEST-111524', 'bc_no_pm', 'TEST-111525', 'TEST-112104', '', 'TEST-111526']

GBG_METHOD_NAME = 'PSD integration test with API'
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

# Create a connection to the cherrytrack database
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
    dict_result = {}
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor(dictionary=True, buffered=True)

        # Call stored procedure with system name as parameter
        args = [system_name]
        cursor.callproc('getConfigurationForSystem', args)

        # Process the result into a dictionary
        dict_tmp = {}
        for result in cursor.stored_results(): # only one result
            configs = result.fetchall() # array of key value pairs
            for config in configs:
                dict_tmp.update({config['config_key']: config['config_value']})

    except Exception as e:
        print(e)
    else:
        print("Fetched configuration for system name %s" % system_name)
        dict_result = dict_tmp
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()
        return dict_result

# Insert a run record
def create_run_record(system_name, gbg_method_name, user_id):
    result = None
    automation_system_run_id = -1
    try:
        # open DB connection
        db_conn = create_database_connection()

        # disable auto-commit
        db_conn.autocommit = False

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with system name as parameter
        args = [system_name, gbg_method_name, user_id, -1]
        result = cursor.callproc('createRunRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)

        # reverting changes because of exception
        if db_conn.is_connected():
            db_conn.rollback()
    else:
        automation_system_run_id = result[3]
        print("Created run record for id = %s" % automation_system_run_id)
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()

    return automation_system_run_id

# Insert empty wells for the destination plate
def create_empty_destination_plate_wells(automation_system_run_id, destination_barcode, well_coords):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # disable auto-commit
        db_conn.autocommit = False

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters for each well

        for well_coord in well_coords:
            args = [automation_system_run_id, destination_barcode, well_coord]
            cursor.callproc('createEmptyDestinationPlateWellsRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)

        # reverting changes because of exception
        if db_conn.is_connected():
            db_conn.rollback()
    else:
        print("Created destination plate %s empty wells" % destination_barcode)
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()

# Insert rows for the control plate
def create_control_plate(automation_system_run_id, control_plate_barcode, controls):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # disable auto-commit
        db_conn.autocommit = False

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters for each well
        for control in controls:
            args = [automation_system_run_id, control_plate_barcode, control['coordinate'], control['control']]
            cursor.callproc('createControlPlateWellsRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)

        # reverting changes because of exception
        if db_conn.is_connected():
            db_conn.rollback()
    else:
        print("Created control plate %s for run id %s" % (control_plate_barcode, automation_system_run_id))
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()

# Update the destination plate well after picking a control
def update_destination_plate_well_for_control(automation_system_run_id, destination_barcode, destination_coordinate, control_barcode, control_coordinate):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # disable auto-commit
        db_conn.autocommit = False

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters
        args = [automation_system_run_id, destination_barcode, destination_coordinate, control_barcode, control_coordinate]
        cursor.callproc('updateDestinationPlateWellWithControl', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)

        # reverting changes because of exception
        if db_conn.is_connected():
            db_conn.rollback()
    else:
        print("Updated destination coord %s with picked control %s coord %s" % (destination_coordinate, control_barcode, control_coordinate))
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()

def generate_destination_plate_barcode() -> str:
    barcodes = generate_baracoda_barcodes(1, DESTINATION_BARACODA_PREFIX)
    return barcodes[0]

def generate_baracoda_barcodes(count, prefix) -> list:
    # Current accepted prefixes: https://github.com/sanger/baracoda/blob/4f001ecc771311ec85c07ea5f5e67e4c313adef5/tests/data/fixture_data.py

    baracoda_url = f"http://{BARACODA_URL}/barcodes_group/{prefix}/new?count={count}"

    try:
        print(f"Sending request for destination barcode to: {baracoda_url}")
        response = requests.post(baracoda_url, data={})

        print(response.status_code, response.reason)

        response_json = response.json()
        barcodes = response_json["barcodes_group"]["barcodes"]
        return barcodes
    except requests.ConnectionError:
        raise requests.ConnectionError("Unable to access Baracoda")

# Choose a random coordinate from a list (and removes it from list)
def choose_random_coordinate(well_coords) -> str:
    index = random.randint(0, (len(well_coords) - 1))
    coord = well_coords[index]
    well_coords.remove(coord)
    return coord

# Insert source plate well rows for each pickable sample
def create_source_plate(source_barcode, pickable_samples):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # disable auto-commit
        db_conn.autocommit = False

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters for each well
        for pickable_sample in pickable_samples:
            args = [source_barcode, pickable_sample['source_coordinate_unpadded'], pickable_sample['sample_id'], pickable_sample['rna_id'], pickable_sample['lab_id']]
            cursor.callproc('createSourcePlateWellRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)

        # reverting changes because of exception
        if db_conn.is_connected():
            db_conn.rollback()
    else:
        print("Created source plate %s with %s pickable samples" % (source_barcode, len(pickable_samples)))
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()

# Check whether source plate exists
def does_source_plate_exist(source_barcode):
    plate_exists = None
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with source barcode
        args = [source_barcode]

        cursor.callproc('doesSourcePlateExist', args)

        # Process the result
        for result in cursor.stored_results(): # only one result
            # this stored proc returns 0 or 1
            result = result.fetchone() # array of key value pairs
            plate_exists = result[0]
    except Exception as e:
        print(e)
    else:
        print("Checked if source plate exists for barcode %s" % barcode)

    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()
        return plate_exists

# Fetch the remaining pickable samples for a source plate
def remaining_pickable_samples_for_source_plate(barcode):
    pickable_samples = []
    try:
        # open DB connection
        db_conn = create_database_connection()

        # Get a cursor
        cursor = db_conn.cursor(dictionary=True, buffered=True)

        # Call stored procedure with source barcode
        args = [barcode]
        cursor.callproc('getPickableSamplesForSourcePlate', args)

        # Process the result into a dictionary
        for result in cursor.stored_results(): # only one result
            wells = result.fetchall() # array of key value pairs
            for well in wells:
                pickable_samples.append(
                    {
                        'source_coordinate_unpadded': well['coordinate'],
                        'sample_id': well['sample_id'],
                        'rna_id': well['rna_id'],
                        'lab_id': well['lab_id']
                    }
                )

    except Exception as e:
        print(e)
    else:
        print("Fetched pickable samples for source plate %s" % barcode)
        pickable_samples_in_db = pickable_samples

    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()
        return pickable_samples_in_db

# Update the destination plate well for a picked source plate well
def update_destination_plate_well_for_source(automation_system_run_id, destination_barcode, destination_coordinate, source_barcode, source_coordinate):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # disable auto-commit
        db_conn.autocommit = False

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters
        args = [automation_system_run_id, destination_barcode, destination_coordinate, source_barcode, source_coordinate]
        cursor.callproc('updateDestinationPlateWellWithSource', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)

        # reverting changes because of exception
        if db_conn.is_connected():
            db_conn.rollback()
    else:
        print("Updated destination coord %s with picked source %s coord %s" % (destination_coordinate, source_barcode, source_coordinate))
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()

# Update the run record at the end of the run
def update_run_record(automation_system_run_id, new_state):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # disable auto-commit
        db_conn.autocommit = False

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters
        args = [automation_system_run_id, new_state]
        cursor.callproc('updateRunState', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)

        # reverting changes because of exception
        if db_conn.is_connected():
            db_conn.rollback()
    else:
        print("Updated run record id %s with state %s" % (automation_system_run_id, new_state))
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()

# Insert a run event record
def create_run_event_record(automation_system_run_id, event_type, event):
    try:
        # open DB connection
        db_conn = create_database_connection()

        # disable auto-commit
        db_conn.autocommit = False

        # Get a cursor
        cursor = db_conn.cursor()

        # Call stored procedure with parameters
        args = [automation_system_run_id, event_type, event]
        cursor.callproc('createRunEventRecord', args)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)

        # reverting changes because of exception
        if db_conn.is_connected():
            db_conn.rollback()
    else:
        print("Created run event type %s with event %s" % (event_type, event))
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()

def get_source_plate_from_lims(source_barcode):
    print(f"Getting source plate information for barcode {source_barcode}")

    lighthouse_url = f"http://{LIGHTHOUSE_URL}" f"/plates?barcodes={source_barcode}"

    try:
        print(f"Attempting GET from {lighthouse_url}")
        response = requests.get(lighthouse_url)

        print(f"Response status code: {response.status_code}")

        return response.json()
    except requests.ConnectionError:
        raise requests.ConnectionError("Unable to access Lighthouse")

def post_event_to_lighthouse(url, payload):
    try:
        headers = {"Authorization": APP_KEY}

        print(f"Attempting POST to {url} with payload {payload}")
        response = requests.post(url, headers=headers, data=payload)

        print(f"Response status code: {response.status_code}")
        return response.status_code
    except requests.ConnectionError:
        raise requests.ConnectionError("Unable to access Lighthouse")

def call_lighthouse_source_plate_unrecognised(automation_system_run_id):
    print("calling API to record source plate unrecognisable event")

    lighthouse_url = f"http://{LIGHTHOUSE_URL}" f"/events"

    payload = {
      "automation_system_run_id": automation_system_run_id,
      "event_type": "lh_biosero_cp_source_plate_unrecognised"
    }

    return post_event_to_lighthouse(lighthouse_url, payload)

def call_lighthouse_source_no_plate_map_data(automation_system_run_id, source_barcode):
    print("calling API to record source plate no plate map data event")

    lighthouse_url = f"http://{LIGHTHOUSE_URL}" f"/events"

    payload = {
      "automation_system_run_id": automation_system_run_id,
      "barcode": source_barcode,
      "event_type": "lh_biosero_cp_source_no_plate_map_data"
    }

    return post_event_to_lighthouse(lighthouse_url, payload)

def call_lighthouse_source_plate_no_pickable_samples(automation_system_run_id, source_barcode):
    print("calling API to record source plate no pickable samples event")

    lighthouse_url = f"http://{LIGHTHOUSE_URL}" f"/events"

    payload = {
      "automation_system_run_id": automation_system_run_id,
      "barcode": source_barcode,
      "event_type": "lh_biosero_cp_source_no_pickable_samples"
    }

    return post_event_to_lighthouse(lighthouse_url, payload)

def call_lighthouse_source_partial(automation_system_run_id, source_barcode):
    print("calling API to record source plate partial event")

    lighthouse_url = f"http://{LIGHTHOUSE_URL}" f"/events"

    payload = {
      "automation_system_run_id": automation_system_run_id,
      "barcode": source_barcode,
      "event_type": "lh_biosero_cp_source_partial"
    }

    return post_event_to_lighthouse(lighthouse_url, payload)

def call_lighthouse_source_completed(automation_system_run_id, source_barcode):
    print("calling API to record source plate completed event")

    lighthouse_url = f"http://{LIGHTHOUSE_URL}" f"/events"

    payload = {
      "automation_system_run_id": automation_system_run_id,
      "barcode": source_barcode,
      "event_type": "lh_biosero_cp_source_completed"
    }

    return post_event_to_lighthouse(lighthouse_url, payload)

def call_lighthouse_destination_partial(automation_system_run_id, destination_barcode):
    print("calling API to record destination plate partial event")

    lighthouse_url = f"http://{LIGHTHOUSE_URL}" f"/events"

    payload = {
      "automation_system_run_id": automation_system_run_id,
      "barcode": destination_barcode,
      "event_type": "lh_biosero_cp_destination_plate_partial"
    }

    return post_event_to_lighthouse(lighthouse_url, payload)

def call_lighthouse_create_destination_plate(automation_system_run_id, destination_barcode):
    print("calling API to create destination plate")

    lighthouse_url = f"http://{LIGHTHOUSE_URL}" f"/events"

    payload = {
      "automation_system_run_id": automation_system_run_id,
      "barcode": destination_barcode,
      "event_type": "lh_biosero_cp_destination_plate_completed"
    }

    return post_event_to_lighthouse(lighthouse_url, payload)

# =============
# Script starts here
# =============
partial_source_barcode = ''
sample_uuid_index = 1

print("-------------")
print("Run started")
print("-------------")
print("Fetching system configuration")
# [SP] Fetch config for CPA
configuration = get_configuration_for_system('CPA')
if configuration == {}:
    print("Aborting, no configuration selected")
    sys.exit()
# [SP] Create run (run id = run_id_index) and run_configuration rows
automation_system_run_id = create_run_record(SYSTEM_NAME, GBG_METHOD_NAME, USER_ID)
if automation_system_run_id < 0:
    print("Aborting, no run set up")
    sys.exit()
print("Created a new run record, automation_system_run_id (database id) = %s" % automation_system_run_id)
# [SP] Insert destination plate 96 empty rows
dest_wells = WELL_COORDS.copy()
destination_barcode = generate_destination_plate_barcode()
create_empty_destination_plate_wells(automation_system_run_id, destination_barcode, dest_wells)
# Insert control plate rows using config
# [SP] Insert controls - from config control coordinates =
# [{coordinate: <positive coord>, control: 'positive'},{coordinate: <negative coord>, control: 'negative'}
pos_control_coord = configuration['control_coordinate_positive']
neg_control_coord = configuration['control_coordinate_negative']
controls = [{'coordinate': pos_control_coord, 'control': 'positive'},{'coordinate': neg_control_coord, 'control': 'negative'}]
create_control_plate(automation_system_run_id, CONTROL_PLATE_BC, controls)
print("Control plate coords: Pos in %s, neg in %s" % (pos_control_coord, neg_control_coord))
# Update destination plate rows for controls
pos_control_dest_coord = choose_random_coordinate(dest_wells)
neg_control_dest_coord = choose_random_coordinate(dest_wells)
# For Positive
# [SP] Update destination with pos control - dest coord = random coord from (empty wells - excluded wells from config)
update_destination_plate_well_for_control(automation_system_run_id, destination_barcode, pos_control_dest_coord, CONTROL_PLATE_BC, pos_control_coord)
# For Negative
# [SP] Update destination with neg control - dest coord = random coord from (empty wells - excluded wells from config)
update_destination_plate_well_for_control(automation_system_run_id, destination_barcode, neg_control_dest_coord, CONTROL_PLATE_BC, neg_control_coord)

src_plate_index = 0
pickable_samples = []
current_source_barcode = None
destination_completed = False

# loop until destination has no empty wells remaining
while not destination_completed:
    if len(pickable_samples) == 0:
        # check we still have source barcodes remaining in the list
        print(f"No pickable samples, check next source in list (index = {src_plate_index})")
        if len(SOURCE_PLATE_BARCODES) > src_plate_index:
            # fetch next source plate barcode from list
            current_source_barcode = SOURCE_PLATE_BARCODES[src_plate_index]
            print(f"New source plate barcode = {current_source_barcode}")
            print(f"Source barcode to be checked = {current_source_barcode}")

            # process unrecognised barcode(s)
            while current_source_barcode == '':
                print("Current source barcode is an empty string, mock as unrecognised")
                # no barcode scanned
                # [API Call here - Source event unrecognisable plate]
                # Lighthouse writes event to MLWH
                call_lighthouse_source_plate_unrecognised(automation_system_run_id)

                # increment counter
                src_plate_index += 1
                print(f"Counter incremented = {src_plate_index}")

                # check we still have source barcodes remaining in the list
                if len(SOURCE_PLATE_BARCODES) > src_plate_index:
                    # fetch next source plate barcode from list
                    current_source_barcode = SOURCE_PLATE_BARCODES[src_plate_index]
                    print(f"New source plate barcode after blank = {current_source_barcode}")
                else:
                    # TODO: test this works if last barcode in list is ''
                    # end looping, no sources remaining
                    current_source_barcode = None

            if current_source_barcode != None:
                # first check if source plate is already in cherrytrack i.e. partial source from previous run
                source_exists = does_source_plate_exist(current_source_barcode)

                if source_exists:
                    print(f"Source barcode { current_source_barcode } already exists in Cherrytrack")
                    pickable_samples = remaining_pickable_samples_for_source_plate(current_source_barcode)
                else:
                    print(f"Source barcode { current_source_barcode } does NOT exist, fetch details")

                    has_plate_map = False

                    # [API - LIMS Lookup for current_source_barcode]
                    response = get_source_plate_from_lims(current_source_barcode)

                    has_plate_map = response['plates'][0]['has_plate_map']
                    print(f"Source barcode { current_source_barcode } has plate map = { has_plate_map }")

                    if has_plate_map:
                        pickable_samples = response['plates'][0]['pickable_samples']
                        # print(f"pickable_samples = {pickable_samples}")

                        if (pickable_samples != None) and (len(pickable_samples) > 0):
                            print("Creating cherrytrack source plate rows")
                            # [SP] Insert new source rows (pickable_samples)
                            create_source_plate(current_source_barcode, pickable_samples)
                        else:
                            # [API Call here - Source event no pickable samples]
                            # Lighthouse writes event to MLWH
                            call_lighthouse_source_plate_no_pickable_samples(automation_system_run_id, current_source_barcode)

                            # increment counter
                            src_plate_index += 1
                            print(f"Counter incremented = {src_plate_index}")

                            # get next source
                            continue
                    else:
                        # [API Call here - Source event no plate map data]
                        # Lighthouse writes event to MLWH
                        call_lighthouse_source_no_plate_map_data(automation_system_run_id, current_source_barcode)

                        # increment counter
                        src_plate_index += 1
                        print(f"Counter incremented = {src_plate_index}")

                        # get next source
                        continue
        else:
            print("No remaining source plates")
            # [API Call here - Destination partial]
            # Lighthouse calls cherrytrack API to fetch destination plate information
            # drops down to code for end of run
            call_lighthouse_destination_partial(automation_system_run_id, destination_barcode)

            # set flag so know finished
            destination_completed = True

    pickable_samples_index = 0
    for pickable_sample in pickable_samples:
        if len(dest_wells) > 0:
            #  print("Length destination wells = %s" % len(dest_wells))
            # [SP] Update destination plate row at coord empty wells[0] to source[src_index]
            update_destination_plate_well_for_source(automation_system_run_id, destination_barcode, dest_wells.pop(0), current_source_barcode, pickable_sample['source_coordinate_unpadded'])

            if (pickable_samples_index + 1) >= len(pickable_samples):
                # source is used up
                # [API call here - Source event completed]
                # Lighthouse API calls cherrytrack service to select source plate information
                # and creates event in MLWH
                call_lighthouse_source_completed(automation_system_run_id, current_source_barcode)

                # increment counter
                src_plate_index += 1
                print(f"Counter incremented = {src_plate_index}")
            else:
                pickable_samples_index += 1
        else:
            # destination is full
            destination_completed = True

            # [API call here - Create completed destination plate in LIMS]
            # Lighthouse API calls cherrytrack service to select destination plate information
            # Destination plate gets created in SS
            call_lighthouse_create_destination_plate(automation_system_run_id, destination_barcode)

            # check, source plate may be partial
            if pickable_samples.index(pickable_sample) < (len(pickable_samples) - 1):
                # source is a partial, store barcode for next run cycle
                partial_source_barcode = current_source_barcode
                num_rem_samples = (len(pickable_samples) - pickable_samples.index(pickable_sample))
                print("Partial source %s recorded with %s pickable samples remaining" % (partial_source_barcode, num_rem_samples))

                # [API call here - Source event partial]
                # Lighthouse API calls cherrytrack service to select source plate information
                # and creates event in MLWH
                call_lighthouse_source_partial(automation_system_run_id, current_source_barcode)
            break

    # reset pickable samples for next source
    pickable_samples = []

# Run complete

# Add an example event to test the run event stored procedure
event_type = "info"
event = '{"code":"200","message":"run completed","other":"some information"}'
create_run_event_record(automation_system_run_id, event_type, event)

# [SP] Update run log to completed at the end of the run
new_state = "completed"
update_run_record(automation_system_run_id, new_state)

print("-------------")
print("Run completed")
print("-------------")
