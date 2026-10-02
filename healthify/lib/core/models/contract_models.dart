import 'emergency_model.dart';



/// Request DTO for creating an appointment
class CreateAppointmentRequest {
  final String hospitalId;
  final String patientId;
  final String doctorId;
  final String departmentId;
  final DateTime dateTime;
  final String reason;
  final String type; // Consultation, FollowUp, WalkIn, Emergency

  const CreateAppointmentRequest({
    required this.hospitalId,
    required this.patientId,
    required this.doctorId,
    required this.departmentId,
    required this.dateTime,
    required this.reason,
    this.type = 'Consultation',
  });
}

/// Request DTO for assigning a bed to a patient
class AssignBedRequest {
  final String bedId;
  final String patientId;
  final String? admissionId;
  final String assignedByUserId;
  final String? notes;

  const AssignBedRequest({
    required this.bedId,
    required this.patientId,
    this.admissionId,
    required this.assignedByUserId,
    this.notes,
  });
}

/// Request DTO for creating a blood inventory request
class CreateBloodRequest {
  final String hospitalId;
  final String patientId;
  final String requesterId;
  final String bloodGroup;
  final int unitsRequired;
  final String urgencyLevel; // ROUTINE, URGENT, STAT_CRITICAL

  const CreateBloodRequest({
    required this.hospitalId,
    required this.patientId,
    required this.requesterId,
    required this.bloodGroup,
    required this.unitsRequired,
    required this.urgencyLevel,
  });
}

/// Request DTO for registering an emergency case
class CreateEmergencyCaseRequest {
  final String hospitalId;
  final String? patientId; // Nullable for anonymous/unconscious patients
  final String patientName;
  final int age;
  final String gender;
  final String chiefComplaint;
  final TriagePriority priority;
  final String arrivalMode; // ambulance, walkIn, referral, police

  const CreateEmergencyCaseRequest({
    required this.hospitalId,
    this.patientId,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.chiefComplaint,
    required this.priority,
    required this.arrivalMode,
  });
}

/// Request DTO for assigning a doctor to an emergency case
class AssignEmergencyDoctorRequest {
  final String caseId;
  final String doctorId;
  final String doctorName;
  final String assignedByUserId;

  const AssignEmergencyDoctorRequest({
    required this.caseId,
    required this.doctorId,
    required this.doctorName,
    required this.assignedByUserId,
  });
}

/// Request DTO for uploading a diagnostic report
class UploadReportRequest {
  final String hospitalId;
  final String patientId;
  final String orderingDoctorId;
  final String departmentId;
  final String reportType; // laboratory, radiology, cardiology, pathology
  final String title;
  final String summary;
  final Map<String, dynamic> resultData;
  final String fileName;
  final String mimeType;
  final int fileSize;

  const UploadReportRequest({
    required this.hospitalId,
    required this.patientId,
    required this.orderingDoctorId,
    required this.departmentId,
    required this.reportType,
    required this.title,
    required this.summary,
    required this.resultData,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
  });
}

/// Request DTO for updating hospital settings
class UpdateHospitalSettingsRequest {
  final String hospitalId;
  final String category;
  final Map<String, dynamic> settingsPayload;
  final String updatedByUserId;

  const UpdateHospitalSettingsRequest({
    required this.hospitalId,
    required this.category,
    required this.settingsPayload,
    required this.updatedByUserId,
  });
}

/// Request DTO for creating a resource request
class CreateResourceRequest {
  final String hospitalId;
  final String departmentId;
  final String resourceType; // equipment, supply, staff, facility
  final String title;
  final int quantity;
  final String priority;

  const CreateResourceRequest({
    required this.hospitalId,
    required this.departmentId,
    required this.resourceType,
    required this.title,
    required this.quantity,
    required this.priority,
  });
}

// ==========================================
// RESPONSE DTO MODELS
// ==========================================

/// Response DTO for appointment queue details
class AppointmentQueueResponse {
  final String doctorId;
  final String doctorName;
  final String department;
  final int totalScheduledToday;
  final int totalCheckedIn;
  final int totalCompleted;
  final int totalCancelled;
  final int nextQueueNumber;

  const AppointmentQueueResponse({
    required this.doctorId,
    required this.doctorName,
    required this.department,
    required this.totalScheduledToday,
    required this.totalCheckedIn,
    required this.totalCompleted,
    required this.totalCancelled,
    required this.nextQueueNumber,
  });
}

/// Response DTO for hospital KPI metrics
class HospitalKpiResponse {
  final String hospitalId;
  final int activePatients;
  final double wardOccupancyRate;
  final double icuOccupancyRate;
  final int pendingEmergencyCases;
  final int unverifiedReports;
  final int criticalBloodAlerts;
  final DateTime timestamp;

  const HospitalKpiResponse({
    required this.hospitalId,
    required this.activePatients,
    required this.wardOccupancyRate,
    required this.icuOccupancyRate,
    required this.pendingEmergencyCases,
    required this.unverifiedReports,
    required this.criticalBloodAlerts,
    required this.timestamp,
  });
}

/// Response DTO for AI insight payload
class AIInsightResponse {
  final String insightId;
  final String category;
  final String summary;
  final double confidenceScore;
  final List<String> recommendedActions;
  final DateTime generatedAt;
  final String disclaimer;

  const AIInsightResponse({
    required this.insightId,
    required this.category,
    required this.summary,
    required this.confidenceScore,
    required this.recommendedActions,
    required this.generatedAt,
    this.disclaimer = 'Clinical decisions remain the sole responsibility of attending physicians.',
  });
}
