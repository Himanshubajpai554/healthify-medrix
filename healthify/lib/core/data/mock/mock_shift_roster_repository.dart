import '../../enums/domain_enums.dart';
import '../../models/staff_model.dart';
import '../repositories/shift_roster_repository.dart';

class MockShiftRosterRepository implements ShiftRosterRepository {
  final List<ShiftRoster> _shifts = [
    ShiftRoster(
      id: 'SFT-101',
      staffId: 'STF-301',
      hospitalId: 'HOSP-101',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 6)),
      shiftStatus: ShiftStatus.inProgress,
      ward: 'ICU Main Wing',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    ShiftRoster(
      id: 'SFT-102',
      staffId: 'STF-304',
      hospitalId: 'HOSP-101',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 9)),
      shiftStatus: ShiftStatus.scheduled,
      ward: 'Radiology Imaging',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    ShiftRoster(
      id: 'SFT-103',
      staffId: 'STF-308',
      hospitalId: 'HOSP-101',
      startTime: DateTime.now().subtract(const Duration(hours: 4)),
      endTime: DateTime.now().add(const Duration(hours: 4)),
      shiftStatus: ShiftStatus.inProgress,
      ward: 'Central Pharmacy',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<ShiftRoster>> getShiftRoster({String? departmentId, DateTime? date}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_shifts);
  }

  @override
  Future<List<ShiftRoster>> getStaffShifts(String staffId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _shifts.where((s) => s.staffId == staffId).toList();
  }

  @override
  Future<ShiftRoster> createShift(ShiftRoster shift) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _shifts.insert(0, shift);
    return shift;
  }

  @override
  Future<void> updateShift(ShiftRoster shift) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _shifts.indexWhere((s) => s.id == shift.id);
    if (index != -1) {
      _shifts[index] = shift;
    }
  }

  @override
  Future<void> reassignShift(String shiftId, String newStaffId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _shifts.indexWhere((s) => s.id == shiftId);
    if (index != -1) {
      final old = _shifts[index];
      _shifts[index] = ShiftRoster(
        id: old.id,
        staffId: newStaffId,
        hospitalId: old.hospitalId,
        startTime: old.startTime,
        endTime: old.endTime,
        shiftStatus: old.shiftStatus,
        ward: old.ward,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> cancelShift(String shiftId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _shifts.indexWhere((s) => s.id == shiftId);
    if (index != -1) {
      final old = _shifts[index];
      _shifts[index] = ShiftRoster(
        id: old.id,
        staffId: old.staffId,
        hospitalId: old.hospitalId,
        startTime: old.startTime,
        endTime: old.endTime,
        shiftStatus: ShiftStatus.cancelled,
        ward: old.ward,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<double> getDepartmentCoverage(String departmentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 0.92; // 92% coverage
  }
}
