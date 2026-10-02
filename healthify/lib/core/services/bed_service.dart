import '../data/repositories/repositories.dart';
import '../models/core_models.dart';

class BedService {
  final BedRepository bedRepository;

  BedService({required this.bedRepository});

  Future<void> assignPatientToBed(String bedId, String patientId, [String? admissionId]) async {
    await bedRepository.assignPatientToBed(bedId, patientId, admissionId);
  }

  Future<void> transferPatient(String fromBedId, String toBedId) async {
    await bedRepository.transferPatient(fromBedId, toBedId);
  }

  Future<void> reserveBed(String bedId, String patientId) async {
    await bedRepository.reserveBed(bedId, patientId);
  }

  Future<void> releaseBed(String bedId) async {
    await bedRepository.releaseBed(bedId);
  }

  Future<void> startSanitization(String bedId) async {
    await bedRepository.startSanitization(bedId);
  }

  Future<void> completeSanitization(String bedId) async {
    await bedRepository.completeSanitization(bedId);
  }

  Future<void> startMaintenance(String bedId, [String? reason]) async {
    await bedRepository.startMaintenance(bedId, reason);
  }

  Future<void> completeMaintenance(String bedId) async {
    await bedRepository.completeMaintenance(bedId);
  }

  Future<void> blockBed(String bedId, [String? reason]) async {
    await bedRepository.blockBed(bedId, reason);
  }

  Future<void> unblockBed(String bedId) async {
    await bedRepository.unblockBed(bedId);
  }

  Future<BedOccupancySummary> getOccupancySummary() async {
    return await bedRepository.getOccupancySummary();
  }
}
