BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hospital_membership" (
    "id" bigserial PRIMARY KEY,
    "hospitalKey" text NOT NULL,
    "userIdentifier" text NOT NULL,
    "role" text NOT NULL,
    "isActive" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "hospital_membership_unique_idx" ON "hospital_membership" USING btree ("hospitalKey", "userIdentifier");
CREATE INDEX "hospital_membership_user_idx" ON "hospital_membership" USING btree ("userIdentifier");


--
-- MIGRATION VERSION FOR healthify_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('healthify_server', '20261011134943604-hospital-membership', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261011134943604-hospital-membership', "timestamp" = now();

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
