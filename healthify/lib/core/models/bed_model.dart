import '../enums/domain_enums.dart';
export '../../hospital/beds/bed_model.dart';
export 'hospital_model.dart' show Building, Floor, Ward, Room;

class Bed {
  final String id;
  final String hospitalId;
  final String buildingId;
  final String floorId;
  final String wardId;
  final String roomId;
  final String bedNumber;
  final String bedType;
  final BedStatus status;
  final String? currentPatientId;
  final String? assignedDoctorId;
  final String? admissionId;
  final bool isIsolation;
  final bool isICU;
  final double dailyRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Bed({
    required this.id,
    required this.hospitalId,
    this.buildingId = 'BLD-1',
    this.floorId = 'FLR-1',
    required this.wardId,
    required this.roomId,
    required this.bedNumber,
    this.bedType = 'General',
    required this.status,
    this.currentPatientId,
    this.assignedDoctorId,
    this.admissionId,
    this.isIsolation = false,
    required this.isICU,
    required this.dailyRate,
    required this.createdAt,
    required this.updatedAt,
  });

  String get ward => wardId;
  String get patientName => currentPatientId ?? '';
}

class ICUUnit {
  final String id;
  final String bedId;
  final String hospitalId;
  final String unitName;
  final bool ventilatorAvailable;
  final String monitorType;
  final bool isOccupied;
  final String? patientId;
  final String? doctorInChargeId;
  final String? nurseInChargeId;
  final String vitalAlertStatus; // normal, warning, critical
  final DateTime createdAt;
  final DateTime updatedAt;

  const ICUUnit({
    required this.id,
    required this.bedId,
    required this.hospitalId,
    required this.unitName,
    required this.ventilatorAvailable,
    required this.monitorType,
    required this.isOccupied,
    this.patientId,
    this.doctorInChargeId,
    this.nurseInChargeId,
    this.vitalAlertStatus = 'normal',
    required this.createdAt,
    required this.updatedAt,
  });
}

class BedOccupancySummary {
  final int total;
  final int occupied;
  final int available;
  final int reserved;
  final int maintenance;
  final int sanitizing;
  final int blocked;

  const BedOccupancySummary({
    required this.total,
    required this.occupied,
    required this.available,
    required this.reserved,
    required this.maintenance,
    required this.sanitizing,
    required this.blocked,
  });

  double get occupancyRate => total > 0 ? (occupied / total) * 100 : 0.0;
}

class BedCapacitySimulation {
  final int additionalPatients;
  final int expectedDischarges;
  final int expectedTransfers;
  final int simulatedOccupancy;
  final int simulatedAvailableBeds;
  final String capacityRisk;

  const BedCapacitySimulation({
    required this.additionalPatients,
    required this.expectedDischarges,
    required this.expectedTransfers,
    required this.simulatedOccupancy,
    required this.simulatedAvailableBeds,
    required this.capacityRisk,
  });
}

class BedActivityRecord {
  final String id;
  final String bedId;
  final String action;
  final DateTime timestamp;
  final String actorId;
  final String? patientId;
  final String? admissionId;

  const BedActivityRecord({
    required this.id,
    required this.bedId,
    required this.action,
    required this.timestamp,
    required this.actorId,
    this.patientId,
    this.admissionId,
  });
}
