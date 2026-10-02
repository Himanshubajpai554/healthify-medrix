import '../../enums/domain_enums.dart';
import '../../models/hospital_settings_model.dart';

abstract class HospitalSettingsRepository {
  Future<LegacyHospitalSettings> getSettings(String hospitalId);
  Future<void> updateSettings(LegacyHospitalSettings settings);

  Future<List<UserAccessRecord>> getUserAccessList(String hospitalId);
  Future<void> updateUserRole(String userId, UserRole role);
  Future<void> toggleUserAccess(String userId, bool isActive);
}
