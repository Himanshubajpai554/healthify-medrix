BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hospital_info" (
    "id" bigserial PRIMARY KEY,
    "hospitalKey" text NOT NULL,
    "name" text NOT NULL,
    "code" text NOT NULL,
    "tagline" text NOT NULL,
    "address" text NOT NULL,
    "phone" text NOT NULL,
    "email" text NOT NULL,
    "emergencyHotline" text NOT NULL,
    "totalBedCapacity" bigint NOT NULL,
    "icuCapacity" bigint NOT NULL,
    "activeDoctorCount" bigint NOT NULL,
    "totalStaffCount" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hospital_profile" (
    "id" bigserial PRIMARY KEY,
    "hospitalKey" text NOT NULL,
    "name" text NOT NULL,
    "legalName" text NOT NULL,
    "displayName" text NOT NULL,
    "hospitalType" text NOT NULL,
    "establishmentDate" text NOT NULL,
    "registrationLicenseId" text NOT NULL,
    "taxId" text NOT NULL,
    "accreditationInfo" text NOT NULL,
    "email" text NOT NULL,
    "emergencyHelpline" text NOT NULL,
    "receptionPhone" text NOT NULL,
    "website" text NOT NULL,
    "address" text NOT NULL,
    "city" text NOT NULL,
    "state" text NOT NULL,
    "country" text NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "totalBeds" bigint NOT NULL,
    "icuBeds" bigint NOT NULL,
    "operatingTheatres" bigint NOT NULL,
    "emergencyCapacity" bigint NOT NULL,
    "has247Emergency" boolean NOT NULL,
    "traumaLevel" text NOT NULL,
    "hasAmbulance" boolean NOT NULL,
    "opdTimings" text NOT NULL,
    "operatingStatus" text NOT NULL,
    "verificationStatus" text NOT NULL,
    "submittedDate" timestamp without time zone,
    "verifiedDate" timestamp without time zone,
    "verificationNotes" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hospital_settings" (
    "id" bigserial PRIMARY KEY,
    "hospitalKey" text NOT NULL,
    "timezone" text NOT NULL,
    "defaultCurrency" text NOT NULL,
    "opdOpeningTime" text NOT NULL,
    "opdClosingTime" text NOT NULL,
    "appointmentSlotDurationMinutes" bigint NOT NULL,
    "autoReleaseExpiredBeds" boolean NOT NULL,
    "isEmergencyActive" boolean NOT NULL,
    "emergencyHotline" text NOT NULL,
    "traumaLevel" text NOT NULL,
    "ambulanceCount" bigint NOT NULL,
    "isHospitalDiscoverable" boolean NOT NULL,
    "showFacilitiesToPatients" boolean NOT NULL,
    "showDoctorSchedulesToPatients" boolean NOT NULL,
    "showBedAvailabilityToPatients" boolean NOT NULL,
    "showRatingsAndReviews" boolean NOT NULL,
    "sessionTimeoutMinutes" bigint NOT NULL,
    "enforceMfaForAdmin" boolean NOT NULL,
    "enableAuditLogging" boolean NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "hospital_user_access" (
    "id" bigserial PRIMARY KEY,
    "hospitalKey" text NOT NULL,
    "userKey" text NOT NULL,
    "userName" text NOT NULL,
    "email" text NOT NULL,
    "role" text NOT NULL,
    "department" text NOT NULL,
    "isActive" boolean NOT NULL,
    "lastActive" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "verification_document" (
    "id" bigserial PRIMARY KEY,
    "hospitalKey" text NOT NULL,
    "title" text NOT NULL,
    "documentType" text NOT NULL,
    "fileUrl" text NOT NULL,
    "uploadDate" timestamp without time zone NOT NULL,
    "status" text NOT NULL
);


--
-- MIGRATION VERSION FOR healthify_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('healthify_server', '20261011131406153-hospital-core', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261011131406153-hospital-core', "timestamp" = now();

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
