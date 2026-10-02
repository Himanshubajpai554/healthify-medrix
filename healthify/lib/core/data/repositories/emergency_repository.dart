import '../../enums/domain_enums.dart';
import '../../models/emergency_model.dart';
import '../../models/ai_insight_model.dart';
import '../../queries/domain_queries.dart';

abstract class EmergencyRepository {
  Future<List<EmergencyCaseItem>> getEmergencyCases({EmergencyQuery? query});
  Future<EmergencyCaseItem?> getEmergencyCaseById(String id);
  Future<EmergencyCaseItem> registerEmergencyCase(EmergencyCaseItem emergencyCase);
  Future<EmergencyCaseItem> createAnonymousEmergencyCase(EmergencyCaseItem anonymousCase);
  Future<void> linkPatient(String caseId, String patientId);
  Future<void> assignTriageLevel(String caseId, TriagePriority priority);
  Future<void> updateEmergencyStatus(String caseId, EmergencyStatus status);
  Future<void> assignDoctorToEmergency(String caseId, String doctorName);
  Future<void> assignNurse(String caseId, String nurseName);
  Future<void> assignBay(String caseId, String bayName);
  Future<EmergencyCapacitySummary> getEmergencyCapacity();
  Future<List<EmergencyHospitalRecommendation>> getHospitalRecommendations();
  Future<void> dischargeEmergencyCase(String caseId);
}
