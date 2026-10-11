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

abstract class HospitalUserAccessRecord implements _i1.SerializableModel {
  HospitalUserAccessRecord._({
    this.id,
    required this.hospitalKey,
    required this.userKey,
    required this.userName,
    required this.email,
    required this.role,
    required this.department,
    required this.isActive,
    required this.lastActive,
  });

  factory HospitalUserAccessRecord({
    int? id,
    required String hospitalKey,
    required String userKey,
    required String userName,
    required String email,
    required String role,
    required String department,
    required bool isActive,
    required DateTime lastActive,
  }) = _HospitalUserAccessRecordImpl;

  factory HospitalUserAccessRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalUserAccessRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      userKey: jsonSerialization['userKey'] as String,
      userName: jsonSerialization['userName'] as String,
      email: jsonSerialization['email'] as String,
      role: jsonSerialization['role'] as String,
      department: jsonSerialization['department'] as String,
      isActive: _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      lastActive: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastActive'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String hospitalKey;

  String userKey;

  String userName;

  String email;

  String role;

  String department;

  bool isActive;

  DateTime lastActive;

  /// Returns a shallow copy of this [HospitalUserAccessRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalUserAccessRecord copyWith({
    int? id,
    String? hospitalKey,
    String? userKey,
    String? userName,
    String? email,
    String? role,
    String? department,
    bool? isActive,
    DateTime? lastActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalUserAccessRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'userKey': userKey,
      'userName': userName,
      'email': email,
      'role': role,
      'department': department,
      'isActive': isActive,
      'lastActive': lastActive.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalUserAccessRecordImpl extends HospitalUserAccessRecord {
  _HospitalUserAccessRecordImpl({
    int? id,
    required String hospitalKey,
    required String userKey,
    required String userName,
    required String email,
    required String role,
    required String department,
    required bool isActive,
    required DateTime lastActive,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         userKey: userKey,
         userName: userName,
         email: email,
         role: role,
         department: department,
         isActive: isActive,
         lastActive: lastActive,
       );

  /// Returns a shallow copy of this [HospitalUserAccessRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalUserAccessRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? userKey,
    String? userName,
    String? email,
    String? role,
    String? department,
    bool? isActive,
    DateTime? lastActive,
  }) {
    return HospitalUserAccessRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      userKey: userKey ?? this.userKey,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
