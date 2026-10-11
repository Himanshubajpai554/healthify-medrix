BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hospital_operational_record" (
    "id" bigserial PRIMARY KEY,
    "hospitalKey" text NOT NULL,
    "collection" text NOT NULL,
    "recordKey" text NOT NULL,
    "payload" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "hospital_operational_record_unique_idx" ON "hospital_operational_record" USING btree ("hospitalKey", "collection", "recordKey");
CREATE INDEX "hospital_operational_record_collection_idx" ON "hospital_operational_record" USING btree ("hospitalKey", "collection", "updatedAt");


--
-- MIGRATION VERSION FOR healthify_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('healthify_server', '20261011141240472-hospital-operational-records', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261011141240472-hospital-operational-records', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
