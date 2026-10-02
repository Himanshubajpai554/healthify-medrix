import '../enums/domain_enums.dart';
export '../../doctor/doctors/doctor_model.dart';

class Doctor {
  final String id;
  final String hospitalId;
  final String departmentId;
  final String name;
  final String specialization;
  final String qualification;
  final String email;
  final String phone;
  final int experienceYears;
  final DoctorAvailabilityStatus availabilityStatus;
  final DoctorAffiliationStatus affiliationStatus;
  final double rating;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Doctor({
    required this.id,
    required this.hospitalId,
    required this.departmentId,
    required this.name,
    required this.specialization,
    required this.qualification,
    required this.email,
    required this.phone,
    required this.experienceYears,
    required this.availabilityStatus,
    required this.affiliationStatus,
    required this.rating,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get departmentName => specialization;
  String get specialty => specialization;
  String? get subSpecialty => null;
}


class DoctorAffiliation {
  final String id;
  final String doctorId;
  final String hospitalId;
  final DoctorAffiliationStatus affiliationStatus;
  final DateTime startDate;
  final DateTime? endDate;
  final String department;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DoctorAffiliation({
    required this.id,
    required this.doctorId,
    required this.hospitalId,
    required this.affiliationStatus,
    required this.startDate,
    this.endDate,
    required this.department,
    required this.createdAt,
    required this.updatedAt,
  });
}
