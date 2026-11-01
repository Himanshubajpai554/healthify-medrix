import '../enums/domain_enums.dart';
import '../models/core_models.dart';

/// Bidirectional Domain <-> DTO Mapping Layer Specs for Serverpod Integration

class HospitalMapper {
  static Map<String, dynamic> toServerDto(HospitalSettings settings) {
    return {
      'hospitalId': settings.hospitalId,
      'displayName': settings.displayName,
      'legalName': settings.legalName,
      'hospitalType': settings.hospitalType,
      'licenseId': settings.licenseId,
      'email': settings.email,
      'phone': settings.phone,
      'emergencyHelpline': settings.emergencyHelpline,
      'operatingMode': settings.operatingMode,
    };
  }

  static HospitalSettings fromServerDto(Map<String, dynamic> dto) {
    return HospitalSettings(
      hospitalId: dto['hospitalId'] as String? ?? 'HOSP-101',
      displayName: dto['displayName'] as String? ?? 'St. Jude Memorial Hospital',
      legalName: dto['legalName'] as String? ?? 'St. Jude Healthcare Systems Inc.',
      hospitalType: dto['hospitalType'] as String? ?? 'Multi-specialty Center',
      licenseId: dto['licenseId'] as String? ?? 'HOSP-NY-90218',
      email: dto['email'] as String? ?? 'admin@stjude-hospital.org',
      phone: dto['phone'] as String? ?? '+1 (555) 900-HEALTHIFY',
      emergencyHelpline: dto['emergencyHelpline'] as String? ?? '+1 (555) 911-STJUDE',
      operatingMode: dto['operatingMode'] as String? ?? 'Normal Operations',
    );
  }
}

class DoctorMapper {
  static Map<String, dynamic> toServerDto(DoctorItem doc) {
    return {
      'id': doc.id,
      'name': doc.name,
      'department': doc.department,
      'status': doc.status.name,
      'activePatients': doc.activePatients,
      'phone': doc.phone,
      'email': doc.email,
      'experienceYears': doc.experienceYears,
      'shiftHours': doc.shiftHours,
    };
  }

  static DoctorItem fromServerDto(Map<String, dynamic> dto) {
    return DoctorItem(
      id: dto['id'] as String,
      name: dto['name'] as String,
      department: dto['department'] as String,
      status: DoctorStatus.values.firstWhere(
        (s) => s.name == dto['status'],
        orElse: () => DoctorStatus.available,
      ),
      activePatients: dto['activePatients'] as int? ?? 0,
      phone: dto['phone'] as String? ?? '',
      email: dto['email'] as String? ?? '',
      experienceYears: dto['experienceYears'] as int? ?? 5,
      shiftHours: dto['shiftHours'] as String? ?? '08:00 AM - 04:00 PM',
    );
  }
}

class PatientMapper {
  static Map<String, dynamic> toServerDto(PatientItem patient) {
    return {
      'id': patient.id,
      'name': patient.name,
      'age': patient.age,
      'gender': patient.gender,
      'bloodGroup': patient.bloodGroup,
      'ward': patient.ward,
      'status': patient.status.name,
      'doctorName': patient.doctorName,
      'admissionDate': patient.admissionDate.toUtc().toIso8601String(),
      'vitals': patient.vitals,
    };
  }

  static PatientItem fromServerDto(Map<String, dynamic> dto) {
    return PatientItem(
      id: dto['id'] as String,
      name: dto['name'] as String,
      age: dto['age'] as int,
      gender: dto['gender'] as String,
      bloodGroup: dto['bloodGroup'] as String,
      ward: dto['ward'] as String,
      status: PatientStatus.values.firstWhere(
        (s) => s.name == dto['status'],
        orElse: () => PatientStatus.admitted,
      ),
      doctorName: dto['doctorName'] as String,
      admissionDate: DateTime.parse(dto['admissionDate'] as String).toLocal(),
      vitals: Map<String, String>.from(dto['vitals'] as Map? ?? {}),
    );
  }
}

class AppointmentMapper {
  static Map<String, dynamic> toServerDto(AppointmentItem appt) {
    return {
      'id': appt.id,
      'patientName': appt.patientName,
      'doctorName': appt.doctorName,
      'department': appt.department,
      'dateTime': appt.dateTime.toUtc().toIso8601String(),
      'status': appt.status,
      'type': appt.type,
    };
  }

  static AppointmentItem fromServerDto(Map<String, dynamic> dto) {
    return AppointmentItem(
      id: dto['id'] as String,
      patientName: dto['patientName'] as String,
      doctorName: dto['doctorName'] as String,
      department: dto['department'] as String,
      dateTime: DateTime.parse(dto['dateTime'] as String).toLocal(),
      status: dto['status'] as String,
      type: dto['type'] as String? ?? 'Consultation',
    );
  }
}

class BedMapper {
  static Map<String, dynamic> toServerDto(BedItem bed) {
    return {
      'id': bed.id,
      'type': bed.type,
      'ward': bed.ward,
      'floor': bed.floor,
      'status': bed.status.name,
      'patientId': bed.patientId,
      'equipment': bed.equipment,
      'lastUpdated': bed.lastUpdated,
    };
  }

  static BedItem fromServerDto(Map<String, dynamic> dto) {
    return BedItem(
      id: dto['id'] as String,
      type: dto['type'] as String,
      ward: dto['ward'] as String,
      floor: dto['floor'] as int,
      status: BedStatus.values.firstWhere(
        (s) => s.name == dto['status'],
        orElse: () => BedStatus.available,
      ),
      patientId: dto['patientId'] as String?,
      equipment: List<String>.from(dto['equipment'] as List? ?? []),
      lastUpdated: dto['lastUpdated'] as String? ?? 'Just now',
    );
  }
}

class BloodUnitMapper {
  static Map<String, dynamic> toServerDto(BloodInventoryUnit unit) {
    return {
      'unitId': unit.unitId,
      'bloodGroup': unit.bloodGroup,
      'component': unit.component,
      'quantityUnits': unit.quantityUnits,
      'collectionDate': unit.collectionDate.toUtc().toIso8601String(),
      'expiryDate': unit.expiryDate.toUtc().toIso8601String(),
      'status': unit.status.name,
      'storageLocation': unit.storageLocation,
      'lastUpdated': unit.lastUpdated,
    };
  }

  static BloodInventoryUnit fromServerDto(Map<String, dynamic> dto) {
    return BloodInventoryUnit(
      unitId: dto['unitId'] as String,
      bloodGroup: dto['bloodGroup'] as String,
      component: dto['component'] as String? ?? 'Whole Blood',
      quantityUnits: dto['quantityUnits'] as int? ?? 1,
      collectionDate: DateTime.parse(dto['collectionDate'] as String).toLocal(),
      expiryDate: DateTime.parse(dto['expiryDate'] as String).toLocal(),
      status: InventoryUnitStatus.values.firstWhere(
        (s) => s.name == dto['status'],
        orElse: () => InventoryUnitStatus.available,
      ),
      storageLocation: dto['storageLocation'] as String? ?? 'Refrigerator A',
      lastUpdated: dto['lastUpdated'] as String? ?? 'Just now',
    );
  }
}

class EmergencyCaseMapper {
  static Map<String, dynamic> toServerDto(EmergencyCaseItem item) {
    return {
      'id': item.id,
      'patientName': item.patientName,
      'age': item.age,
      'gender': item.gender,
      'chiefComplaint': item.chiefComplaint,
      'priority': item.priority.name,
      'status': item.status.name,
      'assignedDoctor': item.assignedDoctor,
      'arrivalTime': item.arrivalTime,
      'locationBed': item.locationBed,
    };
  }

  static EmergencyCaseItem fromServerDto(Map<String, dynamic> dto) {
    return EmergencyCaseItem(
      id: dto['id'] as String,
      patientName: dto['patientName'] as String,
      age: dto['age'] as int,
      gender: dto['gender'] as String,
      chiefComplaint: dto['chiefComplaint'] as String,
      priority: TriagePriority.values.firstWhere(
        (p) => p.name == dto['priority'],
        orElse: () => TriagePriority.level2Emergent,
      ),
      status: EmergencyStatus.values.firstWhere(
        (s) => s.name == dto['status'],
        orElse: () => EmergencyStatus.waiting,
      ),
      assignedDoctor: dto['assignedDoctor'] as String,
      arrivalTime: dto['arrivalTime'] as String,
      locationBed: dto['locationBed'] as String,
    );
  }
}

class DiagnosticReportMapper {
  static Map<String, dynamic> toServerDto(DiagnosticReport report) {
    return {
      'id': report.id,
      'hospitalId': report.hospitalId,
      'patientId': report.patientId,
      'orderingDoctorId': report.orderingDoctorId,
      'title': report.title,
      'reportType': report.reportType.name,
      'verificationStatus': report.verificationStatus.name,
      'isCritical': report.isCritical,
      'summary': report.summary,
      'date': report.date.toUtc().toIso8601String(),
    };
  }

  static DiagnosticReport fromServerDto(Map<String, dynamic> dto) {
    return DiagnosticReport(
      id: dto['id'] as String,
      hospitalId: dto['hospitalId'] as String? ?? 'HOSP-101',
      patientId: dto['patientId'] as String,
      orderingDoctorId: dto['orderingDoctorId'] as String? ?? 'DOC-1001',
      title: dto['title'] as String,
      reportType: ReportType.values.firstWhere(
        (t) => t.name == dto['reportType'],
        orElse: () => ReportType.laboratory,
      ),
      verificationStatus: ReportVerificationStatus.values.firstWhere(
        (s) => s.name == dto['verificationStatus'],
        orElse: () => ReportVerificationStatus.uploaded,
      ),
      isCritical: dto['isCritical'] as bool? ?? false,
      summary: dto['summary'] as String? ?? '',
      date: DateTime.parse(dto['date'] as String).toLocal(),
      uploadedAt: DateTime.parse(dto['date'] as String).toLocal(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
