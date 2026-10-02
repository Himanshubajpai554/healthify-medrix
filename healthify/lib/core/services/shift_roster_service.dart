import '../data/repositories/repositories.dart';
import '../models/core_models.dart';

class ShiftRosterService {
  final ShiftRosterRepository shiftRosterRepository;

  ShiftRosterService({required this.shiftRosterRepository});

  Future<List<ShiftRoster>> getRoster({String? departmentId, DateTime? date}) async {
    return await shiftRosterRepository.getShiftRoster(departmentId: departmentId, date: date);
  }

  Future<ShiftRoster> createShift(ShiftRoster shift) async {
    return await shiftRosterRepository.createShift(shift);
  }

  Future<void> reassignShift(String shiftId, String newStaffId) async {
    await shiftRosterRepository.reassignShift(shiftId, newStaffId);
  }

  Future<void> cancelShift(String shiftId) async {
    await shiftRosterRepository.cancelShift(shiftId);
  }
}
