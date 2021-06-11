-- An example of a run event insert
INSERT INTO `run_events` (
  automation_system_run_id,
  type,
  event,
  created_at,
  updated_at
)
VALUES (
  1,
  'error',
  '{"code":"101","message":"an error occurred","other":"some information"}',
  now(),
  now()
);
