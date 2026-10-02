import 'package:flutter/material.dart';

enum EmergencyOperationalPriority {
  immediate,
  high,
  standard,
}

extension EmergencyOperationalPriorityExtension on EmergencyOperationalPriority {
  String get label {
    switch (this) {
      case EmergencyOperationalPriority.immediate:
        return 'Immediate';
      case EmergencyOperationalPriority.high:
        return 'High';
      case EmergencyOperationalPriority.standard:
        return 'Standard';
    }
  }

  Color get color {
    switch (this) {
      case EmergencyOperationalPriority.immediate:
        return Colors.redAccent;
      case EmergencyOperationalPriority.high:
        return Colors.orangeAccent.shade700;
      case EmergencyOperationalPriority.standard:
        return const Color(0xFF10B981); // Emerald
    }
  }
}

enum EmergencyCaseStatus {
  waiting,
  inTreatment,
  observation,
  transferred,
  resolved,
  cancelled,
}

extension EmergencyCaseStatusExtension on EmergencyCaseStatus {
  String get label {
    switch (this) {
      case EmergencyCaseStatus.waiting:
        return 'Waiting';
      case EmergencyCaseStatus.inTreatment:
        return 'In Treatment';
      case EmergencyCaseStatus.observation:
        return 'Observation';
      case EmergencyCaseStatus.transferred:
        return 'Transferred';
      case EmergencyCaseStatus.resolved:
        return 'Resolved';
      case EmergencyCaseStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case EmergencyCaseStatus.waiting:
        return Colors.amber.shade800;
      case EmergencyCaseStatus.inTreatment:
        return Colors.blue.shade600;
      case EmergencyCaseStatus.observation:
        return Colors.purple.shade600;
      case EmergencyCaseStatus.transferred:
        return Colors.indigo.shade600;
      case EmergencyCaseStatus.resolved:
        return const Color(0xFF10B981);
      case EmergencyCaseStatus.cancelled:
        return Colors.grey.shade600;
    }
  }
}

enum EmergencyNoteType {
  emergencyNote,
  clinicalNote,
  handoverNote,
  administrativeNote,
}

extension EmergencyNoteTypeExtension on EmergencyNoteType {
  String get label {
    switch (this) {
      case EmergencyNoteType.emergencyNote:
        return 'Emergency Note';
      case EmergencyNoteType.clinicalNote:
        return 'Clinical Note';
      case EmergencyNoteType.handoverNote:
        return 'Handover Note';
      case EmergencyNoteType.administrativeNote:
        return 'Administrative Note';
    }
  }
}

enum EmergencyDisposition {
  discharged,
  admitted,
  transferred,
  followUpRequired,
}

extension EmergencyDispositionExtension on EmergencyDisposition {
  String get label {
    switch (this) {
      case EmergencyDisposition.discharged:
        return 'Discharged Home';
      case EmergencyDisposition.admitted:
        return 'Admitted to Inpatient Ward';
      case EmergencyDisposition.transferred:
        return 'Transferred to Specialized Facility';
      case EmergencyDisposition.followUpRequired:
        return 'Discharged with Follow-up Required';
    }
  }
}

class EmergencyTimelineItem {
  final String id;
  final DateTime timestamp;
  final String actor;
  final String action;
  final String? optionalNote;

  const EmergencyTimelineItem({
    required this.id,
    required this.timestamp,
    required this.actor,
    required this.action,
    this.optionalNote,
  });
}

class EmergencyNoteModel {
  final String id;
  final EmergencyNoteType noteType;
  final String content;
  final bool isInternalPrivate;
  final String author;
  final DateTime createdAt;

  const EmergencyNoteModel({
    required this.id,
    required this.noteType,
    required this.content,
    required this.isInternalPrivate,
    required this.author,
    required this.createdAt,
  });
}

class EmergencyObservationsModel {
  final String bpSystolic;
  final String bpDiastolic;
  final String heartRate;
  final String temperature;
  final String respiratoryRate;
  final String oxygenSaturation;
  final String weight;
  final String additionalObservations;
  final String recordedBy;
  final DateTime recordedAt;

  const EmergencyObservationsModel({
    required this.bpSystolic,
    required this.bpDiastolic,
    required this.heartRate,
    required this.temperature,
    required this.respiratoryRate,
    required this.oxygenSaturation,
    required this.weight,
    required this.additionalObservations,
    required this.recordedBy,
    required this.recordedAt,
  });

  String get bpText => '$bpSystolic / $bpDiastolic mmHg';
}

class EmergencyTransferInfoModel {
  final String transferredToDepartment;
  final String transferredToDoctor;
  final String transferredToWard;
  final String reason;
  final String transferNotes;
  final String transferredBy;
  final DateTime timestamp;

  const EmergencyTransferInfoModel({
    required this.transferredToDepartment,
    required this.transferredToDoctor,
    required this.transferredToWard,
    required this.reason,
    required this.transferNotes,
    required this.transferredBy,
    required this.timestamp,
  });
}

class EmergencyResolutionInfoModel {
  final String resolutionNote;
  final EmergencyDisposition disposition;
  final String resolvedBy;
  final DateTime timestamp;

  const EmergencyResolutionInfoModel({
    required this.resolutionNote,
    required this.disposition,
    required this.resolvedBy,
    required this.timestamp,
  });
}

class DoctorEmergencyCaseFullModel {
  final String id; // e.g. "EMR-2026-0042"
  final String patientId;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String bloodGroup;
  final List<String> allergies;
  final List<String> knownConditions;
  final List<String> currentMedications;
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactPhone;
  final DateTime arrivalTime;
  final String arrivalMethod;
  final String referralSource;
  final String emergencyReason;
  final String patientReportedInfo;
  final String arrivalNotes;
  final EmergencyOperationalPriority priority;
  final EmergencyCaseStatus status;
  final String assignedDoctor;
  final String department;
  final String location;
  final EmergencyObservationsModel? observations;
  final List<EmergencyNoteModel> notes;
  final List<EmergencyTimelineItem> timeline;
  final EmergencyTransferInfoModel? transferInfo;
  final EmergencyResolutionInfoModel? resolutionInfo;
  final String? consultationId;
  final List<String> attachedReportIds;
  final List<String> attachedPrescriptionIds;
  final List<EmergencyTimelineItem> auditHistory;

  DoctorEmergencyCaseFullModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.bloodGroup,
    required this.allergies,
    required this.knownConditions,
    required this.currentMedications,
    required this.emergencyContactName,
    required this.emergencyContactRelation,
    required this.emergencyContactPhone,
    required this.arrivalTime,
    required this.arrivalMethod,
    required this.referralSource,
    required this.emergencyReason,
    required this.patientReportedInfo,
    required this.arrivalNotes,
    required this.priority,
    required this.status,
    required this.assignedDoctor,
    required this.department,
    required this.location,
    this.observations,
    required this.notes,
    required this.timeline,
    this.transferInfo,
    this.resolutionInfo,
    this.consultationId,
    required this.attachedReportIds,
    required this.attachedPrescriptionIds,
    required this.auditHistory,
  });

  DoctorEmergencyCaseFullModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    int? patientAge,
    String? patientGender,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? knownConditions,
    List<String>? currentMedications,
    String? emergencyContactName,
    String? emergencyContactRelation,
    String? emergencyContactPhone,
    DateTime? arrivalTime,
    String? arrivalMethod,
    String? referralSource,
    String? emergencyReason,
    String? patientReportedInfo,
    String? arrivalNotes,
    EmergencyOperationalPriority? priority,
    EmergencyCaseStatus? status,
    String? assignedDoctor,
    String? department,
    String? location,
    EmergencyObservationsModel? observations,
    List<EmergencyNoteModel>? notes,
    List<EmergencyTimelineItem>? timeline,
    EmergencyTransferInfoModel? transferInfo,
    EmergencyResolutionInfoModel? resolutionInfo,
    String? consultationId,
    List<String>? attachedReportIds,
    List<String>? attachedPrescriptionIds,
    List<EmergencyTimelineItem>? auditHistory,
  }) {
    return DoctorEmergencyCaseFullModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      knownConditions: knownConditions ?? this.knownConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      arrivalMethod: arrivalMethod ?? this.arrivalMethod,
      referralSource: referralSource ?? this.referralSource,
      emergencyReason: emergencyReason ?? this.emergencyReason,
      patientReportedInfo: patientReportedInfo ?? this.patientReportedInfo,
      arrivalNotes: arrivalNotes ?? this.arrivalNotes,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedDoctor: assignedDoctor ?? this.assignedDoctor,
      department: department ?? this.department,
      location: location ?? this.location,
      observations: observations ?? this.observations,
      notes: notes ?? this.notes,
      timeline: timeline ?? this.timeline,
      transferInfo: transferInfo ?? this.transferInfo,
      resolutionInfo: resolutionInfo ?? this.resolutionInfo,
      consultationId: consultationId ?? this.consultationId,
      attachedReportIds: attachedReportIds ?? this.attachedReportIds,
      attachedPrescriptionIds: attachedPrescriptionIds ?? this.attachedPrescriptionIds,
      auditHistory: auditHistory ?? this.auditHistory,
    );
  }
}
