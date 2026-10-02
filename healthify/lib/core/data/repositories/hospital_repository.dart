import '../../enums/domain_enums.dart';
import '../../models/hospital_model.dart';

abstract class HospitalRepository {
  Future<HospitalInfo> getHospitalInfo();
  Future<void> updateHospitalInfo(HospitalInfo info);
  Future<HospitalProfile> getHospitalProfile();
  Future<void> updateHospitalProfile(HospitalProfile profile);
  Future<VerificationStatus> getVerificationStatus();
  Future<void> submitVerification(Map<String, dynamic> request);
  Future<List<VerificationDocument>> getVerificationDocuments();
}
