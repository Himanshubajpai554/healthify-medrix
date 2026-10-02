import '../enums/domain_enums.dart';

class LegacyHospitalSettings {
  final String hospitalId;
  final String timezone;
  final String defaultCurrency;
  
  // Operational Settings
  final String opdOpeningTime;
  final String opdClosingTime;
  final int appointmentSlotDurationMinutes;
  final bool autoReleaseExpiredBeds;
  
  // Emergency Settings
  final bool isEmergencyActive;
  final String emergencyHotline;
  final String traumaLevel;
  final int ambulanceCount;

  // Patient Visibility Settings
  final bool isHospitalDiscoverable;
  final bool showFacilitiesToPatients;
  final bool showDoctorSchedulesToPatients;
  final bool showBedAvailabilityToPatients;
  final bool showRatingsAndReviews;

  // Security & Audit Settings
  final int sessionTimeoutMinutes;
  final bool enforceMfaForAdmin;
  final bool enableAuditLogging;

  const LegacyHospitalSettings({
    required this.hospitalId,
    this.timezone = 'UTC-5 (EST)',
    this.defaultCurrency = 'USD (\$)',
    this.opdOpeningTime = '08:00 AM',
    this.opdClosingTime = '08:00 PM',
    this.appointmentSlotDurationMinutes = 30,
    this.autoReleaseExpiredBeds = true,
    this.isEmergencyActive = true,
    this.emergencyHotline = '+1 (555) 911-STJUDE',
    this.traumaLevel = 'Level 1 Trauma Center',
    this.ambulanceCount = 8,
    this.isHospitalDiscoverable = true,
    this.showFacilitiesToPatients = true,
    this.showDoctorSchedulesToPatients = true,
    this.showBedAvailabilityToPatients = true,
    this.showRatingsAndReviews = true,
    this.sessionTimeoutMinutes = 30,
    this.enforceMfaForAdmin = true,
    this.enableAuditLogging = true,
  });

  LegacyHospitalSettings copyWith({

    String? timezone,
    String? defaultCurrency,
    String? opdOpeningTime,
    String? opdClosingTime,
    int? appointmentSlotDurationMinutes,
    bool? autoReleaseExpiredBeds,
    bool? isEmergencyActive,
    String? emergencyHotline,
    String? traumaLevel,
    int? ambulanceCount,
    bool? isHospitalDiscoverable,
    bool? showFacilitiesToPatients,
    bool? showDoctorSchedulesToPatients,
    bool? showBedAvailabilityToPatients,
    bool? showRatingsAndReviews,
    int? sessionTimeoutMinutes,
    bool? enforceMfaForAdmin,
    bool? enableAuditLogging,
  }) {
    return LegacyHospitalSettings(
      hospitalId: hospitalId,

      timezone: timezone ?? this.timezone,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      opdOpeningTime: opdOpeningTime ?? this.opdOpeningTime,
      opdClosingTime: opdClosingTime ?? this.opdClosingTime,
      appointmentSlotDurationMinutes: appointmentSlotDurationMinutes ?? this.appointmentSlotDurationMinutes,
      autoReleaseExpiredBeds: autoReleaseExpiredBeds ?? this.autoReleaseExpiredBeds,
      isEmergencyActive: isEmergencyActive ?? this.isEmergencyActive,
      emergencyHotline: emergencyHotline ?? this.emergencyHotline,
      traumaLevel: traumaLevel ?? this.traumaLevel,
      ambulanceCount: ambulanceCount ?? this.ambulanceCount,
      isHospitalDiscoverable: isHospitalDiscoverable ?? this.isHospitalDiscoverable,
      showFacilitiesToPatients: showFacilitiesToPatients ?? this.showFacilitiesToPatients,
      showDoctorSchedulesToPatients: showDoctorSchedulesToPatients ?? this.showDoctorSchedulesToPatients,
      showBedAvailabilityToPatients: showBedAvailabilityToPatients ?? this.showBedAvailabilityToPatients,
      showRatingsAndReviews: showRatingsAndReviews ?? this.showRatingsAndReviews,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      enforceMfaForAdmin: enforceMfaForAdmin ?? this.enforceMfaForAdmin,
      enableAuditLogging: enableAuditLogging ?? this.enableAuditLogging,
    );
  }
}

class UserAccessRecord {
  final String userId;
  final String userName;
  final String email;
  final UserRole role;
  final String department;
  final bool isActive;
  final DateTime lastActive;

  const UserAccessRecord({
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    required this.department,
    required this.isActive,
    required this.lastActive,
  });
}
