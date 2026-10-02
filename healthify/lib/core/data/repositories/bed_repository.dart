import '../../models/bed_model.dart';
import '../../queries/domain_queries.dart';

abstract class BedRepository {
  Future<List<BedItem>> getBeds({BedQuery? query});
  Future<List<WardCapacityItem>> getWardCapacities();
  Future<List<LiveActivityItem>> getLiveActivities();
  Future<BedItem> addBed(BedItem bed);
  Future<void> updateBedStatus(String bedId, BedStatus status);
  Future<void> assignPatientToBed(String bedId, String patientId, [String? admissionId]);
  Future<void> transferPatient(String fromBedId, String toBedId);
  Future<void> reserveBed(String bedId, String patientId);
  Future<void> releaseBed(String bedId);
  Future<void> startSanitization(String bedId);
  Future<void> completeSanitization(String bedId);
  Future<void> startMaintenance(String bedId, [String? reason]);
  Future<void> completeMaintenance(String bedId);
  Future<void> blockBed(String bedId, [String? reason]);
  Future<void> unblockBed(String bedId);
  Future<BedOccupancySummary> getOccupancySummary();
  Future<void> togglePatientVisibility(String bedId, bool isVisible);
}
