import 'doctor_dashboard_models.dart';
import 'patient_profile_models.dart';

enum ConsultationStatus {
  scheduled,
  checkedIn,
  waiting,
  inConsultation,
  draft,
  completed,
  cancelled,
}

enum NoteVisibility {
  internalPrivate,
  patientVisible,
}

enum AutosaveState {
  saved,
  saving,
  failed,
}

class ConsultationVitalsModel {
  final String bpSystolic;
  final String bpDiastolic;
  final String heartRate;
  final String temperature;
  final String respiratoryRate;
  final String oxygenSaturation;
  final String weight;
  final String height;
  final String additionalObservations;

  const ConsultationVitalsModel({
    this.bpSystolic = '120',
    this.bpDiastolic = '80',
    this.heartRate = '76',
    this.temperature = '98.6',
    this.respiratoryRate = '16',
    this.oxygenSaturation = '98',
    this.weight = '78.5',
    this.height = '175',
    this.additionalObservations = 'Hemodynamically stable. No pedal edema noted.',
  });

  ConsultationVitalsModel copyWith({
    String? bpSystolic,
    String? bpDiastolic,
    String? heartRate,
    String? temperature,
    String? respiratoryRate,
    String? oxygenSaturation,
    String? weight,
    String? height,
    String? additionalObservations,
  }) {
    return ConsultationVitalsModel(
      bpSystolic: bpSystolic ?? this.bpSystolic,
      bpDiastolic: bpDiastolic ?? this.bpDiastolic,
      heartRate: heartRate ?? this.heartRate,
      temperature: temperature ?? this.temperature,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      additionalObservations: additionalObservations ?? this.additionalObservations,
    );
  }

  String get bpText => '$bpSystolic / $bpDiastolic mmHg';
}

class PatientReportedInfoModel {
  final String primaryConcern;
  final String duration;
  final String reportedSymptoms;
  final String relevantHistory;

  const PatientReportedInfoModel({
    this.primaryConcern = 'Exertional chest tightness & mild shortness of breath when climbing stairs',
    this.duration = '2 Weeks',
    this.reportedSymptoms = 'Retrosternal heaviness on moderate physical exertion, relieved after 5-10 mins resting.',
    this.relevantHistory = 'Known hypertension & type 2 diabetes mellitus under active medical therapy.',
  });

  PatientReportedInfoModel copyWith({
    String? primaryConcern,
    String? duration,
    String? reportedSymptoms,
    String? relevantHistory,
  }) {
    return PatientReportedInfoModel(
      primaryConcern: primaryConcern ?? this.primaryConcern,
      duration: duration ?? this.duration,
      reportedSymptoms: reportedSymptoms ?? this.reportedSymptoms,
      relevantHistory: relevantHistory ?? this.relevantHistory,
    );
  }
}

class ConsultationPrescriptionItemModel {
  final String id;
  final String drugName;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  const ConsultationPrescriptionItemModel({
    required this.id,
    required this.drugName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
  });

  ConsultationPrescriptionItemModel copyWith({
    String? drugName,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    return ConsultationPrescriptionItemModel(
      id: id,
      drugName: drugName ?? this.drugName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }
}

class ConsultationAttachmentModel {
  final String id;
  final String fileName;
  final String fileType;
  final String uploadDate;
  final String fileSize;
  final String category;
  final bool isAttachedToConsultation;

  const ConsultationAttachmentModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.uploadDate,
    required this.fileSize,
    required this.category,
    this.isAttachedToConsultation = false,
  });

  ConsultationAttachmentModel copyWith({bool? isAttachedToConsultation}) {
    return ConsultationAttachmentModel(
      id: id,
      fileName: fileName,
      fileType: fileType,
      uploadDate: uploadDate,
      fileSize: fileSize,
      category: category,
      isAttachedToConsultation: isAttachedToConsultation ?? this.isAttachedToConsultation,
    );
  }
}

class ConsultationFollowUpModel {
  final bool isRequired;
  final String dueDate;
  final String department;
  final String doctorName;
  final String reason;
  final String instructions;

  const ConsultationFollowUpModel({
    this.isRequired = true,
    this.dueDate = '04 Oct 2026',
    this.department = 'Cardiology',
    this.doctorName = 'Dr. Sarah Jenkins',
    this.reason = 'Review Treadmill Stress Test & Lipid response to Atorvastatin 40mg',
    this.instructions = 'Fasting 8-10 hours prior to lipid panel.',
  });

  ConsultationFollowUpModel copyWith({
    bool? isRequired,
    String? dueDate,
    String? department,
    String? doctorName,
    String? reason,
    String? instructions,
  }) {
    return ConsultationFollowUpModel(
      isRequired: isRequired ?? this.isRequired,
      dueDate: dueDate ?? this.dueDate,
      department: department ?? this.department,
      doctorName: doctorName ?? this.doctorName,
      reason: reason ?? this.reason,
      instructions: instructions ?? this.instructions,
    );
  }
}

class ConsultationAuditLogModel {
  final String id;
  final String action;
  final String timestamp;
  final String doctorName;
  final String patientId;

  const ConsultationAuditLogModel({
    required this.id,
    required this.action,
    required this.timestamp,
    required this.doctorName,
    required this.patientId,
  });
}

class ConsultationFullModel {
  final String id;
  final String appointmentId;
  final PatientModel patient;
  final ConsultationStatus status;
  final String startedAt;
  final String lastSavedAt;
  final String reasonForVisit;
  final PatientReportedInfoModel patientReported;
  final ConsultationVitalsModel vitals;
  final String clinicalNotes;
  final NoteVisibility noteVisibility;
  final List<PatientReportModel> reportsReferenced;
  final List<ConsultationPrescriptionItemModel> prescriptions;
  final List<ConsultationAttachmentModel> attachments;
  final ConsultationFollowUpModel followUp;
  final AIPatientSummaryModel aiSummary;
  final List<ConsultationAuditLogModel> auditLogs;
  final bool isDraft;

  const ConsultationFullModel({
    required this.id,
    required this.appointmentId,
    required this.patient,
    required this.status,
    required this.startedAt,
    required this.lastSavedAt,
    required this.reasonForVisit,
    required this.patientReported,
    required this.vitals,
    required this.clinicalNotes,
    required this.noteVisibility,
    required this.reportsReferenced,
    required this.prescriptions,
    required this.attachments,
    required this.followUp,
    required this.aiSummary,
    required this.auditLogs,
    required this.isDraft,
  });

  ConsultationFullModel copyWith({
    ConsultationStatus? status,
    String? lastSavedAt,
    String? reasonForVisit,
    PatientReportedInfoModel? patientReported,
    ConsultationVitalsModel? vitals,
    String? clinicalNotes,
    NoteVisibility? noteVisibility,
    List<PatientReportModel>? reportsReferenced,
    List<ConsultationPrescriptionItemModel>? prescriptions,
    List<ConsultationAttachmentModel>? attachments,
    ConsultationFollowUpModel? followUp,
    AIPatientSummaryModel? aiSummary,
    List<ConsultationAuditLogModel>? auditLogs,
    bool? isDraft,
  }) {
    return ConsultationFullModel(
      id: id,
      appointmentId: appointmentId,
      patient: patient,
      status: status ?? this.status,
      startedAt: startedAt,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      patientReported: patientReported ?? this.patientReported,
      vitals: vitals ?? this.vitals,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      noteVisibility: noteVisibility ?? this.noteVisibility,
      reportsReferenced: reportsReferenced ?? this.reportsReferenced,
      prescriptions: prescriptions ?? this.prescriptions,
      attachments: attachments ?? this.attachments,
      followUp: followUp ?? this.followUp,
      aiSummary: aiSummary ?? this.aiSummary,
      auditLogs: auditLogs ?? this.auditLogs,
      isDraft: isDraft ?? this.isDraft,
    );
  }
}
