import '../data/repositories/repositories.dart';
import '../enums/domain_enums.dart';
import '../models/core_models.dart';

class StaffManagementService {
  final StaffRepository staffRepository;

  StaffManagementService({required this.staffRepository});

  Future<List<StaffModel>> getStaffList() async {
    return await staffRepository.getStaffList();
  }

  Future<StaffModel> addStaff(StaffModel staff) async {
    return await staffRepository.addStaff(staff);
  }

  Future<void> updateStaff(StaffModel staff) async {
    await staffRepository.updateStaff(staff);
  }

  Future<void> updateStatus(String staffId, StaffStatus status) async {
    await staffRepository.updateStaffStatus(staffId, status);
  }

  Future<void> assignDepartment(String staffId, String departmentId) async {
    await staffRepository.assignStaffDepartment(staffId, departmentId);
  }
}
