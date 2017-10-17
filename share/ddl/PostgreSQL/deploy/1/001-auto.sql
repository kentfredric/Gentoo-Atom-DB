-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Oct 17 17:13:55 2017
-- 
;
--
-- Table: note_kind
--
CREATE TABLE "note_kind" (
  "note_kind_id" serial NOT NULL,
  "note_kind_name" text NOT NULL,
  PRIMARY KEY ("note_kind_id"),
  CONSTRAINT "note_kind_note_kind_name" UNIQUE ("note_kind_name")
);

;
--
-- Table: support_level
--
CREATE TABLE "support_level" (
  "support_level_id" serial NOT NULL,
  "support_level_name" text NOT NULL,
  PRIMARY KEY ("support_level_id"),
  CONSTRAINT "support_level_support_level_name" UNIQUE ("support_level_name")
);

;
--
-- Table: sync
--
CREATE TABLE "sync" (
  "sync_id" serial NOT NULL,
  "sync_start" text NOT NULL,
  "sync_stop" text,
  PRIMARY KEY ("sync_id"),
  CONSTRAINT "sync_sync_start" UNIQUE ("sync_start")
);

;
--
-- Table: trait
--
CREATE TABLE "trait" (
  "trait_id" serial NOT NULL,
  "trait_name" text NOT NULL,
  PRIMARY KEY ("trait_id"),
  CONSTRAINT "trait_trait_name" UNIQUE ("trait_name")
);

;
--
-- Table: architecture
--
CREATE TABLE "architecture" (
  "architecture_id" serial NOT NULL,
  "architecture_name" text NOT NULL,
  "sync_id" integer,
  PRIMARY KEY ("architecture_id"),
  CONSTRAINT "architecture_architecture_name" UNIQUE ("architecture_name")
);
CREATE INDEX "architecture_idx_sync_id" on "architecture" ("sync_id");

;
--
-- Table: category
--
CREATE TABLE "category" (
  "category_id" serial NOT NULL,
  "category_name" text NOT NULL,
  "sync_id" integer,
  PRIMARY KEY ("category_id"),
  CONSTRAINT "category_category_name" UNIQUE ("category_name")
);
CREATE INDEX "category_idx_sync_id" on "category" ("sync_id");

;
--
-- Table: mask
--
CREATE TABLE "mask" (
  "mask_id" serial NOT NULL,
  "mask_author" text NOT NULL,
  "mask_datestamp" text NOT NULL,
  "mask_content" text NOT NULL,
  "mask_content_checksum" text NOT NULL,
  "mask_atoms" text NOT NULL,
  "sync_id" integer,
  PRIMARY KEY ("mask_id"),
  CONSTRAINT "mask_mask_content_checksum" UNIQUE ("mask_content_checksum")
);
CREATE INDEX "mask_idx_sync_id" on "mask" ("sync_id");

;
--
-- Table: note
--
CREATE TABLE "note" (
  "note_id" serial NOT NULL,
  "note_kind_id" integer NOT NULL,
  "note_description" text NOT NULL,
  PRIMARY KEY ("note_id")
);
CREATE INDEX "note_idx_note_kind_id" on "note" ("note_kind_id");

;
--
-- Table: package
--
CREATE TABLE "package" (
  "package_id" serial NOT NULL,
  "package_name" text NOT NULL,
  "category_id" integer NOT NULL,
  "sync_id" integer,
  PRIMARY KEY ("package_id"),
  CONSTRAINT "package_category_id_package_name" UNIQUE ("category_id", "package_name")
);
CREATE INDEX "package_idx_category_id" on "package" ("category_id");
CREATE INDEX "package_idx_sync_id" on "package" ("sync_id");

;
--
-- Table: profile
--
CREATE TABLE "profile" (
  "profile_id" serial NOT NULL,
  "profile_name" text NOT NULL,
  "architecture_id" integer,
  "parent_profile_id" integer,
  "sync_id" integer,
  PRIMARY KEY ("profile_id"),
  CONSTRAINT "profile_profile_name" UNIQUE ("profile_name")
);
CREATE INDEX "profile_idx_architecture_id" on "profile" ("architecture_id");
CREATE INDEX "profile_idx_parent_profile_id" on "profile" ("parent_profile_id");
CREATE INDEX "profile_idx_sync_id" on "profile" ("sync_id");

;
--
-- Table: version
--
CREATE TABLE "version" (
  "version_id" serial NOT NULL,
  "version_string" text NOT NULL,
  "category_id" integer NOT NULL,
  "package_id" integer NOT NULL,
  "sync_id" integer,
  PRIMARY KEY ("version_id"),
  CONSTRAINT "version_category_id_package_id_version_string" UNIQUE ("category_id", "package_id", "version_string")
);
CREATE INDEX "version_idx_category_id" on "version" ("category_id");
CREATE INDEX "version_idx_package_id_category_id" on "version" ("package_id", "category_id");
CREATE INDEX "version_idx_sync_id" on "version" ("sync_id");

;
--
-- Table: mask_impact
--
CREATE TABLE "mask_impact" (
  "mask_impact_id" serial NOT NULL,
  "mask_id" integer NOT NULL,
  "version_id" integer NOT NULL,
  "sync_id" integer,
  PRIMARY KEY ("mask_impact_id"),
  CONSTRAINT "mask_impact_mask_id_version_id" UNIQUE ("mask_id", "version_id")
);
CREATE INDEX "mask_impact_idx_mask_id" on "mask_impact" ("mask_id");
CREATE INDEX "mask_impact_idx_sync_id" on "mask_impact" ("sync_id");
CREATE INDEX "mask_impact_idx_version_id" on "mask_impact" ("version_id");

;
--
-- Table: trait_applies
--
CREATE TABLE "trait_applies" (
  "trait_applies_id" serial NOT NULL,
  "trait_id" integer NOT NULL,
  "version_id" integer NOT NULL,
  "sync_id" integer,
  PRIMARY KEY ("trait_applies_id")
);
CREATE INDEX "trait_applies_idx_sync_id" on "trait_applies" ("sync_id");
CREATE INDEX "trait_applies_idx_trait_id" on "trait_applies" ("trait_id");
CREATE INDEX "trait_applies_idx_version_id" on "trait_applies" ("version_id");

;
--
-- Table: note_applies
--
CREATE TABLE "note_applies" (
  "note_applies_id" serial NOT NULL,
  "note_id" integer NOT NULL,
  "version_id" integer NOT NULL,
  PRIMARY KEY ("note_applies_id")
);
CREATE INDEX "note_applies_idx_note_id" on "note_applies" ("note_id");
CREATE INDEX "note_applies_idx_version_id" on "note_applies" ("version_id");

;
--
-- Table: version_support
--
CREATE TABLE "version_support" (
  "version_support_id" serial NOT NULL,
  "architecture_id" integer NOT NULL,
  "support_level_id" integer NOT NULL,
  "version_id" integer NOT NULL,
  "sync_id" integer,
  PRIMARY KEY ("version_support_id"),
  CONSTRAINT "version_support_architecture_id_support_level_id" UNIQUE ("architecture_id", "support_level_id")
);
CREATE INDEX "version_support_idx_architecture_id" on "version_support" ("architecture_id");
CREATE INDEX "version_support_idx_support_level_id" on "version_support" ("support_level_id");
CREATE INDEX "version_support_idx_sync_id" on "version_support" ("sync_id");
CREATE INDEX "version_support_idx_version_id" on "version_support" ("version_id");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "architecture" ADD CONSTRAINT "architecture_fk_sync_id" FOREIGN KEY ("sync_id")
  REFERENCES "sync" ("sync_id") DEFERRABLE;

;
ALTER TABLE "category" ADD CONSTRAINT "category_fk_sync_id" FOREIGN KEY ("sync_id")
  REFERENCES "sync" ("sync_id") DEFERRABLE;

;
ALTER TABLE "mask" ADD CONSTRAINT "mask_fk_sync_id" FOREIGN KEY ("sync_id")
  REFERENCES "sync" ("sync_id") DEFERRABLE;

;
ALTER TABLE "note" ADD CONSTRAINT "note_fk_note_kind_id" FOREIGN KEY ("note_kind_id")
  REFERENCES "note_kind" ("note_kind_id") DEFERRABLE;

;
ALTER TABLE "package" ADD CONSTRAINT "package_fk_category_id" FOREIGN KEY ("category_id")
  REFERENCES "category" ("category_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "package" ADD CONSTRAINT "package_fk_sync_id" FOREIGN KEY ("sync_id")
  REFERENCES "sync" ("sync_id") DEFERRABLE;

;
ALTER TABLE "profile" ADD CONSTRAINT "profile_fk_architecture_id" FOREIGN KEY ("architecture_id")
  REFERENCES "architecture" ("architecture_id") DEFERRABLE;

;
ALTER TABLE "profile" ADD CONSTRAINT "profile_fk_parent_profile_id" FOREIGN KEY ("parent_profile_id")
  REFERENCES "profile" ("profile_id") DEFERRABLE;

;
ALTER TABLE "profile" ADD CONSTRAINT "profile_fk_sync_id" FOREIGN KEY ("sync_id")
  REFERENCES "sync" ("sync_id") DEFERRABLE;

;
ALTER TABLE "version" ADD CONSTRAINT "version_fk_category_id" FOREIGN KEY ("category_id")
  REFERENCES "category" ("category_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "version" ADD CONSTRAINT "version_fk_package_id_category_id" FOREIGN KEY ("package_id", "category_id")
  REFERENCES "package" ("package_id", "category_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "version" ADD CONSTRAINT "version_fk_sync_id" FOREIGN KEY ("sync_id")
  REFERENCES "sync" ("sync_id") DEFERRABLE;

;
ALTER TABLE "mask_impact" ADD CONSTRAINT "mask_impact_fk_mask_id" FOREIGN KEY ("mask_id")
  REFERENCES "mask" ("mask_id") DEFERRABLE;

;
ALTER TABLE "mask_impact" ADD CONSTRAINT "mask_impact_fk_sync_id" FOREIGN KEY ("sync_id")
  REFERENCES "sync" ("sync_id") DEFERRABLE;

;
ALTER TABLE "mask_impact" ADD CONSTRAINT "mask_impact_fk_version_id" FOREIGN KEY ("version_id")
  REFERENCES "version" ("version_id") DEFERRABLE;

;
ALTER TABLE "trait_applies" ADD CONSTRAINT "trait_applies_fk_sync_id" FOREIGN KEY ("sync_id")
  REFERENCES "sync" ("sync_id") DEFERRABLE;

;
ALTER TABLE "trait_applies" ADD CONSTRAINT "trait_applies_fk_trait_id" FOREIGN KEY ("trait_id")
  REFERENCES "trait" ("trait_id") DEFERRABLE;

;
ALTER TABLE "trait_applies" ADD CONSTRAINT "trait_applies_fk_version_id" FOREIGN KEY ("version_id")
  REFERENCES "version" ("version_id") DEFERRABLE;

;
ALTER TABLE "note_applies" ADD CONSTRAINT "note_applies_fk_note_id" FOREIGN KEY ("note_id")
  REFERENCES "note" ("note_id") DEFERRABLE;

;
ALTER TABLE "note_applies" ADD CONSTRAINT "note_applies_fk_version_id" FOREIGN KEY ("version_id")
  REFERENCES "version" ("version_id") DEFERRABLE;

;
ALTER TABLE "version_support" ADD CONSTRAINT "version_support_fk_architecture_id" FOREIGN KEY ("architecture_id")
  REFERENCES "architecture" ("architecture_id") DEFERRABLE;

;
ALTER TABLE "version_support" ADD CONSTRAINT "version_support_fk_support_level_id" FOREIGN KEY ("support_level_id")
  REFERENCES "support_level" ("support_level_id") DEFERRABLE;

;
ALTER TABLE "version_support" ADD CONSTRAINT "version_support_fk_sync_id" FOREIGN KEY ("sync_id")
  REFERENCES "sync" ("sync_id") DEFERRABLE;

;
ALTER TABLE "version_support" ADD CONSTRAINT "version_support_fk_version_id" FOREIGN KEY ("version_id")
  REFERENCES "version" ("version_id") DEFERRABLE;

;
