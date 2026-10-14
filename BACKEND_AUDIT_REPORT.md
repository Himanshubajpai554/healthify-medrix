# Healthify backend audit

**Audit date:** 14 October 2026  
**Scope:** Static review of the Serverpod backend, Flutter repository wiring, and patient/doctor/hospital workflows in the current workspace. This report reflects code present at audit time; it is not a claim of successful live deployment or end-to-end operation.

## Executive summary

Healthify has a substantial Serverpod foundation: authenticated hospital tenancy, patient email/password accounts, scoped patient records, core hospital operations, doctor-scoped server checks, appointment/admission synchronization, private storage for hospital verification and doctor report files, and patient account-link/report-sharing endpoints.

**The backend is not yet complete for production or verified end to end.** The largest remaining blockers are real patient-file uploads, account-link approval UI and identity proofing, doctor patient/prescription workflows that still rely on sample data, delivery providers, server-side session/permission administration, and deployment configuration. Several features have backend persistence but not a complete UI-to-live-data workflow.

## What is implemented in code

| Area | Current implementation |
|---|---|
| Server foundation | Serverpod project, PostgreSQL migrations, generated client/protocol, authenticated endpoints, tenant-scoped operational records, and append-only operational audit rows. |
| Hospital account | Hospital registration creates the hospital tenant, owner membership, profile/settings/access records transactionally. Profile, verification submission, private verification document storage, settings, user-access controls, and operational-record endpoints exist. |
| Patient authentication | Patient email/password signup, login, email verification/password reset flow, and server-derived authenticated user ownership for patient portal records. |
| Patient portal | Patient profile, appointments, favorites, report metadata, prescriptions, and blood-request records use a private authenticated-user partition. Patient appointment requests route to hospital appointment records; appointment status syncs back. |
| Admissions | Patient-scoped admission workflow creates/updates admission and patient/link rows under a transaction lock to prevent concurrent duplicate active admissions. |
| Patient discovery | Hospital/doctor directory is based on verified, discoverable hospitals. Bed and blood inventory discovery returns aggregate data rather than patient/donor/individual-bed rows. Emergency hospital modal uses this directory. |
| Account linking | Patient can request a hospital record link, see requests/approved links, and revoke an active link. Hospital admin endpoint can approve/reject; approvals serialize competing requests and recheck the patient row. Approved links gate report release and prescription copies. |
| Patient blood requests | Patient selects a verified/discoverable hospital. Server transactionally writes the private patient request and hospital blood queue record. Hospital status writes can sync a status back to the patient's record. |
| Doctor access | Hospital login checks active membership and doctor profile. Server write/read checks restrict doctor operations to supported collections and assigned doctor records/patients. |
| Doctor workflows | Appointment decisions, schedule availability, clinical note/follow-up/prescription data paths, emergency case paths, diagnostic report metadata/file endpoints, and patient report sharing have Serverpod-backed implementations. |
| Private files | Hospital verification files and doctor-uploaded diagnostic report files use Serverpod private storage with size/type/signature checks and authorized download endpoints. Doctor report release to a linked patient is separate from hospital storage. |
| Reviews | Patient review eligibility and review endpoints exist. |

## Remaining work, by priority

### P0 — Resolve before real patient/clinical use

1. **Connect doctor clinical views to real patient records.** `DoctorPatientService` still initializes an in-memory sample patient profile, sample vitals/history/summary, and sample related clinical lists. Some notes use the new Serverpod clinical-record service, but that does not make the rest of the patient chart live. Replace this source with server-backed, assigned-patient data and remove sample clinical content from connected mode.
2. **Replace hardcoded prescription patient and consultation choices.** `CreatePrescriptionModal` contains `_mockPatients` and `_mockConsultations`; the doctor prescription service has seeded in-memory prescription examples alongside its live path. This can disconnect a prescription from a real hospital patient/appointment. Load selectable patients and consultations from assigned server records and ensure the saved prescription references those keys.
3. **Implement patient report file upload.** Patient reports currently save metadata in the private partition. There is no patient-owned file upload/storage endpoint or picker-to-upload path. Existing private file upload covers hospital verification and doctor diagnostic reports, not patient-submitted report bytes.
4. **Complete and operate account-link review.** The server approval endpoint exists, but there is no hospital UI to list/review requests. Approval verifies that the hospital patient row exists; it does not prove the requester is that patient. Provide a staff workflow and an explicit identity verification process before releasing records.
5. **Verify clinical and security flows with a live database.** Current source inspection cannot establish transaction behavior under a real PostgreSQL/Serverpod runtime. Run integration coverage for patient auth/ownership, hospital tenant isolation, roles, appointment/admission synchronization, account-link approval/revocation, report upload/release/download/revoke, and blood-request/status synchronization once the test database is available.

### P1 — Required for a usable, safe production service

6. **Configure outbound delivery.** Verification/reset codes are printed to the Serverpod terminal in local development. Real email delivery is not configured; SMS/phone verification and push delivery are not configured. Persistent notification rows are not equivalent to a delivery provider.
7. **Finish session administration.** The connected security repository returns no active sessions and throws `UnsupportedError` for session termination. Server-side revocation/termination and an administrative session view are not implemented.
8. **Enforce configurable permissions on the server.** Permission settings can be stored/read by the app, but endpoint authorization uses hardcoded role-to-collection sets. Changing a saved permission does not become the server's authorization source of truth. Reconcile the UI model with server-side enforcement before relying on custom permissions.
9. **Finish break-glass access.** The current adapter persists requests and supports revoke, but does not provide a complete approve/grant/expiry-enforcement workflow. It must not be presented as active emergency authorization until approval, scope, expiry enforcement, and audit behavior are enforced by the server.
10. **Complete hospital staff onboarding.** There is no end-to-end staff invitation/claim flow that ties a verified staff identity to an active hospital membership. Doctor self-signup directs doctors to ask a hospital admin to provision access; this provisioning path needs a usable admin workflow and identity checks.
11. **Add a platform verification reviewer workflow.** Hospitals can submit verification and store documents, but the platform reviewer console/approval process is not implemented as a complete operational workflow.
12. **Replace demo recommendation flows.** Symptom checker recommendations and nearby hospital/doctor recommendations still use static sample datasets/rules. Donation-center discovery is not connected to a real backend workflow. Do not treat these results as live availability or clinical recommendations.
13. **Audit remaining doctor/hospital screen fallbacks.** Some connected-mode screens deliberately return empty collections, while other areas still source dashboard indicators, profile details, analytics, prescription selection, or help/support data from mock services. Finish a screen-by-screen live-data audit and make unavailable data explicit rather than presenting seeded clinical examples as real records.

### P2 — Scale, operations, and polish

14. **Replace snapshot analytics with defined operational metrics.** Current analytics/AI insight adapters derive summaries from stored rows or use simple rules; there is no trained forecast model or validated clinical AI service. Establish metric definitions, data quality, and model governance before presenting predictions.
15. **Review list limits and pagination.** Several directory/record paths use bounded fetches (for example, directory limits and client-side filtering). Verify paging/order/filter behavior for larger tenants and move filtering/aggregation to indexed server queries where needed.
16. **Finish production deployment configuration.** Production config still contains example host/database values. Set real `SERVERPOD_URL`, domains, database credentials, TLS/load balancer, private storage, backups, monitoring/logging/alerts, migrations, and recovery procedures. Keep real secrets out of source control and rotate any credentials that have been used outside local development.
17. **Complete external storage and retention design.** Verify Serverpod private-storage persistence, backup/restore, access logging, retention/deletion, and data residency requirements in the chosen deployment. The code's private storage calls do not by themselves provision durable production storage.
18. **Document API/operational procedures.** Add runbooks for administrator provisioning, identity proofing, hospital verification review, file recovery, notification failures, account recovery, audit review, and incident response.

## Verification status

- **Static review:** Completed for endpoint inventory, major repository wiring, relevant patient/doctor flows, configs, migrations, and available test files.
- **Tests:** Not run during this audit. The repository contains the default greeting integration test and a doctor report-sharing integration test; there is not broad integration coverage for the workflows listed above.
- **Live database / E2E:** Not verified in this audit. Earlier work in this conversation recorded that the local Docker test database was unavailable; the report-sharing fixture was changed to seed an approved account link but has not been confirmed by a successful run.
- **Analyzer:** Earlier targeted analysis of the changed endpoint and patient blood-request screen found no errors, with style infos. That does not prove runtime/database correctness or analyze the entire app.
- **Workspace state:** There are many modified and untracked files in both app and server workspaces. This report does not assume they are committed or deployed, and no existing edits were reverted as part of this audit.

## Completion criteria for a defensible “backend complete” claim

Call the backend complete only after the P0/P1 items are implemented or explicitly excluded from product scope, every shipped portal workflow has been verified against the live Serverpod/PostgreSQL path (including authorization-denial cases), patient file handling and account-link identity review are operational, no clinical connected screen silently uses seeded sample records, and deployment/backup/monitoring procedures are exercised. External provider or deployment-dependent items need real credentials/infrastructure and must be marked unverified until exercised.
