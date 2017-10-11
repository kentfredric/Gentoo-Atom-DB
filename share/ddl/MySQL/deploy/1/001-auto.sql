-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Thu Oct 12 10:31:28 2017
-- 
;
SET foreign_key_checks=0;
--
-- Table: `sync`
--
CREATE TABLE `sync` (
  `sync_id` integer NOT NULL auto_increment,
  `sync_start` text NOT NULL,
  `sync_stop` text NULL,
  PRIMARY KEY (`sync_id`),
  UNIQUE `sync_sync_start` (`sync_start`)
) ENGINE=InnoDB;
--
-- Table: `architecture`
--
CREATE TABLE `architecture` (
  `architecture_id` integer NOT NULL auto_increment,
  `architecture_name` text NOT NULL,
  `sync_id` integer NULL,
  INDEX `architecture_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`architecture_id`),
  UNIQUE `architecture_architecture_name` (`architecture_name`),
  CONSTRAINT `architecture_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `category`
--
CREATE TABLE `category` (
  `category_id` integer NOT NULL auto_increment,
  `category_name` text NOT NULL,
  `sync_id` integer NULL,
  INDEX `category_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`category_id`),
  UNIQUE `category_category_name` (`category_name`),
  CONSTRAINT `category_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `mask`
--
CREATE TABLE `mask` (
  `mask_id` integer NOT NULL auto_increment,
  `mask_author` text NOT NULL,
  `mask_datestamp` text NOT NULL,
  `mask_content` text NOT NULL,
  `mask_content_checksum` text NOT NULL,
  `mask_atoms` text NOT NULL,
  `sync_id` integer NULL,
  INDEX `mask_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`mask_id`),
  UNIQUE `mask_mask_content_checksum` (`mask_content_checksum`),
  CONSTRAINT `mask_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `note_kind`
--
CREATE TABLE `note_kind` (
  `note_kind_id` integer NOT NULL auto_increment,
  `note_kind_name` text NOT NULL,
  `sync_id` integer NULL,
  INDEX `note_kind_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`note_kind_id`),
  UNIQUE `note_kind_note_kind_name` (`note_kind_name`),
  CONSTRAINT `note_kind_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `support_level`
--
CREATE TABLE `support_level` (
  `support_level_id` integer NOT NULL auto_increment,
  `support_level_name` text NOT NULL,
  `sync_id` integer NULL,
  INDEX `support_level_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`support_level_id`),
  UNIQUE `support_level_support_level_name` (`support_level_name`),
  CONSTRAINT `support_level_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `trait`
--
CREATE TABLE `trait` (
  `trait_id` integer NOT NULL auto_increment,
  `trait_name` text NOT NULL,
  `sync_id` integer NULL,
  INDEX `trait_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`trait_id`),
  UNIQUE `trait_trait_name` (`trait_name`),
  CONSTRAINT `trait_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `note`
--
CREATE TABLE `note` (
  `note_id` integer NOT NULL auto_increment,
  `note_kind_id` integer NOT NULL,
  `note_description` text NOT NULL,
  `sync_id` integer NULL,
  INDEX `note_idx_note_kind_id` (`note_kind_id`),
  INDEX `note_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`note_id`),
  CONSTRAINT `note_fk_note_kind_id` FOREIGN KEY (`note_kind_id`) REFERENCES `note_kind` (`note_kind_id`),
  CONSTRAINT `note_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `package`
--
CREATE TABLE `package` (
  `package_id` integer NOT NULL auto_increment,
  `package_name` text NOT NULL,
  `category_id` integer NOT NULL,
  `sync_id` integer NULL,
  INDEX `package_idx_category_id` (`category_id`),
  INDEX `package_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`package_id`),
  UNIQUE `package_category_id_package_name` (`category_id`, `package_name`),
  CONSTRAINT `package_fk_category_id` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `package_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `profile`
--
CREATE TABLE `profile` (
  `profile_id` integer NOT NULL auto_increment,
  `profile_name` text NOT NULL,
  `architecture_id` integer NOT NULL,
  `parent_profile_id` integer NULL,
  `sync_id` integer NULL,
  INDEX `profile_idx_architecture_id` (`architecture_id`),
  INDEX `profile_idx_parent_profile_id` (`parent_profile_id`),
  INDEX `profile_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`profile_id`),
  UNIQUE `profile_profile_name` (`profile_name`),
  CONSTRAINT `profile_fk_architecture_id` FOREIGN KEY (`architecture_id`) REFERENCES `architecture` (`architecture_id`),
  CONSTRAINT `profile_fk_parent_profile_id` FOREIGN KEY (`parent_profile_id`) REFERENCES `profile` (`profile_id`),
  CONSTRAINT `profile_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `version`
--
CREATE TABLE `version` (
  `version_id` integer NOT NULL auto_increment,
  `version_string` text NOT NULL,
  `category_id` integer NOT NULL,
  `package_id` integer NOT NULL,
  `sync_id` integer NULL,
  INDEX `version_idx_category_id` (`category_id`),
  INDEX `version_idx_package_id_category_id` (`package_id`, `category_id`),
  INDEX `version_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`version_id`),
  UNIQUE `version_category_id_package_id_version_string` (`category_id`, `package_id`, `version_string`),
  CONSTRAINT `version_fk_category_id` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `version_fk_package_id_category_id` FOREIGN KEY (`package_id`, `category_id`) REFERENCES `package` (`package_id`, `category_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `version_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `version_support`
--
CREATE TABLE `version_support` (
  `version_support_id` integer NOT NULL auto_increment,
  `architecture_id` integer NOT NULL,
  `support_level_id` integer NOT NULL,
  `sync_id` integer NULL,
  INDEX `version_support_idx_architecture_id` (`architecture_id`),
  INDEX `version_support_idx_support_level_id` (`support_level_id`),
  INDEX `version_support_idx_sync_id` (`sync_id`),
  PRIMARY KEY (`version_support_id`),
  UNIQUE `version_support_architecture_id_support_level_id` (`architecture_id`, `support_level_id`),
  CONSTRAINT `version_support_fk_architecture_id` FOREIGN KEY (`architecture_id`) REFERENCES `architecture` (`architecture_id`),
  CONSTRAINT `version_support_fk_support_level_id` FOREIGN KEY (`support_level_id`) REFERENCES `support_level` (`support_level_id`),
  CONSTRAINT `version_support_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`)
) ENGINE=InnoDB;
--
-- Table: `mask_impact`
--
CREATE TABLE `mask_impact` (
  `mask_impact_id` integer NOT NULL auto_increment,
  `mask_id` integer NOT NULL,
  `version_id` integer NOT NULL,
  `sync_id` integer NULL,
  INDEX `mask_impact_idx_mask_id` (`mask_id`),
  INDEX `mask_impact_idx_sync_id` (`sync_id`),
  INDEX `mask_impact_idx_version_id` (`version_id`),
  PRIMARY KEY (`mask_impact_id`),
  UNIQUE `mask_impact_mask_id_version_id` (`mask_id`, `version_id`),
  CONSTRAINT `mask_impact_fk_mask_id` FOREIGN KEY (`mask_id`) REFERENCES `mask` (`mask_id`),
  CONSTRAINT `mask_impact_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`),
  CONSTRAINT `mask_impact_fk_version_id` FOREIGN KEY (`version_id`) REFERENCES `version` (`version_id`)
) ENGINE=InnoDB;
--
-- Table: `trait_applies`
--
CREATE TABLE `trait_applies` (
  `trait_applies_id` integer NOT NULL auto_increment,
  `trait_id` integer NOT NULL,
  `version_id` integer NOT NULL,
  `sync_id` integer NULL,
  INDEX `trait_applies_idx_sync_id` (`sync_id`),
  INDEX `trait_applies_idx_trait_id` (`trait_id`),
  INDEX `trait_applies_idx_version_id` (`version_id`),
  PRIMARY KEY (`trait_applies_id`),
  CONSTRAINT `trait_applies_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`),
  CONSTRAINT `trait_applies_fk_trait_id` FOREIGN KEY (`trait_id`) REFERENCES `trait` (`trait_id`),
  CONSTRAINT `trait_applies_fk_version_id` FOREIGN KEY (`version_id`) REFERENCES `version` (`version_id`)
) ENGINE=InnoDB;
--
-- Table: `note_applies`
--
CREATE TABLE `note_applies` (
  `note_applies_id` integer NOT NULL auto_increment,
  `note_id` integer NOT NULL,
  `version_id` integer NOT NULL,
  `sync_id` integer NULL,
  INDEX `note_applies_idx_note_id` (`note_id`),
  INDEX `note_applies_idx_sync_id` (`sync_id`),
  INDEX `note_applies_idx_version_id` (`version_id`),
  PRIMARY KEY (`note_applies_id`),
  CONSTRAINT `note_applies_fk_note_id` FOREIGN KEY (`note_id`) REFERENCES `note` (`note_id`),
  CONSTRAINT `note_applies_fk_sync_id` FOREIGN KEY (`sync_id`) REFERENCES `sync` (`sync_id`),
  CONSTRAINT `note_applies_fk_version_id` FOREIGN KEY (`version_id`) REFERENCES `version` (`version_id`)
) ENGINE=InnoDB;
SET foreign_key_checks=1;
