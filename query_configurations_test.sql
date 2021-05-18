INSERT INTO `biosero_test`.`configurations` (
machine_name,
config_key,
config_value,
description,
created_at,
updated_at
)
VALUES
('Workcell 1', 'version', '2', 'version of these configs', now(), now()), ('Workcell 1', 'change_description', 'moved the positive control', 'describes what was changed in this version', now(), now()),
('Workcell 1', 'changed_by_user', 'ab1', 'user that made the changes', now(), now()),
('Workcell 1', 'positive_control_coordinate', 'A1', 'the position of the positive control on the control plate', now(), now()),
('Workcell 1', 'negative_control_coordinate', 'H12', 'the position of the negative control on the control plate', now(), now()),
('Workcell 1', 'excluded_control_wells', 'B5, B6, B7', 'list of wells to exclude from control placement on the destination', now(), now()),
('Workcell 1', 'control_plate_barcode_prefixes', 'DN', 'list of possible prefixes allowed for bed verification of the control plate barcodes', now(), now()),
('Workcell 1', 'destination_plate_barcode prefixes', 'HT, HZ', 'list of possible prefixes allowed for bed verification of the destination plate barcodes', now(), now()),
('Workcell 2', 'version', '2', 'version of these configs', now(), now()),
('Workcell 2', 'change_description', 'moved the positive control', 'describes what was changed in this version', now(), now()),
('Workcell 2', 'changed_by_user', 'ab1', 'user that made the changes', now(), now()),
('Workcell 2', 'positive_control_coordinate', 'A1', 'the position of the positive control on the control plate', now(), now()),
('Workcell 2', 'negative_control_coordinate', 'H12', 'the position of the negative control on the control plate', now(), now()),
('Workcell 2', 'excluded_control_wells', 'B5, B6, B7', 'list of wells to exclude from control placement on the destination', now(), now()),
('Workcell 2', 'control_plate_barcode_prefixes', 'DN', 'list of possible prefixes allowed for bed verification of the control plate barcodes', now(), now()),
('Workcell 2', 'destination_plate_barcode prefixes', 'HT, HZ', 'list of possible prefixes allowed for bed verification of the destination plate barcodes', now(), now())
;
