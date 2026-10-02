/// Domain enums for Medrix Hospital Portal.
/// Source of truth for entity statuses and classifications across the application.
library;

enum PatientStatus {
  active,
  discharged,
  admitted,
  critical,
  deceased,
  outpatient,
  icu,
  observation,
}

enum AppointmentStatus {
  scheduled,
  checkedIn,
  inConsultation,
  inProgress,
  completed,
  cancelled,
  noShow,
  missed,
}

enum AppointmentType {
  scheduled,
  walkIn,
  followUp,
  emergency,
  consultation,
  other,
}

enum BedStatus {
  available,
  occupied,
  maintenance,
  reserved,
  cleaning,
}

enum BloodUnitStatus {
  available,
  reserved,
  dispatched,
  expired,
  quarantined,
}

enum BloodRequestStatus {
  pending,
  approved,
  fulfilled,
  rejected,
  cancelled,
}

enum DoctorAvailabilityStatus {
  available,
  busy,
  onLeave,
  inSurgery,
  offDuty,
}

enum DoctorAffiliationStatus {
  fullTime,
  partTime,
  visiting,
  consultant,
  honorary,
}

enum StaffStatus {
  active,
  inShift,
  onLeave,
  suspended,
  terminated,
  offDuty,
}

enum ShiftStatus {
  scheduled,
  inProgress,
  completed,
  swapped,
  cancelled,
}

enum EmergencyStatus {
  arrived,
  triaged,
  waiting,
  assigned,
  inTreatment,
  stabilizing,
  transferred,
  discharged,
  deceased,
  triage,
  admitted,
  cancelled,
}

enum TriageLevel {
  level1Immediate,
  level2Emergent,
  level3Urgent,
  level4LessUrgent,
  level5NonUrgent,
}

enum VerificationStatus {
  pending,
  verified,
  rejected,
  unverified,
}

enum ReportType {
  laboratory,
  radiology,
  imaging,
  pathology,
  cardiology,
  other,
}

enum ReportVerificationStatus {
  uploaded,
  underReview,
  verified,
  rejected,
  released,
}

enum PrescriptionStatus {
  signed,
  active,
  completed,
  cancelled,
}

enum PharmacyFulfillmentStatus {
  pending,
  partiallyFulfilled,
  fulfilled,
  cancelled,
}

enum DocumentActivityAction {
  uploaded,
  viewed,
  reviewed,
  verified,
  rejected,
  released,
  downloaded,
}

enum ClinicalAccessState {
  fullAccess,
  metadataOnly,
  readOnly,
  restricted,
  clinicalAccessRequired,
  noPermission,
}

enum HospitalResourceType {
  bed,
  icuBed,
  doctor,
  nurse,
  blood,
  operatingTheatre,
  ventilator,
  equipment,
  facility,
  ambulance,
  other,
}

enum ResourceAvailabilityStatus {
  available,
  partiallyAvailable,
  occupied,
  reserved,
  unavailable,
  maintenance,
  critical,
  unknown,
}

enum AllocationRequestStatus {
  pending,
  underReview,
  approved,
  rejected,
  completed,
  cancelled,
}

enum AllocationPriority {
  low,
  medium,
  high,
  urgent,
  critical,
}

enum RecommendationStatus {
  newAction,
  reviewed,
  accepted,
  rejected,
  expired,
}

enum AIModelType {
  doctorAvailability,
  bloodDemand,
  emergencyHospitalRecommendation,
  bedOccupancy,
  hospitalCapacity,
  queueForecast,
}

enum AIPredictionStatus {
  generated,
  reviewed,
  accepted,
  rejected,
  expired,
  unavailable,
}

enum AIModelStatus {
  active,
  inactive,
  unavailable,
  experimental,
}

enum AIInsightSeverity {
  informational,
  low,
  medium,
  high,
  critical,
}

enum CapacityPressureLevel {
  normal,
  watch,
  elevated,
  high,
  critical,
}

enum AIFeatureSource {
  appointments,
  emergencyCases,
  admissions,
  beds,
  icu,
  bloodBank,
  doctors,
  staff,
  facilities,
  equipment,
}

enum AnalyticsGranularity {
  hour,
  day,
  week,
  month,
}

enum ReportStatus {
  pending,
  completed,
  verified,
  archived,
  cancelled,
}

enum NotificationType {
  newEmergencyArrival,
  icuVitalCritical,
  bloodStockCritical,
  patientCheckedIn,
  bedSanitizationCleared,
  reportUploaded,
  staffShiftReminder,
  bedCapacityWarning,
  icuCapacityWarning,
  emergencyQueueWarning,
  aiForecastAlert,
  resourceAllocationRequest,
  reportVerificationRequired,
  reportReleased,
  prescriptionFulfillmentUpdate,
  appointmentReminder,
  patientAppointmentReminder,
  patientReportReleased,
  systemAlert,
  emergency,
  appointment,
  system,
  labResult,
  bedAlert,
  bloodAlert,
}

enum NotificationPriority {
  informational,
  low,
  medium,
  high,
  critical,
}

enum NotificationStatus {
  unread,
  read,
  acknowledged,
  expired,
  dismissed,
}

enum DispatchStatus {
  pending,
  queued,
  sent,
  delivered,
  failed,
  cancelled,
}

enum DispatchChannel {
  inApp,
  push,
  email,
  sms,
}

enum OperationalAlertStatus {
  active,
  acknowledged,
  resolved,
  expired,
}

enum NotificationActivityAction {
  created,
  read,
  acknowledged,
  dismissed,
  dispatched,
  delivered,
  failed,
  expired,
}

enum FacilityStatus {
  operational,
  maintenance,
  closed,
  emergencyOnly,
}

enum EquipmentStatus {
  operational,
  needsMaintenance,
  outOfOrder,
  inUse,
}

enum AdmissionStatus {
  pending,
  admitted,
  discharged,
  transferred,
  cancelled,
}

enum UserRole {
  superAdmin,
  hospitalOwner,
  hospitalAdmin,
  hospitalManager,
  doctor,
  nurse,
  inpatientNurse,
  triageNurse,
  receptionist,
  receptionStaff,
  billingStaff,
  bloodBankStaff,
  labTechnician,
  pharmacist,
  erCoordinator,
  patient,
}

enum AuditActionType {
  create,
  read,
  update,
  delete,
  login,
  logout,
  permissionDenied,
  roleChanged,
  accessGranted,
  accessRevoked,
  export,
  verification,
  approval,
  assignment,
  transfer,
  discharge,
  breakGlassRequested,
  breakGlassRevoked,
}

enum SecurityEventSeverity {
  low,
  medium,
  high,
  critical,
}

enum SecurityEventType {
  permissionDenied,
  suspiciousAccess,
  roleChanged,
  accessRevoked,
  repeatedFailure,
  sensitiveDataAccess,
  breakGlassTriggered,
}

enum BreakGlassStatus {
  requested,
  granted,
  expired,
  revoked,
}

enum SessionStatus {
  active,
  idle,
  terminated,
  expired,
}
