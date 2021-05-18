-- Automation system runs table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`automation_system_runs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `automation_system_type` ENUM('biosero', 'beckman', 'sentinel') NOT NULL,
  `automation_system_name` ENUM('CPA', 'CPB') NOT NULL,
  `system_run_id` INT NOT NULL UNIQUE,
  `method` VARCHAR(255) NOT NULL,
  `user_id` VARCHAR(255) NOT NULL,
  `start_time` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `end_time` DATETIME DEFAULT NULL,
  `state` ENUM('started','completed','aborted') NOT NULL,
  `liquid_handler_serial_number` ENUM('h1000001','h1000002') NOT NULL,
  `configuration_used` JSON NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `automation_system_run_id` UNIQUE
  (`automation_system_name`,`system_run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Events table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`events` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `automation_system_run_id` INT NOT NULL,
  `type` ENUM('info','warning','error'),
  `event` JSON NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (automation_system_run_id)
  REFERENCES `biosero_uat`.`automation_system_runs`(`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Source Plate Wells table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`source_plate_wells` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `barcode` VARCHAR(255) NOT NULL,
  `coordinate` ENUM('A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12','E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12') NOT NULL,
  `sample_id` VARCHAR(36) DEFAULT NULL,
  `rna_id` VARCHAR(255) DEFAULT NULL,
  `lab_id` VARCHAR(255) DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_source_plate_wells_on_source_barcode` (`barcode`),
  CONSTRAINT `source_plate_well` UNIQUE (`barcode`,`coordinate`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Control Plate Wells table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`control_plate_wells` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `automation_system_run_id` INT NOT NULL,
  `barcode` VARCHAR(255) NOT NULL,
  `coordinate` ENUM('A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12','E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12') NOT NULL,
  `control` VARCHAR(20) DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `control_plate_well` UNIQUE (`automation_system_run_id`,`barcode`,`coordinate`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Destination Plate Wells table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`destination_plate_wells` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `automation_system_run_id` INT NOT NULL,
  `barcode` VARCHAR(255) NOT NULL,
  `coordinate` ENUM('A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','A11','A12','B1','B2','B3','B4','B5','B6','B7','B8','B9','B10','B11','B12','C1','C2','C3','C4','C5','C6','C7','C8','C9','C10','C11','C12','D1','D2','D3','D4','D5','D6','D7','D8','D9','D10','D11','D12','E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12','G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','H1','H2','H3','H4','H5','H6','H7','H8','H9','H10','H11','H12') NOT NULL,
  `source_plate_well_id` INT DEFAULT NULL,
  `control_plate_well_id` INT DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_destination_plate_wells_on_barcode` (`barcode`),
  CONSTRAINT `run_destination_plate_well` UNIQUE (`automation_system_run_id`,`barcode`,`coordinate`),
  CONSTRAINT `source_plate_well_id_or_control_plate_well_id` CHECK (
    `control_plate_well_id` IS NULL AND `source_plate_well_id` IS NULL
    OR
    `source_plate_well_id` IS NULL AND `control_plate_well_id` IS NOT NULL
    OR
    `control_plate_well_id` IS NULL AND `source_plate_well_id` IS NOT NULL
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
  `id` INT NOT NULL AUTO_INCREMENT,
  `automation_system_name` VARCHAR(255) NOT NULL,
  `config_key` VARCHAR(255) NOT NULL,
  `config_value` VARCHAR(255) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `automation_system_name_config_key` UNIQUE
  (`automation_system_name`,`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
