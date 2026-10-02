import '../models/settings_model.dart';

/// Validation result class for settings validation
class SettingsValidationResult {
  final bool isValid;
  final List<String> errors;

  const SettingsValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  factory SettingsValidationResult.success() =>
      const SettingsValidationResult(isValid: true);

  factory SettingsValidationResult.failure(List<String> errors) =>
      SettingsValidationResult(isValid: false, errors: errors);
}

/// Service class for validating configuration inputs
class SettingsValidator {
  /// Validate HospitalSettings
  static SettingsValidationResult validateHospitalSettings(HospitalSettings settings) {
    final errors = <String>[];

    if (settings.displayName.trim().isEmpty) {
      errors.add('Hospital display name cannot be empty');
    }
    if (settings.hospitalId.trim().isEmpty) {
      errors.add('Hospital ID cannot be empty');
    }
    if (!settings.email.contains('@') || !settings.email.contains('.')) {
      errors.add('Valid hospital contact email address is required');
    }
    if (settings.phone.trim().isEmpty) {
      errors.add('Hospital contact phone cannot be empty');
    }
    if (settings.emergencyHelpline.trim().isEmpty) {
      errors.add('Emergency helpline phone cannot be empty');
    }

    return errors.isEmpty
        ? SettingsValidationResult.success()
        : SettingsValidationResult.failure(errors);
  }

  /// Validate OperationalSettings
  static SettingsValidationResult validateOperationalSettings(OperationalSettings settings) {
    final errors = <String>[];

    if (settings.defaultAppointmentDuration <= 0) {
      errors.add('Default appointment duration must be greater than 0 minutes');
    }
    if (settings.appointmentBufferMinutes < 0) {
      errors.add('Appointment buffer minutes cannot be negative');
    }
    if (settings.maxAdvanceBookingDays <= 0) {
      errors.add('Maximum advance booking days must be greater than 0');
    }
    if (settings.noShowThreshold < 1) {
      errors.add('No-show threshold must be at least 1');
    }

    return errors.isEmpty
        ? SettingsValidationResult.success()
        : SettingsValidationResult.failure(errors);
  }

  /// Validate EmergencySettings
  static SettingsValidationResult validateEmergencySettings(EmergencySettings settings) {
    final errors = <String>[];

    if (settings.traumaLevel.trim().isEmpty) {
      errors.add('Trauma level designation cannot be empty');
    }

    return errors.isEmpty
        ? SettingsValidationResult.success()
        : SettingsValidationResult.failure(errors);
  }

  /// Validate BedManagementSettings
  static SettingsValidationResult validateBedSettings(BedManagementSettings settings) {
    final errors = <String>[];

    if (settings.capacityWarningThreshold < 0.0 || settings.capacityWarningThreshold > 1.0) {
      errors.add('Bed capacity warning threshold must be between 0% and 100%');
    }
    if (settings.criticalCapacityThreshold < 0.0 || settings.criticalCapacityThreshold > 1.0) {
      errors.add('Bed critical capacity threshold must be between 0% and 100%');
    }
    if (settings.capacityWarningThreshold >= settings.criticalCapacityThreshold) {
      errors.add('Capacity warning threshold must be lower than critical capacity threshold');
    }
    if (settings.icuCriticalThreshold < 0.0 || settings.icuCriticalThreshold > 1.0) {
      errors.add('ICU critical threshold must be between 0% and 100%');
    }

    return errors.isEmpty
        ? SettingsValidationResult.success()
        : SettingsValidationResult.failure(errors);
  }

  /// Validate BloodBankSettings
  static SettingsValidationResult validateBloodBankSettings(BloodBankSettings settings) {
    final errors = <String>[];

    if (settings.expiryWarningDays <= 0) {
      errors.add('Expiry warning days must be greater than 0');
    }
    if (settings.criticalStockThreshold < 0) {
      errors.add('Critical stock threshold cannot be negative');
    }

    return errors.isEmpty
        ? SettingsValidationResult.success()
        : SettingsValidationResult.failure(errors);
  }

  /// Validate NotificationSystemSettings
  static SettingsValidationResult validateNotificationSettings(NotificationSystemSettings settings) {
    final errors = <String>[];

    if (settings.notificationRetentionDays <= 0) {
      errors.add('Notification retention days must be greater than 0');
    }

    return errors.isEmpty
        ? SettingsValidationResult.success()
        : SettingsValidationResult.failure(errors);
  }

  /// Validate AISettings
  static SettingsValidationResult validateAISettings(AISettings settings) {
    final errors = <String>[];

    if (settings.confidenceThreshold < 0.0 || settings.confidenceThreshold > 1.0) {
      errors.add('AI confidence threshold must be between 0% and 100%');
    }

    return errors.isEmpty
        ? SettingsValidationResult.success()
        : SettingsValidationResult.failure(errors);
  }

  /// Validate SecuritySettings
  static SettingsValidationResult validateSecuritySettings(SecuritySettings settings) {
    final errors = <String>[];

    if (settings.sessionTimeoutMinutes < 5 || settings.sessionTimeoutMinutes > 480) {
      errors.add('Session timeout must be between 5 and 480 minutes (8 hours)');
    }

    return errors.isEmpty
        ? SettingsValidationResult.success()
        : SettingsValidationResult.failure(errors);
  }
}
