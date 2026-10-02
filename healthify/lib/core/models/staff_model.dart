import '../enums/domain_enums.dart';

enum StaffRole { nurse, technician, pharmacist, administrative, support }

class StaffModel {
  final String id;
  final String name;
  final StaffRole role;
  final String department;
  final StaffStatus status;
  final String phone;
  final String shift;

  const StaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.status,
    required this.phone,
    required this.shift,
  });
}

class Staff {
  final String id;
  final String hospitalId;
  final String departmentId;
  final String name;
  final String role;
  final String email;
  final String phone;
  final StaffStatus status;
  final String? shiftId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Staff({
    required this.id,
    required this.hospitalId,
    required this.departmentId,
    required this.name,
    required this.role,
    required this.email,
    required this.phone,
    required this.status,
    this.shiftId,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ShiftRoster {
  final String id;
  final String staffId;
  final String hospitalId;
  final DateTime startTime;
  final DateTime endTime;
  final ShiftStatus shiftStatus;
  final String ward;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShiftRoster({
    required this.id,
    required this.staffId,
    required this.hospitalId,
    required this.startTime,
    required this.endTime,
    required this.shiftStatus,
    required this.ward,
    required this.createdAt,
    required this.updatedAt,
  });
}
