# Healthify hospital backend

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

Hospital registration, profile, verification uploads/submission, settings, user-access controls, and tenant-scoped operational records use authenticated Serverpod endpoints. Screens that directly construct analytics, notifications, diagnostic report/prescription, resource, audit/security, or AI insight mock repositories are routed through Serverpod-backed repository factories after the Serverpod client initializes; no screen edits are required. Analytics and AI forecast views derive current snapshots from persisted operational records. They do not run a trained prediction model. Session administration and permission-role catalogue persistence remain incomplete. Hospital staff invitation/claim onboarding and a separate verification reviewer console are not implemented. Local email verification codes are printed to the Serverpod terminal. Before public deployment, replace the development email-code logger with a real email delivery provider and configure production secrets, HTTPS, and external private file storage.
