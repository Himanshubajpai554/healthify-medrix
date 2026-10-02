import 'package:flutter/material.dart';

enum PrescriptionStatus {
  draft,
  active,
  completed,
  cancelled,
}

extension PrescriptionStatusExtension on PrescriptionStatus {
  String get label {
    switch (this) {
      case PrescriptionStatus.draft:
        return 'Draft';
      case PrescriptionStatus.active:
        return 'Active';
      case PrescriptionStatus.completed:
        return 'Completed';
      case PrescriptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case PrescriptionStatus.draft:
        return Colors.indigo;
      case PrescriptionStatus.active:
        return const Color(0xFF10B981); // Emerald green
      case PrescriptionStatus.completed:
        return Colors.blue;
      case PrescriptionStatus.cancelled:
        return Colors.redAccent;
    }
  }
}

class PrescriptionMedicineModel {
  final String id;
  final String medicineName;
  final String dosage;
  final String frequency;
  final String route;
  final String duration;
  final String instructions;

  const PrescriptionMedicineModel({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.duration,
    required this.instructions,
  });

  PrescriptionMedicineModel copyWith({
    String? id,
    String? medicineName,
    String? dosage,
    String? frequency,
    String? route,
    String? duration,
    String? instructions,
  }) {
    return PrescriptionMedicineModel(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      route: route ?? this.route,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }
}

class PrescriptionAuditItemModel {
  final String id;
  final DateTime timestamp;
  final String action; // "Created", "Updated Draft", "Activated", "Cancelled", "Duplicated"
  final String performedBy;
  final String details;

  const PrescriptionAuditItemModel({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.performedBy,
    required this.details,
  });
}

class DiscontinuedMedicationModel {
  final String medicineName;
  final String dosage;
  final String reason;
  final DateTime discontinuedDate;

  const DiscontinuedMedicationModel({
    required this.medicineName,
    required this.dosage,
    required this.reason,
    required this.discontinuedDate,
  });
}

class PatientMedicationHistoryModel {
  final String patientId;
  final List<PrescriptionMedicineModel> activeMedications;
  final List<PrescriptionMedicineModel> previousMedications;
  final List<DiscontinuedMedicationModel> discontinuedMedications;

  const PatientMedicationHistoryModel({
    required this.patientId,
    required this.activeMedications,
    required this.previousMedications,
    required this.discontinuedMedications,
  });
}

class DoctorPrescriptionFullModel {
  final String id; // e.g. "RX-2026-00982"
  final String patientId;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String bloodGroup;
  final List<String> allergies;
  final String doctorName;
  final String doctorQualification;
  final String registrationNumber;
  final String department;
  final String consultationId;
  final DateTime date;
  final PrescriptionStatus status;
  final List<PrescriptionMedicineModel> medicines;
  final String generalInstructions;
  final DateTime lastSaved;
  final String? cancelledBy;
  final DateTime? cancelledDate;
  final String? cancellationReason;
  final List<PrescriptionAuditItemModel> auditHistory;

  DoctorPrescriptionFullModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.bloodGroup,
    required this.allergies,
    required this.doctorName,
    required this.doctorQualification,
    required this.registrationNumber,
    required this.department,
    required this.consultationId,
    required this.date,
    required this.status,
    required this.medicines,
    required this.generalInstructions,
    required this.lastSaved,
    this.cancelledBy,
    this.cancelledDate,
    this.cancellationReason,
    required this.auditHistory,
  });

  DoctorPrescriptionFullModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    int? patientAge,
    String? patientGender,
    String? bloodGroup,
    List<String>? allergies,
    String? doctorName,
    String? doctorQualification,
    String? registrationNumber,
    String? department,
    String? consultationId,
    DateTime? date,
    PrescriptionStatus? status,
    List<PrescriptionMedicineModel>? medicines,
    String? generalInstructions,
    DateTime? lastSaved,
    String? cancelledBy,
    DateTime? cancelledDate,
    String? cancellationReason,
    List<PrescriptionAuditItemModel>? auditHistory,
  }) {
    return DoctorPrescriptionFullModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      doctorName: doctorName ?? this.doctorName,
      doctorQualification: doctorQualification ?? this.doctorQualification,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      department: department ?? this.department,
      consultationId: consultationId ?? this.consultationId,
      date: date ?? this.date,
      status: status ?? this.status,
      medicines: medicines ?? this.medicines,
      generalInstructions: generalInstructions ?? this.generalInstructions,
      lastSaved: lastSaved ?? this.lastSaved,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      auditHistory: auditHistory ?? this.auditHistory,
    );
  }
}
