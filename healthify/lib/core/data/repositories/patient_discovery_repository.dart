import '../../models/ai_insight_model.dart';
import '../../models/doctor_model.dart';
import '../../models/hospital_model.dart';


import '../../queries/domain_queries.dart';

class HealthConcernMappingResult {
  final String queryText;
  final List<Department> relevantDepartments;
  final List<String> relevantSpecialties;
  final List<Doctor> matchingDoctors;
  final List<Hospital> nearbyHospitals;
  final String nonDiagnosticDisclaimer;

  const HealthConcernMappingResult({
    required this.queryText,
    required this.relevantDepartments,
    required this.relevantSpecialties,
    required this.matchingDoctors,
    required this.nearbyHospitals,
    this.nonDiagnosticDisclaimer =
        'This helps you find relevant healthcare services. It is not a diagnosis or clinical recommendation.',
  });
}

abstract class PatientDiscoveryRepository {
  Future<List<Hospital>> searchHospitals(HospitalSearchQuery query);
  Future<HospitalProfile?> getHospitalDetails(String hospitalId);
  Future<List<Doctor>> searchDoctors(DoctorSearchQuery query);
  Future<Doctor?> getDoctorDetails(String doctorId);
  Future<HealthConcernMappingResult> getHealthConcernMapping(HealthConcernQuery query);
  Future<List<EmergencyHospitalRecommendation>> getEmergencyRecommendations(
    EmergencyRecommendationQuery query,
  );
  Future<List<Map<String, dynamic>>> getVisibleBloodAvailability();
  Future<List<Map<String, dynamic>>> getVisibleBedAvailability();
}
