import '../enums/domain_enums.dart';
export '../../patient/patients/patient_model.dart' show PatientItem, PatientStatus;

/// Global Patient Identity Entity
class Patient {
  final String id;
  final String name;
  final int age;
  final DateTime? dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String phone;
  final String email;
  final String address;
  final String emergencyContact;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    this.email = '',
    required this.address,
    required this.emergencyContact,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? phone,
    String? email,
    String? address,
    String? emergencyContact,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Hospital-Specific Patient Link & MRN Association
class HospitalPatientLink {
  final String id;
  final String hospitalId;
  final String patientId;
  final String mrnNumber;
  final String linkStatus; // Active, Inactive, Archived
  final DateTime registrationDate;
  final DateTime? lastVisitAt;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HospitalPatientLink({
    required this.id,
    required this.hospitalId,
    required this.patientId,
    required this.mrnNumber,
    this.linkStatus = 'Active',
    required this.registrationDate,
    this.lastVisitAt,
    this.isPrimary = true,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Hospital Stay & Operational Admission Entity
class Admission {
  final String id;
  final String hospitalId;
  final String patientId;
  final String hospitalPatientLinkId;
  final String bedId;
  final String ward;
  final String attendingDoctorId;
  final String doctorName;
  final String departmentId;
  final DateTime admissionDate;
  final DateTime? dischargeDate;
  final String admissionType; // Emergency, Scheduled, WalkIn, Transfer, Observation
  final AdmissionStatus admissionStatus;
  final String reason;
  final String diagnosis;
  final Map<String, String> vitals;
  final String? clinicalNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Admission({
    required this.id,
    required this.hospitalId,
    required this.patientId,
    this.hospitalPatientLinkId = '',
    required this.bedId,
    this.ward = 'General Ward A',
    required this.attendingDoctorId,
    this.doctorName = 'Dr. Sarah Jenkins',
    required this.departmentId,
    required this.admissionDate,
    this.dischargeDate,
    this.admissionType = 'Emergency',
    required this.admissionStatus,
    required this.reason,
    required this.diagnosis,
    required this.vitals,
    this.clinicalNotes,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Patient Access Control State
enum PatientAccessState {
  allowed,
  restricted,
  clinicalAccessRequired,
  noPermission,
  breakGlassRequired,
}

class PatientAccessPermission {
  final PatientAccessState state;
  final String message;
  final bool canViewIdentity;
  final bool canViewMrn;
  final bool canViewAdmission;
  final bool canViewClinicalNotes;

  const PatientAccessPermission({
    required this.state,
    required this.message,
    this.canViewIdentity = true,
    this.canViewMrn = true,
    this.canViewAdmission = true,
    this.canViewClinicalNotes = false,
  });

  static const PatientAccessPermission defaultAdmin = PatientAccessPermission(
    state: PatientAccessState.restricted,
    message: 'Administrative view active. Clinical diagnostic notes require clinical access authorization.',
    canViewIdentity: true,
    canViewMrn: true,
    canViewAdmission: true,
    canViewClinicalNotes: false,
  );
}

/// Operational KPI Analytics Metrics Summary for Patients
class PatientOverviewMetrics {
  final int totalActiveAdmissions;
  final int icuPatients;
  final int admissionsToday;
  final int dischargesToday;
  final int observationPatients;

  const PatientOverviewMetrics({
    required this.totalActiveAdmissions,
    required this.icuPatients,
    required this.admissionsToday,
    required this.dischargesToday,
    required this.observationPatients,
  });
}

class PatientAdmissionRequest {
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  final String ward;
  final PatientStatus status;
  final String doctorName;
  final Map<String, String> vitals;
  final String? existingPatientId;

  PatientAdmissionRequest({
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.ward,
    required this.status,
    required this.doctorName,
    required this.vitals,
    this.existingPatientId,
  });
}
