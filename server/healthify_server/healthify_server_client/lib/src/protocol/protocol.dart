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
import 'greetings/greeting.dart' as _i2;
import 'hospital/hospital_audit_event.dart' as _i3;
import 'hospital/hospital_info.dart' as _i4;
import 'hospital/hospital_membership.dart' as _i5;
import 'hospital/hospital_operational_record.dart' as _i6;
import 'hospital/hospital_profile.dart' as _i7;
import 'hospital/hospital_settings.dart' as _i8;
import 'hospital/hospital_user_access.dart' as _i9;
import 'hospital/verification_document.dart' as _i10;
import 'package:healthify_server_client/src/protocol/hospital/hospital_operational_record.dart'
    as _i11;
import 'package:healthify_server_client/src/protocol/hospital/hospital_audit_event.dart'
    as _i12;
import 'package:healthify_server_client/src/protocol/hospital/verification_document.dart'
    as _i13;
import 'package:healthify_server_client/src/protocol/hospital/hospital_profile.dart'
    as _i14;
import 'package:healthify_server_client/src/protocol/hospital/hospital_user_access.dart'
    as _i15;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i16;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i17;
export 'greetings/greeting.dart';
export 'hospital/hospital_audit_event.dart';
export 'hospital/hospital_info.dart';
export 'hospital/hospital_membership.dart';
export 'hospital/hospital_operational_record.dart';
export 'hospital/hospital_profile.dart';
export 'hospital/hospital_settings.dart';
export 'hospital/hospital_user_access.dart';
export 'hospital/verification_document.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Greeting) {
      return _i2.Greeting.fromJson(data) as T;
    }
    if (t == _i3.HospitalAuditEvent) {
      return _i3.HospitalAuditEvent.fromJson(data) as T;
    }
    if (t == _i4.HospitalInfoRecord) {
      return _i4.HospitalInfoRecord.fromJson(data) as T;
    }
    if (t == _i5.HospitalMembershipRecord) {
      return _i5.HospitalMembershipRecord.fromJson(data) as T;
    }
    if (t == _i6.HospitalOperationalRecord) {
      return _i6.HospitalOperationalRecord.fromJson(data) as T;
    }
    if (t == _i7.HospitalProfileRecord) {
      return _i7.HospitalProfileRecord.fromJson(data) as T;
    }
    if (t == _i8.HospitalSettingsRecord) {
      return _i8.HospitalSettingsRecord.fromJson(data) as T;
    }
    if (t == _i9.HospitalUserAccessRecord) {
      return _i9.HospitalUserAccessRecord.fromJson(data) as T;
    }
    if (t == _i10.VerificationDocumentRecord) {
      return _i10.VerificationDocumentRecord.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Greeting?>()) {
      return (data != null ? _i2.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.HospitalAuditEvent?>()) {
      return (data != null ? _i3.HospitalAuditEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.HospitalInfoRecord?>()) {
      return (data != null ? _i4.HospitalInfoRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.HospitalMembershipRecord?>()) {
      return (data != null ? _i5.HospitalMembershipRecord.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.HospitalOperationalRecord?>()) {
      return (data != null
              ? _i6.HospitalOperationalRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i7.HospitalProfileRecord?>()) {
      return (data != null ? _i7.HospitalProfileRecord.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.HospitalSettingsRecord?>()) {
      return (data != null ? _i8.HospitalSettingsRecord.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.HospitalUserAccessRecord?>()) {
      return (data != null ? _i9.HospitalUserAccessRecord.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.VerificationDocumentRecord?>()) {
      return (data != null
              ? _i10.VerificationDocumentRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == List<_i11.HospitalOperationalRecord>) {
      return (data as List)
              .map((e) => deserialize<_i11.HospitalOperationalRecord>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i12.HospitalAuditEvent>) {
      return (data as List)
              .map((e) => deserialize<_i12.HospitalAuditEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_i13.VerificationDocumentRecord>) {
      return (data as List)
              .map((e) => deserialize<_i13.VerificationDocumentRecord>(e))
              .toList()
          as T;
    }
    if (t == List<_i14.HospitalProfileRecord>) {
      return (data as List)
              .map((e) => deserialize<_i14.HospitalProfileRecord>(e))
              .toList()
          as T;
    }
    if (t == List<_i15.HospitalUserAccessRecord>) {
      return (data as List)
              .map((e) => deserialize<_i15.HospitalUserAccessRecord>(e))
              .toList()
          as T;
    }
    try {
      return _i16.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i17.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Greeting => 'Greeting',
      _i3.HospitalAuditEvent => 'HospitalAuditEvent',
      _i4.HospitalInfoRecord => 'HospitalInfoRecord',
      _i5.HospitalMembershipRecord => 'HospitalMembershipRecord',
      _i6.HospitalOperationalRecord => 'HospitalOperationalRecord',
      _i7.HospitalProfileRecord => 'HospitalProfileRecord',
      _i8.HospitalSettingsRecord => 'HospitalSettingsRecord',
      _i9.HospitalUserAccessRecord => 'HospitalUserAccessRecord',
      _i10.VerificationDocumentRecord => 'VerificationDocumentRecord',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'healthify_server.',
        '',
      );
    }

    switch (data) {
      case _i2.Greeting():
        return 'Greeting';
      case _i3.HospitalAuditEvent():
        return 'HospitalAuditEvent';
      case _i4.HospitalInfoRecord():
        return 'HospitalInfoRecord';
      case _i5.HospitalMembershipRecord():
        return 'HospitalMembershipRecord';
      case _i6.HospitalOperationalRecord():
        return 'HospitalOperationalRecord';
      case _i7.HospitalProfileRecord():
        return 'HospitalProfileRecord';
      case _i8.HospitalSettingsRecord():
        return 'HospitalSettingsRecord';
      case _i9.HospitalUserAccessRecord():
        return 'HospitalUserAccessRecord';
      case _i10.VerificationDocumentRecord():
        return 'VerificationDocumentRecord';
    }
    className = _i16.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i17.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i2.Greeting>(data['data']);
    }
    if (dataClassName == 'HospitalAuditEvent') {
      return deserialize<_i3.HospitalAuditEvent>(data['data']);
    }
    if (dataClassName == 'HospitalInfoRecord') {
      return deserialize<_i4.HospitalInfoRecord>(data['data']);
    }
    if (dataClassName == 'HospitalMembershipRecord') {
      return deserialize<_i5.HospitalMembershipRecord>(data['data']);
    }
    if (dataClassName == 'HospitalOperationalRecord') {
      return deserialize<_i6.HospitalOperationalRecord>(data['data']);
    }
    if (dataClassName == 'HospitalProfileRecord') {
      return deserialize<_i7.HospitalProfileRecord>(data['data']);
    }
    if (dataClassName == 'HospitalSettingsRecord') {
      return deserialize<_i8.HospitalSettingsRecord>(data['data']);
    }
    if (dataClassName == 'HospitalUserAccessRecord') {
      return deserialize<_i9.HospitalUserAccessRecord>(data['data']);
    }
    if (dataClassName == 'VerificationDocumentRecord') {
      return deserialize<_i10.VerificationDocumentRecord>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i16.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i17.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i16.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i17.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
