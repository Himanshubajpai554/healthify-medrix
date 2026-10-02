# MEDRIX SERVERPOD INTEGRATION CONTRACT & BACKEND SWAP BLUEPRINT

> **Developer-Facing Architecture & Serverpod Contract Specification**  
> **Target Version**: Medrix Frontend Architecture v1  
> **Status**: Verified Contract Specification (Zero Flutter UI Rewrites Required)

---

## 1. Integration Architecture & Data Flow

Medrix Flutter frontend enforces a strict 6-layer decoupled architecture:

$$\text{UI Widgets} \longrightarrow \text{State / Controllers} \longrightarrow \text{Domain Services} \longrightarrow \text{Repository Interfaces} \longrightarrow \text{Domain Mappers} \longrightarrow \text{Serverpod DTO / Endpoints}$$

### Mandatory Rule
UI widgets **NEVER** consume Serverpod-generated model classes directly. They strictly interact with canonical Flutter Domain Models (`PatientItem`, `DoctorItem`, `Appointment`, `Bed`, `EmergencyCase`, `DiagnosticReport`, etc.).

---

## 2. Canonical Domain Entities

| Entity Class | Primary Key | Key Fields & Nullability | Scope |
| :--- | :--- | :--- | :--- |
| `HospitalInfo` / `HospitalSettings` | `hospitalId` (String) | `displayName`, `licenseId`, `operatingMode`, `timezone` | Global / System |
| `Department` | `id` (String) | `hospitalId`, `name`, `code`, `headDoctorId` | Hospital-Scoped |
| `Doctor` / `DoctorItem` | `id` (String) | `name`, `department`, `status`, `phone`, `email` | Global / Multi-Hospital |
| `DoctorAffiliation` | `id` (String) | `doctorId`, `hospitalId`, `departmentId`, `role` | Hospital-Scoped |
| `StaffModel` | `id` (String) | `name`, `role`, `department`, `status`, `shift` | Hospital-Scoped |
| `Patient` | `id` (String) | `name`, `age`, `dateOfBirth`, `gender`, `bloodGroup` | Global Identity |
| `HospitalPatientLink` | `id` (String) | `hospitalId`, `patientId`, `mrnNumber` (Unique per Hosp) | Hospital-Scoped Link |
| `Admission` | `id` (String) | `hospitalId`, `patientId`, `bedId`, `ward`, `status` | Hospital-Scoped Stay |
| `Appointment` / `AppointmentItem` | `id` (String) | `hospitalId`, `patientId`, `doctorId`, `dateTime`, `status` | Hospital-Scoped |
| `Bed` / `BedItem` | `id` (String) | `hospitalId`, `ward`, `bedNumber`, `status`, `patientId?` | Hospital-Scoped |
| `ICUUnit` | `id` (String) | `bedId`, `hospitalId`, `unitName`, `ventilatorAvailable` | Hospital-Scoped |
| `BloodInventoryUnit` | `id` (String) | `hospitalId`, `bloodGroup`, `expiresAt`, `status` | Hospital-Scoped |
| `BloodRequestItem` | `requestId` (String)| `hospitalId`, `patientId`, `bloodGroup`, `unitsRequired` | Hospital-Scoped |
| `EmergencyCaseItem` | `id` (String) | `hospitalId`, `patientName`, `priority`, `status`, `patientId?`| Hospital-Scoped |
| `DiagnosticReport` | `id` (String) | `hospitalId`, `patientId`, `reportType`, `verificationStatus` | Hospital-Scoped |
| `PrescriptionRecordItem` | `id` (String) | `hospitalId`, `patientId`, `doctorId`, `medications` | Hospital-Scoped |
| `EquipmentItem` / `FacilityModel` | `id` (String) | `hospitalId`, `name`, `category`, `status` | Hospital-Scoped |
| `NotificationRecord` | `id` (String) | `recipientId`, `title`, `message`, `type`, `isRead` | User-Scoped |
| `AuditLog` | `id` (String) | `actorId`, `actorRole`, `actionType`, `targetEntityId` | System / Immutable |
| `AuthSession` | `sessionId` (String) | `userId`, `role`, `hospitalId`, `isAuthenticated` | User-Scoped |

---

## 3. Serverpod Repository Map

| Abstract Repository Interface | Mock Implementation (Current) | Future Serverpod Repository Implementation |
| :--- | :--- | :--- |
| `HospitalRepository` | `MockHospitalRepository` | `ServerpodHospitalRepository` |
| `DepartmentRepository` | `MockDepartmentRepository` | `ServerpodDepartmentRepository` |
| `DoctorRepository` | `MockDoctorRepository` | `ServerpodDoctorRepository` |
| `StaffRepository` | `MockStaffRepository` | `ServerpodStaffRepository` |
| `PatientRepository` | `MockPatientRepository` | `ServerpodPatientRepository` |
| `AppointmentRepository` | `MockAppointmentRepository` | `ServerpodAppointmentRepository` |
| `BedRepository` | `MockBedRepository` | `ServerpodBedRepository` |
| `ICURepository` | `MockICURepository` | `ServerpodICURepository` |
| `BloodBankRepository` | `MockBloodBankRepository` | `ServerpodBloodBankRepository` |
| `FacilityRepository` | `MockFacilityRepository` | `ServerpodFacilityRepository` |
| `EmergencyRepository` | `MockEmergencyRepository` | `ServerpodEmergencyRepository` |
| `ReportRepository` | `MockReportRepository` | `ServerpodReportRepository` |
| `PrescriptionRepository` | `MockPrescriptionRepository` | `ServerpodPrescriptionRepository` |
| `ResourceRepository` | `MockResourceRepository` | `ServerpodResourceRepository` |
| `AnalyticsRepository` | `MockAnalyticsRepository` | `ServerpodAnalyticsRepository` |
| `AIInsightRepository` | `MockAIInsightRepository` | `ServerpodAIRepository` |
| `NotificationRepository` | `MockNotificationRepository` | `ServerpodNotificationRepository` |
| `AuditRepository` | `MockAuditRepository` | `ServerpodAuditRepository` |
| `SettingsRepository` | `MockSettingsRepository` | `ServerpodSettingsRepository` |
| `AuthRepository` | `MockAuthRepository` | `ServerpodAuthRepository` |
| `FileStorageRepository` | `MockFileStorageRepository` | `ServerpodFileStorageRepository` |
| `RealtimeRepository` | `MockRealtimeRepository` | `ServerpodRealtimeRepository` |

---

## 4. Serverpod Endpoint Map & Contract Specifications

```text
hospital Endpoint:
  - createProfile(HospitalInfo info) -> HospitalInfo
  - getProfile(String hospitalId) -> HospitalInfo
  - updateProfile(HospitalInfo info) -> HospitalInfo
  - updateEmergencyStatus(String hospitalId, bool isEmergencyActive) -> void

doctor Endpoint:
  - listDoctors(DoctorQuery query) -> PaginatedResult<DoctorItem>
  - linkAffiliation(String doctorId, String hospitalId, String departmentId) -> DoctorAffiliation
  - setScheduleSlots(String doctorId, List<ScheduleSlot> slots) -> void
  - requestLeave(String doctorId, DateTime startDate, DateTime endDate) -> void

patient Endpoint:
  - registerLocalMRN(String hospitalId, String patientId) -> HospitalPatientLink
  - lookupByMRN(String hospitalId, String mrn) -> PatientItem?
  - admitPatient(PatientAdmissionRequest request) -> PatientItem
  - dischargePatient(String patientId) -> void
  - getAdmissionHistory(String patientId) -> List<Admission>

appointment Endpoint:
  - createWalkIn(CreateAppointmentRequest req) -> AppointmentItem
  - checkIn(String appointmentId) -> void
  - cancel(String appointmentId, String reason) -> void
  - listDoctorQueue(String doctorId, DateTime date) -> AppointmentQueueResponse

bed Endpoint:
  - assignPatient(AssignBedRequest req) -> void
  - updateStatus(String bedId, BedStatus status) -> void
  - getLiveOccupancyMap(String hospitalId) -> BedOccupancySummary

blood Endpoint:
  - logUnit(BloodInventoryUnit unit) -> BloodInventoryUnit
  - reserveUnit(String unitId, String requestId) -> void
  - issueUnits(String requestId, List<String> unitIds) -> void
  - getInventorySummary(String hospitalId) -> BloodInventorySummary

emergency Endpoint:
  - createCase(CreateEmergencyCaseRequest req) -> EmergencyCaseItem
  - assignTriageLevel(String caseId, TriagePriority priority) -> void
  - assignDoctor(AssignEmergencyDoctorRequest req) -> void
  - dischargeCase(String caseId) -> void

reports Endpoint:
  - uploadDiagnostic(UploadReportRequest req) -> DiagnosticReport
  - verifyReport(String reportId, String doctorId) -> DiagnosticReport
  - releaseReportToPatient(String reportId) -> DiagnosticReport

analytics Endpoint:
  - getOccupancyMetrics(String hospitalId) -> HospitalAnalyticsMetrics
  - getEmergencyThroughput(String hospitalId) -> Map<String, dynamic>

notifications Endpoint:
  - markAsRead(String id) -> void
  - acknowledgeAlert(String id) -> void

audit Endpoint:
  - queryLogs(AuditLogQuery query) -> PaginatedResult<AuditLog>

settings Endpoint:
  - getSettings(String hospitalId) -> HospitalSettings
  - updateSettings(UpdateHospitalSettingsRequest req) -> void
```

---

## 5. Domain Request & Response Contracts

All complex payloads use explicit, strongly-typed DTOs defined in `lib/core/models/contract_models.dart`:
- **Requests**: `CreateAppointmentRequest`, `AssignBedRequest`, `CreateBloodRequest`, `CreateEmergencyCaseRequest`, `AssignEmergencyDoctorRequest`, `UploadReportRequest`, `UpdateHospitalSettingsRequest`, `CreateResourceRequest`.
- **Responses**: `AppointmentQueueResponse`, `HospitalKpiResponse`, `AIInsightResponse`, `BedOccupancySummary`, `PatientOverviewMetrics`.

---

## 6. Query, Filter, Sorting & Pagination Contracts

- All lists use `PaginatedResult<T>`:
  - `items: List<T>`
  - `page: int`
  - `pageSize: int`
  - `totalCount: int`
  - `hasNextPage: bool`
- Queries (`PatientQuery`, `AppointmentQuery`, `BedQuery`, `EmergencyQuery`, `ReportQuery`, `AuditLogQuery`) provide domain-level filters, typed enum sorts (`sortField`), and page indices without exposing SQL string constructions.

---

## 7. Error Mapping Strategy

Serverpod server exceptions map directly into canonical `DomainError` variants:

$$\text{Serverpod Exception} \longrightarrow \text{DomainError Mapping} \longrightarrow \text{UI Friendly Notification}$$

| Serverpod Error Code | DomainError Variant | UI Display Behavior |
| :--- | :--- | :--- |
| `VALIDATION_FAILED` | `ValidationError` | Highlights form fields with field error strings. |
| `NOT_FOUND` | `NotFoundError` | Renders `MedrixErrorState` with entity details and Retry button. |
| `UNAUTHORIZED` / `FORBIDDEN` | `PermissionError` / `PermissionDeniedError` | Renders `AccessDeniedWidget` with audit denial logging. |
| `STATE_CONFLICT` | `ConflictError` | Shows snackbar with refreshed data prompt. |
| `SERVICE_UNAVAILABLE` | `UnavailableError` | Renders temporary unavailability message with retry. |

---

## 8. Boundaries & Security Architecture

1. **Authentication Boundary**: `AuthSession` decouples Flutter components from Serverpod auth tokens.
2. **Permission Boundary**: `PermissionService` enforces UX access control; Serverpod authorization remains authoritative on the server.
3. **File Storage Boundary**: Documents use `DocumentReference` (`storageKey`, `mimeType`, `size`) and `FileStorageRepository`. Direct local path dependencies are strictly prohibited.
4. **AI Boundary**: Flutter receives immutable `AIInsightResponse` DTOs with mandatory medical disclaimers; no ML model binaries or Python runtimes exist in Flutter.
5. **Notification Boundary**: Events trigger `NotificationRecord` payloads via `NotificationRepository`.
6. **Real-time Boundary**: `RealtimeRepository` streams `DomainEvent` objects without forcing WebSockets directly into UI widgets.

---

## 9. Transaction-Sensitive Workflows

The following operations will eventually require atomic server database transactions:
1. **Patient Admission**: Creates `HospitalPatientLink`, `Admission`, and updates `Bed` status atomically.
2. **Bed Assignment**: Validates sanitation clearance, updates `Bed.status = occupied`, and links `Admission.bedId`.
3. **Blood Unit Issue**: Validates compatibility, marks `BloodInventoryUnit.status = issued`, and updates `BloodRequestItem.allocatedUnits`.
4. **Emergency Case Intake**: Registers `EmergencyCaseItem`, links MRN (if patient exists), and logs `AuditLog`.
5. **Diagnostic Report Verification**: Locks report as verified/released and writes immutable `DocumentActivity` audit log.

---

## 10. Multi-Hospital & Data Ownership Rules

1. **Hospital Ownership**: Every operational record (`Bed`, `BloodInventoryUnit`, `EmergencyCaseItem`, `AppointmentItem`, `DiagnosticReport`) is scoped by `hospitalId`.
2. **Doctor Multi-Hospital Rule**: Doctor identity (`Doctor`) is global; hospital-specific roles are scoped via `DoctorAffiliation`.
3. **Patient Ownership Rule**: Patient identity (`Patient`) is global across hospitals; local medical records and MRNs are scoped via `HospitalPatientLink`.
4. **Clinical Immutability Rule**: Verified Diagnostic Reports, Signed Prescriptions, and Audit Logs become strictly immutable after verification.

---

## 11. Backend Swap Protocol (Step-by-Step)

When commencing live Serverpod backend integration:
1. Start Serverpod server project and apply PostgreSQL migrations for domain entities.
2. Implement `Serverpod*Repository` classes implementing the abstract interfaces.
3. Inject Serverpod endpoints using `DomainMappers`.
4. Update `RepositoryContainer.instance` in `lib/core/provider/repository_provider.dart`:
   ```dart
   final container = RepositoryContainer(
     patientRepository: ServerpodPatientRepository(client),
     doctorRepository: ServerpodDoctorRepository(client),
     // ...
   );
   ```
5. **Zero UI widget rewrites are required!**
