import 'package:flutter/material.dart';

enum ReportCategory {
  all,
  laboratory,
  radiology,
  pathology,
  cardiology,
  imaging,
  other,
}

extension ReportCategoryExtension on ReportCategory {
  String get label {
    switch (this) {
      case ReportCategory.all:
        return 'All';
      case ReportCategory.laboratory:
        return 'Laboratory';
      case ReportCategory.radiology:
        return 'Radiology';
      case ReportCategory.pathology:
        return 'Pathology';
      case ReportCategory.cardiology:
        return 'Cardiology';
      case ReportCategory.imaging:
        return 'Imaging';
      case ReportCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportCategory.all:
        return Icons.grid_view_rounded;
      case ReportCategory.laboratory:
        return Icons.science_rounded;
      case ReportCategory.radiology:
        return Icons.biotech_rounded;
      case ReportCategory.pathology:
        return Icons.coronavirus_rounded;
      case ReportCategory.cardiology:
        return Icons.favorite_rounded;
      case ReportCategory.imaging:
        return Icons.image_rounded;
      case ReportCategory.other:
        return Icons.description_rounded;
    }
  }
}

enum ReportStatus {
  newReport,
  pendingReview,
  reviewed,
  archived,
}

extension ReportStatusExtension on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.newReport:
        return 'New';
      case ReportStatus.pendingReview:
        return 'Pending Review';
      case ReportStatus.reviewed:
        return 'Reviewed';
      case ReportStatus.archived:
        return 'Archived';
    }
  }
}

enum ReportModality {
  pdf,
  xray,
  ctScan,
  mri,
  ultrasound,
  labText,
}

extension ReportModalityExtension on ReportModality {
  String get label {
    switch (this) {
      case ReportModality.pdf:
        return 'PDF Document';
      case ReportModality.xray:
        return 'X-Ray Imaging';
      case ReportModality.ctScan:
        return 'CT Scan (DICOM)';
      case ReportModality.mri:
        return 'MRI Scan';
      case ReportModality.ultrasound:
        return 'Ultrasound';
      case ReportModality.labText:
        return 'Structured Lab Data';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportModality.pdf:
        return Icons.picture_as_pdf_rounded;
      case ReportModality.xray:
        return Icons.medical_information_rounded;
      case ReportModality.ctScan:
        return Icons.center_focus_strong_rounded;
      case ReportModality.mri:
        return Icons.grain_rounded;
      case ReportModality.ultrasound:
        return Icons.waves_rounded;
      case ReportModality.labText:
        return Icons.table_chart_rounded;
    }
  }
}

class ReportAuditItem {
  final String id;
  final DateTime timestamp;
  final String action; // e.g. "Uploaded", "Viewed", "Reviewed", "Attached to Consultation"
  final String performedBy;
  final String details;

  const ReportAuditItem({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.performedBy,
    required this.details,
  });
}

class DoctorReportFullModel {
  final String id;
  final String title;
  final String patientId;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final ReportCategory category;
  final ReportStatus status;
  final ReportModality modality;
  final DateTime uploadedDate;
  final DateTime? reviewedDate;
  final String uploadedBy;
  final String requestedBy;
  final String performedBy;
  final String department;
  final String facility;
  final String? fileUrl;
  final bool isReleasedToPatient;
  final String summaryAiText;
  final String findingsText;
  final String impressionText;
  final String recommendationText;
  final String doctorNotesPrivate;
  final String doctorNotesPatientVisible;
  final String? reviewDoctorName;
  final String? reviewNotes;
  final String? attachedConsultationId;
  final List<ReportAuditItem> auditHistory;

  DoctorReportFullModel({
    required this.id,
    required this.title,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.category,
    required this.status,
    required this.modality,
    required this.uploadedDate,
    this.reviewedDate,
    required this.uploadedBy,
    required this.requestedBy,
    required this.performedBy,
    required this.department,
    required this.facility,
    this.fileUrl,
    this.isReleasedToPatient = false,
    required this.summaryAiText,
    required this.findingsText,
    required this.impressionText,
    required this.recommendationText,
    this.doctorNotesPrivate = '',
    this.doctorNotesPatientVisible = '',
    this.reviewDoctorName,
    this.reviewNotes,
    this.attachedConsultationId,
    required this.auditHistory,
  });

  DoctorReportFullModel copyWith({
    String? id,
    String? title,
    String? patientId,
    String? patientName,
    int? patientAge,
    String? patientGender,
    ReportCategory? category,
    ReportStatus? status,
    ReportModality? modality,
    DateTime? uploadedDate,
    DateTime? reviewedDate,
    String? uploadedBy,
    String? requestedBy,
    String? performedBy,
    String? department,
    String? facility,
    String? fileUrl,
    bool? isReleasedToPatient,
    String? summaryAiText,
    String? findingsText,
    String? impressionText,
    String? recommendationText,
    String? doctorNotesPrivate,
    String? doctorNotesPatientVisible,
    String? reviewDoctorName,
    String? reviewNotes,
    String? attachedConsultationId,
    List<ReportAuditItem>? auditHistory,
  }) {
    return DoctorReportFullModel(
      id: id ?? this.id,
      title: title ?? this.title,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      category: category ?? this.category,
      status: status ?? this.status,
      modality: modality ?? this.modality,
      uploadedDate: uploadedDate ?? this.uploadedDate,
      reviewedDate: reviewedDate ?? this.reviewedDate,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      requestedBy: requestedBy ?? this.requestedBy,
      performedBy: performedBy ?? this.performedBy,
      department: department ?? this.department,
      facility: facility ?? this.facility,
      fileUrl: fileUrl ?? this.fileUrl,
      isReleasedToPatient: isReleasedToPatient ?? this.isReleasedToPatient,
      summaryAiText: summaryAiText ?? this.summaryAiText,
      findingsText: findingsText ?? this.findingsText,
      impressionText: impressionText ?? this.impressionText,
      recommendationText: recommendationText ?? this.recommendationText,
      doctorNotesPrivate: doctorNotesPrivate ?? this.doctorNotesPrivate,
      doctorNotesPatientVisible: doctorNotesPatientVisible ?? this.doctorNotesPatientVisible,
      reviewDoctorName: reviewDoctorName ?? this.reviewDoctorName,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      attachedConsultationId: attachedConsultationId ?? this.attachedConsultationId,
      auditHistory: auditHistory ?? this.auditHistory,
    );
  }
}
