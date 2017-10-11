-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Oct 12 10:48:45 2017
-- 

;
BEGIN TRANSACTION;
--
-- Table: note_kind
--
CREATE TABLE note_kind (
  note_kind_id INTEGER PRIMARY KEY NOT NULL,
  note_kind_name text NOT NULL
);
CREATE UNIQUE INDEX note_kind_note_kind_name ON note_kind (note_kind_name);
--
-- Table: support_level
--
CREATE TABLE support_level (
  support_level_id INTEGER PRIMARY KEY NOT NULL,
  support_level_name text NOT NULL
);
CREATE UNIQUE INDEX support_level_support_level_name ON support_level (support_level_name);
--
-- Table: sync
--
CREATE TABLE sync (
  sync_id INTEGER PRIMARY KEY NOT NULL,
  sync_start text NOT NULL,
  sync_stop text
);
CREATE UNIQUE INDEX sync_sync_start ON sync (sync_start);
--
-- Table: trait
--
CREATE TABLE trait (
  trait_id INTEGER PRIMARY KEY NOT NULL,
  trait_name text NOT NULL
);
CREATE UNIQUE INDEX trait_trait_name ON trait (trait_name);
--
-- Table: architecture
--
CREATE TABLE architecture (
  architecture_id INTEGER PRIMARY KEY NOT NULL,
  architecture_name text NOT NULL,
  sync_id integer,
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id)
);
CREATE INDEX architecture_idx_sync_id ON architecture (sync_id);
CREATE UNIQUE INDEX architecture_architecture_name ON architecture (architecture_name);
--
-- Table: category
--
CREATE TABLE category (
  category_id INTEGER PRIMARY KEY NOT NULL,
  category_name text NOT NULL,
  sync_id integer,
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id)
);
CREATE INDEX category_idx_sync_id ON category (sync_id);
CREATE UNIQUE INDEX category_category_name ON category (category_name);
--
-- Table: mask
--
CREATE TABLE mask (
  mask_id INTEGER PRIMARY KEY NOT NULL,
  mask_author text NOT NULL,
  mask_datestamp text NOT NULL,
  mask_content text NOT NULL,
  mask_content_checksum text NOT NULL,
  mask_atoms text NOT NULL,
  sync_id integer,
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id)
);
CREATE INDEX mask_idx_sync_id ON mask (sync_id);
CREATE UNIQUE INDEX mask_mask_content_checksum ON mask (mask_content_checksum);
--
-- Table: note
--
CREATE TABLE note (
  note_id INTEGER PRIMARY KEY NOT NULL,
  note_kind_id integer NOT NULL,
  note_description text NOT NULL,
  sync_id integer,
  FOREIGN KEY (note_kind_id) REFERENCES note_kind(note_kind_id),
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id)
);
CREATE INDEX note_idx_note_kind_id ON note (note_kind_id);
CREATE INDEX note_idx_sync_id ON note (sync_id);
--
-- Table: package
--
CREATE TABLE package (
  package_id INTEGER PRIMARY KEY NOT NULL,
  package_name text NOT NULL,
  category_id integer NOT NULL,
  sync_id integer,
  FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id)
);
CREATE INDEX package_idx_category_id ON package (category_id);
CREATE INDEX package_idx_sync_id ON package (sync_id);
CREATE UNIQUE INDEX package_category_id_package_name ON package (category_id, package_name);
--
-- Table: profile
--
CREATE TABLE profile (
  profile_id INTEGER PRIMARY KEY NOT NULL,
  profile_name text NOT NULL,
  architecture_id integer NOT NULL,
  parent_profile_id integer,
  sync_id integer,
  FOREIGN KEY (architecture_id) REFERENCES architecture(architecture_id),
  FOREIGN KEY (parent_profile_id) REFERENCES profile(profile_id),
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id)
);
CREATE INDEX profile_idx_architecture_id ON profile (architecture_id);
CREATE INDEX profile_idx_parent_profile_id ON profile (parent_profile_id);
CREATE INDEX profile_idx_sync_id ON profile (sync_id);
CREATE UNIQUE INDEX profile_profile_name ON profile (profile_name);
--
-- Table: version
--
CREATE TABLE version (
  version_id INTEGER PRIMARY KEY NOT NULL,
  version_string text NOT NULL,
  category_id integer NOT NULL,
  package_id integer NOT NULL,
  sync_id integer,
  FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (package_id, category_id) REFERENCES package(package_id, category_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id)
);
CREATE INDEX version_idx_category_id ON version (category_id);
CREATE INDEX version_idx_package_id_category_id ON version (package_id, category_id);
CREATE INDEX version_idx_sync_id ON version (sync_id);
CREATE UNIQUE INDEX version_category_id_package_id_version_string ON version (category_id, package_id, version_string);
--
-- Table: mask_impact
--
CREATE TABLE mask_impact (
  mask_impact_id INTEGER PRIMARY KEY NOT NULL,
  mask_id integer NOT NULL,
  version_id integer NOT NULL,
  sync_id integer,
  FOREIGN KEY (mask_id) REFERENCES mask(mask_id),
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id),
  FOREIGN KEY (version_id) REFERENCES version(version_id)
);
CREATE INDEX mask_impact_idx_mask_id ON mask_impact (mask_id);
CREATE INDEX mask_impact_idx_sync_id ON mask_impact (sync_id);
CREATE INDEX mask_impact_idx_version_id ON mask_impact (version_id);
CREATE UNIQUE INDEX mask_impact_mask_id_version_id ON mask_impact (mask_id, version_id);
--
-- Table: trait_applies
--
CREATE TABLE trait_applies (
  trait_applies_id INTEGER PRIMARY KEY NOT NULL,
  trait_id integer NOT NULL,
  version_id integer NOT NULL,
  sync_id integer,
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id),
  FOREIGN KEY (trait_id) REFERENCES trait(trait_id),
  FOREIGN KEY (version_id) REFERENCES version(version_id)
);
CREATE INDEX trait_applies_idx_sync_id ON trait_applies (sync_id);
CREATE INDEX trait_applies_idx_trait_id ON trait_applies (trait_id);
CREATE INDEX trait_applies_idx_version_id ON trait_applies (version_id);
--
-- Table: note_applies
--
CREATE TABLE note_applies (
  note_applies_id INTEGER PRIMARY KEY NOT NULL,
  note_id integer NOT NULL,
  version_id integer NOT NULL,
  sync_id integer,
  FOREIGN KEY (note_id) REFERENCES note(note_id),
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id),
  FOREIGN KEY (version_id) REFERENCES version(version_id)
);
CREATE INDEX note_applies_idx_note_id ON note_applies (note_id);
CREATE INDEX note_applies_idx_sync_id ON note_applies (sync_id);
CREATE INDEX note_applies_idx_version_id ON note_applies (version_id);
--
-- Table: version_support
--
CREATE TABLE version_support (
  version_support_id INTEGER PRIMARY KEY NOT NULL,
  architecture_id integer NOT NULL,
  support_level_id integer NOT NULL,
  version_id integer NOT NULL,
  sync_id integer,
  FOREIGN KEY (architecture_id) REFERENCES architecture(architecture_id),
  FOREIGN KEY (support_level_id) REFERENCES support_level(support_level_id),
  FOREIGN KEY (sync_id) REFERENCES sync(sync_id),
  FOREIGN KEY (version_id) REFERENCES version(version_id)
);
CREATE INDEX version_support_idx_architecture_id ON version_support (architecture_id);
CREATE INDEX version_support_idx_support_level_id ON version_support (support_level_id);
CREATE INDEX version_support_idx_sync_id ON version_support (sync_id);
CREATE INDEX version_support_idx_version_id ON version_support (version_id);
CREATE UNIQUE INDEX version_support_architecture_id_support_level_id ON version_support (architecture_id, support_level_id);
COMMIT;
