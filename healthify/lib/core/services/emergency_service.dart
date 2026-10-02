import '../data/repositories/repositories.dart';
import '../models/core_models.dart';

class EmergencyService {
  final EmergencyRepository emergencyRepository;

  EmergencyService({required this.emergencyRepository});

  Future<EmergencyCaseItem> createEmergencyCase(EmergencyCaseItem item) async {
    return await emergencyRepository.registerEmergencyCase(item);
  }

  Future<EmergencyCaseItem> createAnonymousCase(EmergencyCaseItem anonymousCase) async {
    return await emergencyRepository.createAnonymousEmergencyCase(anonymousCase);
  }

  Future<void> linkPatient(String caseId, String patientId) async {
    await emergencyRepository.linkPatient(caseId, patientId);
  }

  Future<void> assignTriage(String caseId, TriagePriority priority) async {
    await emergencyRepository.assignTriageLevel(caseId, priority);
  }

  Future<void> assignDoctor(String caseId, String doctorName) async {
    await emergencyRepository.assignDoctorToEmergency(caseId, doctorName);
  }

  Future<void> assignNurse(String caseId, String nurseName) async {
    await emergencyRepository.assignNurse(caseId, nurseName);
  }

  Future<void> assignBay(String caseId, String bayName) async {
    await emergencyRepository.assignBay(caseId, bayName);
  }

  Future<void> dischargeCase(String caseId) async {
    await emergencyRepository.dischargeEmergencyCase(caseId);
  }

  Future<EmergencyCapacitySummary> getCapacity() async {
    return await emergencyRepository.getEmergencyCapacity();
  }
}
