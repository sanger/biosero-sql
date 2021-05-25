-- Insert automation system rows for both workcells
INSERT INTO `biosero_uat`.`automation_systems` (
  automation_system_name,
  automation_system_manufacturer,
  liquid_handler_serial_number,
  created_at,
  updated_at
)
VALUES
('CPA', 'biosero', 'LHS000001', now(), now()),
('CPB', 'biosero', 'LHS000001', now(), now())
;
