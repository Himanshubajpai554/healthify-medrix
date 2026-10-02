import '../enums/domain_enums.dart';

enum DiagnosticReportStatus { pending, inProgress, completed, verified, cancelled }

/// Document Reference abstraction representing future Serverpod/Storage file URL/Key.
class DocumentReference {
  final String id;
  final String fileName;
  final String mimeType;
  final int size; // bytes
  final String storageKey;
  final DateTime createdAt;

  const DocumentReference({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.storageKey,
    required this.createdAt,
  });
}

/// Document Access record for future security/audit verification.
class DocumentAccess {
  final String documentId;
  final String userId;
  final String permission;
  final bool accessGranted;
  final DateTime accessedAt;

  const DocumentAccess({
    required this.documentId,
    required this.userId,
    required this.permission,
    required this.accessGranted,
    required this.accessedAt,
  });
}

/// Document Activity history trail for reports and prescriptions.
class DocumentActivity {
  final String id;
  final String documentId;
  final String documentType; // "Report" or "Prescription"
  final String actorId;
  final String actorName;
  final DocumentActivityAction action;
  final DateTime timestamp;
  final String? notes;

  const DocumentActivity({
    required this.id,
    required this.documentId,
    required this.documentType,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.timestamp,
    this.notes,
  });
}

/// Core Diagnostic Report Model for Medrix Phase 8
class DiagnosticReport {
  final String id;
  final String hospitalId;
  final String patientId;
  final String? hospitalPatientLinkId;
  final String? appointmentId;
  final String? admissionId;
  final String orderingDoctorId;
  final String? fulfillingStaffId;
  final String departmentId;
  final ReportType reportType;
  final String title;
  final DocumentReference? fileReference;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;
  final String? verifiedByDoctorId;
  final ReportVerificationStatus verificationStatus;
  final bool isCritical;
  final bool releasedToPatient;
  final String summary;
  final Map<String, dynamic> resultData;
  final DateTime date;
  final String? reportUrl;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiagnosticReport({
    required this.id,
    required this.hospitalId,
    required this.patientId,
    this.hospitalPatientLinkId,
    this.appointmentId,
    this.admissionId,
    required this.orderingDoctorId,
    this.fulfillingStaffId,
    this.departmentId = 'DEP-LAB-01',
    this.reportType = ReportType.laboratory,
    required this.title,
    this.fileReference,
    required this.uploadedAt,
    this.verifiedAt,
    this.verifiedByDoctorId,
    this.verificationStatus = ReportVerificationStatus.uploaded,
    this.isCritical = false,
    this.releasedToPatient = false,
    this.summary = '',
    this.resultData = const {},
    required this.date,
    this.reportUrl,
    this.status = ReportStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  String get patientName => 'Patient $patientId';
  String get doctorName => 'Dr. $orderingDoctorId';

  DiagnosticReport copyWith({
    String? id,
    String? hospitalId,
    String? patientId,
    String? hospitalPatientLinkId,
    String? appointmentId,
    String? admissionId,
    String? orderingDoctorId,
    String? fulfillingStaffId,
    String? departmentId,
    ReportType? reportType,
    String? title,
    DocumentReference? fileReference,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
    String? verifiedByDoctorId,
    ReportVerificationStatus? verificationStatus,
    bool? isCritical,
    bool? releasedToPatient,
    String? summary,
    Map<String, dynamic>? resultData,
    DateTime? date,
    String? reportUrl,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiagnosticReport(
      id: id ?? this.id,
      hospitalId: hospitalId ?? this.hospitalId,
      patientId: patientId ?? this.patientId,
      hospitalPatientLinkId: hospitalPatientLinkId ?? this.hospitalPatientLinkId,
      appointmentId: appointmentId ?? this.appointmentId,
      admissionId: admissionId ?? this.admissionId,
      orderingDoctorId: orderingDoctorId ?? this.orderingDoctorId,
      fulfillingStaffId: fulfillingStaffId ?? this.fulfillingStaffId,
      departmentId: departmentId ?? this.departmentId,
      reportType: reportType ?? this.reportType,
      title: title ?? this.title,
      fileReference: fileReference ?? this.fileReference,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedByDoctorId: verifiedByDoctorId ?? this.verifiedByDoctorId,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isCritical: isCritical ?? this.isCritical,
      releasedToPatient: releasedToPatient ?? this.releasedToPatient,
      summary: summary ?? this.summary,
      resultData: resultData ?? this.resultData,
      date: date ?? this.date,
      reportUrl: reportUrl ?? this.reportUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Legacy Helper class for backward compatibility with existing patient portal widgets
class DiagnosticReportItem {
  final String id;
  final String patientId;
  final String patientName;
  final String title;
  final String category;
  final String orderingDoctor;
  final DateTime date;
  final DiagnosticReportStatus status;
  final Map<String, String> labResults;
  final String? fileUrl;

  const DiagnosticReportItem({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.title,
    required this.category,
    required this.orderingDoctor,
    required this.date,
    required this.status,
    required this.labResults,
    this.fileUrl,
  });
}
