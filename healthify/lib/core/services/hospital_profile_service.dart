import '../data/repositories/repositories.dart';
import '../models/core_models.dart';

class HospitalProfileService {
  final HospitalRepository hospitalRepository;

  HospitalProfileService({required this.hospitalRepository});

  Future<HospitalProfile> getProfile() async {
    return await hospitalRepository.getHospitalProfile();
  }

  Future<void> updateProfile(HospitalProfile profile) async {
    await hospitalRepository.updateHospitalProfile(profile);
  }

  Future<void> submitVerification(Map<String, dynamic> request) async {
    await hospitalRepository.submitVerification(request);
  }
}
