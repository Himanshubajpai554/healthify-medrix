import '../../models/blood_model.dart';
import '../../queries/domain_queries.dart';

abstract class BloodRepository {
  Future<List<BloodGroupSummaryItem>> getBloodSummaries();
  Future<List<BloodInventoryUnit>> getInventoryUnits({BloodInventoryQuery? query});
  Future<List<DonationRecordItem>> getDonationRecords();
  Future<List<BloodRequestItem>> getBloodRequests();
  Future<BloodInventoryUnit> addInventoryUnit(BloodInventoryUnit unit);
  Future<BloodRequestItem> createBloodRequest(BloodRequestItem request);
  Future<DonationRecordItem> recordDonation(DonationRecordItem donation);
  Future<void> updateRequestStatus(String requestId, RequestStatus status, int allocatedUnits);
  Future<void> reserveUnit(String unitId, String requestId);
  Future<void> allocateUnits(String requestId, List<String> unitIds);
  Future<void> issueUnits(String requestId, List<String> unitIds);
  Future<void> quarantineUnit(String unitId, [String? reason]);
  Future<void> releaseFromQuarantine(String unitId);
  Future<void> discardUnit(String unitId, [String? reason]);
  Future<BloodInventorySummary> getInventorySummary();
}

typedef BloodBankRepository = BloodRepository;
