# Healthify Serverpod backend

This Serverpod project stores hospital information, the hospital profile and its verification status/documents, hospital settings, hospital user access, and tenant-scoped operational records. Operational records cover appointments, beds/ICU, admissions, patients, doctors, staff/shifts, blood bank, facilities/equipment, emergencies, diagnostics, prescriptions, resources, notifications, insights, and settings. Operational record changes are audited in an append-only audit table. Hospital routes require an authenticated account and an active hospital membership, with role checks on record access and writes. Verification files use Serverpod's private storage; file bytes are only returned through an authorized endpoint. `fileUrl` on verification document records stores an internal storage path, not a public URL.

## Run locally

1. Install Docker Desktop and start Docker.
2. From this folder, start PostgreSQL:

   ```powershell
   docker compose -f .\healthify_server\healthify_server_server\docker-compose.yaml up -d postgres
   ```

3. Start the API and apply database migrations:

   ```powershell
   cd .\healthify_server\healthify_server_server
   dart bin/main.dart --apply-migrations
   ```

   The API listens on `http://localhost:8080/`. Hospital registration creates the tenant, owner membership, profile, settings, and access row in one database transaction.

4. In a second terminal, run the existing Flutter app from `..\healthify`:

   ```powershell
   flutter run
   ```

   Set `SERVERPOD_URL` at build/run time to override the API URL. For Android emulators, use `http://10.0.2.2:8080/`.

## Regenerate after changing a model or endpoint

From `healthify_server` run:

```powershell
serverpod generate
```

Then create a migration from `healthify_server_server`:

```powershell
serverpod create-migration --tag=short-lowercase-description
```

The schema files are in `healthify_server_server/lib/src/hospital/`. The typed client lives in `healthify_server_client/`.

## Current boundary

Hospital registration, profile, verification uploads/submission, settings, user-access controls, and tenant-scoped operational records use authenticated Serverpod endpoints. Patient portal signup/login now uses Serverpod email/password auth; patient profiles, appointments, and patient-uploaded reports are persisted in a per-authenticated-user partition, with the owner identifier derived on the server. Patient prescriptions read from that same private partition. The patient email verification and password reset codes are printed to the Serverpod terminal in local development because an email delivery provider is not configured. Patient-entered phone numbers are not phone-verified. Configure real email delivery and a phone verification provider before relying on those contact channels in production.

Patient records and hospital links, admissions, doctors/schedules/affiliations, emergencies, and hospital configuration also route through Serverpod-backed repositories. New active admissions and their patient/link records commit under a patient-scoped transaction lock, preventing concurrent duplicate active stays. Patient directory APIs read verified, discoverable hospitals and their public doctor fields from Serverpod. Bed and blood discovery return aggregate availability, without individual bed, patient, donor, or storage details. Patient appointment requests are stored in the patient's account and routed transactionally into the selected hospital's appointment records with `pending` status; doctor-role users can access only records assigned to their linked doctor profile. The doctor login resolves that profile from the active hospital membership and hospital-user email. Doctor appointment decisions and status changes synchronize to the patient's appointment record in the same transaction. Doctor patient lists, EHR notes, prescriptions, diagnostic-report review metadata/files, assigned emergency cases, follow-ups, and schedule availability are connected to tenant-scoped operational records with doctor ownership checks.

Patient-to-hospital account linking uses a patient-submitted request, hospital-administrator approval, an active link record, and patient revocation. Approval rechecks the patient record and serializes competing requests for the same hospital record. Approved links authorize report release and prescription copies into the authenticated patient's private partition. Link approval still depends on a hospital administrator verifying the claimant outside the app; there is no hospital UI for reviewing link requests yet. Account-link and report-sharing live integration verification has not completed because the local Docker test database was unavailable. The report-sharing integration fixture now seeds an approved link record but has not been rerun.

Remaining backend and deployment gaps: patient-uploaded report file bytes are not stored and that picker is still a UI mock; patient symptom recommendations, donation centers, and emergency hospital recommendations are demo/empty; analytics and AI forecast views derive snapshots rather than using trained models; session administration and server-side session termination are incomplete; configurable permission records are not the source of truth for endpoint authorization; hospital staff invitations/claim onboarding and a platform verification reviewer console are not implemented; external email/SMS/push delivery is not configured. Patient blood requests now require a selected verified/discoverable hospital and are transactionally copied into its staff blood-request queue; hospital status changes mirror back to the patient's private request. Email IDP registration and reset codes are logged to the server terminal in local development, and patient-entered phone numbers are not phone-verified. Several nonclinical doctor indicators and hospital screens still use demo data. Production deployment still needs real hosts/secrets, HTTPS/load-balancer configuration, backups/monitoring, and an external private-storage plan.
