-- Run Level View
CREATE VIEW `biosero_uat`.`run_level_view` AS
    SELECT
        r.automation_system,
        r.run_id,
        r.method,
        r.start_time,
        r.end_time,
        TIMESTAMPDIFF(MINUTE,
            r.start_time,
            r.end_time) AS duration_minutes,
        state,
        (CASE r.state
            WHEN 'started' THEN FALSE
            WHEN 'aborted' THEN FALSE
            WHEN 'completed' THEN TRUE
        END) AS completed_successfully,
        r.machine_name,
        r.instrument_serial_number,
        r.configuration_used
    FROM
        `biosero_uat`.`automation_system_runs` r;
