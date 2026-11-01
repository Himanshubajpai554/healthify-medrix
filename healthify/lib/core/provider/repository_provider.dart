import 'package:flutter/material.dart';
import 'package:healthify_server_client/healthify_server_client.dart';
import '../data/mock/mock_repositories.dart';
import '../data/mock/mock_resource_repository.dart';
import '../data/serverpod/serverpod_hospital_repositories.dart';
import '../data/serverpod/hospital_operational_repository.dart';
import '../data/serverpod/serverpod_hospital_operations.dart';
import '../data/serverpod/serverpod_analytics_repository.dart';
import '../data/serverpod/serverpod_notification_repository.dart';
import '../data/serverpod/serverpod_resource_repository.dart';
import '../data/serverpod/serverpod_clinical_document_repositories.dart';
import '../data/serverpod/serverpod_audit_repository.dart';
import '../data/serverpod/serverpod_ai_insight_repository.dart';
import '../data/serverpod/serverpod_security_repository.dart';
import '../data/serverpod/serverpod_patient_doctor_emergency_repositories.dart';
import '../data/serverpod/serverpod_settings_repository.dart';
import '../data/serverpod/serverpod_patient_portal_repository.dart';
import '../data/serverpod/serverpod_patient_discovery_repository.dart';
import '../data/serverpod/serverpod_patient_review_repositories.dart';
import '../data/repositories/repositories.dart';

/// Central Dependency Injection container / InheritedWidget for Healthify repositories.
class RepositoryContainer {
  final Client? serverpodClient;
  final HospitalOperationalRepository? hospitalOperationalRepository;
  final ServerpodPatientPortalRepository? patientPortalRepository;
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
  final ResourceRepository resourceRepository;
  final ReportRepository reportRepository;
  final PrescriptionRepository prescriptionRepository;
  final AnalyticsRepository analyticsRepository;
  final NotificationRepository notificationRepository;
  final AIInsightRepository aiInsightRepository;
  final AuditRepository auditRepository;
  final SecurityRepository securityRepository;
  final SettingsRepository settingsRepository;
  final AuthRepository authRepository;
  final FileStorageRepository fileStorageRepository;
  final RealtimeRepository realtimeRepository;
  final LocationRepository locationRepository;
  final ReviewRepository reviewRepository;
  final ReviewEligibilityRepository reviewEligibilityRepository;
  final PatientDiscoveryRepository patientDiscoveryRepository;
  String currentDoctorId = '';
  String currentDoctorName = '';
  String currentDoctorSpecialty = '';

  RepositoryContainer({
    this.serverpodClient,
    this.hospitalOperationalRepository,
    this.patientPortalRepository,
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
    ResourceRepository? resourceRepository,
    ReportRepository? reportRepository,
    PrescriptionRepository? prescriptionRepository,
    AnalyticsRepository? analyticsRepository,
    NotificationRepository? notificationRepository,
    AIInsightRepository? aiInsightRepository,
    AuditRepository? auditRepository,
    SecurityRepository? securityRepository,
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
        resourceRepository = resourceRepository ?? MockResourceRepository(),
        reportRepository = reportRepository ?? MockReportRepository(),
        prescriptionRepository = prescriptionRepository ?? MockPrescriptionRepository(),
        analyticsRepository = analyticsRepository ?? MockAnalyticsRepository(),
        notificationRepository = notificationRepository ?? MockNotificationRepository(),
        aiInsightRepository = aiInsightRepository ?? MockAIInsightRepository(),
        auditRepository = auditRepository ?? MockAuditRepository(),
        securityRepository = securityRepository ?? MockSecurityRepository(),
        settingsRepository = settingsRepository ?? MockSettingsRepository(),
        authRepository = authRepository ?? MockAuthRepository(),
        fileStorageRepository = fileStorageRepository ?? MockFileStorageRepository(),
        realtimeRepository = realtimeRepository ?? MockRealtimeRepository(),
        locationRepository = locationRepository ?? MockLocationRepository(),
        reviewRepository = reviewRepository ?? MockReviewRepository(),
        reviewEligibilityRepository = reviewEligibilityRepository ?? MockReviewEligibilityRepository(),
        patientDiscoveryRepository = patientDiscoveryRepository ?? MockPatientDiscoveryRepository();


  static RepositoryContainer instance = RepositoryContainer();

  factory RepositoryContainer.withServerpod(Client client) {
    final operationalRecords = HospitalOperationalRepository(client);
    final analytics = ServerpodAnalyticsRepository(operationalRecords);
    final notifications = ServerpodNotificationRepository(operationalRecords);
    final resources = ServerpodResourceRepository(operationalRecords);
    final reports = ServerpodReportRepository(operationalRecords);
    final prescriptions = ServerpodPrescriptionRepository(operationalRecords);
    final audit = ServerpodAuditRepository(operationalRecords);
    final aiInsights = ServerpodAIInsightRepository(operationalRecords);
    final security = ServerpodSecurityRepository(operationalRecords);
    final patients = ServerpodPatientRepository(operationalRecords);
    final hospitalPatients = ServerpodHospitalPatientRepository(operationalRecords);
    final doctors = ServerpodDoctorRepository(operationalRecords);
    final emergencies = ServerpodEmergencyRepository(operationalRecords);
    final settings = ServerpodSettingsRepository(operationalRecords);
    final patientDiscovery = ServerpodPatientDiscoveryRepository(client);
    final reviews = ServerpodReviewRepository(client);
    final reviewEligibility = ServerpodReviewEligibilityRepository(client);
    MockDoctorRepository.serverpodFactory = () => doctors;
    MockAnalyticsRepository.serverpodFactory = () => analytics;
    MockNotificationRepository.serverpodFactory = () => notifications;
    MockResourceRepository.serverpodFactory = () => resources;
    MockReportRepository.serverpodFactory = () => reports;
    MockPrescriptionRepository.serverpodFactory = () => prescriptions;
    MockAuditRepository.serverpodFactory = () => audit;
    MockAIInsightRepository.serverpodFactory = () => aiInsights;
    MockSecurityRepository.serverpodFactory = () => security;
    return RepositoryContainer(
      serverpodClient: client,
      hospitalOperationalRepository: operationalRecords,
      patientPortalRepository: ServerpodPatientPortalRepository(client),
      patientDiscoveryRepository: patientDiscovery,
      reviewRepository: reviews,
      reviewEligibilityRepository: reviewEligibility,
      patientRepository: patients,
      hospitalPatientRepository: hospitalPatients,
      doctorRepository: doctors,
      emergencyRepository: emergencies,
      settingsRepository: settings,
      departmentRepository:
          ServerpodDepartmentRepository(operationalRecords),
      staffRepository: ServerpodStaffRepository(operationalRecords),
      shiftRosterRepository: ServerpodShiftRosterRepository(operationalRecords),
      bedRepository: ServerpodBedRepository(operationalRecords),
      appointmentRepository:
          ServerpodAppointmentRepository(operationalRecords),
      admissionRepository: ServerpodAdmissionRepository(operationalRecords),
      bloodBankRepository: ServerpodBloodRepository(operationalRecords),
      facilityRepository: ServerpodFacilityRepository(operationalRecords),
      equipmentRepository: ServerpodEquipmentRepository(operationalRecords),
      resourceRepository: resources,
      analyticsRepository: analytics,
      notificationRepository: notifications,
      reportRepository: reports,
      prescriptionRepository: prescriptions,
      auditRepository: audit,
      aiInsightRepository: aiInsights,
      securityRepository: security,
      // Resource screen uses a direct MockResourceRepository constructor; the
      // factory override routes that call to this tenant-scoped backend adapter.
      hospitalRepository: ServerpodHospitalRepository(client),
      hospitalSettingsRepository:
          ServerpodHospitalSettingsRepository(client),
    );
  }

  void setHospitalKey(String hospitalKey) {
    final hospital = hospitalRepository;
    final settings = hospitalSettingsRepository;
    hospitalOperationalRepository?.hospitalKey = hospitalKey;
    if (hospital is ServerpodHospitalRepository) {
      hospital.hospitalKey = hospitalKey;
    }
    if (settings is ServerpodHospitalSettingsRepository) {
      settings.hospitalKey = hospitalKey;
    }
  }
  void setDoctorIdentity({
    required String doctorId,
    required String name,
    required String specialty,
  }) {
    currentDoctorId = doctorId;
    currentDoctorName = name;
    currentDoctorSpecialty = specialty;
  }

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
