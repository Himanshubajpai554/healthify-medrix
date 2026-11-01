import 'dart:typed_data';

import '../repositories/hospital_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/hospital_model.dart';
import 'mock_data_store.dart';

class MockHospitalRepository implements HospitalRepository {
  final MockDataStore _store = MockDataStore();

  HospitalProfile _profile = HospitalProfile(
    id: 'HOSP-101',
    name: 'St. Jude Memorial Hospital',
    legalName: 'St. Jude Memorial Healthcare System Inc.',
    displayName: 'St. Jude Memorial Hospital & Trauma Center',
    hospitalType: 'Multi-Specialty Tertiary Hospital',
    establishmentDate: '1984-06-15',
    registrationLicenseId: 'NY-MED-891024-HOSP',
    taxId: 'EIN-12-3456789',
    accreditationInfo: 'JCI Accredited & NABH Level 3 Certified',
    email: 'admin@stjude-hospital.org',
    emergencyHelpline: '+1 (555) 911-STJUDE',
    receptionPhone: '+1 (555) 900-HEALTHIFY',
    website: 'https://www.stjude-hospital.org',
    address: '742 Healthcare Boulevard, Medical District',
    city: 'New York',
    state: 'NY',
    country: 'USA',
    latitude: 40.7128,
    longitude: -74.0060,
    totalBeds: 450,
    icuBeds: 60,
    operatingTheatres: 12,
    emergencyCapacity: 40,
    has247Emergency: true,
    traumaLevel: 'Level 1 Trauma Center',
    hasAmbulance: true,
    opdTimings: '08:00 AM - 08:00 PM (Mon-Sat)',
    operatingStatus: 'Fully Operational',
    verificationStatus: VerificationStatus.verified,
    submittedDate: DateTime.now().subtract(const Duration(days: 120)),
    verifiedDate: DateTime.now().subtract(const Duration(days: 90)),
    verificationDocuments: [
      VerificationDocument(
        id: 'DOC-VER-01',
        title: 'State Healthcare Operating License',
        documentType: 'Operating License',
        fileUrl: 'https://stjude.org/docs/license.pdf',
        uploadDate: DateTime(2026, 5, 12),
        status: 'Verified',
      ),
      VerificationDocument(
        id: 'DOC-VER-02',
        title: 'Joint Commission Accreditation Certificate',
        documentType: 'Accreditation',
        fileUrl: 'https://stjude.org/docs/jci_certificate.pdf',
        uploadDate: DateTime(2026, 6, 1),
        status: 'Verified',
      ),
    ],
    verificationNotes: 'All licensing and medical accreditation checks passed by NY Health Department.',
  );

  @override
  Future<HospitalInfo> getHospitalInfo() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.hospitalInfo;
  }

  @override
  Future<void> updateHospitalInfo(HospitalInfo info) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _store.hospitalInfo = info;
  }

  @override
  Future<HospitalProfile> getHospitalProfile() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _profile;
  }

  @override
  Future<void> updateHospitalProfile(HospitalProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profile = profile;
  }

  @override
  Future<VerificationStatus> getVerificationStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _profile.verificationStatus;
  }

  @override
  Future<void> submitVerification(Map<String, dynamic> request) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _profile = _profile.copyWith(
      verificationStatus: VerificationStatus.pending,
      submittedDate: DateTime.now(),
      verificationNotes: 'Verification submission received. Under review by Healthify Health Portal Audit Team.',
    );
  }

  @override
  Future<List<VerificationDocument>> getVerificationDocuments() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _profile.verificationDocuments;
  }

  @override
  Future<Uint8List> getVerificationDocumentBytes(String documentId) async =>
      Uint8List(0);

  @override
  Future<VerificationDocument> uploadVerificationDocument({
    required String title,
    required String documentType,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final document = VerificationDocument(
      id: 'DOC-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      documentType: documentType,
      fileUrl: '',
      uploadDate: DateTime.now(),
      status: 'Uploaded',
    );
    _profile = _profile.copyWith(
      verificationDocuments: [..._profile.verificationDocuments, document],
    );
    return document;
  }
}
