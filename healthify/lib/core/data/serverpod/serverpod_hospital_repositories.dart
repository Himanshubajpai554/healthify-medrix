import 'package:healthify_server_client/healthify_server_client.dart';
import 'dart:typed_data';

import '../../enums/domain_enums.dart';
import '../../models/hospital_model.dart';
import '../../models/hospital_settings_model.dart';
import '../mock/mock_hospital_repository.dart';
import '../repositories/hospital_repository.dart';
import '../repositories/hospital_settings_repository.dart';

/// Maps the generated Serverpod protocol into the UI's stable domain models.
class ServerpodHospitalRepository implements HospitalRepository {
  ServerpodHospitalRepository(this.client, {this.hospitalKey = 'HOSP-101'});

  final Client client;
  String hospitalKey;

  @override
  Future<HospitalInfo> getHospitalInfo() async {
    final row = await client.hospital.getInfo(hospitalKey);
    if (row == null) {
      final initial = await MockHospitalRepository().getHospitalInfo();
      await updateHospitalInfo(initial);
      return initial;
    }
    return HospitalInfo(
      id: row.hospitalKey,
      name: row.name,
      code: row.code,
      tagline: row.tagline,
      address: row.address,
      phone: row.phone,
      email: row.email,
      emergencyHotline: row.emergencyHotline,
      totalBedCapacity: row.totalBedCapacity,
      icuCapacity: row.icuCapacity,
      activeDoctorCount: row.activeDoctorCount,
      totalStaffCount: row.totalStaffCount,
    );
  }

  @override
  Future<void> updateHospitalInfo(HospitalInfo info) async {
    await client.hospital.saveInfo(HospitalInfoRecord(
      hospitalKey: info.id,
      name: info.name,
      code: info.code,
      tagline: info.tagline,
      address: info.address,
      phone: info.phone,
      email: info.email,
      emergencyHotline: info.emergencyHotline,
      totalBedCapacity: info.totalBedCapacity,
      icuCapacity: info.icuCapacity,
      activeDoctorCount: info.activeDoctorCount,
      totalStaffCount: info.totalStaffCount,
    ));
  }

  @override
  Future<HospitalProfile> getHospitalProfile() async {
    final row = await client.hospital.getProfile(hospitalKey);
    if (row == null) {
      final initial = await MockHospitalRepository().getHospitalProfile();
      await updateHospitalProfile(initial);
      return initial;
    }
    final documents = await getVerificationDocuments();
    return HospitalProfile(
      id: row.hospitalKey,
      name: row.name,
      legalName: row.legalName,
      displayName: row.displayName,
      hospitalType: row.hospitalType,
      establishmentDate: row.establishmentDate,
      registrationLicenseId: row.registrationLicenseId,
      taxId: row.taxId,
      accreditationInfo: row.accreditationInfo,
      email: row.email,
      emergencyHelpline: row.emergencyHelpline,
      receptionPhone: row.receptionPhone,
      website: row.website,
      address: row.address,
      city: row.city,
      state: row.state,
      country: row.country,
      latitude: row.latitude,
      longitude: row.longitude,
      totalBeds: row.totalBeds,
      icuBeds: row.icuBeds,
      operatingTheatres: row.operatingTheatres,
      emergencyCapacity: row.emergencyCapacity,
      has247Emergency: row.has247Emergency,
      traumaLevel: row.traumaLevel,
      hasAmbulance: row.hasAmbulance,
      opdTimings: row.opdTimings,
      operatingStatus: row.operatingStatus,
      verificationStatus: _verificationStatus(row.verificationStatus),
      submittedDate: row.submittedDate,
      verifiedDate: row.verifiedDate,
      verificationDocuments: documents,
      verificationNotes: row.verificationNotes,
    );
  }

  @override
  Future<void> updateHospitalProfile(HospitalProfile profile) async {
    await client.hospital.saveProfile(HospitalProfileRecord(
      hospitalKey: profile.id,
      name: profile.name,
      legalName: profile.legalName,
      displayName: profile.displayName,
      hospitalType: profile.hospitalType,
      establishmentDate: profile.establishmentDate,
      registrationLicenseId: profile.registrationLicenseId,
      taxId: profile.taxId,
      accreditationInfo: profile.accreditationInfo,
      email: profile.email,
      emergencyHelpline: profile.emergencyHelpline,
      receptionPhone: profile.receptionPhone,
      website: profile.website,
      address: profile.address,
      city: profile.city,
      state: profile.state,
      country: profile.country,
      latitude: profile.latitude,
      longitude: profile.longitude,
      totalBeds: profile.totalBeds,
      icuBeds: profile.icuBeds,
      operatingTheatres: profile.operatingTheatres,
      emergencyCapacity: profile.emergencyCapacity,
      has247Emergency: profile.has247Emergency,
      traumaLevel: profile.traumaLevel,
      hasAmbulance: profile.hasAmbulance,
      opdTimings: profile.opdTimings,
      operatingStatus: profile.operatingStatus,
      verificationStatus: profile.verificationStatus.name,
      submittedDate: profile.submittedDate,
      verifiedDate: profile.verifiedDate,
      verificationNotes: profile.verificationNotes,
    ));
  }

  @override
  Future<VerificationStatus> getVerificationStatus() async =>
      _verificationStatus(await client.hospital.getVerificationStatus(hospitalKey));

  @override
  Future<void> submitVerification(Map<String, dynamic> request) async {
    await client.hospital.submitVerification(hospitalKey);
  }

  @override
  Future<List<VerificationDocument>> getVerificationDocuments() async {
    final rows = await client.hospital.getVerificationDocuments(hospitalKey);
    return rows.map((row) => VerificationDocument(
              id: row.id?.toString() ?? '',
              title: row.title,
              documentType: row.documentType,
              fileUrl: '',
              uploadDate: row.uploadDate,
              status: row.status,
            )).toList();
  }

  @override
  Future<Uint8List> getVerificationDocumentBytes(String documentId) async {
    final bytes = await client.hospital.getVerificationDocumentBytes(
      hospitalKey,
      int.parse(documentId),
    );
    return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }

  @override
  Future<VerificationDocument> uploadVerificationDocument({
    required String title,
    required String documentType,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final record = await client.hospital.uploadVerificationDocument(
      hospitalKey,
      title,
      documentType,
      fileName,
      mimeType,
      ByteData.sublistView(bytes),
    );
    return VerificationDocument(
      id: record.id.toString(),
      title: record.title,
      documentType: record.documentType,
      fileUrl: '',
      uploadDate: record.uploadDate,
      status: record.status,
    );
  }

  VerificationStatus _verificationStatus(String value) =>
      VerificationStatus.values.firstWhere(
        (status) => status.name == value,
        orElse: () => VerificationStatus.unverified,
      );
}

class ServerpodHospitalSettingsRepository implements HospitalSettingsRepository {
  ServerpodHospitalSettingsRepository(this.client, {this.hospitalKey = 'HOSP-101'});

  final Client client;
  String hospitalKey;

  @override
  Future<LegacyHospitalSettings> getSettings(String hospitalId) async {
    final row = await client.hospital.getSettings(hospitalId);
    if (row == null) return LegacyHospitalSettings(hospitalId: hospitalId);
    return LegacyHospitalSettings(
      hospitalId: row.hospitalKey,
      timezone: row.timezone,
      defaultCurrency: row.defaultCurrency,
      opdOpeningTime: row.opdOpeningTime,
      opdClosingTime: row.opdClosingTime,
      appointmentSlotDurationMinutes: row.appointmentSlotDurationMinutes,
      autoReleaseExpiredBeds: row.autoReleaseExpiredBeds,
      isEmergencyActive: row.isEmergencyActive,
      emergencyHotline: row.emergencyHotline,
      traumaLevel: row.traumaLevel,
      ambulanceCount: row.ambulanceCount,
      isHospitalDiscoverable: row.isHospitalDiscoverable,
      showFacilitiesToPatients: row.showFacilitiesToPatients,
      showDoctorSchedulesToPatients: row.showDoctorSchedulesToPatients,
      showBedAvailabilityToPatients: row.showBedAvailabilityToPatients,
      showRatingsAndReviews: row.showRatingsAndReviews,
      sessionTimeoutMinutes: row.sessionTimeoutMinutes,
      enforceMfaForAdmin: row.enforceMfaForAdmin,
      enableAuditLogging: row.enableAuditLogging,
    );
  }

  @override
  Future<void> updateSettings(LegacyHospitalSettings settings) async {
    await client.hospital.saveSettings(HospitalSettingsRecord(
      hospitalKey: settings.hospitalId,
      timezone: settings.timezone,
      defaultCurrency: settings.defaultCurrency,
      opdOpeningTime: settings.opdOpeningTime,
      opdClosingTime: settings.opdClosingTime,
      appointmentSlotDurationMinutes: settings.appointmentSlotDurationMinutes,
      autoReleaseExpiredBeds: settings.autoReleaseExpiredBeds,
      isEmergencyActive: settings.isEmergencyActive,
      emergencyHotline: settings.emergencyHotline,
      traumaLevel: settings.traumaLevel,
      ambulanceCount: settings.ambulanceCount,
      isHospitalDiscoverable: settings.isHospitalDiscoverable,
      showFacilitiesToPatients: settings.showFacilitiesToPatients,
      showDoctorSchedulesToPatients: settings.showDoctorSchedulesToPatients,
      showBedAvailabilityToPatients: settings.showBedAvailabilityToPatients,
      showRatingsAndReviews: settings.showRatingsAndReviews,
      sessionTimeoutMinutes: settings.sessionTimeoutMinutes,
      enforceMfaForAdmin: settings.enforceMfaForAdmin,
      enableAuditLogging: settings.enableAuditLogging,
    ));
  }

  @override
  Future<List<UserAccessRecord>> getUserAccessList(String hospitalId) async {
    final rows = await client.hospital.getUserAccessList(hospitalId);
    return rows
        .map((row) => UserAccessRecord(
              userId: row.userKey,
              userName: row.userName,
              email: row.email,
              role: _role(row.role),
              department: row.department,
              isActive: row.isActive,
              lastActive: row.lastActive,
            ))
        .toList(growable: false);
  }

  @override
  Future<void> updateUserRole(String userId, UserRole role) async {
    await client.hospital.updateUserRole(hospitalKey, userId, role.name);
  }

  @override
  Future<void> toggleUserAccess(String userId, bool isActive) async {
    await client.hospital.setUserAccess(hospitalKey, userId, isActive);
  }

  UserRole _role(String value) => UserRole.values.firstWhere(
        (role) => role.name == value,
        orElse: () => UserRole.receptionist,
      );
}
