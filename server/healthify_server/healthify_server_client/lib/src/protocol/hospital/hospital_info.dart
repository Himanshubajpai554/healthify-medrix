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

abstract class HospitalInfoRecord implements _i1.SerializableModel {
  HospitalInfoRecord._({
    this.id,
    required this.hospitalKey,
    required this.name,
    required this.code,
    required this.tagline,
    required this.address,
    required this.phone,
    required this.email,
    required this.emergencyHotline,
    required this.totalBedCapacity,
    required this.icuCapacity,
    required this.activeDoctorCount,
    required this.totalStaffCount,
  });

  factory HospitalInfoRecord({
    int? id,
    required String hospitalKey,
    required String name,
    required String code,
    required String tagline,
    required String address,
    required String phone,
    required String email,
    required String emergencyHotline,
    required int totalBedCapacity,
    required int icuCapacity,
    required int activeDoctorCount,
    required int totalStaffCount,
  }) = _HospitalInfoRecordImpl;

  factory HospitalInfoRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return HospitalInfoRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      name: jsonSerialization['name'] as String,
      code: jsonSerialization['code'] as String,
      tagline: jsonSerialization['tagline'] as String,
      address: jsonSerialization['address'] as String,
      phone: jsonSerialization['phone'] as String,
      email: jsonSerialization['email'] as String,
      emergencyHotline: jsonSerialization['emergencyHotline'] as String,
      totalBedCapacity: jsonSerialization['totalBedCapacity'] as int,
      icuCapacity: jsonSerialization['icuCapacity'] as int,
      activeDoctorCount: jsonSerialization['activeDoctorCount'] as int,
      totalStaffCount: jsonSerialization['totalStaffCount'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String hospitalKey;

  String name;

  String code;

  String tagline;

  String address;

  String phone;

  String email;

  String emergencyHotline;

  int totalBedCapacity;

  int icuCapacity;

  int activeDoctorCount;

  int totalStaffCount;

  /// Returns a shallow copy of this [HospitalInfoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalInfoRecord copyWith({
    int? id,
    String? hospitalKey,
    String? name,
    String? code,
    String? tagline,
    String? address,
    String? phone,
    String? email,
    String? emergencyHotline,
    int? totalBedCapacity,
    int? icuCapacity,
    int? activeDoctorCount,
    int? totalStaffCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalInfoRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'name': name,
      'code': code,
      'tagline': tagline,
      'address': address,
      'phone': phone,
      'email': email,
      'emergencyHotline': emergencyHotline,
      'totalBedCapacity': totalBedCapacity,
      'icuCapacity': icuCapacity,
      'activeDoctorCount': activeDoctorCount,
      'totalStaffCount': totalStaffCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalInfoRecordImpl extends HospitalInfoRecord {
  _HospitalInfoRecordImpl({
    int? id,
    required String hospitalKey,
    required String name,
    required String code,
    required String tagline,
    required String address,
    required String phone,
    required String email,
    required String emergencyHotline,
    required int totalBedCapacity,
    required int icuCapacity,
    required int activeDoctorCount,
    required int totalStaffCount,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         name: name,
         code: code,
         tagline: tagline,
         address: address,
         phone: phone,
         email: email,
         emergencyHotline: emergencyHotline,
         totalBedCapacity: totalBedCapacity,
         icuCapacity: icuCapacity,
         activeDoctorCount: activeDoctorCount,
         totalStaffCount: totalStaffCount,
       );

  /// Returns a shallow copy of this [HospitalInfoRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalInfoRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? name,
    String? code,
    String? tagline,
    String? address,
    String? phone,
    String? email,
    String? emergencyHotline,
    int? totalBedCapacity,
    int? icuCapacity,
    int? activeDoctorCount,
    int? totalStaffCount,
  }) {
    return HospitalInfoRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      name: name ?? this.name,
      code: code ?? this.code,
      tagline: tagline ?? this.tagline,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emergencyHotline: emergencyHotline ?? this.emergencyHotline,
      totalBedCapacity: totalBedCapacity ?? this.totalBedCapacity,
      icuCapacity: icuCapacity ?? this.icuCapacity,
      activeDoctorCount: activeDoctorCount ?? this.activeDoctorCount,
      totalStaffCount: totalStaffCount ?? this.totalStaffCount,
    );
  }
}
