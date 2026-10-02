import '../repositories/settings_repository.dart';
import '../../models/settings_model.dart';
import 'mock_data_store.dart';

/// Mock implementation of [SettingsRepository] backed by [MockDataStore].
class MockSettingsRepository implements SettingsRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<HospitalSettings> getHospitalSettings(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.hospitalSettings;
  }

  @override
  Future<void> updateHospitalSettings(HospitalSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.hospitalSettings = settings;
  }

  @override
  Future<OperationalSettings> getOperationalSettings(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.operationalSettings;
  }

  @override
  Future<void> updateOperationalSettings(OperationalSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.operationalSettings = settings;
  }

  @override
  Future<EmergencySettings> getEmergencySettings(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.emergencySettings;
  }

  @override
  Future<void> updateEmergencySettings(EmergencySettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.emergencySettings = settings;
  }

  @override
  Future<BedManagementSettings> getBedManagementSettings(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.bedManagementSettings;
  }

  @override
  Future<void> updateBedManagementSettings(BedManagementSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.bedManagementSettings = settings;
  }

  @override
  Future<BloodBankSettings> getBloodBankSettings(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.bloodBankSettings;
  }

  @override
  Future<void> updateBloodBankSettings(BloodBankSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.bloodBankSettings = settings;
  }

  @override
  Future<NotificationSystemSettings> getNotificationSystemSettings(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.notificationSystemSettings;
  }

  @override
  Future<void> updateNotificationSystemSettings(NotificationSystemSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.notificationSystemSettings = settings;
  }

  @override
  Future<AISettings> getAISettings(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.aiSettings;
  }

  @override
  Future<void> updateAISettings(AISettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.aiSettings = settings;
  }

  @override
  Future<SecuritySettings> getSecuritySettings(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.securitySettings;
  }

  @override
  Future<void> updateSecuritySettings(SecuritySettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.securitySettings = settings;
  }

  @override
  Future<UserPreferences> getUserPreferences(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.userPreferences;
  }

  @override
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.userPreferences = preferences;
  }

  @override
  Future<AppearanceSettings> getAppearanceSettings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _store.appearanceSettings;
  }

  @override
  Future<void> updateAppearanceSettings(AppearanceSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _store.appearanceSettings = settings;
  }

  @override
  Future<SystemInformation> getSystemInformation() async {
    await Future.delayed(const Duration(milliseconds: 30));
    return _store.systemInformation;
  }

  @override
  Future<List<ConfigurationChange>> getConfigurationHistory(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_store.configurationHistory);
  }

  @override
  Future<void> recordConfigurationChange(ConfigurationChange change) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _store.configurationHistory.insert(0, change);
  }
}
