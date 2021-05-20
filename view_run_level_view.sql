-- Run Level View
CREATE VIEW `biosero_uat`.`run_level_view` AS
    SELECT
        r.automation_system_type,
        r.automation_system_name,
        r.system_run_id,
        r.method,
        r.user_id,
        r.start_time,
        r.end_time,
        TIMESTAMPDIFF(
            MINUTE,
            r.start_time,
            r.end_time
        ) AS duration_minutes,
        state,
        (CASE r.state
            WHEN 'started' THEN false
            WHEN 'aborted' THEN false
            WHEN 'completed' THEN true
        END) AS completed_successfully,
        r.liquid_handler_serial_number,
        r.configuration_used
    FROM `biosero_uat`.`automation_system_runs` r;
