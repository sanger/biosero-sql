-- Run Level View
CREATE VIEW `run_level_view` AS
    SELECT
        asys.automation_system_manufacturer,
        asys.automation_system_name,
        asys.liquid_handler_serial_number,
        asysr.id AS automation_system_run_id,
        asysr.method,
        asysr.user_id,
        asysr.start_time,
        asysr.end_time,
        TIMESTAMPDIFF(
            MINUTE,
            asysr.start_time,
            asysr.end_time
        ) AS duration_minutes,
        state,
        (CASE asysr.state
            WHEN 'started' THEN false
            WHEN 'aborted' THEN false
            WHEN 'completed' THEN true
        END) AS completed_successfully,
        rc.configuration_used
    FROM `automation_system_runs` asysr
    JOIN `automation_systems` asys
        ON asysr.automation_system_id = asys.id
    JOIN `run_configurations` rc
        ON rc.automation_system_run_id = asysr.id
;
