-- An example of a run event insert
INSERT INTO `run_events` (
  automation_system_run_id,
    type,
    event,
    created_at,
    updated_at
)
VALUES (
  (SELECT id FROM `automation_system_runs`
    WHERE automation_system_id = (
      SELECT id FROM `automation_systems`
        WHERE automation_system_name = 'CPA'
    )
    AND system_run_id = 1
  ),
  'error',
  '{"code":"101","message":"an error occurred","other":"some information"}',
  now(),
  now()
);
