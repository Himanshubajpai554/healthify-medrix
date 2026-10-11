BEGIN;

--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "hospital_info_key_unique_idx" ON "hospital_info" USING btree ("hospitalKey");
--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "hospital_profile_key_unique_idx" ON "hospital_profile" USING btree ("hospitalKey");
--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "hospital_settings_key_unique_idx" ON "hospital_settings" USING btree ("hospitalKey");
--
-- ACTION ALTER TABLE
--
CREATE UNIQUE INDEX "hospital_user_key_unique_idx" ON "hospital_user_access" USING btree ("hospitalKey", "userKey");

--
-- MIGRATION VERSION FOR healthify_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('healthify_server', '20261011132121582-hospital-unique-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261011132121582-hospital-unique-keys', "timestamp" = now();

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
