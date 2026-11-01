import 'package:flutter_test/flutter_test.dart';
import 'package:healthify_hospital/core/core.dart';

/// Fake Serverpod Repository simulation for swap readiness verification
class FakeServerpodPatientRepository implements PatientRepository {
  final List<PatientItem> _fakeServerpodDb = [
    PatientItem(
      id: 'PT-SERVERPOD-909',
      name: 'Serverpod Test Patient',
      age: 42,
      gender: 'Male',
      bloodGroup: 'O+',
      ward: 'Ward 404',
      status: PatientStatus.admitted,
      doctorName: 'Dr. Sarah Jenkins',
      admissionDate: DateTime.now().subtract(const Duration(days: 1)),
      vitals: const {'BP': '120/80', 'HR': '72'},
    ),
  ];

  @override
  Future<List<PatientItem>> getPatients({PatientQuery? query}) async {
    return _fakeServerpodDb;
  }

  @override
  Future<PatientItem?> getPatientById(String id) async {
    return _fakeServerpodDb.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<Patient>> getGlobalPatients() async {
    return [];
  }

  @override
  Future<Patient?> findPatientByMrnOrPhone(String queryStr) async {
    return null;
  }

  @override
  Future<PatientItem> admitPatient(PatientAdmissionRequest request) async {
    final item = PatientItem(
      id: 'PT-${DateTime.now().millisecondsSinceEpoch}',
      name: request.name,
      age: request.age,
      gender: request.gender,
      bloodGroup: request.bloodGroup,
      ward: request.ward,
      admissionDate: DateTime.now(),
      status: request.status,
      doctorName: request.doctorName,
      vitals: request.vitals,
    );
    _fakeServerpodDb.add(item);
    return item;
  }

  @override
  Future<void> updatePatient(PatientItem patient) async {
    final idx = _fakeServerpodDb.indexWhere((p) => p.id == patient.id);
    if (idx != -1) _fakeServerpodDb[idx] = patient;
  }

  @override
  Future<void> updatePatientStatus(String patientId, PatientStatus newStatus) async {
    final item = await getPatientById(patientId);
    if (item != null) item.status = newStatus;
  }

  @override
  Future<void> updatePatientWard(String patientId, String newWard) async {
    final item = await getPatientById(patientId);
    if (item != null) item.ward = newWard;
  }

  @override
  Future<void> dischargePatient(String patientId) async {
    await updatePatientStatus(patientId, PatientStatus.discharged);
  }

  @override
  Future<PatientOverviewMetrics> getPatientMetrics(String hospitalId) async {
    return const PatientOverviewMetrics(
      totalActiveAdmissions: 1,
      icuPatients: 0,
      admissionsToday: 1,
      dischargesToday: 0,
      observationPatients: 0,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HEALTHIFY Phase 14 & 15 Core Architecture & Contract Tests', () {
    test('1. Appointment Lifecycle Workflow', () async {
      final apptRepo = MockAppointmentRepository();
      final docRepo = MockDoctorRepository();
      final patientRepo = MockPatientRepository();
      final service = AppointmentService(
        appointmentRepository: apptRepo,
        doctorRepository: docRepo,
        patientRepository: patientRepo,
      );

      final walkIn = await service.createWalkIn(
        patientName: 'Test Walk-In',
        doctorName: 'Dr. Sarah Jenkins',
        department: 'Cardiology',
        dateTime: DateTime.now(),
        reason: 'Routine Checkup',
      );
      expect(walkIn.id, isNotEmpty);

      await service.cancelAppointment(walkIn.id, 'Patient requested');
    });

    test('2. Bed Capacity & Assignment Workflow', () async {
      final bedRepo = MockBedRepository();
      final bedService = BedService(bedRepository: bedRepo);

      await bedService.reserveBed('BED-101', 'PT-1001');
      await bedService.releaseBed('BED-101');

      final summary = await bedService.getOccupancySummary();
      expect(summary.available, greaterThanOrEqualTo(0));
    });

    test('3. Blood Bank Unit Reservation Workflow', () async {
      final bloodRepo = MockBloodBankRepository();
      final bloodService = BloodBankService(bloodBankRepository: bloodRepo);

      final req = await bloodService.createRequest(
        hospitalId: 'HOSP-101',
        patientId: 'PT-1001',
        requesterId: 'DOC-1001',
        bloodGroup: 'A+',
        unitsRequired: 2,
        urgencyLevel: 'URGENT',
      );
      expect(req.requestId, isNotEmpty);

      final summary = await bloodService.getInventorySummary();
      expect(summary.totalUnits, greaterThanOrEqualTo(0));
    });

    test('4. Emergency Room Triage Lifecycle', () async {
      final emergencyRepo = MockEmergencyRepository();
      final emergencyService = EmergencyService(emergencyRepository: emergencyRepo);

      final newCase = await emergencyService.createEmergencyCase(
        EmergencyCaseItem(
          id: 'EM-TEST-1',
          patientName: 'Emergency Test Patient',
          age: 35,
          gender: 'Female',
          chiefComplaint: 'Acute Chest Pressure',
          priority: TriagePriority.level1Resuscitation,
          status: EmergencyStatus.waiting,
          arrivalTime: '10:00 AM',
          locationBed: 'Trauma Bay 1',
          assignedDoctor: 'Dr. Alex Rivera',
        ),
      );
      expect(newCase.id, isNotEmpty);

      await emergencyService.assignTriage(newCase.id, TriagePriority.level1Resuscitation);
      await emergencyService.dischargeCase(newCase.id);
    });

    test('5. Diagnostic Report Verification Workflow', () async {
      final reportRepo = MockReportRepository();
      final reportService = ReportService(reportRepository: reportRepo);

      final reports = await reportService.getReports();
      expect(reports, isNotEmpty);

      final firstReport = reports.first;
      final verified = await reportService.verifyReport(firstReport.id, 'DOC-1001');
      expect(verified.verificationStatus, equals(ReportVerificationStatus.verified));
    });

    test('6. RBAC Permission Engine Check', () {
      expect(PermissionService.hasPermission(UserRole.hospitalAdmin, Permission.manageHospital), isTrue);
      expect(PermissionService.hasPermission(UserRole.hospitalAdmin, Permission.manageBeds), isTrue);
      expect(PermissionService.hasPermission(UserRole.patient, Permission.manageSecurity), isFalse);
    });

    test('7. Notification Acknowledgement & Read Workflow', () async {
      final notifRepo = MockNotificationRepository();
      final notifService = NotificationService(notificationRepository: notifRepo);

      final notifs = await notifService.getNotifications();
      expect(notifs, isNotEmpty);

      final firstNotif = notifs.first;
      await notifService.markAsRead(firstNotif.id);

      final updated = await notifService.getNotification(firstNotif.id);
      expect(updated?.isRead, isTrue);
    });

    test('8. Settings Validation & Service Workflow', () async {
      final settingsRepo = MockSettingsRepository();
      final auditRepo = MockAuditRepository();
      final notifRepo = MockNotificationRepository();

      final settingsService = SettingsService(
        settingsRepository: settingsRepo,
        auditService: AuditService(auditRepository: auditRepo),
        notificationService: NotificationService(notificationRepository: notifRepo),
      );

      final current = await settingsService.getHospitalSettings('HOSP-101');
      expect(current.displayName, isNotEmpty);

      // Validation check for invalid duration
      const invalidOperational = OperationalSettings(defaultAppointmentDuration: -10);
      final valRes = SettingsValidator.validateOperationalSettings(invalidOperational);
      expect(valRes.isValid, isFalse);
      expect(valRes.errors, isNotEmpty);

      // Valid update
      const validOperational = OperationalSettings(defaultAppointmentDuration: 45);
      final updateRes = await settingsService.updateOperationalSettings(
        validOperational,
        hospitalId: 'HOSP-101',
        userId: 'ADM-001',
        role: UserRole.hospitalAdmin,
      );
      expect(updateRes.isValid, isTrue);
    });

    test('9. SERVERPOD SWAP SIMULATION: Repository Interface Swap Test', () async {
      final fakeServerpodRepo = FakeServerpodPatientRepository();
      final container = RepositoryContainer(
        patientRepository: fakeServerpodRepo,
        hospitalPatientRepository: MockHospitalPatientRepository(),
        admissionRepository: MockAdmissionRepository(),
        bedRepository: MockBedRepository(),
        auditRepository: MockAuditRepository(),
      );

      final patientService = PatientService(
        patientRepository: container.patientRepository,
        hospitalPatientRepository: container.hospitalPatientRepository,
        admissionRepository: container.admissionRepository,
        bedRepository: container.bedRepository,
        auditRepository: container.auditRepository,
      );
      final metrics = await patientService.getOverviewMetrics('HOSP-101');

      expect(metrics.totalActiveAdmissions, equals(1));
    });

    test('10. PHASE 15 CONTRACT: DTO Bidirectional Mapping Validation', () {
      final patient = PatientItem(
        id: 'PT-999',
        name: 'Mapper Test Patient',
        age: 50,
        gender: 'Male',
        bloodGroup: 'B+',
        ward: 'General Ward A',
        admissionDate: DateTime.now(),
        status: PatientStatus.admitted,
        doctorName: 'Dr. Michael Chen',
        vitals: const {'BP': '120/80'},
      );

      final dto = PatientMapper.toServerDto(patient);
      expect(dto['id'], equals('PT-999'));
      expect(dto['status'], equals('admitted'));

      final restored = PatientMapper.fromServerDto(dto);
      expect(restored.id, equals(patient.id));
      expect(restored.status, equals(PatientStatus.admitted));
    });

    test('11. PHASE 15 CONTRACT: Auth, Storage & Realtime Abstraction Verification', () async {
      final authRepo = MockAuthRepository();
      final session = await authRepo.getSession();
      expect(session.isAuthenticated, isTrue);
      expect(session.role, equals(UserRole.hospitalAdmin));

      final storageRepo = MockFileStorageRepository();
      final docRef = await storageRepo.uploadFile(
        fileName: 'lab_report.pdf',
        bytes: [1, 2, 3, 4],
        mimeType: 'application/pdf',
        category: 'reports',
      );
      expect(docRef.storageKey, contains('lab_report.pdf'));

      final realtimeRepo = MockRealtimeRepository();
      expect(realtimeRepo.eventStream, isNotNull);

    });
  });
}
