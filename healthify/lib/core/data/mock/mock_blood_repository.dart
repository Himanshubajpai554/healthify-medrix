import '../repositories/blood_repository.dart';
import '../../models/blood_model.dart';
import '../../queries/domain_queries.dart';
import 'mock_data_store.dart';

class MockBloodRepository implements BloodRepository {
  final MockDataStore _store = MockDataStore();

  @override
  Future<List<BloodGroupSummaryItem>> getBloodSummaries() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_store.bloodSummaries);
  }

  @override
  Future<List<BloodInventoryUnit>> getInventoryUnits({BloodInventoryQuery? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var list = _store.bloodInventory.toList();

    if (query != null) {
      if (query.bloodGroup != null && query.bloodGroup != 'All') {
        list = list.where((u) => u.bloodGroup.toUpperCase() == query.bloodGroup!.toUpperCase()).toList();
      }
      if (query.status != null) {
        final sStr = query.status!.name.toLowerCase();
        list = list.where((u) => u.status.name.toLowerCase() == sStr).toList();
      }
    }

    return List.unmodifiable(list);
  }

  @override
  Future<List<DonationRecordItem>> getDonationRecords() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_store.donationRecords);
  }

  @override
  Future<List<BloodRequestItem>> getBloodRequests() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_store.bloodRequests);
  }

  @override
  Future<BloodInventoryUnit> addInventoryUnit(BloodInventoryUnit unit) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.bloodInventory.insert(0, unit);
    return unit;
  }

  @override
  Future<BloodRequestItem> createBloodRequest(BloodRequestItem request) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.bloodRequests.insert(0, request);
    return request;
  }

  @override
  Future<DonationRecordItem> recordDonation(DonationRecordItem donation) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.donationRecords.insert(0, donation);
    return donation;
  }

  @override
  Future<void> updateRequestStatus(String requestId, RequestStatus status, int allocatedUnits) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _store.bloodRequests.indexWhere((r) => r.requestId == requestId);
    if (index != -1) {
      _store.bloodRequests[index].status = status;
      _store.bloodRequests[index].allocatedUnits = allocatedUnits;
    }
  }

  @override
  Future<void> reserveUnit(String unitId, String requestId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.bloodInventory.indexWhere((u) => u.unitId == unitId);
    if (index != -1) {
      _store.bloodInventory[index].status = InventoryUnitStatus.reserved;
    }
  }

  @override
  Future<void> allocateUnits(String requestId, List<String> unitIds) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final unitId in unitIds) {
      await reserveUnit(unitId, requestId);
    }
    final reqIndex = _store.bloodRequests.indexWhere((r) => r.requestId == requestId);
    if (reqIndex != -1) {
      _store.bloodRequests[reqIndex].status = RequestStatus.allocated;
      _store.bloodRequests[reqIndex].allocatedUnits = unitIds.length;
    }
  }

  @override
  Future<void> issueUnits(String requestId, List<String> unitIds) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final unitId in unitIds) {
      final index = _store.bloodInventory.indexWhere((u) => u.unitId == unitId);
      if (index != -1) {
        _store.bloodInventory[index].status = InventoryUnitStatus.reserved;
      }
    }
    final reqIndex = _store.bloodRequests.indexWhere((r) => r.requestId == requestId);
    if (reqIndex != -1) {
      _store.bloodRequests[reqIndex].status = RequestStatus.completed;
    }
  }

  @override
  Future<void> quarantineUnit(String unitId, [String? reason]) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.bloodInventory.indexWhere((u) => u.unitId == unitId);
    if (index != -1) {
      _store.bloodInventory[index].status = InventoryUnitStatus.quarantine;
    }
  }

  @override
  Future<void> releaseFromQuarantine(String unitId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.bloodInventory.indexWhere((u) => u.unitId == unitId);
    if (index != -1) {
      _store.bloodInventory[index].status = InventoryUnitStatus.available;
    }
  }

  @override
  Future<void> discardUnit(String unitId, [String? reason]) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _store.bloodInventory.indexWhere((u) => u.unitId == unitId);
    if (index != -1) {
      _store.bloodInventory[index].status = InventoryUnitStatus.discarded;
    }
  }

  @override
  Future<BloodInventorySummary> getInventorySummary() async {
    await Future.delayed(const Duration(milliseconds: 100));
    int total = 0;
    int available = 0;
    int reserved = 0;
    int expiring = 0;
    int critical = 0;

    for (final unit in _store.bloodInventory) {
      total += unit.quantityUnits;
      if (unit.status == InventoryUnitStatus.available) available += unit.quantityUnits;
      if (unit.status == InventoryUnitStatus.reserved) reserved += unit.quantityUnits;
      if (unit.status == InventoryUnitStatus.expired || unit.status == InventoryUnitStatus.expiringSoon) expiring += unit.quantityUnits;
      if (unit.status == InventoryUnitStatus.quarantine) critical += unit.quantityUnits;
    }

    return BloodInventorySummary(
      totalUnits: total,
      availableUnits: available,
      reservedUnits: reserved,
      expiringUnits: expiring,
      criticalUnits: critical,
      lastUpdated: DateTime.now(),
    );
  }
}

typedef MockBloodBankRepository = MockBloodRepository;
