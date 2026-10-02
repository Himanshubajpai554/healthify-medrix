import '../enums/domain_enums.dart';

enum ArrivalMode { ambulance, walkIn, referral, police, other }

enum TriagePriority { level1Resuscitation, level2Emergent, level3Urgent, level4LessUrgent, level5NonUrgent }

class EmergencyCaseItem {
  final String id;
  final String patientName;
  final int age;
  final String gender;
  final String chiefComplaint;
  final TriagePriority priority;
  EmergencyStatus status;
  final String assignedDoctor;
  final String arrivalTime;
  final String locationBed;

  EmergencyCaseItem({
    required this.id,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.chiefComplaint,
    required this.priority,
    required this.status,
    required this.assignedDoctor,
    required this.arrivalTime,
    required this.locationBed,
  });
}

class EmergencyCase {
  final String id;
  final String hospitalId;
  final String? patientId;
  final String? anonymousPatientReference;
  final TriageLevel triageLevel;
  final EmergencyStatus status;
  final ArrivalMode arrivalMode;
  final String chiefComplaint;
  final DateTime arrivalTime;
  final String? assignedDoctorId;
  final String? assignedNurseId;
  final String? assignedBayId;
  final String departmentId;
  final List<String> requiredResources;
  final String location;
  final Map<String, String> vitals;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmergencyCase({
    required this.id,
    required this.hospitalId,
    this.patientId,
    this.anonymousPatientReference,
    required this.triageLevel,
    required this.status,
    this.arrivalMode = ArrivalMode.ambulance,
    required this.chiefComplaint,
    required this.arrivalTime,
    this.assignedDoctorId,
    this.assignedNurseId,
    this.assignedBayId,
    this.departmentId = 'DEP-EMERGENCY',
    this.requiredResources = const [],
    required this.location,
    required this.vitals,
    required this.createdAt,
    required this.updatedAt,
  });

  String get patientName => patientId != null ? 'Patient $patientId' : (anonymousPatientReference ?? 'Anonymous Emergency');
  String get triage => triageLevel.name;
  bool get isAnonymous => patientId == null || patientId!.isEmpty;
}

class ERBay {
  final String id;
  final String hospitalId;
  final String name;
  final String departmentId;
  final String status; // Available, Occupied, Cleaning, Maintenance, Blocked
  final String? currentEmergencyCaseId;
  final List<String> equipmentReferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ERBay({
    required this.id,
    required this.hospitalId,
    required this.name,
    this.departmentId = 'DEP-EMERGENCY',
    this.status = 'Available',
    this.currentEmergencyCaseId,
    this.equipmentReferences = const [],
    required this.createdAt,
    required this.updatedAt,
  });
}

class EmergencyResourceRequirement {
  final String caseId;
  final String resourceType; // ICU, Blood, Ventilator, Specialist, OT, Isolation, Imaging
  final bool required;
  final String status; // Requested, Approved, Fulfilled, Cancelled
  final DateTime requestedAt;
  final DateTime? fulfilledAt;

  const EmergencyResourceRequirement({
    required this.caseId,
    required this.resourceType,
    required this.required,
    this.status = 'Requested',
    required this.requestedAt,
    this.fulfilledAt,
  });
}

class EmergencyActivity {
  final String id;
  final String caseId;
  final String action;
  final String actorId;
  final DateTime timestamp;
  final String? metadata;

  const EmergencyActivity({
    required this.id,
    required this.caseId,
    required this.action,
    required this.actorId,
    required this.timestamp,
    this.metadata,
  });
}

class EmergencyCapacitySummary {
  final int totalBays;
  final int availableBays;
  final int occupiedBays;
  final int cleaningBays;
  final int maintenanceBays;
  final int criticalCases;
  final int waitingCases;
  final int inTreatmentCases;

  const EmergencyCapacitySummary({
    required this.totalBays,
    required this.availableBays,
    required this.occupiedBays,
    required this.cleaningBays,
    required this.maintenanceBays,
    required this.criticalCases,
    required this.waitingCases,
    required this.inTreatmentCases,
  });
}




