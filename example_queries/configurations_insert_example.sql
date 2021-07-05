-- Insert configuration for both workcells
INSERT INTO `configurations` (
  automation_system_id,
  config_key,
  config_value,
  description,
  created_at,
  updated_at
)
VALUES
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'config_version', '1.0', 'version of these configurations', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'change_description', 'initial version', 'describes what was changed in this version', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'change_user_id', 'PSD', 'user that made the changes', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'control_coordinate_positive', 'A1', 'the coordinate of the positive control on the control plate', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'control_coordinate_negative', 'H12', 'the coordinate of the negative control on the control plate', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'control_excluded_destination_wells', '', 'list of wells to exclude from control placement on the destination', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'bv_barcode_prefixes_control', 'DN', 'list of possible prefixes allowed for bed verification of the control plate barcodes', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'bv_barcode_prefixes_destination', 'HT', 'list of possible prefixes allowed for bed verification of the destination plate barcodes', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'bv_deck_barcode_control', 'DECKC123', 'barcode for the deck location of the control plate on the liquid handler for bed verification', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPA'), 'bv_deck_barcode_destination', 'DECKP123', 'barcode for the deck location of the destination plate on the liquid handler for bed verification', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'config_version', '1.0', 'version of these configurations', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'change_description', 'initial version', 'describes what was changed in this version', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'change_user_id', 'PSD', 'user that made the changes', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'control_coordinate_positive', 'A1', 'the coordinate of the positive control on the control plate', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'control_coordinate_negative', 'H12', 'the coordinate of the negative control on the control plate', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'control_excluded_destination_wells', '', 'list of wells to exclude from control placement on the destination', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'bv_barcode_prefixes_control', 'DN', 'list of possible prefixes allowed for bed verification of the control plate barcodes', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'bv_barcode_prefixes_destination', 'HT', 'list of possible prefixes allowed for bed verification of the destination plate barcodes', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'bv_deck_barcode_control', 'DECKC123', 'barcode for the deck location of the control plate on the liquid handler for bed verification', now(), now()),
((SELECT id FROM `automation_systems` WHERE automation_system_name = 'CPB'), 'bv_deck_barcode_destination', 'DECKP123', 'barcode for the deck location of the destination plate on the liquid handler for bed verification', now(), now())
;
