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

abstract class HospitalOperationalRecord implements _i1.SerializableModel {
  HospitalOperationalRecord._({
    this.id,
    required this.hospitalKey,
    required this.collection,
    required this.recordKey,
    required this.payload,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HospitalOperationalRecord({
    int? id,
    required String hospitalKey,
    required String collection,
    required String recordKey,
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _HospitalOperationalRecordImpl;

  factory HospitalOperationalRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HospitalOperationalRecord(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      collection: jsonSerialization['collection'] as String,
      recordKey: jsonSerialization['recordKey'] as String,
      payload: jsonSerialization['payload'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String hospitalKey;

  String collection;

  String recordKey;

  String payload;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [HospitalOperationalRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalOperationalRecord copyWith({
    int? id,
    String? hospitalKey,
    String? collection,
    String? recordKey,
    String? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalOperationalRecord',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'collection': collection,
      'recordKey': recordKey,
      'payload': payload,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalOperationalRecordImpl extends HospitalOperationalRecord {
  _HospitalOperationalRecordImpl({
    int? id,
    required String hospitalKey,
    required String collection,
    required String recordKey,
    required String payload,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         collection: collection,
         recordKey: recordKey,
         payload: payload,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [HospitalOperationalRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalOperationalRecord copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? collection,
    String? recordKey,
    String? payload,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HospitalOperationalRecord(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      collection: collection ?? this.collection,
      recordKey: recordKey ?? this.recordKey,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
