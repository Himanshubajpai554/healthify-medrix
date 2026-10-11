import 'dart:typed_data';

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
  Future<Uint8List> getVerificationDocumentBytes(String documentId);
  Future<VerificationDocument> uploadVerificationDocument({
    required String title,
    required String documentType,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  });
}

