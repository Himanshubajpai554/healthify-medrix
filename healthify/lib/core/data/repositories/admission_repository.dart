import '../../models/patient_model.dart';

abstract class AdmissionRepository {
  Future<List<Admission>> getAdmissions({String? patientId, String? bedId, String? hospitalId});
  Future<Admission?> getAdmissionById(String id);
  Future<Admission?> getActiveAdmissionForPatient(String patientId);
  Future<List<Admission>> getAdmissionHistory(String patientId);
  Future<Admission> createAdmission(Admission admission);
  Future<void> updateAdmission(Admission admission);
  Future<void> dischargeAdmission(String admissionId);
}
