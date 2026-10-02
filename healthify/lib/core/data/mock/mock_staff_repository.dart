import '../repositories/staff_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/staff_model.dart';
import 'mock_data_store.dart';

class MockStaffRepository implements StaffRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<StaffModel>> getStaffList() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_store.staff);
  }

  @override
  Future<StaffModel?> getStaffById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _store.staff.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StaffModel> addStaff(StaffModel staff) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.staff.insert(0, staff);
    return staff;
  }

  @override
  Future<void> updateStaffStatus(String staffId, StaffStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.staff.indexWhere((s) => s.id == staffId);
    if (index != -1) {
      final old = _store.staff[index];
      _store.staff[index] = StaffModel(
        id: old.id,
        name: old.name,
        role: old.role,
        department: old.department,
        status: status,
        phone: old.phone,
        shift: old.shift,
      );
    }
  }

  @override
  Future<void> updateStaff(StaffModel staff) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _store.staff.indexWhere((s) => s.id == staff.id);
    if (index != -1) {
      _store.staff[index] = staff;
    }
  }

  @override
  Future<void> assignStaffDepartment(String staffId, String departmentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.staff.indexWhere((s) => s.id == staffId);
    if (index != -1) {
      final old = _store.staff[index];
      _store.staff[index] = StaffModel(
        id: old.id,
        name: old.name,
        role: old.role,
        department: departmentId,
        status: old.status,
        phone: old.phone,
        shift: old.shift,
      );
    }
  }
}
