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

abstract class HospitalProfileRecord implements _i1.SerializableModel {
  HospitalProfileRecord._({
    this.id,
    required this.hospitalKey,
    required this.name,
    required this.legalName,
    required this.displayName,
    required this.hospitalType,
    required this.establishmentDate,
    required this.registrationLicenseId,
    required this.taxId,
    required this.accreditationInfo,
    required this.email,
    required this.emergencyHelpline,
    required this.receptionPhone,
    required this.website,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.totalBeds,
    required this.icuBeds,
    required this.operatingTheatres,
    required this.emergencyCapacity,
    required this.has247Emergency,
    required this.traumaLevel,
    required this.hasAmbulance,
    required this.opdTimings,
    required this.operatingStatus,
    required this.verificationStatus,
    this.submittedDate,
    this.verifiedDate,
    required this.verificationNotes,
  });

  factory HospitalProfileRecord({
    int? id,
    required String hospitalKey,
    required String name,
    required String legalName,
    required String displayName,
    required String hospitalType,
    required String establishmentDate,
    required String registrationLicenseId,
    required String taxId,
    required String accreditationInfo,
    required String email,
    required String emergencyHelpline,
    required String receptionPhone,
    required String website,
    required String address,
    required String city,
    required String state,
    required String country,
    required double latitude,
    required double longitude,
    required int totalBeds,
    required int icuBeds,
    required int operatingTheatres,
    required int emergencyCapacity,
    required bool has247Emergency,
    required String traumaLevel,
    required bool hasAmbulance,
    required String opdTimings,
    required String operatingStatus,
    required String verificationStatus,
    DateTime? submittedDate,
    DateTime? verifiedDate,
    required String verificationNotes,
  }) = _HospitalProfileRecordImpl;

  factory HospitalProfileRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalProfileRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      name: jsonSerialization['name'] as String,
      legalName: jsonSerialization['legalName'] as String,
      displayName: jsonSerialization['displayName'] as String,
      hospitalType: jsonSerialization['hospitalType'] as String,
      establishmentDate: jsonSerialization['establishmentDate'] as String,
      registrationLicenseId:
          jsonSerialization['registrationLicenseId'] as String,
      taxId: jsonSerialization['taxId'] as String,
      accreditationInfo: jsonSerialization['accreditationInfo'] as String,
      email: jsonSerialization['email'] as String,
      emergencyHelpline: jsonSerialization['emergencyHelpline'] as String,
      receptionPhone: jsonSerialization['receptionPhone'] as String,
      website: jsonSerialization['website'] as String,
      address: jsonSerialization['address'] as String,
      city: jsonSerialization['city'] as String,
      state: jsonSerialization['state'] as String,
      country: jsonSerialization['country'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      totalBeds: jsonSerialization['totalBeds'] as int,
      icuBeds: jsonSerialization['icuBeds'] as int,
      operatingTheatres: jsonSerialization['operatingTheatres'] as int,
      emergencyCapacity: jsonSerialization['emergencyCapacity'] as int,
      has247Emergency: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['has247Emergency'],
      ),
      traumaLevel: jsonSerialization['traumaLevel'] as String,
      hasAmbulance: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['hasAmbulance'],
      ),
      opdTimings: jsonSerialization['opdTimings'] as String,
      operatingStatus: jsonSerialization['operatingStatus'] as String,
      verificationStatus: jsonSerialization['verificationStatus'] as String,
      submittedDate: jsonSerialization['submittedDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['submittedDate'],
            ),
      verifiedDate: jsonSerialization['verifiedDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['verifiedDate'],
            ),
      verificationNotes: jsonSerialization['verificationNotes'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String hospitalKey;

  String name;

  String legalName;

  String displayName;

  String hospitalType;

  String establishmentDate;

  String registrationLicenseId;

  String taxId;

  String accreditationInfo;

  String email;

  String emergencyHelpline;

  String receptionPhone;

  String website;

  String address;

  String city;

  String state;

  String country;

  double latitude;

  double longitude;

  int totalBeds;

  int icuBeds;

  int operatingTheatres;

  int emergencyCapacity;

  bool has247Emergency;

  String traumaLevel;

  bool hasAmbulance;

  String opdTimings;

  String operatingStatus;

  String verificationStatus;

  DateTime? submittedDate;

  DateTime? verifiedDate;

  String verificationNotes;

  /// Returns a shallow copy of this [HospitalProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalProfileRecord copyWith({
    int? id,
    String? hospitalKey,
    String? name,
    String? legalName,
    String? displayName,
    String? hospitalType,
    String? establishmentDate,
    String? registrationLicenseId,
    String? taxId,
    String? accreditationInfo,
    String? email,
    String? emergencyHelpline,
    String? receptionPhone,
    String? website,
    String? address,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    int? totalBeds,
    int? icuBeds,
    int? operatingTheatres,
    int? emergencyCapacity,
    bool? has247Emergency,
    String? traumaLevel,
    bool? hasAmbulance,
    String? opdTimings,
    String? operatingStatus,
    String? verificationStatus,
    DateTime? submittedDate,
    DateTime? verifiedDate,
    String? verificationNotes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalProfileRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'name': name,
      'legalName': legalName,
      'displayName': displayName,
      'hospitalType': hospitalType,
      'establishmentDate': establishmentDate,
      'registrationLicenseId': registrationLicenseId,
      'taxId': taxId,
      'accreditationInfo': accreditationInfo,
      'email': email,
      'emergencyHelpline': emergencyHelpline,
      'receptionPhone': receptionPhone,
      'website': website,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'totalBeds': totalBeds,
      'icuBeds': icuBeds,
      'operatingTheatres': operatingTheatres,
      'emergencyCapacity': emergencyCapacity,
      'has247Emergency': has247Emergency,
      'traumaLevel': traumaLevel,
      'hasAmbulance': hasAmbulance,
      'opdTimings': opdTimings,
      'operatingStatus': operatingStatus,
      'verificationStatus': verificationStatus,
      if (submittedDate != null) 'submittedDate': submittedDate?.toJson(),
      if (verifiedDate != null) 'verifiedDate': verifiedDate?.toJson(),
      'verificationNotes': verificationNotes,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalProfileRecordImpl extends HospitalProfileRecord {
  _HospitalProfileRecordImpl({
    int? id,
    required String hospitalKey,
    required String name,
    required String legalName,
    required String displayName,
    required String hospitalType,
    required String establishmentDate,
    required String registrationLicenseId,
    required String taxId,
    required String accreditationInfo,
    required String email,
    required String emergencyHelpline,
    required String receptionPhone,
    required String website,
    required String address,
    required String city,
    required String state,
    required String country,
    required double latitude,
    required double longitude,
    required int totalBeds,
    required int icuBeds,
    required int operatingTheatres,
    required int emergencyCapacity,
    required bool has247Emergency,
    required String traumaLevel,
    required bool hasAmbulance,
    required String opdTimings,
    required String operatingStatus,
    required String verificationStatus,
    DateTime? submittedDate,
    DateTime? verifiedDate,
    required String verificationNotes,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         name: name,
         legalName: legalName,
         displayName: displayName,
         hospitalType: hospitalType,
         establishmentDate: establishmentDate,
         registrationLicenseId: registrationLicenseId,
         taxId: taxId,
         accreditationInfo: accreditationInfo,
         email: email,
         emergencyHelpline: emergencyHelpline,
         receptionPhone: receptionPhone,
         website: website,
         address: address,
         city: city,
         state: state,
         country: country,
         latitude: latitude,
         longitude: longitude,
         totalBeds: totalBeds,
         icuBeds: icuBeds,
         operatingTheatres: operatingTheatres,
         emergencyCapacity: emergencyCapacity,
         has247Emergency: has247Emergency,
         traumaLevel: traumaLevel,
         hasAmbulance: hasAmbulance,
         opdTimings: opdTimings,
         operatingStatus: operatingStatus,
         verificationStatus: verificationStatus,
         submittedDate: submittedDate,
         verifiedDate: verifiedDate,
         verificationNotes: verificationNotes,
       );

  /// Returns a shallow copy of this [HospitalProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalProfileRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? name,
    String? legalName,
    String? displayName,
    String? hospitalType,
    String? establishmentDate,
    String? registrationLicenseId,
    String? taxId,
    String? accreditationInfo,
    String? email,
    String? emergencyHelpline,
    String? receptionPhone,
    String? website,
    String? address,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    int? totalBeds,
    int? icuBeds,
    int? operatingTheatres,
    int? emergencyCapacity,
    bool? has247Emergency,
    String? traumaLevel,
    bool? hasAmbulance,
    String? opdTimings,
    String? operatingStatus,
    String? verificationStatus,
    Object? submittedDate = _Undefined,
    Object? verifiedDate = _Undefined,
    String? verificationNotes,
  }) {
    return HospitalProfileRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      name: name ?? this.name,
      legalName: legalName ?? this.legalName,
      displayName: displayName ?? this.displayName,
      hospitalType: hospitalType ?? this.hospitalType,
      establishmentDate: establishmentDate ?? this.establishmentDate,
      registrationLicenseId:
          registrationLicenseId ?? this.registrationLicenseId,
      taxId: taxId ?? this.taxId,
      accreditationInfo: accreditationInfo ?? this.accreditationInfo,
      email: email ?? this.email,
      emergencyHelpline: emergencyHelpline ?? this.emergencyHelpline,
      receptionPhone: receptionPhone ?? this.receptionPhone,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      totalBeds: totalBeds ?? this.totalBeds,
      icuBeds: icuBeds ?? this.icuBeds,
      operatingTheatres: operatingTheatres ?? this.operatingTheatres,
      emergencyCapacity: emergencyCapacity ?? this.emergencyCapacity,
      has247Emergency: has247Emergency ?? this.has247Emergency,
      traumaLevel: traumaLevel ?? this.traumaLevel,
      hasAmbulance: hasAmbulance ?? this.hasAmbulance,
      opdTimings: opdTimings ?? this.opdTimings,
      operatingStatus: operatingStatus ?? this.operatingStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      submittedDate: submittedDate is DateTime?
          ? submittedDate
          : this.submittedDate,
      verifiedDate: verifiedDate is DateTime?
          ? verifiedDate
          : this.verifiedDate,
      verificationNotes: verificationNotes ?? this.verificationNotes,
    );
  }
}
