import 'package:flutter/material.dart';
import 'doctor_dashboard_models.dart';

enum MedicalHistoryCategory {
  all,
  consultation,
  admission,
  report,
  procedure,
  prescription,
}

enum ReportCategory {
  all,
  laboratory,
  radiology,
  pathology,
  cardiology,
}

class MedicalHistoryItemModel {
  final String id;
  final String date;
  final String title;
  final MedicalHistoryCategory category;
  final String doctorName;
  final String department;
  final String summary;
  final String status;
  final IconData icon;
  final Color badgeColor;

  const MedicalHistoryItemModel({
    required this.id,
    required this.date,
    required this.title,
    required this.category,
    required this.doctorName,
    required this.department,
    required this.summary,
    required this.status,
    required this.icon,
    required this.badgeColor,
  });
}

class PatientConsultationRecordModel {
  final String id;
  final String date;
  final String time;
  final String doctorName;
  final String doctorSpecialty;
  final String department;
  final String chiefComplaint;
  final String diagnosis;
  final Map<String, String> vitals;
  final String clinicalNotes;
  final List<String> prescribedMedications;
  final String? followUpDate;
  final String status;

  const PatientConsultationRecordModel({
    required this.id,
    required this.date,
    required this.time,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.department,
    required this.chiefComplaint,
    required this.diagnosis,
    required this.vitals,
    required this.clinicalNotes,
    required this.prescribedMedications,
    this.followUpDate,
    this.status = 'Completed',
  });
}

class PatientReportModel {
  final String id;
  final String title;
  final ReportCategory category;
  final String date;
  final String labName;
  final String orderingDoctor;
  final String status; // 'Normal', 'Abnormal', 'Pending Review'
  final ReportPriority priority;
  final Map<String, String> labValues;
  final String? attachmentUrl;
  final String? attachmentType; // 'X-Ray Scan', 'ECG Waveform', 'Lab PDF'
  final String? clinicalNotes;

  const PatientReportModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.labName,
    required this.orderingDoctor,
    required this.status,
    required this.priority,
    required this.labValues,
    this.attachmentUrl,
    this.attachmentType,
    this.clinicalNotes,
  });
}

class PrescriptionMedicationItem {
  final String drugName;
  final String dosage; // e.g. 20mg
  final String frequency; // e.g. OD, BD, TDS
  final String duration; // e.g. 30 Days
  final String timing; // e.g. After Food
  final String? specialInstructions;

  const PrescriptionMedicationItem({
    required this.drugName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.timing,
    this.specialInstructions,
  });
}

class PatientPrescriptionModel {
  final String id;
  final String prescriptionDate;
  final String doctorName;
  final String department;
  final String diagnosis;
  final List<PrescriptionMedicationItem> medications;
  final String generalInstructions;
  final bool isActive;
  final String validityUntil;

  const PatientPrescriptionModel({
    required this.id,
    required this.prescriptionDate,
    required this.doctorName,
    required this.department,
    required this.diagnosis,
    required this.medications,
    required this.generalInstructions,
    required this.isActive,
    required this.validityUntil,
  });
}

class PatientNoteModel {
  final String id;
  final String date;
  final String authorDoctor;
  final String authorSpecialty;
  final String content;
  final bool isInternalPrivate; // Private Internal Doctor Note vs Patient-Visible
  final ClinicalNoteType noteType;

  const PatientNoteModel({
    required this.id,
    required this.date,
    required this.authorDoctor,
    required this.authorSpecialty,
    required this.content,
    required this.isInternalPrivate,
    required this.noteType,
  });
}

class PatientFollowUpModel {
  final String id;
  final String dueDate;
  final String reason;
  final String doctorName;
  final String department;
  final String status; // 'Due', 'Scheduled', 'Completed', 'Missed'
  final String? notes;

  const PatientFollowUpModel({
    required this.id,
    required this.dueDate,
    required this.reason,
    required this.doctorName,
    required this.department,
    required this.status,
    this.notes,
  });

  PatientFollowUpModel copyWith({String? status, String? notes}) {
    return PatientFollowUpModel(
      id: id,
      dueDate: dueDate,
      reason: reason,
      doctorName: doctorName,
      department: department,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class PatientDocumentModel {
  final String id;
  final String fileName;
  final String fileType; // PDF, PNG, DICOM
  final String uploadDate;
  final String fileSize;
  final String category;

  const PatientDocumentModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.uploadDate,
    required this.fileSize,
    required this.category,
  });
}

class PatientProfileFullModel {
  final PatientModel patient;
  final Map<String, String> currentVitals;
  final DoctorEmergencyCaseModel? activeEmergency;
  final AIPatientSummaryModel summary;
  final List<MedicalHistoryItemModel> medicalHistory;
  final List<PatientConsultationRecordModel> consultations;
  final List<PatientReportModel> reports;
  final List<PatientPrescriptionModel> prescriptions;
  final List<DoctorAppointmentModel> appointments;
  final List<PatientNoteModel> notes;
  final List<PatientFollowUpModel> followUps;
  final List<PatientDocumentModel> documents;

  const PatientProfileFullModel({
    required this.patient,
    required this.currentVitals,
    this.activeEmergency,
    required this.summary,
    required this.medicalHistory,
    required this.consultations,
    required this.reports,
    required this.prescriptions,
    required this.appointments,
    required this.notes,
    required this.followUps,
    required this.documents,
  });
}
