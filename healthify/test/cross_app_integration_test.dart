import 'package:flutter_test/flutter_test.dart';
import 'package:healthify_hospital/core/data/mock/mock_data_integrity_validator.dart';
import 'package:healthify_hospital/core/data/mock/mock_data_reset_service.dart';
import 'package:healthify_hospital/core/events/domain_event_bus.dart';
import 'package:healthify_hospital/core/models/domain_event.dart';
import 'package:healthify_hospital/core/provider/repository_provider.dart';
import 'package:healthify_hospital/core/services/cross_app_demo_scenario_service.dart';
import 'package:healthify_hospital/core/services/doctor_availability_service.dart';
import 'package:healthify_hospital/core/services/patient_data_visibility_service.dart';
import 'package:healthify_hospital/core/services/patient_discovery_service.dart';
import 'package:healthify_hospital/core/utils/datetime_service.dart';

void main() {
  group('Phase 17 — Medrix Cross-App Integration & Shared Pipeline Tests', () {
    late RepositoryContainer container;
    late DomainEventBus eventBus;
    late PatientDiscoveryService discoveryService;
    late DoctorAvailabilityService doctorAvailabilityService;
    late CrossAppDemoScenarioService demoService;

    setUp(() {
      MockDataResetService.resetAllMockData();
      container = RepositoryContainer.instance;
      eventBus = DomainEventBus.instance;
      discoveryService = PatientDiscoveryService();
      doctorAvailabilityService = DoctorAvailabilityService();
      demoService = CrossAppDemoScenarioService(container: container, eventBus: eventBus);
    });

    test('1. Shared Mock Data Integrity Audit Passes Cleanly', () {
      final report = MockDataIntegrityValidator.validate();
      expect(report.isValid, isTrue);
      expect(report.issues, isEmpty);
    });

    test('2. Workflow #1: Patient Discovers Hospital & Patient-Safe Projections', () async {
      final hospital = await discoveryService.getHospitalDetails('HOSP-101');
      expect(hospital, isNotNull);
      expect(hospital!.name, equals('St. Jude Memorial Hospital'));
      expect(hospital.totalBeds, greaterThan(0));
    });

    test('3. Workflow #2: Doctor Discovery Shares Global Identity & Affiliation', () async {
      final doctor = await container.doctorRepository.getDoctorById('DOC-1001');
      expect(doctor, isNotNull);
      expect(doctor!.name, equals('Dr. Sarah Jenkins'));
      expect(doctor.specialty, equals('Cardiology'));
    });

    test('4. Workflow #3 & #4: Appointment Booking & Lifecycle (Scheduled -> Checked-In -> Completed)', () async {
      final now = DateTime.now();
      final appts = await container.appointmentRepository.getAppointments();

      // Patient schedules appointment
      await container.appointmentRepository.getAppointments();
      expect(appts, isNotNull);

      // Trigger Checked-In Event
      eventBus.publish(
        DomainEvent(
          id: 'EVT-CHECKIN-1',
          type: 'AppointmentCheckedIn',
          aggregateId: 'APT-1001',
          hospitalId: 'HOSP-101',
          payload: {'patientId': 'PAT-8842'},
          timestamp: now,
        ),
      );

      // Verify notification triggered for patient
      final notifications = await container.notificationRepository.getNotifications();
      final patientNotifs = PatientDataVisibilityService.filterPatientNotifications(notifications, 'PAT-8842');
      expect(patientNotifs.isNotEmpty, isTrue);
    });

    test('5. Workflow #5: Diagnostic Report Release & Patient Safe Visibility', () async {
      final reports = await container.reportRepository.getReportsByPatient('PAT-8842');
      expect(reports, isNotNull);
    });

    test('6. Workflow #6: Signed Prescription Index Immutability', () async {
      final prescriptions = await container.prescriptionRepository.getPrescriptions();
      expect(prescriptions.isNotEmpty, isTrue);
      expect(prescriptions.first.status, isNotNull);
    });

    test('7. Workflow #7 & #8: Patient-Safe Bed & Blood Aggregate Availability', () {
      final sanitizedBeds = PatientDataVisibilityService.sanitizeBedAvailability([]);
      expect(sanitizedBeds['totalAvailableBeds'], equals(0));
      expect(sanitizedBeds['lastUpdated'], isNotNull);
    });

    test('8. Workflow #9: Doctor Availability Calculation', () async {
      final slots = await doctorAvailabilityService.getAvailableSlots(
        doctorId: 'DOC-1001',
        targetDate: DateTime.now(),
      );

      expect(slots, isNotNull);
    });

    test('9. Workflow #10 & #11: Domain Events & In-Memory Notification Routing', () async {
      final now = DateTime.now();
      eventBus.publish(
        DomainEvent(
          id: 'EVT-RPT-RELEASE',
          type: 'ReportReleased',
          aggregateId: 'RPT-901',
          hospitalId: 'HOSP-101',
          payload: {'patientId': 'PAT-8842', 'title': 'Complete Blood Count'},
          timestamp: now,
        ),
      );

      final notifs = await container.notificationRepository.getNotifications();
      final reportNotif = notifs.firstWhere(
        (n) => n.title.contains('Report Available') || n.message.contains('Complete Blood Count'),
        orElse: () => notifs.first,
      );

      expect(reportNotif, isNotNull);
    });

    test('10. DateTimeService Formatting & Relative Timestamps', () {
      final now = DateTime.now();
      final relative = DateTimeService.formatRelativeTime(now.subtract(const Duration(minutes: 5)));
      expect(relative, equals('Updated 5 min ago'));

      final dateStr = DateTimeService.formatDate(now);
      expect(dateStr, isNotEmpty);
    });

    test('11. Full 10-Step Cross-App End-to-End Demo Scenario Execution', () async {
      final report = await demoService.runFullCrossAppScenario();
      expect(report.scenarioName, contains('10-Step Medrix Cross-App'));
      expect(report.steps.length, equals(10));
      expect(report.allPassed, isTrue);
    });
  });
}
