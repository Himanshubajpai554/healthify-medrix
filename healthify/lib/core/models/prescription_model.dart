import '../enums/domain_enums.dart';

class MedicationItem {
  final String drugName;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  const MedicationItem({
    required this.drugName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
  });
}

class PrescriptionRecordItem {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final String department;
  final DateTime date;
  final String diagnosis;
  final List<MedicationItem> medications;
  final bool isActive;

  const PrescriptionRecordItem({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.department,
    required this.date,
    required this.diagnosis,
    required this.medications,
    required this.isActive,
  });
}

class PrescriptionItem {
  final String medicationName;
  final String dosage;
  final String frequency;
  final int durationDays;
  final String instructions;

  const PrescriptionItem({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.durationDays,
    required this.instructions,
  });
}

/// Core Prescription Index Model for Medrix Phase 8
class PrescriptionIndex {
  final String id;
  final String hospitalId;
  final String patientId;
  final String? hospitalPatientLinkId;
  final String doctorId;
  final String? appointmentId;
  final String? admissionId;
  final String prescriptionReference;
  final DateTime signedAt;
  final PrescriptionStatus status;
  final PharmacyFulfillmentStatus pharmacyFulfillmentStatus;
  final List<PrescriptionItem> medications;
  final String? clinicalNotes;
  final String instructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PrescriptionIndex({
    required this.id,
    required this.hospitalId,
    required this.patientId,
    this.hospitalPatientLinkId,
    required this.doctorId,
    this.appointmentId,
    this.admissionId,
    required this.prescriptionReference,
    required this.signedAt,
    this.status = PrescriptionStatus.signed,
    this.pharmacyFulfillmentStatus = PharmacyFulfillmentStatus.pending,
    required this.medications,
    this.clinicalNotes,
    this.instructions = 'Take as prescribed by doctor',
    required this.createdAt,
    required this.updatedAt,
  });

  PrescriptionIndex copyWith({
    String? id,
    String? hospitalId,
    String? patientId,
    String? hospitalPatientLinkId,
    String? doctorId,
    String? appointmentId,
    String? admissionId,
    String? prescriptionReference,
    DateTime? signedAt,
    PrescriptionStatus? status,
    PharmacyFulfillmentStatus? pharmacyFulfillmentStatus,
    List<PrescriptionItem>? medications,
    String? clinicalNotes,
    String? instructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrescriptionIndex(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      patientId: patientId ?? this.patientId,
      hospitalPatientLinkId: hospitalPatientLinkId ?? this.hospitalPatientLinkId,
      doctorId: doctorId ?? this.doctorId,
      appointmentId: appointmentId ?? this.appointmentId,
      admissionId: admissionId ?? this.admissionId,
      prescriptionReference: prescriptionReference ?? this.prescriptionReference,
      signedAt: signedAt ?? this.signedAt,
      status: status ?? this.status,
      pharmacyFulfillmentStatus: pharmacyFulfillmentStatus ?? this.pharmacyFulfillmentStatus,
      medications: medications ?? this.medications,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
