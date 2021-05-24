-- Automation systems table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`automation_systems` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'unique database identifier for this row',
  `automation_system_name` VARCHAR(255) NOT NULL COMMENT 'the name for the workcell as used by the lab staff',
  `automation_system_manufacturer` VARCHAR(255) NOT NULL COMMENT 'used to distinguish groups of cherrypicking systems supplied by different manufacturers',
  `liquid_handler_serial_number` VARCHAR(255) NOT NULL COMMENT 'the serial number of the liquid handler on the workcell performing this run',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was created in the database',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was updated in the database',
  PRIMARY KEY (`id`),
  CONSTRAINT `unique_automation_system` UNIQUE
  (`automation_system_name`,`automation_system_manufacturer`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Automation system runs table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`automation_system_runs` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'unique database identifier for this row',
  `automation_system_id` INT NOT NULL COMMENT 'the foreign key id from the automation systems table',
  `system_run_id` INT NOT NULL UNIQUE COMMENT 'the run id as used by the workcell software',
  `method` VARCHAR(255) NOT NULL COMMENT 'the name of the method running on the workcell, including a version number',
  `user_id` VARCHAR(255) NOT NULL COMMENT 'the user id of the lab staff member performing the run',
  `start_time` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the date time when the run started',
  `end_time` DATETIME DEFAULT NULL COMMENT 'the date time when the run ended, whether completed or aborted',
  `state` ENUM('started','completed','aborted') NOT NULL COMMENT 'the state of the run',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was created in the database',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was updated in the database',
  PRIMARY KEY (`id`),
  FOREIGN KEY (automation_system_id)
  REFERENCES `biosero_uat`.`automation_systems`(`id`),
  CONSTRAINT `automation_system_run_id` UNIQUE
  (`system_run_id`,`automation_system_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Run Configurations table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`run_configurations` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'unique database identifier for this row',
  `automation_system_run_id` INT NOT NULL COMMENT 'the foreign key id from the automation system runs table, uniquely identifying the run',
  `configuration_used` JSON NOT NULL COMMENT 'the json representation of the configuration extracted from the configurations table that was used for this run',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was created in the database',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was updated in the database',
  PRIMARY KEY (`id`),
  FOREIGN KEY (automation_system_run_id)
  REFERENCES `biosero_uat`.`automation_system_runs`(`id`),
  CONSTRAINT `unique_automation_system_run_id` UNIQUE (`automation_system_run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Run Events table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`run_events` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'unique database identifier for this row',
  `automation_system_run_id` INT NOT NULL COMMENT 'the foreign key id from the automation system runs table, uniquely identifying the run',
  `type` ENUM('info','warning','error') COMMENT 'the type of the event being logged',
  `event` JSON NOT NULL COMMENT 'the json representation of the event information',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was created in the database',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was updated in the database',
  PRIMARY KEY (`id`),
  FOREIGN KEY (automation_system_run_id)
  REFERENCES `biosero_uat`.`automation_system_runs`(`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Source Plate Wells table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`source_plate_wells` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'unique database identifier for this row',
  `barcode` VARCHAR(255) NOT NULL COMMENT 'the barcode for this plate, as scanned from the label',
  `coordinate` ENUM('A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12','E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12') NOT NULL COMMENT 'the coordinate of this well within the plate',
  `sample_id` VARCHAR(36) DEFAULT NULL COMMENT 'the unique uuid identifier for the sample in this source well, passed through from the LIMS lookup API endpoint',
  `rna_id` VARCHAR(255) DEFAULT NULL COMMENT 'the rna id identifier for the sample, passed through from the LIMS lookup API endpoint',
  `lab_id` VARCHAR(255) DEFAULT NULL COMMENT 'the lighthouse lab id, passed through from the LIMS lookup API endpoint',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was created in the database',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was updated in the database',
  PRIMARY KEY (`id`),
  KEY `index_source_plate_wells_on_source_barcode` (`barcode`),
  CONSTRAINT `source_plate_well` UNIQUE (`barcode`,`coordinate`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Control Plate Wells table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`control_plate_wells` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'unique database identifier for this row',
  `automation_system_run_id` INT NOT NULL COMMENT 'the foreign key id from the automation system runs table, uniquely identifying the run',
  `barcode` VARCHAR(255) NOT NULL COMMENT 'the barcode for this plate, as scanned from the label',
  `coordinate` ENUM('A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12','E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12') NOT NULL COMMENT 'the coordinate of this well within the plate',
  `control` ENUM('positive','negative') DEFAULT NULL COMMENT 'the type of control in this well',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was created in the database',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was updated in the database',
  PRIMARY KEY (`id`),
  FOREIGN KEY (automation_system_run_id)
  REFERENCES `biosero_uat`.`automation_system_runs`(`id`),
  CONSTRAINT `control_plate_well` UNIQUE (`automation_system_run_id`,`barcode`,`coordinate`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Destination Plate Wells table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`destination_plate_wells` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'unique database identifier for this row',
  `automation_system_run_id` INT NOT NULL COMMENT 'the foreign key id from the automation system runs table, uniquely identifying the run',
  `barcode` VARCHAR(255) NOT NULL COMMENT 'the barcode for this plate, as scanned from the label',
  `coordinate` ENUM('A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12','E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12') NOT NULL COMMENT 'the coordinate of this well within the plate',
  `source_plate_well_id` INT DEFAULT NULL COMMENT 'the foreign key from the source plate wells table, uniquely identifying the source well picked into this destination well',
  `control_plate_well_id` INT DEFAULT NULL COMMENT 'the foreign key from the control plate wells table, uniquely identifying the control well picked into this destination well',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was created in the database',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was updated in the database',
  PRIMARY KEY (`id`),
  KEY `index_destination_plate_wells_on_barcode` (`barcode`),
  CONSTRAINT `run_destination_plate_well` UNIQUE (`automation_system_run_id`,`barcode`,`coordinate`),
  CONSTRAINT `source_plate_well_id_or_control_plate_well_id` CHECK (
    `control_plate_well_id` = 1 XOR `source_plate_well_id` = 1
  ),
  FOREIGN KEY (source_plate_well_id)
  REFERENCES `biosero_uat`.`source_plate_wells`(`id`),
  FOREIGN KEY (control_plate_well_id)
  REFERENCES `biosero_uat`.`control_plate_wells`(`id`),
  FOREIGN KEY (automation_system_run_id)
  REFERENCES `biosero_uat`.`automation_system_runs`(`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Configurations table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`configurations` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'unique database identifier for this row',
  `automation_system_name` ENUM('CPA', 'CPB') NOT NULL COMMENT 'the name for the workcell as used by the lab staff',
  `config_key` VARCHAR(255) NOT NULL COMMENT 'the key or name for this configuration key value pair',
  `config_value` VARCHAR(255) NOT NULL COMMENT 'the value for this configuration key value pair',
  `description` VARCHAR(255) NOT NULL COMMENT 'the description of what this key value pairing is used for',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was created in the database',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the datetime when this row was updated in the database',
  PRIMARY KEY (`id`),
  CONSTRAINT `automation_system_name_config_key` UNIQUE
  (`automation_system_name`,`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
