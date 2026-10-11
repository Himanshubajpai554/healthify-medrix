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

abstract class HospitalMembershipRecord implements _i1.SerializableModel {
  HospitalMembershipRecord._({
    this.id,
    required this.hospitalKey,
    required this.userIdentifier,
    required this.role,
    required this.isActive,
  });

  factory HospitalMembershipRecord({
    int? id,
    required String hospitalKey,
    required String userIdentifier,
    required String role,
    required bool isActive,
  }) = _HospitalMembershipRecordImpl;

  factory HospitalMembershipRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalMembershipRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      userIdentifier: jsonSerialization['userIdentifier'] as String,
      role: jsonSerialization['role'] as String,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String hospitalKey;

  String userIdentifier;

  String role;

  bool isActive;

  /// Returns a shallow copy of this [HospitalMembershipRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalMembershipRecord copyWith({
    int? id,
    String? hospitalKey,
    String? userIdentifier,
    String? role,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalMembershipRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'userIdentifier': userIdentifier,
      'role': role,
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalMembershipRecordImpl extends HospitalMembershipRecord {
  _HospitalMembershipRecordImpl({
    int? id,
    required String hospitalKey,
    required String userIdentifier,
    required String role,
    required bool isActive,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         userIdentifier: userIdentifier,
         role: role,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [HospitalMembershipRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalMembershipRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? userIdentifier,
    String? role,
    bool? isActive,
  }) {
    return HospitalMembershipRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      userIdentifier: userIdentifier ?? this.userIdentifier,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
