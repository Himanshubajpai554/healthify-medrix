import '../../models/patient_model.dart';
import '../../queries/domain_queries.dart';

abstract class PatientRepository {
  Future<List<PatientItem>> getPatients({PatientQuery? query});
  Future<PatientItem?> getPatientById(String id);
  Future<List<Patient>> getGlobalPatients();
  Future<Patient?> findPatientByMrnOrPhone(String queryStr);
  Future<PatientItem> admitPatient(PatientAdmissionRequest request);
  Future<void> updatePatient(PatientItem patient);
  Future<void> updatePatientStatus(String patientId, PatientStatus newStatus);
  Future<void> updatePatientWard(String patientId, String newWard);
  Future<void> dischargePatient(String patientId);
  Future<PatientOverviewMetrics> getPatientMetrics(String hospitalId);
}

/// Optional repository capability for committing a patient, hospital link,
/// and first active admission as a single server transaction.
abstract interface class AtomicPatientAdmissionRepository {
  Future<void> createAdmissionBundle({
    required PatientItem patient,
    required HospitalPatientLink link,
    required Admission admission,
  });
}
