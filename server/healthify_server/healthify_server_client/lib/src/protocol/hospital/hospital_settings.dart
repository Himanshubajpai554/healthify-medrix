/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class HospitalSettingsRecord implements _i1.SerializableModel {
  HospitalSettingsRecord._({
    this.id,
    required this.hospitalKey,
    required this.timezone,
    required this.defaultCurrency,
    required this.opdOpeningTime,
    required this.opdClosingTime,
    required this.appointmentSlotDurationMinutes,
    required this.autoReleaseExpiredBeds,
    required this.isEmergencyActive,
    required this.emergencyHotline,
    required this.traumaLevel,
    required this.ambulanceCount,
    required this.isHospitalDiscoverable,
    required this.showFacilitiesToPatients,
    required this.showDoctorSchedulesToPatients,
    required this.showBedAvailabilityToPatients,
    required this.showRatingsAndReviews,
    required this.sessionTimeoutMinutes,
    required this.enforceMfaForAdmin,
    required this.enableAuditLogging,
  });

  factory HospitalSettingsRecord({
    int? id,
    required String hospitalKey,
    required String timezone,
    required String defaultCurrency,
    required String opdOpeningTime,
    required String opdClosingTime,
    required int appointmentSlotDurationMinutes,
    required bool autoReleaseExpiredBeds,
    required bool isEmergencyActive,
    required String emergencyHotline,
    required String traumaLevel,
    required int ambulanceCount,
    required bool isHospitalDiscoverable,
    required bool showFacilitiesToPatients,
    required bool showDoctorSchedulesToPatients,
    required bool showBedAvailabilityToPatients,
    required bool showRatingsAndReviews,
    required int sessionTimeoutMinutes,
    required bool enforceMfaForAdmin,
    required bool enableAuditLogging,
  }) = _HospitalSettingsRecordImpl;

  factory HospitalSettingsRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalSettingsRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      timezone: jsonSerialization['timezone'] as String,
      defaultCurrency: jsonSerialization['defaultCurrency'] as String,
      opdOpeningTime: jsonSerialization['opdOpeningTime'] as String,
      opdClosingTime: jsonSerialization['opdClosingTime'] as String,
      appointmentSlotDurationMinutes:
          jsonSerialization['appointmentSlotDurationMinutes'] as int,
      autoReleaseExpiredBeds: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['autoReleaseExpiredBeds'],
      ),
      isEmergencyActive: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isEmergencyActive'],
      ),
      emergencyHotline: jsonSerialization['emergencyHotline'] as String,
      traumaLevel: jsonSerialization['traumaLevel'] as String,
      ambulanceCount: jsonSerialization['ambulanceCount'] as int,
      isHospitalDiscoverable: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isHospitalDiscoverable'],
      ),
      showFacilitiesToPatients: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['showFacilitiesToPatients'],
      ),
      showDoctorSchedulesToPatients: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['showDoctorSchedulesToPatients'],
      ),
      showBedAvailabilityToPatients: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['showBedAvailabilityToPatients'],
      ),
      showRatingsAndReviews: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['showRatingsAndReviews'],
      ),
      sessionTimeoutMinutes: jsonSerialization['sessionTimeoutMinutes'] as int,
      enforceMfaForAdmin: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['enforceMfaForAdmin'],
      ),
      enableAuditLogging: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['enableAuditLogging'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String hospitalKey;

  String timezone;

  String defaultCurrency;

  String opdOpeningTime;

  String opdClosingTime;

  int appointmentSlotDurationMinutes;

  bool autoReleaseExpiredBeds;

  bool isEmergencyActive;

  String emergencyHotline;

  String traumaLevel;

  int ambulanceCount;

  bool isHospitalDiscoverable;

  bool showFacilitiesToPatients;

  bool showDoctorSchedulesToPatients;

  bool showBedAvailabilityToPatients;

  bool showRatingsAndReviews;

  int sessionTimeoutMinutes;

  bool enforceMfaForAdmin;

  bool enableAuditLogging;

  /// Returns a shallow copy of this [HospitalSettingsRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalSettingsRecord copyWith({
    int? id,
    String? hospitalKey,
    String? timezone,
    String? defaultCurrency,
    String? opdOpeningTime,
    String? opdClosingTime,
    int? appointmentSlotDurationMinutes,
    bool? autoReleaseExpiredBeds,
    bool? isEmergencyActive,
    String? emergencyHotline,
    String? traumaLevel,
    int? ambulanceCount,
    bool? isHospitalDiscoverable,
    bool? showFacilitiesToPatients,
    bool? showDoctorSchedulesToPatients,
    bool? showBedAvailabilityToPatients,
    bool? showRatingsAndReviews,
    int? sessionTimeoutMinutes,
    bool? enforceMfaForAdmin,
    bool? enableAuditLogging,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalSettingsRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'timezone': timezone,
      'defaultCurrency': defaultCurrency,
      'opdOpeningTime': opdOpeningTime,
      'opdClosingTime': opdClosingTime,
      'appointmentSlotDurationMinutes': appointmentSlotDurationMinutes,
      'autoReleaseExpiredBeds': autoReleaseExpiredBeds,
      'isEmergencyActive': isEmergencyActive,
      'emergencyHotline': emergencyHotline,
      'traumaLevel': traumaLevel,
      'ambulanceCount': ambulanceCount,
      'isHospitalDiscoverable': isHospitalDiscoverable,
      'showFacilitiesToPatients': showFacilitiesToPatients,
      'showDoctorSchedulesToPatients': showDoctorSchedulesToPatients,
      'showBedAvailabilityToPatients': showBedAvailabilityToPatients,
      'showRatingsAndReviews': showRatingsAndReviews,
      'sessionTimeoutMinutes': sessionTimeoutMinutes,
      'enforceMfaForAdmin': enforceMfaForAdmin,
      'enableAuditLogging': enableAuditLogging,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalSettingsRecordImpl extends HospitalSettingsRecord {
  _HospitalSettingsRecordImpl({
    int? id,
    required String hospitalKey,
    required String timezone,
    required String defaultCurrency,
    required String opdOpeningTime,
    required String opdClosingTime,
    required int appointmentSlotDurationMinutes,
    required bool autoReleaseExpiredBeds,
    required bool isEmergencyActive,
    required String emergencyHotline,
    required String traumaLevel,
    required int ambulanceCount,
    required bool isHospitalDiscoverable,
    required bool showFacilitiesToPatients,
    required bool showDoctorSchedulesToPatients,
    required bool showBedAvailabilityToPatients,
    required bool showRatingsAndReviews,
    required int sessionTimeoutMinutes,
    required bool enforceMfaForAdmin,
    required bool enableAuditLogging,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         timezone: timezone,
         defaultCurrency: defaultCurrency,
         opdOpeningTime: opdOpeningTime,
         opdClosingTime: opdClosingTime,
         appointmentSlotDurationMinutes: appointmentSlotDurationMinutes,
         autoReleaseExpiredBeds: autoReleaseExpiredBeds,
         isEmergencyActive: isEmergencyActive,
         emergencyHotline: emergencyHotline,
         traumaLevel: traumaLevel,
         ambulanceCount: ambulanceCount,
         isHospitalDiscoverable: isHospitalDiscoverable,
         showFacilitiesToPatients: showFacilitiesToPatients,
         showDoctorSchedulesToPatients: showDoctorSchedulesToPatients,
         showBedAvailabilityToPatients: showBedAvailabilityToPatients,
         showRatingsAndReviews: showRatingsAndReviews,
         sessionTimeoutMinutes: sessionTimeoutMinutes,
         enforceMfaForAdmin: enforceMfaForAdmin,
         enableAuditLogging: enableAuditLogging,
       );

  /// Returns a shallow copy of this [HospitalSettingsRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalSettingsRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? timezone,
    String? defaultCurrency,
    String? opdOpeningTime,
    String? opdClosingTime,
    int? appointmentSlotDurationMinutes,
    bool? autoReleaseExpiredBeds,
    bool? isEmergencyActive,
    String? emergencyHotline,
    String? traumaLevel,
    int? ambulanceCount,
    bool? isHospitalDiscoverable,
    bool? showFacilitiesToPatients,
    bool? showDoctorSchedulesToPatients,
    bool? showBedAvailabilityToPatients,
    bool? showRatingsAndReviews,
    int? sessionTimeoutMinutes,
    bool? enforceMfaForAdmin,
    bool? enableAuditLogging,
  }) {
    return HospitalSettingsRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      timezone: timezone ?? this.timezone,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      opdOpeningTime: opdOpeningTime ?? this.opdOpeningTime,
      opdClosingTime: opdClosingTime ?? this.opdClosingTime,
      appointmentSlotDurationMinutes:
          appointmentSlotDurationMinutes ?? this.appointmentSlotDurationMinutes,
      autoReleaseExpiredBeds:
          autoReleaseExpiredBeds ?? this.autoReleaseExpiredBeds,
      isEmergencyActive: isEmergencyActive ?? this.isEmergencyActive,
      emergencyHotline: emergencyHotline ?? this.emergencyHotline,
      traumaLevel: traumaLevel ?? this.traumaLevel,
      ambulanceCount: ambulanceCount ?? this.ambulanceCount,
      isHospitalDiscoverable:
          isHospitalDiscoverable ?? this.isHospitalDiscoverable,
      showFacilitiesToPatients:
          showFacilitiesToPatients ?? this.showFacilitiesToPatients,
      showDoctorSchedulesToPatients:
          showDoctorSchedulesToPatients ?? this.showDoctorSchedulesToPatients,
      showBedAvailabilityToPatients:
          showBedAvailabilityToPatients ?? this.showBedAvailabilityToPatients,
      showRatingsAndReviews:
          showRatingsAndReviews ?? this.showRatingsAndReviews,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      enforceMfaForAdmin: enforceMfaForAdmin ?? this.enforceMfaForAdmin,
      enableAuditLogging: enableAuditLogging ?? this.enableAuditLogging,
    );
  }
}
