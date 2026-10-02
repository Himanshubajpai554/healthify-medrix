import '../../enums/domain_enums.dart';
import '../../models/hospital_settings_model.dart';
import '../repositories/hospital_settings_repository.dart';

class MockHospitalSettingsRepository implements HospitalSettingsRepository {
  LegacyHospitalSettings _settings = const LegacyHospitalSettings(
    hospitalId: 'HOSP-101',
  );

  final List<UserAccessRecord> _users = [

    UserAccessRecord(
      userId: 'USR-101',
      userName: 'Dr. Sarah Jenkins',
      email: 'sarah.jenkins@stjude-hospital.org',
      role: UserRole.doctor,
      department: 'Cardiology',
      isActive: true,
      lastActive: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    UserAccessRecord(
      userId: 'USR-102',
      userName: 'Admin Marcus Vance',
      email: 'admin.vance@stjude-hospital.org',
      role: UserRole.hospitalAdmin,
      department: 'Administration',
      isActive: true,
      lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    UserAccessRecord(
      userId: 'USR-103',
      userName: 'Nurse Clara Oswald',
      email: 'clara.oswald@stjude-hospital.org',
      role: UserRole.nurse,
      department: 'ICU Main Wing',
      isActive: true,
      lastActive: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    UserAccessRecord(
      userId: 'USR-104',
      userName: 'Receptionist David Miller',
      email: 'david.miller@stjude-hospital.org',
      role: UserRole.receptionist,
      department: 'Front Desk OPD',
      isActive: true,
      lastActive: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  Future<LegacyHospitalSettings> getSettings(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _settings;
  }

  @override
  Future<void> updateSettings(LegacyHospitalSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _settings = settings;
  }


  @override
  Future<List<UserAccessRecord>> getUserAccessList(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_users);
  }

  @override
  Future<void> updateUserRole(String userId, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _users.indexWhere((u) => u.userId == userId);
    if (index != -1) {
      final old = _users[index];
      _users[index] = UserAccessRecord(
        userId: old.userId,
        userName: old.userName,
        email: old.email,
        role: role,
        department: old.department,
        isActive: old.isActive,
        lastActive: old.lastActive,
      );
    }
  }

  @override
  Future<void> toggleUserAccess(String userId, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _users.indexWhere((u) => u.userId == userId);
    if (index != -1) {
      final old = _users[index];
      _users[index] = UserAccessRecord(
        userId: old.userId,
        userName: old.userName,
        email: old.email,
        role: old.role,
        department: old.department,
        isActive: isActive,
        lastActive: old.lastActive,
      );
    }
  }
}
