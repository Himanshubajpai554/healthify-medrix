import '../enums/domain_enums.dart';
export '../../hospital/facilities/facility_model.dart';

class Facility {
  final String id;
  final String hospitalId;
  final String name;
  final String category;
  final FacilityStatus status;
  final String location;
  final int capacity;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Facility({
    required this.id,
    required this.hospitalId,
    required this.name,
    required this.category,
    required this.status,
    required this.location,
    required this.capacity,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });
}

class Equipment {
  final String id;
  final String facilityId;
  final String hospitalId;
  final String name;
  final String model;
  final String serialNumber;
  final EquipmentStatus status;
  final DateTime lastMaintenanceDate;
  final DateTime nextMaintenanceDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Equipment({
    required this.id,
    required this.facilityId,
    required this.hospitalId,
    required this.name,
    required this.model,
    required this.serialNumber,
    required this.status,
    required this.lastMaintenanceDate,
    required this.nextMaintenanceDate,
    required this.createdAt,
    required this.updatedAt,
  });
}
