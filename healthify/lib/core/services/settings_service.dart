import '../data/repositories/settings_repository.dart';
import '../enums/domain_enums.dart';
import '../models/audit_model.dart';
import '../models/settings_model.dart';
import 'audit_service.dart';
import 'notification_service.dart';
import 'settings_validator.dart';

/// Service managing hospital configurations, preferences, and system settings.
class SettingsService {
  final SettingsRepository _settingsRepository;
  final AuditService _auditService;

  SettingsService({
    required SettingsRepository settingsRepository,
    required AuditService auditService,
    required NotificationService notificationService,
  })  : _settingsRepository = settingsRepository,
        _auditService = auditService;

  /// Fetch Hospital Identity Settings
  Future<HospitalSettings> getHospitalSettings(String hospitalId) async {
    return await _settingsRepository.getHospitalSettings(hospitalId);
  }

  /// Update Hospital Identity Settings with validation, audit logging, & config change tracking
  Future<SettingsValidationResult> updateHospitalSettings(
    HospitalSettings settings, {
    required String userId,
    required UserRole role,
  }) async {
    final validation = SettingsValidator.validateHospitalSettings(settings);
    if (!validation.isValid) return validation;

    final current = await _settingsRepository.getHospitalSettings(settings.hospitalId);
    await _settingsRepository.updateHospitalSettings(settings);

    final now = DateTime.now();
    await _auditService.record(
      AuditLog(
        id: 'AUD-${now.millisecondsSinceEpoch}',
        timestamp: now,
        actorId: userId,
        actorRole: role,
        actionType: AuditActionType.update,
        targetEntityType: 'HospitalSettings',
        targetEntityId: settings.hospitalId,
        createdAt: now,
        updatedAt: now,
        details: {'displayName': settings.displayName, 'operatingMode': settings.operatingMode},
      ),
    );

    if (current.operatingMode != settings.operatingMode) {
      await _settingsRepository.recordConfigurationChange(
        ConfigurationChange(
          id: 'CFG-${now.millisecondsSinceEpoch}',
          hospitalId: settings.hospitalId,
          category: 'Operating Mode',
          setting: 'operatingMode',
          previousValue: current.operatingMode,
          newValue: settings.operatingMode,
          changedBy: userId,
          changedAt: now,
        ),
      );
    }

    return SettingsValidationResult.success();
  }

  /// Fetch Operational Settings
  Future<OperationalSettings> getOperationalSettings(String hospitalId) async {
    return await _settingsRepository.getOperationalSettings(hospitalId);
  }

  /// Update Operational Settings
  Future<SettingsValidationResult> updateOperationalSettings(
    OperationalSettings settings, {
    required String hospitalId,
    required String userId,
    required UserRole role,
  }) async {
    final validation = SettingsValidator.validateOperationalSettings(settings);
    if (!validation.isValid) return validation;

    await _settingsRepository.updateOperationalSettings(settings);

    final now = DateTime.now();
    await _auditService.record(
      AuditLog(
        id: 'AUD-${now.millisecondsSinceEpoch}',
        timestamp: now,
        actorId: userId,
        actorRole: role,
        actionType: AuditActionType.update,
        targetEntityType: 'OperationalSettings',
        targetEntityId: hospitalId,
        createdAt: now,
        updatedAt: now,
        details: {'duration': settings.defaultAppointmentDuration, 'buffer': settings.appointmentBufferMinutes},
      ),
    );

    return SettingsValidationResult.success();
  }

  /// Fetch Emergency Settings
  Future<EmergencySettings> getEmergencySettings(String hospitalId) async {
    return await _settingsRepository.getEmergencySettings(hospitalId);
  }

  /// Update Emergency Settings
  Future<SettingsValidationResult> updateEmergencySettings(
    EmergencySettings settings, {
    required String hospitalId,
    required String userId,
    required UserRole role,
  }) async {
    final validation = SettingsValidator.validateEmergencySettings(settings);
    if (!validation.isValid) return validation;

    final current = await _settingsRepository.getEmergencySettings(hospitalId);
    await _settingsRepository.updateEmergencySettings(settings);

    final now = DateTime.now();
    await _auditService.record(
      AuditLog(
        id: 'AUD-${now.millisecondsSinceEpoch}',
        timestamp: now,
        actorId: userId,
        actorRole: role,
        actionType: AuditActionType.update,
        targetEntityType: 'EmergencySettings',
        targetEntityId: hospitalId,
        createdAt: now,
        updatedAt: now,
        details: {'traumaLevel': settings.traumaLevel, '24hEmergency': settings.is24HourEmergency},
      ),
    );

    if (current.emergencyServicesEnabled != settings.emergencyServicesEnabled) {
      await _settingsRepository.recordConfigurationChange(
        ConfigurationChange(
          id: 'CFG-${now.millisecondsSinceEpoch}',
          hospitalId: hospitalId,
          category: 'Emergency Services',
          setting: 'emergencyServicesEnabled',
          previousValue: current.emergencyServicesEnabled.toString(),
          newValue: settings.emergencyServicesEnabled.toString(),
          changedBy: userId,
          changedAt: now,
        ),
      );
    }

    return SettingsValidationResult.success();
  }

  /// Fetch Bed Management Settings
  Future<BedManagementSettings> getBedManagementSettings(String hospitalId) async {
    return await _settingsRepository.getBedManagementSettings(hospitalId);
  }

  /// Update Bed Management Settings
  Future<SettingsValidationResult> updateBedManagementSettings(
    BedManagementSettings settings, {
    required String hospitalId,
    required String userId,
    required UserRole role,
  }) async {
    final validation = SettingsValidator.validateBedSettings(settings);
    if (!validation.isValid) return validation;

    await _settingsRepository.updateBedManagementSettings(settings);

    final now = DateTime.now();
    await _auditService.record(
      AuditLog(
        id: 'AUD-${now.millisecondsSinceEpoch}',
        timestamp: now,
        actorId: userId,
        actorRole: role,
        actionType: AuditActionType.update,
        targetEntityType: 'BedManagementSettings',
        targetEntityId: hospitalId,
        createdAt: now,
        updatedAt: now,
        details: {'warningThreshold': settings.capacityWarningThreshold, 'criticalThreshold': settings.criticalCapacityThreshold},
      ),
    );

    return SettingsValidationResult.success();
  }

  /// Fetch Blood Bank Settings
  Future<BloodBankSettings> getBloodBankSettings(String hospitalId) async {
    return await _settingsRepository.getBloodBankSettings(hospitalId);
  }

  /// Update Blood Bank Settings
  Future<SettingsValidationResult> updateBloodBankSettings(
    BloodBankSettings settings, {
    required String hospitalId,
    required String userId,
    required UserRole role,
  }) async {
    final validation = SettingsValidator.validateBloodBankSettings(settings);
    if (!validation.isValid) return validation;

    await _settingsRepository.updateBloodBankSettings(settings);

    final now = DateTime.now();
    await _auditService.record(
      AuditLog(
        id: 'AUD-${now.millisecondsSinceEpoch}',
        timestamp: now,
        actorId: userId,
        actorRole: role,
        actionType: AuditActionType.update,
        targetEntityType: 'BloodBankSettings',
        targetEntityId: hospitalId,
        createdAt: now,
        updatedAt: now,
        details: {'expiryWarningDays': settings.expiryWarningDays, 'criticalStockThreshold': settings.criticalStockThreshold},
      ),
    );

    return SettingsValidationResult.success();
  }

  /// Fetch Notification System Settings
  Future<NotificationSystemSettings> getNotificationSystemSettings(String hospitalId) async {
    return await _settingsRepository.getNotificationSystemSettings(hospitalId);
  }

  /// Update Notification System Settings
  Future<SettingsValidationResult> updateNotificationSystemSettings(
    NotificationSystemSettings settings, {
    required String hospitalId,
    required String userId,
    required UserRole role,
  }) async {
    final validation = SettingsValidator.validateNotificationSettings(settings);
    if (!validation.isValid) return validation;

    await _settingsRepository.updateNotificationSystemSettings(settings);

    final now = DateTime.now();
    await _auditService.record(
      AuditLog(
        id: 'AUD-${now.millisecondsSinceEpoch}',
        timestamp: now,
        actorId: userId,
        actorRole: role,
        actionType: AuditActionType.update,
        targetEntityType: 'NotificationSystemSettings',
        targetEntityId: hospitalId,
        createdAt: now,
        updatedAt: now,
        details: {'retentionDays': settings.notificationRetentionDays},
      ),
    );

    return SettingsValidationResult.success();
  }

  /// Fetch AI Settings
  Future<AISettings> getAISettings(String hospitalId) async {
    return await _settingsRepository.getAISettings(hospitalId);
  }

  /// Update AI Settings
  Future<SettingsValidationResult> updateAISettings(
    AISettings settings, {
    required String hospitalId,
    required String userId,
    required UserRole role,
  }) async {
    final validation = SettingsValidator.validateAISettings(settings);
    if (!validation.isValid) return validation;

    await _settingsRepository.updateAISettings(settings);

    final now = DateTime.now();
    await _auditService.record(
      AuditLog(
        id: 'AUD-${now.millisecondsSinceEpoch}',
        timestamp: now,
        actorId: userId,
        actorRole: role,
        actionType: AuditActionType.update,
        targetEntityType: 'AISettings',
        targetEntityId: hospitalId,
        createdAt: now,
        updatedAt: now,
        details: {'confidenceThreshold': settings.confidenceThreshold, 'aiInsightsEnabled': settings.aiInsightsEnabled},
      ),
    );

    return SettingsValidationResult.success();
  }

  /// Fetch Security Settings
  Future<SecuritySettings> getSecuritySettings(String hospitalId) async {
    return await _settingsRepository.getSecuritySettings(hospitalId);
  }

  /// Update Security Settings
  Future<SettingsValidationResult> updateSecuritySettings(
    SecuritySettings settings, {
    required String hospitalId,
    required String userId,
    required UserRole role,
  }) async {
    final validation = SettingsValidator.validateSecuritySettings(settings);
    if (!validation.isValid) return validation;

    await _settingsRepository.updateSecuritySettings(settings);

    final now = DateTime.now();
    await _auditService.record(
      AuditLog(
        id: 'AUD-${now.millisecondsSinceEpoch}',
        timestamp: now,
        actorId: userId,
        actorRole: role,
        actionType: AuditActionType.update,
        targetEntityType: 'SecuritySettings',
        targetEntityId: hospitalId,
        createdAt: now,
        updatedAt: now,
        details: {'sessionTimeout': settings.sessionTimeoutMinutes, 'breakGlass': settings.breakGlassEnabled},
      ),
    );

    return SettingsValidationResult.success();
  }

  /// Fetch User Personal Preferences
  Future<UserPreferences> getUserPreferences(String userId) async {
    return await _settingsRepository.getUserPreferences(userId);
  }

  /// Update User Personal Preferences
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    await _settingsRepository.updateUserPreferences(preferences);
  }

  /// Fetch Appearance Settings
  Future<AppearanceSettings> getAppearanceSettings(String userId) async {
    return await _settingsRepository.getAppearanceSettings(userId);
  }

  /// Update Appearance Settings
  Future<void> updateAppearanceSettings(AppearanceSettings settings, {required String userId}) async {
    await _settingsRepository.updateAppearanceSettings(settings);
  }

  /// Fetch System Information
  Future<SystemInformation> getSystemInformation() async {
    return await _settingsRepository.getSystemInformation();
  }

  /// Fetch Configuration Change Audit History
  Future<List<ConfigurationChange>> getConfigurationHistory(String hospitalId) async {
    return await _settingsRepository.getConfigurationHistory(hospitalId);
  }
}
