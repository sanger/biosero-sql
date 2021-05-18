-- Automation system runs table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`automation_system_runs` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `automation_system` VARCHAR(255) NOT NULL,
  `run_id` INT NOT NULL UNIQUE,
  `method` VARCHAR(255) NOT NULL,
  `user_id` VARCHAR(255) NOT NULL,
  `start_time` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `end_time` DATETIME DEFAULT NULL,
  `state` VARCHAR(255) NOT NULL,
  `machine_name` VARCHAR(255) NOT NULL,
  `instrument_serial_number` VARCHAR(255) NOT NULL,
  `configuration_used` JSON NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `automation_system_run_id` UNIQUE
  (`automation_system`,`run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- Errors table
CREATE TABLE IF NOT EXISTS `biosero_uat`.`errors` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `automation_system_run_id` INT NOT NULL,
  `error` JSON NOT NULL,
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
  `coordinate` VARCHAR(255) NOT NULL,
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
  `coordinate` VARCHAR(255) NOT NULL,
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
  `coordinate` VARCHAR(255) NOT NULL,
  `source_plate_well_id` INT DEFAULT NULL,
  `control_plate_well_id` INT DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_destination_plate_wells_on_barcode` (`barcode`),
  CONSTRAINT `run_destination_plate_well` UNIQUE (`automation_system_run_id`,`barcode`,`coordinate`),
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
  `machine_name` VARCHAR(255) NOT NULL,
  `config_key` VARCHAR(255) NOT NULL,
  `config_value` VARCHAR(255) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `machine_name_config_key` UNIQUE
  (`machine_name`,`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
