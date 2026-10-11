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

abstract class HospitalAuditEvent implements _i1.SerializableModel {
  HospitalAuditEvent._({
    this.id,
    required this.hospitalKey,
    required this.actorUserIdentifier,
    required this.action,
    required this.collection,
    required this.recordKey,
    required this.occurredAt,
    required this.details,
  });

  factory HospitalAuditEvent({
    int? id,
    required String hospitalKey,
    required String actorUserIdentifier,
    required String action,
    required String collection,
    required String recordKey,
    required DateTime occurredAt,
    required String details,
  }) = _HospitalAuditEventImpl;

  factory HospitalAuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return HospitalAuditEvent(
      id: jsonSerialization['id'] as int?,
      hospitalKey: jsonSerialization['hospitalKey'] as String,
      actorUserIdentifier: jsonSerialization['actorUserIdentifier'] as String,
      action: jsonSerialization['action'] as String,
      collection: jsonSerialization['collection'] as String,
      recordKey: jsonSerialization['recordKey'] as String,
      occurredAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
      details: jsonSerialization['details'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String hospitalKey;

  String actorUserIdentifier;

  String action;

  String collection;

  String recordKey;

  DateTime occurredAt;

  String details;

  /// Returns a shallow copy of this [HospitalAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HospitalAuditEvent copyWith({
    int? id,
    String? hospitalKey,
    String? actorUserIdentifier,
    String? action,
    String? collection,
    String? recordKey,
    DateTime? occurredAt,
    String? details,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HospitalAuditEvent',
      if (id != null) 'id': id,
      'hospitalKey': hospitalKey,
      'actorUserIdentifier': actorUserIdentifier,
      'action': action,
      'collection': collection,
      'recordKey': recordKey,
      'occurredAt': occurredAt.toJson(),
      'details': details,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HospitalAuditEventImpl extends HospitalAuditEvent {
  _HospitalAuditEventImpl({
    int? id,
    required String hospitalKey,
    required String actorUserIdentifier,
    required String action,
    required String collection,
    required String recordKey,
    required DateTime occurredAt,
    required String details,
  }) : super._(
         id: id,
         hospitalKey: hospitalKey,
         actorUserIdentifier: actorUserIdentifier,
         action: action,
         collection: collection,
         recordKey: recordKey,
         occurredAt: occurredAt,
         details: details,
       );

  /// Returns a shallow copy of this [HospitalAuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HospitalAuditEvent copyWith({
    Object? id = _Undefined,
    String? hospitalKey,
    String? actorUserIdentifier,
    String? action,
    String? collection,
    String? recordKey,
    DateTime? occurredAt,
    String? details,
  }) {
    return HospitalAuditEvent(
      id: id is int? ? id : this.id,
      hospitalKey: hospitalKey ?? this.hospitalKey,
      actorUserIdentifier: actorUserIdentifier ?? this.actorUserIdentifier,
      action: action ?? this.action,
      collection: collection ?? this.collection,
      recordKey: recordKey ?? this.recordKey,
      occurredAt: occurredAt ?? this.occurredAt,
      details: details ?? this.details,
    );
  }
}
