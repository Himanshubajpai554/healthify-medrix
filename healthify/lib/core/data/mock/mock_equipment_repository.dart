import '../../enums/domain_enums.dart';
import '../../models/facility_model.dart';
import '../repositories/equipment_repository.dart';

class MockEquipmentRepository implements EquipmentRepository {
  final List<Equipment> _equipmentList = [
    Equipment(
      id: 'EQP-401',
      facilityId: 'FAC-101',
      hospitalId: 'HOSP-101',
      name: 'Siemens MAGNETOM 3T MRI Scanner',
      model: 'MAGNETOM Vida 3T',
      serialNumber: 'SN-MRI-99021',
      status: EquipmentStatus.operational,
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 45)),
      nextMaintenanceDate: DateTime.now().add(const Duration(days: 45)),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    Equipment(
      id: 'EQP-402',
      facilityId: 'FAC-104',
      hospitalId: 'HOSP-101',
      name: 'Philips Azurion 7 Cath Lab System',
      model: 'Azurion 7 B20/15',
      serialNumber: 'SN-CATH-88120',
      status: EquipmentStatus.operational,
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 20)),
      nextMaintenanceDate: DateTime.now().add(const Duration(days: 70)),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    Equipment(
      id: 'EQP-403',
      facilityId: 'FAC-108',
      hospitalId: 'HOSP-101',
      name: 'Sechrist Monoplace Hyperbaric Chamber',
      model: 'Sechrist 3600H',
      serialNumber: 'SN-HBOT-77341',
      status: EquipmentStatus.needsMaintenance,
      lastMaintenanceDate: DateTime.now().subtract(const Duration(days: 180)),
      nextMaintenanceDate: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Equipment>> getEquipment({String? facilityId, String? departmentId}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _equipmentList.where((e) {
      if (facilityId != null && e.facilityId != facilityId) return false;
      return true;
    }).toList();
  }

  @override
  Future<Equipment?> getEquipmentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _equipmentList.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Equipment> createEquipment(Equipment equipment) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _equipmentList.insert(0, equipment);
    return equipment;
  }

  @override
  Future<void> updateEquipment(Equipment equipment) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _equipmentList.indexWhere((e) => e.id == equipment.id);
    if (index != -1) {
      _equipmentList[index] = equipment;
    }
  }

  @override
  Future<void> updateEquipmentStatus(String equipmentId, EquipmentStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _equipmentList.indexWhere((e) => e.id == equipmentId);
    if (index != -1) {
      final old = _equipmentList[index];
      _equipmentList[index] = Equipment(
        id: old.id,
        facilityId: old.facilityId,
        hospitalId: old.hospitalId,
        name: old.name,
        model: old.model,
        serialNumber: old.serialNumber,
        status: status,
        lastMaintenanceDate: old.lastMaintenanceDate,
        nextMaintenanceDate: old.nextMaintenanceDate,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}
