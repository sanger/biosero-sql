-- Insert configuration for both workcells
INSERT INTO `biosero_uat`.`configurations` (
  automation_system_name,
  config_key,
  config_value,
  description,
  created_at,
  updated_at
)
VALUES
('CPA', 'config_version', '2', 'version of these configurations', now(), now()),
('CPA', 'change_description', 'moved the positive control', 'describes what was changed in this version', now(), now()),
('CPA', 'change_user_id', 'ab1', 'user that made the changes', now(), now()),
('CPA', 'control_coordinate_positive', 'A1', 'the coordinate of the positive control on the control plate', now(), now()),
('CPA', 'control_coordinate_negative', 'H12', 'the coordinate of the negative control on the control plate', now(), now()),
('CPA', 'control_excluded_destination_wells', 'B5, B6, B7', 'list of wells to exclude from control placement on the destination', now(), now()),
('CPA', 'bv_barcode_prefixes_control', 'DN, DM', 'list of possible prefixes allowed for bed verification of the control plate barcodes', now(), now()),
('CPA', 'bv_barcode_prefixes_destination', 'HT, HZ', 'list of possible prefixes allowed for bed verification of the destination plate barcodes', now(), now()),
('CPA', 'bv_deck_barcode_control', 'DECKC123', 'barcode for the deck location of the control plate on the liquid handler for bed verification', now(), now()),
('CPA', 'bv_deck_barcode_destination', 'DECKP123', 'barcode for the deck location of the destination plate on the liquid handler for bed verification', now(), now()),
('CPB', 'config_version', '2', 'version of these configurations', now(), now()),
('CPB', 'change_description', 'moved the positive control', 'describes what was changed in this version', now(), now()),
('CPB', 'change_user_id', 'ab1', 'user that made the changes', now(), now()),
('CPB', 'control_coordinate_positive', 'A1', 'the coordinate of the positive control on the control plate', now(), now()),
('CPB', 'control_coordinate_negative', 'H12', 'the coordinate of the negative control on the control plate', now(), now()),
('CPB', 'control_excluded_destination_wells', 'B5, B6, B7', 'list of wells to exclude from control placement on the destination', now(), now()),
('CPB', 'bv_barcode_prefixes_control', 'DN, DM', 'list of possible prefixes allowed for bed verification of the control plate barcodes', now(), now()),
('CPB', 'bv_barcode_prefixes_destination', 'HT, HZ', 'list of possible prefixes allowed for bed verification of the destination plate barcodes', now(), now()),
('CPB', 'bv_deck_barcode_control', 'DECKC123', 'barcode for the deck location of the control plate on the liquid handler for bed verification', now(), now()),
('CPB', 'bv_deck_barcode_destination', 'DECKP123', 'barcode for the deck location of the destination plate on the liquid handler for bed verification', now(), now())
;
