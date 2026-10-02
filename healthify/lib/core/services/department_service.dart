import '../data/repositories/repositories.dart';
import '../models/core_models.dart';

class DepartmentService {
  final DepartmentRepository departmentRepository;

  DepartmentService({required this.departmentRepository});

  Future<List<Department>> getDepartments(String hospitalId) async {
    return await departmentRepository.getDepartments(hospitalId);
  }

  Future<void> createDepartment(Department department) async {
    await departmentRepository.createDepartment(department);
  }

  Future<void> updateDepartment(Department department) async {
    await departmentRepository.updateDepartment(department);
  }

  Future<void> toggleDepartmentStatus(String departmentId, bool isActive) async {
    await departmentRepository.updateDepartmentStatus(departmentId, isActive);
  }

  Future<void> assignHeadDoctor(String departmentId, String doctorId) async {
    await departmentRepository.assignDepartmentHead(departmentId, doctorId);
  }
}
