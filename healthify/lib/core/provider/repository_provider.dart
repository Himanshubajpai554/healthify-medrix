import 'package:flutter/material.dart';
import '../data/mock/mock_repositories.dart';
import '../data/repositories/repositories.dart';

/// Central Dependency Injection container / InheritedWidget for Medrix repositories.
class RepositoryContainer {
  final HospitalRepository hospitalRepository;
  final HospitalSettingsRepository hospitalSettingsRepository;
  final DepartmentRepository departmentRepository;
  final PatientRepository patientRepository;
  final HospitalPatientRepository hospitalPatientRepository;
  final AdmissionRepository admissionRepository;
  final DoctorRepository doctorRepository;
  final StaffRepository staffRepository;
  final ShiftRosterRepository shiftRosterRepository;
  final AppointmentRepository appointmentRepository;
  final BedRepository bedRepository;
  final ICURepository icuRepository;
  final BloodBankRepository bloodBankRepository;
  BloodBankRepository get bloodRepository => bloodBankRepository;
  final FacilityRepository facilityRepository;
  final EquipmentRepository equipmentRepository;
  final EmergencyRepository emergencyRepository;
  final ReportRepository reportRepository;
  final PrescriptionRepository prescriptionRepository;
  final AnalyticsRepository analyticsRepository;
  final NotificationRepository notificationRepository;
  final AIInsightRepository aiInsightRepository;
  final AuditRepository auditRepository;
  final SettingsRepository settingsRepository;
  final AuthRepository authRepository;
  final FileStorageRepository fileStorageRepository;
  final RealtimeRepository realtimeRepository;
  final LocationRepository locationRepository;
  final ReviewRepository reviewRepository;
  final ReviewEligibilityRepository reviewEligibilityRepository;
  final PatientDiscoveryRepository patientDiscoveryRepository;

  RepositoryContainer({
    HospitalRepository? hospitalRepository,
    HospitalSettingsRepository? hospitalSettingsRepository,
    DepartmentRepository? departmentRepository,
    PatientRepository? patientRepository,
    HospitalPatientRepository? hospitalPatientRepository,
    AdmissionRepository? admissionRepository,
    DoctorRepository? doctorRepository,
    StaffRepository? staffRepository,
    ShiftRosterRepository? shiftRosterRepository,
    AppointmentRepository? appointmentRepository,
    BedRepository? bedRepository,
    ICURepository? icuRepository,
    BloodBankRepository? bloodBankRepository,
    FacilityRepository? facilityRepository,
    EquipmentRepository? equipmentRepository,
    EmergencyRepository? emergencyRepository,
    ReportRepository? reportRepository,
    PrescriptionRepository? prescriptionRepository,
    AnalyticsRepository? analyticsRepository,
    NotificationRepository? notificationRepository,
    AIInsightRepository? aiInsightRepository,
    AuditRepository? auditRepository,
    SettingsRepository? settingsRepository,
    AuthRepository? authRepository,
    FileStorageRepository? fileStorageRepository,
    RealtimeRepository? realtimeRepository,
    LocationRepository? locationRepository,
    ReviewRepository? reviewRepository,
    ReviewEligibilityRepository? reviewEligibilityRepository,
    PatientDiscoveryRepository? patientDiscoveryRepository,
  })  : hospitalRepository = hospitalRepository ?? MockHospitalRepository(),
        hospitalSettingsRepository = hospitalSettingsRepository ?? MockHospitalSettingsRepository(),
        departmentRepository = departmentRepository ?? MockDepartmentRepository(),
        patientRepository = patientRepository ?? MockPatientRepository(),
        hospitalPatientRepository = hospitalPatientRepository ?? MockHospitalPatientRepository(),
        admissionRepository = admissionRepository ?? MockAdmissionRepository(),
        doctorRepository = doctorRepository ?? MockDoctorRepository(),
        staffRepository = staffRepository ?? MockStaffRepository(),
        shiftRosterRepository = shiftRosterRepository ?? MockShiftRosterRepository(),
        appointmentRepository = appointmentRepository ?? MockAppointmentRepository(),
        bedRepository = bedRepository ?? MockBedRepository(),
        icuRepository = icuRepository ?? MockICURepository(),
        bloodBankRepository = bloodBankRepository ?? MockBloodBankRepository(),
        facilityRepository = facilityRepository ?? MockFacilityRepository(),
        equipmentRepository = equipmentRepository ?? MockEquipmentRepository(),
        emergencyRepository = emergencyRepository ?? MockEmergencyRepository(),
        reportRepository = reportRepository ?? MockReportRepository(),
        prescriptionRepository = prescriptionRepository ?? MockPrescriptionRepository(),
        analyticsRepository = analyticsRepository ?? MockAnalyticsRepository(),
        notificationRepository = notificationRepository ?? MockNotificationRepository(),
        aiInsightRepository = aiInsightRepository ?? MockAIInsightRepository(),
        auditRepository = auditRepository ?? MockAuditRepository(),
        settingsRepository = settingsRepository ?? MockSettingsRepository(),
        authRepository = authRepository ?? MockAuthRepository(),
        fileStorageRepository = fileStorageRepository ?? MockFileStorageRepository(),
        realtimeRepository = realtimeRepository ?? MockRealtimeRepository(),
        locationRepository = locationRepository ?? MockLocationRepository(),
        reviewRepository = reviewRepository ?? MockReviewRepository(),
        reviewEligibilityRepository = reviewEligibilityRepository ?? MockReviewEligibilityRepository(),
        patientDiscoveryRepository = patientDiscoveryRepository ?? MockPatientDiscoveryRepository();


  static final RepositoryContainer instance = RepositoryContainer();


}

class RepositoryScope extends InheritedWidget {
  final RepositoryContainer container;

  const RepositoryScope({
    super.key,
    required this.container,
    required super.child,
  });

  static RepositoryContainer of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RepositoryScope>();
    return scope?.container ?? RepositoryContainer.instance;
  }

  @override
  bool updateShouldNotify(covariant RepositoryScope oldWidget) {
    return container != oldWidget.container;
  }
}
