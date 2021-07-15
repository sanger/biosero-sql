-- Insert automation system rows for both workcells
INSERT INTO `automation_systems` (
  automation_system_name,
  automation_system_manufacturer,
  liquid_handler_serial_number,
  created_at,
  updated_at
)
VALUES
('CPA', 'biosero', '908G', now(), now()),
('CPB', 'biosero', '973G', now(), now())
;
