import '../../models/hospital_model.dart';

abstract class DepartmentRepository {
  Future<List<Department>> getDepartments(String hospitalId);
  Future<Department?> getDepartmentById(String id);
  Future<void> createDepartment(Department department);
  Future<void> updateDepartment(Department department);
  Future<void> updateDepartmentStatus(String departmentId, bool isActive);
  Future<void> assignDepartmentHead(String departmentId, String doctorId);
}
