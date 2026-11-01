# HEALTHIFY — SERVERPOD BACKEND SWAP BLUEPRINT & DOMAIN MAP

This document defines the exact mechanical mapping between the current **Flutter Frontend Repositories & Mock Data Services** and the **Future Serverpod Backend Client, Endpoints, and PostgreSQL Schemas**.

---

## Architecture Overview

```
Current Frontend Architecture (Phase 1 to 18):
UI Widgets -> State / Controllers -> Services -> Repository Interfaces -> Mock Implementations -> MockDataStore

Future Backend Swapped Architecture:
UI Widgets -> State / Controllers -> Services -> Repository Interfaces -> Serverpod Repository -> Serverpod Client -> Serverpod Endpoints -> PostgreSQL
```

Zero UI code or Controller logic will change when swapping from `MockRepository` to `ServerpodRepository`.

---

## 1. Core Repository Mapping Table

| Flutter Repository Interface | Current Mock Repository | Future Serverpod Repository | Future Serverpod Endpoint Method | Target PostgreSQL Table |
|---|---|---|---|---|
| `HospitalRepository` | `MockHospitalRepository` | `ServerpodHospitalRepository` | `client.hospital.getProfile()` | `hospitals`, `departments` |
| `DoctorRepository` | `MockDoctorRepository` | `ServerpodDoctorRepository` | `client.doctor.list()`, `client.doctor.getById()` | `doctors`, `doctor_affiliations` |
| `PatientRepository` | `MockPatientRepository` | `ServerpodPatientRepository` | `client.patient.getProfile()` | `patients` |
| `AppointmentRepository` | `MockAppointmentRepository` | `ServerpodAppointmentRepository` | `client.appointment.schedule()`, `client.appointment.list()` | `appointments` |
| `BedRepository` | `MockBedRepository` | `ServerpodBedRepository` | `client.bed.list()`, `client.bed.assign()` | `beds`, `wards`, `floors` |
| `BloodBankRepository` | `MockBloodBankRepository` | `ServerpodBloodBankRepository` | `client.bloodBank.getInventory()`, `client.bloodBank.request()` | `blood_units`, `blood_requests` |
| `EmergencyRepository` | `MockEmergencyRepository` | `ServerpodEmergencyRepository` | `client.emergency.listCases()`, `client.emergency.triage()` | `emergency_cases` |
| `ReportRepository` | `MockReportRepository` | `ServerpodReportRepository` | `client.report.getReportsByPatient()`, `client.report.upload()` | `diagnostic_reports` |
| `PrescriptionRepository` | `MockPrescriptionRepository` | `ServerpodPrescriptionRepository` | `client.prescription.list()`, `client.prescription.create()` | `prescriptions`, `prescription_items` |
| `NotificationRepository` | `MockNotificationRepository` | `ServerpodNotificationRepository` | `client.notification.list()`, `client.notification.markRead()` | `notification_records` |
| `PatientDiscoveryRepository` | `MockPatientDiscoveryRepository` | `ServerpodPatientDiscoveryRepository` | `client.discovery.searchHospitals()`, `client.discovery.searchDoctors()` | `hospitals`, `doctors` |

---

## 2. DTO & Model Mapping Rules

- **Frontend Domain Models** (`lib/core/models/`) remain the source of truth for UI contracts.
- **Serverpod DTO Mappers** will convert Serverpod generated client objects (e.g. `ServerpodAppointmentDto`) directly to domain entities (`Appointment`).

---

## 3. Realtime Event Stream Swap (WebSockets / SSE)

- `DomainEventBus.instance`: Currently broadcasts local in-memory domain events.
- **Future Serverpod Streaming**:
  - Serverpod WebSocket stream connection will listen to backend events and pipe them into `DomainEventBus.instance.publish(event)`, keeping the exact same reactive notification pipeline active in the UI.
