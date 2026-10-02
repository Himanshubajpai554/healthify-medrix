import '../../models/staff_model.dart';

abstract class ShiftRosterRepository {
  Future<List<ShiftRoster>> getShiftRoster({String? departmentId, DateTime? date});
  Future<List<ShiftRoster>> getStaffShifts(String staffId);
  Future<ShiftRoster> createShift(ShiftRoster shift);
  Future<void> updateShift(ShiftRoster shift);
  Future<void> reassignShift(String shiftId, String newStaffId);
  Future<void> cancelShift(String shiftId);
  Future<double> getDepartmentCoverage(String departmentId);
}
