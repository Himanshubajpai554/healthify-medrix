import '../enums/domain_enums.dart';

class AppointmentItem {
  final String id;
  final String patientName;
  final String doctorName;
  final String department;
  final DateTime dateTime;
  final String status;
  final String type;

  const AppointmentItem({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.department,
    required this.dateTime,
    required this.status,
    required this.type,
  });

  DateTime get appointmentDateTime => dateTime;
}

class Appointment {
  final String id;
  final String hospitalId;
  final String patientId;
  final String doctorId;
  final String departmentId;
  final DateTime appointmentDateTime;
  final AppointmentStatus status;
  final String reason;
  final String notes;
  final String type;
  final String? hospitalPatientLinkId;
  final String? admissionId;
  final String? facilityId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.id,
    required this.hospitalId,
    required this.patientId,
    required this.doctorId,
    required this.departmentId,
    required this.appointmentDateTime,
    required this.status,
    this.reason = 'Routine Checkup',
    this.notes = '',
    required this.type,
    this.hospitalPatientLinkId,
    this.admissionId,
    this.facilityId,
    required this.createdAt,
    required this.updatedAt,
  });


  String get patientName => 'Patient $patientId';
  String get doctorName => 'Dr. $doctorId';
}

class AppointmentSummary {
  final int total;
  final int scheduled;
  final int checkedIn;
  final int inConsultation;
  final int completed;
  final int cancelled;
  final int noShow;

  const AppointmentSummary({
    required this.total,
    required this.scheduled,
    required this.checkedIn,
    required this.inConsultation,
    required this.completed,
    required this.cancelled,
    required this.noShow,
  });
}
