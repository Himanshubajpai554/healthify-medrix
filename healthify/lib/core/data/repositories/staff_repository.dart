import '../../enums/domain_enums.dart';
import '../../models/staff_model.dart';

abstract class StaffRepository {
  Future<List<StaffModel>> getStaffList();
  Future<StaffModel?> getStaffById(String id);
  Future<StaffModel> addStaff(StaffModel staff);
  Future<void> updateStaffStatus(String staffId, StaffStatus status);
  Future<void> updateStaff(StaffModel staff);
  Future<void> assignStaffDepartment(String staffId, String departmentId);
}
