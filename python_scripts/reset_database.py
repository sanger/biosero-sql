# DEPRECATED: USE CHERRYTRACK REPOSITORY

# CARE: This script DROPS and RECREATES the database.
# It resets the database, builds the tables, views and stored procedures, and
# inserts example data into the automation_systems and configurations tables.
# It does this by running the SQL files found elsewhere in this repository.

import mysql.connector
import os
import re

from config.defaults import *

BASE_PATH = os.path.join(os.path.dirname(__file__), '..')

SQL_FILES = [
    'tables_script.sql',
    'views/view_run_level_view.sql',
    'views/view_sample_level_view.sql',
    'example_queries/automation_systems_insert_example.sql',
    'example_queries/configurations_insert_example.sql',
    'stored_procedures/create_control_plate_wells_record.sql',
    'stored_procedures/create_empty_destination_plate_wells_record.sql',
    'stored_procedures/create_run_record.sql',
    'stored_procedures/create_run_event_record.sql',
    'stored_procedures/create_source_plate_well_record.sql',
    'stored_procedures/does_source_plate_exist.sql',
    'stored_procedures/get_configuration_for_system.sql',
    'stored_procedures/get_details_for_destination_plate.sql',
    'stored_procedures/get_pickable_samples_for_source_plate.sql',
    'stored_procedures/update_destination_plate_well_with_control.sql',
    'stored_procedures/update_destination_plate_well_with_source.sql',
    'stored_procedures/update_run_state.sql'
]

def create_database_connection(database_name):
    db_conn = mysql.connector.connect(
       host=DB_HOST,
       port=DB_PORT,
       user=DB_USER,
       passwd=DB_PWD,
       database=database_name
    )
    return db_conn

# Because the stored procedure scripts are written with DELIMITERs and other syntactically
# complex content, this method has to deal with that when parsing the SQL statements.
def execute_scripts_from_file(cursor, filepath):
    ignorestatement = False # by default each time we get a ';' that's our cue to execute.
    statement = ""
    for line in open(filepath):
        if line.startswith('DELIMITER'):
            if not ignorestatement:
                ignorestatement = True # disable executing when we get a ';'
                continue
            else:
                ignorestatement = False # re-enable execution of sql queries on ';'
                line = " ;" # Rewrite the DELIMITER command to allow the block of sql to execute
        if re.match(r'--', line):  # ignore sql comment lines
            continue
        if line.startswith('END$$'):
            line = "END" # remove the end limiter dollars
        if not re.search(r'[^-;]*;', line) or ignorestatement:  # keep appending lines that don't end in ';' or DELIMITER has been called
            statement = statement + line
        else:  # when you get a line ending in ';' then exec statement and reset for next statement providing the DELIMITER hasn't been set
            statement = statement + line
            print("- - - - - - - - - - - - - - - - -")
            print("Executing SQL statement:\n%s" % statement)
            print("- - - - - - - - - - - - - - - - -")
            try:
                cursor.execute(statement)
                statement = ""
            except Exception as e:
                print(e)
                raise

def reset_database():
    try:
        # open DB connection
        db_conn = create_database_connection(None)

        # disable auto-commit
        db_conn.autocommit = False

        # Get a cursor
        cursor = db_conn.cursor()

        drop_statement = "DROP DATABASE IF EXISTS `%s`;" % DB_NAME
        create_statement = "CREATE DATABASE IF NOT EXISTS `%s`;" % DB_NAME

        reset_statements = [
            drop_statement,
            create_statement
        ]

        for statement in reset_statements:
            print("- - - - - - - - - - - - - - - - -")
            print("Executing SQL statement:\n%s" % statement)
            print("- - - - - - - - - - - - - - - - -")
            try:
                cursor.execute(statement)
            except Exception as e:
                print(e)
                raise

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("==============")
        print("Database Reset")
        print("==============")
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()

def setup_database(sqlfiles):
    try:
        # open DB connection
        db_conn = create_database_connection(DB_NAME)

        # Get a cursor
        cursor = db_conn.cursor()

        for sqlfile in sqlfiles:
            filepath = os.path.join(BASE_PATH, sqlfile)
            print("- - - - - - - - - - - - - - - - -")
            print("Reading filepath: %s" % filepath)
            print("- - - - - - - - - - - - - - - - -")
            execute_scripts_from_file(cursor, filepath)

        # commit changes
        db_conn.commit()
    except Exception as e:
        print(e)
    else:
        print("======================")
        print("All SQL files executed")
        print("======================")
    finally:
        if db_conn is not None:
            if db_conn.is_connected():
                if cursor is not None:
                    cursor.close()
                db_conn.close()


reset_database()
setup_database(SQL_FILES)