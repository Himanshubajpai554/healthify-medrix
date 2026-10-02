import '../../models/hospital_model.dart';
import '../repositories/department_repository.dart';

class MockDepartmentRepository implements DepartmentRepository {
  final List<Department> _departments = [
    Department(
      id: 'DEP-101',
      hospitalId: 'HOSP-101',
      name: 'Cardiology',
      code: 'CARD',
      headDoctorId: 'DOC-1001',
      totalStaff: 45,
      doctorCount: 12,
      location: 'Building A, Floor 3',
      contactPhone: '+1 (555) 019-CARD',
      description: 'Comprehensive cardiac care, diagnostics, and intervention.',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    Department(
      id: 'DEP-102',
      hospitalId: 'HOSP-101',
      name: 'General Surgery',
      code: 'SURG',
      headDoctorId: 'DOC-1004',
      totalStaff: 60,
      doctorCount: 15,
      location: 'Building B, Floor 2',
      contactPhone: '+1 (555) 018-SURG',
      description: 'Advanced surgical suites and inpatient care.',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    Department(
      id: 'DEP-103',
      hospitalId: 'HOSP-101',
      name: 'Neurology',
      code: 'NEURO',
      headDoctorId: 'DOC-1009',
      totalStaff: 30,
      doctorCount: 8,
      location: 'Building A, Floor 4',
      contactPhone: '+1 (555) 017-NEUR',
      description: 'Brain, spine, and neuro-vascular diagnostics and treatment.',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    Department(
      id: 'DEP-104',
      hospitalId: 'HOSP-101',
      name: 'Emergency & Trauma',
      code: 'EMG',
      headDoctorId: 'DOC-1015',
      totalStaff: 80,
      doctorCount: 18,
      location: 'Ground Floor, Block C',
      contactPhone: '+1 (555) 016-EMRG',
      description: '24/7 Level 1 Trauma and emergency resuscitation.',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Department>> getDepartments(String hospitalId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_departments);
  }

  @override
  Future<Department?> getDepartmentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _departments.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createDepartment(Department department) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _departments.insert(0, department);
  }

  @override
  Future<void> updateDepartment(Department department) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _departments.indexWhere((d) => d.id == department.id);
    if (index != -1) {
      _departments[index] = department;
    }
  }

  @override
  Future<void> updateDepartmentStatus(String departmentId, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _departments.indexWhere((d) => d.id == departmentId);
    if (index != -1) {
      _departments[index] = _departments[index].copyWith(isActive: isActive);
    }
  }

  @override
  Future<void> assignDepartmentHead(String departmentId, String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _departments.indexWhere((d) => d.id == departmentId);
    if (index != -1) {
      _departments[index] = _departments[index].copyWith(headDoctorId: doctorId);
    }
  }
}
