BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hospital_audit_event" (
    "id" bigserial PRIMARY KEY,
    "hospitalKey" text NOT NULL,
    "actorUserIdentifier" text NOT NULL,
    "action" text NOT NULL,
    "collection" text NOT NULL,
    "recordKey" text NOT NULL,
    "occurredAt" timestamp without time zone NOT NULL,
    "details" text NOT NULL
);

-- Indexes
CREATE INDEX "hospital_audit_event_hospital_idx" ON "hospital_audit_event" USING btree ("hospitalKey", "occurredAt");


--
-- MIGRATION VERSION FOR healthify_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('healthify_server', '20261011141447136-hospital-audit-events', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261011141447136-hospital-audit-events', "timestamp" = now();

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
