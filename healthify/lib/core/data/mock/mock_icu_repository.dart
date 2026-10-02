import '../../models/bed_model.dart';
import '../repositories/icu_repository.dart';

class MockICURepository implements ICURepository {
  final List<ICUUnit> _units = [
    ICUUnit(
      id: 'ICU-101',
      bedId: 'BED-101',
      hospitalId: 'HOSP-101',
      unitName: 'ICU Pod Alpha-1',
      ventilatorAvailable: true,
      monitorType: 'Multi-Para Telemetry V4',
      isOccupied: true,
      patientId: 'PT-1002',
      doctorInChargeId: 'DOC-1001',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    ICUUnit(
      id: 'ICU-102',
      bedId: 'BED-102',
      hospitalId: 'HOSP-101',
      unitName: 'ICU Pod Alpha-2',
      ventilatorAvailable: true,
      monitorType: 'Standard Cardiac Monitor',
      isOccupied: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<ICUUnit>> getICUUnits() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_units);
  }

  @override
  Future<ICUUnit?> getICUUnitById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _units.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateICUUnit(ICUUnit unit) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _units.indexWhere((u) => u.id == unit.id);
    if (index != -1) {
      _units[index] = unit;
    }
  }
}
