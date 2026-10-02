import '../../models/patient_model.dart';

abstract class HospitalPatientRepository {
  Future<List<HospitalPatientLink>> getHospitalPatientLinks(String hospitalId);
  Future<HospitalPatientLink?> getLinkByPatientId(String hospitalId, String patientId);
  Future<HospitalPatientLink?> getLinkByMrn(String hospitalId, String mrnNumber);
  Future<HospitalPatientLink> createLink(HospitalPatientLink link);
  Future<void> updateLinkStatus(String linkId, String newStatus);
}
