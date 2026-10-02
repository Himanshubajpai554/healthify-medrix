import '../../enums/domain_enums.dart';
import '../../models/facility_model.dart';

abstract class EquipmentRepository {
  Future<List<Equipment>> getEquipment({String? facilityId, String? departmentId});
  Future<Equipment?> getEquipmentById(String id);
  Future<Equipment> createEquipment(Equipment equipment);
  Future<void> updateEquipment(Equipment equipment);
  Future<void> updateEquipmentStatus(String equipmentId, EquipmentStatus status);
}
