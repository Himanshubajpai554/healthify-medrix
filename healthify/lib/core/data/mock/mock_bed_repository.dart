import '../repositories/bed_repository.dart';
import '../../models/bed_model.dart';
import '../../queries/domain_queries.dart';
import 'mock_data_store.dart';

class MockBedRepository implements BedRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<BedItem>> getBeds({BedQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.beds.toList();

    if (query != null) {
      if (query.searchQuery != null && query.searchQuery!.trim().isNotEmpty) {
        final q = query.searchQuery!.trim().toLowerCase();
        list = list.where((b) =>
            b.id.toLowerCase().contains(q) ||
            b.ward.toLowerCase().contains(q) ||
            (b.patientId != null && b.patientId!.toLowerCase().contains(q))).toList();
      }

      if (query.status != null) {
        list = list.where((b) => b.status == query.status).toList();
      }

      if (query.ward != null && query.ward != 'All') {
        list = list.where((b) => b.ward.toLowerCase() == query.ward!.toLowerCase()).toList();
      }

      if (query.isICU != null && query.isICU!) {
        list = list.where((b) => b.type.toUpperCase().contains('ICU')).toList();
      }
    }

    return List.unmodifiable(list);
  }

  @override
  Future<List<WardCapacityItem>> getWardCapacities() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_store.wardCapacities);
  }

  @override
  Future<List<LiveActivityItem>> getLiveActivities() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_store.liveActivities);
  }

  @override
  Future<BedItem> addBed(BedItem bed) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.beds.insert(0, bed);
    return bed;
  }

  @override
  Future<void> updateBedStatus(String bedId, BedStatus status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.beds.indexWhere((b) => b.id == bedId);
    if (index != -1) {
      _store.beds[index].status = status;
    }
  }

  @override
  Future<void> assignPatientToBed(String bedId, String patientId, [String? admissionId]) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _store.beds.indexWhere((b) => b.id == bedId);
    if (index != -1) {
      _store.beds[index] = BedItem(
        id: _store.beds[index].id,
        type: _store.beds[index].type,
        ward: _store.beds[index].ward,
        floor: _store.beds[index].floor,
        status: BedStatus.occupied,
        patientId: patientId,
        equipment: _store.beds[index].equipment,
        lastUpdated: 'Just now',
        isVisibleToPatientApp: _store.beds[index].isVisibleToPatientApp,
      );
    }
  }

  @override
  Future<void> transferPatient(String fromBedId, String toBedId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final fromIdx = _store.beds.indexWhere((b) => b.id == fromBedId);
    final toIdx = _store.beds.indexWhere((b) => b.id == toBedId);

    if (fromIdx != -1 && toIdx != -1) {
      final patientId = _store.beds[fromIdx].patientId;
      _store.beds[fromIdx] = BedItem(
        id: _store.beds[fromIdx].id,
        type: _store.beds[fromIdx].type,
        ward: _store.beds[fromIdx].ward,
        floor: _store.beds[fromIdx].floor,
        status: BedStatus.cleaning,
        patientId: null,
        equipment: _store.beds[fromIdx].equipment,
        lastUpdated: 'Just now',
        isVisibleToPatientApp: _store.beds[fromIdx].isVisibleToPatientApp,
      );
      _store.beds[toIdx] = BedItem(
        id: _store.beds[toIdx].id,
        type: _store.beds[toIdx].type,
        ward: _store.beds[toIdx].ward,
        floor: _store.beds[toIdx].floor,
        status: BedStatus.occupied,
        patientId: patientId,
        equipment: _store.beds[toIdx].equipment,
        lastUpdated: 'Just now',
        isVisibleToPatientApp: _store.beds[toIdx].isVisibleToPatientApp,
      );
    }
  }

  @override
  Future<void> reserveBed(String bedId, String patientId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.beds.indexWhere((b) => b.id == bedId);
    if (index != -1) {
      _store.beds[index].status = BedStatus.reserved;
    }
  }

  @override
  Future<void> releaseBed(String bedId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.beds.indexWhere((b) => b.id == bedId);
    if (index != -1) {
      _store.beds[index].status = BedStatus.cleaning;
    }
  }

  @override
  Future<void> startSanitization(String bedId) async {
    await updateBedStatus(bedId, BedStatus.cleaning);
  }

  @override
  Future<void> completeSanitization(String bedId) async {
    await updateBedStatus(bedId, BedStatus.available);
  }

  @override
  Future<void> startMaintenance(String bedId, [String? reason]) async {
    await updateBedStatus(bedId, BedStatus.maintenance);
  }

  @override
  Future<void> completeMaintenance(String bedId) async {
    await updateBedStatus(bedId, BedStatus.available);
  }

  @override
  Future<void> blockBed(String bedId, [String? reason]) async {
    await updateBedStatus(bedId, BedStatus.maintenance);
  }

  @override
  Future<void> unblockBed(String bedId) async {
    await updateBedStatus(bedId, BedStatus.available);
  }

  @override
  Future<BedOccupancySummary> getOccupancySummary() async {
    await Future.delayed(const Duration(milliseconds: 100));
    int total = _store.beds.length;
    int occupied = 0;
    int available = 0;
    int reserved = 0;
    int maintenance = 0;
    int sanitizing = 0;
    int blocked = 0;

    for (final b in _store.beds) {
      switch (b.status) {
        case BedStatus.occupied:
          occupied++;
          break;
        case BedStatus.available:
          available++;
          break;
        case BedStatus.reserved:
          reserved++;
          break;
        case BedStatus.maintenance:
          maintenance++;
          break;
        case BedStatus.cleaning:
          sanitizing++;
          break;
      }
    }

    return BedOccupancySummary(
      total: total,
      occupied: occupied,
      available: available,
      reserved: reserved,
      maintenance: maintenance,
      sanitizing: sanitizing,
      blocked: blocked,
    );
  }

  @override
  Future<void> togglePatientVisibility(String bedId, bool isVisible) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.beds.indexWhere((b) => b.id == bedId);
    if (index != -1) {
      _store.beds[index].isVisibleToPatientApp = isVisible;
    }
  }
}
