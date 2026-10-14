import 'dart:convert';
import 'dart:typed_data';

import 'package:healthify_server_client/healthify_server_client.dart';

/// Tenant-scoped data API for hospital modules backed by Serverpod records.
/// Payloads remain JSON so existing domain/UI models do not need changes.
class HospitalOperationalRepository {
  HospitalOperationalRepository(this.client, {this.hospitalKey = ''});

  final Client client;
  String hospitalKey;

  Future<List<Map<String, dynamic>>> list(
    String collection, {
    int limit = 100,
    int offset = 0,
  }) async {
    _requireHospital();
    final rows = await client.hospital.listOperationalRecords(
      hospitalKey,
      collection,
      limit: limit,
      offset: offset,
    );
    return rows.map(_decode).toList(growable: false);
  }

  Future<Map<String, dynamic>?> get(String collection, String key) async {
    _requireHospital();
    final row = await client.hospital.getOperationalRecord(
      hospitalKey,
      collection,
      key,
    );
    return row == null ? null : _decode(row);
  }

  Future<Map<String, dynamic>> save(
    String collection,
    String key,
    Map<String, dynamic> value,
  ) async {
    _requireHospital();
    final row = await client.hospital.saveOperationalRecord(
      hospitalKey,
      collection,
      key,
      jsonEncode(value),
    );
    return _decode(row);
  }

  Future<Map<String, dynamic>> uploadDoctorReportFile(
    String reportId,
    String fileName,
    String mimeType,
    ByteData bytes,
  ) async {
    _requireHospital();
    final json = await client.hospital.uploadDoctorReportFile(
      hospitalKey, reportId, fileName, mimeType, bytes,
    );
    return Map<String, dynamic>.from(jsonDecode(json) as Map);
  }

  Future<ByteData> getDoctorReportFileBytes(String reportId) {
    _requireHospital();
    return client.hospital.getDoctorReportFileBytes(hospitalKey, reportId);
  }

  Future<Map<String, dynamic>> createAdmission(
    String patientId,
    String recordKey,
    Map<String, dynamic> value,
  ) async {
    _requireHospital();
    final row = await client.hospital.createAdmission(
      hospitalKey, patientId, recordKey, jsonEncode(value),
    );
    return _decode(row);
  }

  Future<Map<String, dynamic>> createAdmissionBundle({
    required String patientId,
    required String admissionId,
    required Map<String, dynamic> patient,
    required Map<String, dynamic> patientLink,
    required Map<String, dynamic> admission,
  }) async {
    _requireHospital();
    final row = await client.hospital.createAdmission(
      hospitalKey,
      patientId,
      admissionId,
      jsonEncode({'patient': patient, 'patientLink': patientLink, 'admission': admission}),
    );
    return _decode(row);
  }

  Future<Map<String, dynamic>> updateActiveAdmission({
    required String patientId,
    required String admissionId,
    required Map<String, dynamic> value,
  }) async {
    _requireHospital();
    final row = await client.hospital.createAdmission(
      hospitalKey, patientId, admissionId,
      jsonEncode({'operation': 'update', 'admission': value}),
    );
    return _decode(row);
  }

  Future<List<Map<String, dynamic>>> saveMany(
    String collection,
    Map<String, Map<String, dynamic>> values,
  ) => saveBatch({collection: values});

  Future<List<Map<String, dynamic>>> saveBatch(
    Map<String, Map<String, Map<String, dynamic>>> changes,
  ) async {
    _requireHospital();
    final entries = [
      for (final group in changes.entries)
        for (final item in group.value.entries)
          (collection: group.key, key: item.key, value: item.value),
    ];
    if (entries.isEmpty) return const [];
    final rows = await client.hospital.saveOperationalRecords(
      hospitalKey,
      entries.map((entry) => entry.collection).toList(growable: false),
      entries.map((entry) => entry.key).toList(growable: false),
      entries.map((entry) => jsonEncode(entry.value)).toList(growable: false),
    );
    return rows.map(_decode).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> listAccountLinkRequests() async {
    _requireHospital();
    final jsonStr = await client.hospital.listHospitalPatientAccountLinkRequests(hospitalKey);
    final decoded = jsonDecode(jsonStr);
    if (decoded is List) {
      return decoded.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList(growable: false);
    }
    return const [];
  }

  Future<bool> reviewAccountLinkRequest({
    required String requestId,
    required bool approve,
  }) async {
    _requireHospital();
    return client.hospital.reviewHospitalPatientAccountLinkRequest(
      hospitalKey,
      requestId,
      approve,
    );
  }

  Future<bool> delete(String collection, String key) async {
    _requireHospital();
    return client.hospital.deleteOperationalRecord(
      hospitalKey,
      collection,
      key,
    );
  }

  Future<List<Map<String, dynamic>>> auditEvents({
    int limit = 100,
    int offset = 0,
  }) async {
    _requireHospital();
    final rows = await client.hospital.getOperationalAuditEvents(
      hospitalKey,
      limit: limit,
      offset: offset,
    );
    return rows
        .map((row) => {
              'id': row.id.toString(),
              'actorUserIdentifier': row.actorUserIdentifier,
              'action': row.action,
              'collection': row.collection,
              'recordKey': row.recordKey,
              'occurredAt': row.occurredAt.toIso8601String(),
              'details': row.details,
            })
        .toList(growable: false);
  }

  Map<String, dynamic> _decode(HospitalOperationalRecord row) => {
        ...Map<String, dynamic>.from(jsonDecode(row.payload) as Map),
        '_key': row.recordKey,
        '_createdAt': row.createdAt.toIso8601String(),
        '_updatedAt': row.updatedAt.toIso8601String(),
      };

  void _requireHospital() {
    if (hospitalKey.isEmpty) {
      throw StateError('Sign in to a hospital account first.');
    }
  }
}
