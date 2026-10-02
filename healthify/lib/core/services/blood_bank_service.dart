import '../data/repositories/repositories.dart';
import '../models/core_models.dart';

class BloodBankService {
  final BloodBankRepository bloodBankRepository;

  BloodBankService({required this.bloodBankRepository});

  Future<BloodRequestItem> createRequest({
    required String hospitalId,
    required String patientId,
    required String requesterId,
    required String bloodGroup,
    required int unitsRequired,
    required String urgencyLevel,
  }) async {
    final request = BloodRequestItem(
      requestId: 'BR-${DateTime.now().millisecondsSinceEpoch}',
      bloodGroup: bloodGroup,
      requiredUnits: unitsRequired,
      allocatedUnits: 0,
      department: 'Emergency & Trauma',
      priority: RequestPriority.urgent,
      status: RequestStatus.pending,
    );

    await bloodBankRepository.createBloodRequest(request);
    return request;
  }

  Future<DonationRecordItem> recordDonation(DonationRecordItem donation) async {
    return await bloodBankRepository.recordDonation(donation);
  }

  Future<BloodInventoryUnit> addInventoryUnit(BloodInventoryUnit unit) async {
    return await bloodBankRepository.addInventoryUnit(unit);
  }

  Future<void> reserveUnit(String unitId, String requestId) async {
    await bloodBankRepository.reserveUnit(unitId, requestId);
  }

  Future<void> allocateUnits(String requestId, List<String> unitIds) async {
    await bloodBankRepository.allocateUnits(requestId, unitIds);
  }

  Future<void> issueUnits(String requestId, List<String> unitIds) async {
    await bloodBankRepository.issueUnits(requestId, unitIds);
  }

  Future<void> quarantineUnit(String unitId, [String? reason]) async {
    await bloodBankRepository.quarantineUnit(unitId, reason);
  }

  Future<void> releaseFromQuarantine(String unitId) async {
    await bloodBankRepository.releaseFromQuarantine(unitId);
  }

  Future<void> discardUnit(String unitId, [String? reason]) async {
    await bloodBankRepository.discardUnit(unitId, reason);
  }

  Future<BloodInventorySummary> getInventorySummary() async {
    return await bloodBankRepository.getInventorySummary();
  }
}
