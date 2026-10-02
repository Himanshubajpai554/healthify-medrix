/// Hospital Identity & Operating Mode Settings Model
class HospitalSettings {

  final String hospitalId;
  final String displayName;
  final String legalName;
  final String hospitalType;
  final String licenseId;
  final String taxId;
  final String email;
  final String phone;
  final String emergencyHelpline;
  final String website;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String timezone;
  final String operatingMode; // Normal, Emergency Surge, Maintenance, Disaster Response

  const HospitalSettings({
    required this.hospitalId,
    this.displayName = 'St. Jude Memorial Hospital',
    this.legalName = 'St. Jude Healthcare Systems Inc.',
    this.hospitalType = 'Multi-specialty Trauma & Academic Center',
    this.licenseId = 'HOSP-NY-90218',
    this.taxId = 'XX-XXX9081',
    this.email = 'admin@stjude-hospital.org',
    this.phone = '+1 (555) 900-MEDRIX',
    this.emergencyHelpline = '+1 (555) 911-STJUDE',
    this.website = 'https://stjude-hospital.org',
    this.address = '742 Healthcare Boulevard',
    this.city = 'New York',
    this.state = 'NY',
    this.country = 'USA',
    this.postalCode = '10001',
    this.timezone = 'America/New_York (EST)',
    this.operatingMode = 'Normal Operations',
  });

  HospitalSettings copyWith({
    String? hospitalId,
    String? displayName,
    String? legalName,
    String? hospitalType,
    String? licenseId,
    String? taxId,
    String? email,
    String? phone,
    String? emergencyHelpline,
    String? website,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? timezone,
    String? operatingMode,
  }) {
    return HospitalSettings(
      hospitalId: hospitalId ?? this.hospitalId,
      displayName: displayName ?? this.displayName,
      legalName: legalName ?? this.legalName,
      hospitalType: hospitalType ?? this.hospitalType,
      licenseId: licenseId ?? this.licenseId,
      taxId: taxId ?? this.taxId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      emergencyHelpline: emergencyHelpline ?? this.emergencyHelpline,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      timezone: timezone ?? this.timezone,
      operatingMode: operatingMode ?? this.operatingMode,
    );
  }
}

/// Day Operating Hours Model
class OperatingHours {
  final String dayOfWeek;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final bool is24Hours;

  const OperatingHours({
    required this.dayOfWeek,
    this.isOpen = true,
    this.openTime = '08:00 AM',
    this.closeTime = '08:00 PM',
    this.is24Hours = false,
  });
}

/// Operational & Appointment Settings Model
class OperationalSettings {
  final int defaultAppointmentDuration;
  final int appointmentBufferMinutes;
  final bool allowWalkIns;
  final bool allowOnlineAppointments;
  final int maxAdvanceBookingDays;
  final int noShowThreshold;
  final bool queueDisplayEnabled;

  const OperationalSettings({
    this.defaultAppointmentDuration = 30,
    this.appointmentBufferMinutes = 5,
    this.allowWalkIns = true,
    this.allowOnlineAppointments = true,
    this.maxAdvanceBookingDays = 30,
    this.noShowThreshold = 3,
    this.queueDisplayEnabled = true,
  });

  OperationalSettings copyWith({
    int? defaultAppointmentDuration,
    int? appointmentBufferMinutes,
    bool? allowWalkIns,
    bool? allowOnlineAppointments,
    int? maxAdvanceBookingDays,
    int? noShowThreshold,
    bool? queueDisplayEnabled,
  }) {
    return OperationalSettings(
      defaultAppointmentDuration: defaultAppointmentDuration ?? this.defaultAppointmentDuration,
      appointmentBufferMinutes: appointmentBufferMinutes ?? this.appointmentBufferMinutes,
      allowWalkIns: allowWalkIns ?? this.allowWalkIns,
      allowOnlineAppointments: allowOnlineAppointments ?? this.allowOnlineAppointments,
      maxAdvanceBookingDays: maxAdvanceBookingDays ?? this.maxAdvanceBookingDays,
      noShowThreshold: noShowThreshold ?? this.noShowThreshold,
      queueDisplayEnabled: queueDisplayEnabled ?? this.queueDisplayEnabled,
    );
  }
}

/// Emergency & Triage Configuration Model
class EmergencySettings {
  final bool emergencyServicesEnabled;
  final bool is24HourEmergency;
  final bool triageEnabled;
  final bool emergencyQueueEnabled;
  final bool ambulanceServiceEnabled;
  final String traumaLevel;
  final bool criticalAlertEnabled;

  const EmergencySettings({
    this.emergencyServicesEnabled = true,
    this.is24HourEmergency = true,
    this.triageEnabled = true,
    this.emergencyQueueEnabled = true,
    this.ambulanceServiceEnabled = true,
    this.traumaLevel = 'Level 1 Comprehensive Trauma Center',
    this.criticalAlertEnabled = true,
  });

  EmergencySettings copyWith({
    bool? emergencyServicesEnabled,
    bool? is24HourEmergency,
    bool? triageEnabled,
    bool? emergencyQueueEnabled,
    bool? ambulanceServiceEnabled,
    String? traumaLevel,
    bool? criticalAlertEnabled,
  }) {
    return EmergencySettings(
      emergencyServicesEnabled: emergencyServicesEnabled ?? this.emergencyServicesEnabled,
      is24HourEmergency: is24HourEmergency ?? this.is24HourEmergency,
      triageEnabled: triageEnabled ?? this.triageEnabled,
      emergencyQueueEnabled: emergencyQueueEnabled ?? this.emergencyQueueEnabled,
      ambulanceServiceEnabled: ambulanceServiceEnabled ?? this.ambulanceServiceEnabled,
      traumaLevel: traumaLevel ?? this.traumaLevel,
      criticalAlertEnabled: criticalAlertEnabled ?? this.criticalAlertEnabled,
    );
  }
}

/// Bed & ICU Capacity Settings Model
class BedManagementSettings {
  final bool allowReservations;
  final bool sanitizationRequired;
  final bool maintenanceTracking;
  final bool occupancyAlerts;
  final double capacityWarningThreshold; // e.g., 0.80 (80%)
  final double criticalCapacityThreshold; // e.g., 0.90 (90%)
  final bool icuCapacityAlerts;
  final double icuCriticalThreshold; // e.g., 0.85 (85%)

  const BedManagementSettings({
    this.allowReservations = true,
    this.sanitizationRequired = true,
    this.maintenanceTracking = true,
    this.occupancyAlerts = true,
    this.capacityWarningThreshold = 0.80,
    this.criticalCapacityThreshold = 0.90,
    this.icuCapacityAlerts = true,
    this.icuCriticalThreshold = 0.85,
  });

  BedManagementSettings copyWith({
    bool? allowReservations,
    bool? sanitizationRequired,
    bool? maintenanceTracking,
    bool? occupancyAlerts,
    double? capacityWarningThreshold,
    double? criticalCapacityThreshold,
    bool? icuCapacityAlerts,
    double? icuCriticalThreshold,
  }) {
    return BedManagementSettings(
      allowReservations: allowReservations ?? this.allowReservations,
      sanitizationRequired: sanitizationRequired ?? this.sanitizationRequired,
      maintenanceTracking: maintenanceTracking ?? this.maintenanceTracking,
      occupancyAlerts: occupancyAlerts ?? this.occupancyAlerts,
      capacityWarningThreshold: capacityWarningThreshold ?? this.capacityWarningThreshold,
      criticalCapacityThreshold: criticalCapacityThreshold ?? this.criticalCapacityThreshold,
      icuCapacityAlerts: icuCapacityAlerts ?? this.icuCapacityAlerts,
      icuCriticalThreshold: icuCriticalThreshold ?? this.icuCriticalThreshold,
    );
  }
}

/// Blood Bank Configuration Model
class BloodBankSettings {
  final int expiryWarningDays;
  final int criticalStockThreshold;
  final bool reservationEnabled;
  final bool quarantineEnabled;
  final bool patientAvailabilityEnabled;

  const BloodBankSettings({
    this.expiryWarningDays = 7,
    this.criticalStockThreshold = 5,
    this.reservationEnabled = true,
    this.quarantineEnabled = true,
    this.patientAvailabilityEnabled = true,
  });

  BloodBankSettings copyWith({
    int? expiryWarningDays,
    int? criticalStockThreshold,
    bool? reservationEnabled,
    bool? quarantineEnabled,
    bool? patientAvailabilityEnabled,
  }) {
    return BloodBankSettings(
      expiryWarningDays: expiryWarningDays ?? this.expiryWarningDays,
      criticalStockThreshold: criticalStockThreshold ?? this.criticalStockThreshold,
      reservationEnabled: reservationEnabled ?? this.reservationEnabled,
      quarantineEnabled: quarantineEnabled ?? this.quarantineEnabled,
      patientAvailabilityEnabled: patientAvailabilityEnabled ?? this.patientAvailabilityEnabled,
    );
  }
}

/// Notification System Configuration Model
class NotificationSystemSettings {
  final bool inAppEnabled;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool criticalAlertsEnabled;
  final int notificationRetentionDays;

  const NotificationSystemSettings({
    this.inAppEnabled = true,
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = true,
    this.criticalAlertsEnabled = true,
    this.notificationRetentionDays = 90,
  });

  NotificationSystemSettings copyWith({
    bool? inAppEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? criticalAlertsEnabled,
    int? notificationRetentionDays,
  }) {
    return NotificationSystemSettings(
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      criticalAlertsEnabled: criticalAlertsEnabled ?? this.criticalAlertsEnabled,
      notificationRetentionDays: notificationRetentionDays ?? this.notificationRetentionDays,
    );
  }
}

/// AI & Forecasting Settings Model
class AISettings {
  final bool aiInsightsEnabled;
  final bool forecastingEnabled;
  final bool emergencyRecommendationEnabled;
  final double confidenceThreshold;
  final bool showModelVersion;
  final bool showForecastLimitations;

  const AISettings({
    this.aiInsightsEnabled = true,
    this.forecastingEnabled = true,
    this.emergencyRecommendationEnabled = true,
    this.confidenceThreshold = 0.80,
    this.showModelVersion = true,
    this.showForecastLimitations = true,
  });

  AISettings copyWith({
    bool? aiInsightsEnabled,
    bool? forecastingEnabled,
    bool? emergencyRecommendationEnabled,
    double? confidenceThreshold,
    bool? showModelVersion,
    bool? showForecastLimitations,
  }) {
    return AISettings(
      aiInsightsEnabled: aiInsightsEnabled ?? this.aiInsightsEnabled,
      forecastingEnabled: forecastingEnabled ?? this.forecastingEnabled,
      emergencyRecommendationEnabled: emergencyRecommendationEnabled ?? this.emergencyRecommendationEnabled,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      showModelVersion: showModelVersion ?? this.showModelVersion,
      showForecastLimitations: showForecastLimitations ?? this.showForecastLimitations,
    );
  }
}

/// Security & Audit System Settings Model
class SecuritySettings {
  final int sessionTimeoutMinutes;
  final bool auditLoggingEnabled;
  final bool sensitiveAccessLoggingEnabled;
  final bool breakGlassEnabled;
  final bool requireAcknowledgementForCriticalAlerts;

  const SecuritySettings({
    this.sessionTimeoutMinutes = 30,
    this.auditLoggingEnabled = true,
    this.sensitiveAccessLoggingEnabled = true,
    this.breakGlassEnabled = true,
    this.requireAcknowledgementForCriticalAlerts = true,
  });

  SecuritySettings copyWith({
    int? sessionTimeoutMinutes,
    bool? auditLoggingEnabled,
    bool? sensitiveAccessLoggingEnabled,
    bool? breakGlassEnabled,
    bool? requireAcknowledgementForCriticalAlerts,
  }) {
    return SecuritySettings(
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      auditLoggingEnabled: auditLoggingEnabled ?? this.auditLoggingEnabled,
      sensitiveAccessLoggingEnabled: sensitiveAccessLoggingEnabled ?? this.sensitiveAccessLoggingEnabled,
      breakGlassEnabled: breakGlassEnabled ?? this.breakGlassEnabled,
      requireAcknowledgementForCriticalAlerts: requireAcknowledgementForCriticalAlerts ?? this.requireAcknowledgementForCriticalAlerts,
    );
  }
}

/// User Personal Preferences Model
class UserPreferences {
  final String userId;
  final String language;
  final String timezone;
  final bool compactMode;
  final String defaultLandingPage;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool reducedMotion;

  const UserPreferences({
    required this.userId,
    this.language = 'en-US (English)',
    this.timezone = 'America/New_York (EST)',
    this.compactMode = false,
    this.defaultLandingPage = 'Overview Dashboard',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.reducedMotion = false,
  });

  UserPreferences copyWith({
    String? userId,
    String? language,
    String? timezone,
    bool? compactMode,
    String? defaultLandingPage,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? reducedMotion,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      compactMode: compactMode ?? this.compactMode,
      defaultLandingPage: defaultLandingPage ?? this.defaultLandingPage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }
}

/// Appearance & Theme Settings Model
class AppearanceSettings {
  final String themeMode; // 'system', 'light', 'dark'
  final String density; // 'comfortable', 'compact'
  final bool sidebarCollapsed;
  final bool animationsEnabled;

  const AppearanceSettings({
    this.themeMode = 'system',
    this.density = 'comfortable',
    this.sidebarCollapsed = false,
    this.animationsEnabled = true,
  });

  AppearanceSettings copyWith({
    String? themeMode,
    String? density,
    bool? sidebarCollapsed,
    bool? animationsEnabled,
  }) {
    return AppearanceSettings(
      themeMode: themeMode ?? this.themeMode,
      density: density ?? this.density,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }
}

/// System Information Contract Model
class SystemInformation {
  final String appName;
  final String appVersion;
  final String buildVersion;
  final String environment;
  final String architectureVersion;

  const SystemInformation({
    this.appName = 'Medrix Hospital Portal',
    this.appVersion = '2.4.0',
    this.buildVersion = 'Build 2026.10',
    this.environment = 'Frontend Architecture v1',
    this.architectureVersion = 'Serverpod-Swap Ready Contract v1',
  });
}

/// Configuration Change Record Model
class ConfigurationChange {
  final String id;
  final String hospitalId;
  final String category;
  final String setting;
  final String previousValue;
  final String newValue;
  final String changedBy;
  final DateTime changedAt;

  const ConfigurationChange({
    required this.id,
    this.hospitalId = 'HOSP-101',
    required this.category,
    required this.setting,
    required this.previousValue,
    required this.newValue,
    required this.changedBy,
    required this.changedAt,
  });
}
