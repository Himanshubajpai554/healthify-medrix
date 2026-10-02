import '../../models/settings_model.dart';

/// Abstract contract for Hospital Settings Repository
abstract class SettingsRepository {
  Future<HospitalSettings> getHospitalSettings(String hospitalId);
  Future<void> updateHospitalSettings(HospitalSettings settings);

  Future<OperationalSettings> getOperationalSettings(String hospitalId);
  Future<void> updateOperationalSettings(OperationalSettings settings);

  Future<EmergencySettings> getEmergencySettings(String hospitalId);
  Future<void> updateEmergencySettings(EmergencySettings settings);

  Future<BedManagementSettings> getBedManagementSettings(String hospitalId);
  Future<void> updateBedManagementSettings(BedManagementSettings settings);

  Future<BloodBankSettings> getBloodBankSettings(String hospitalId);
  Future<void> updateBloodBankSettings(BloodBankSettings settings);

  Future<NotificationSystemSettings> getNotificationSystemSettings(String hospitalId);
  Future<void> updateNotificationSystemSettings(NotificationSystemSettings settings);

  Future<AISettings> getAISettings(String hospitalId);
  Future<void> updateAISettings(AISettings settings);

  Future<SecuritySettings> getSecuritySettings(String hospitalId);
  Future<void> updateSecuritySettings(SecuritySettings settings);

  Future<UserPreferences> getUserPreferences(String userId);
  Future<void> updateUserPreferences(UserPreferences preferences);

  Future<AppearanceSettings> getAppearanceSettings(String userId);
  Future<void> updateAppearanceSettings(AppearanceSettings settings);

  Future<SystemInformation> getSystemInformation();

  Future<List<ConfigurationChange>> getConfigurationHistory(String hospitalId);
  Future<void> recordConfigurationChange(ConfigurationChange change);
}
