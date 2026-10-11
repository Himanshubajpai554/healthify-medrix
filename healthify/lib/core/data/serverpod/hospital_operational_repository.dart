import 'dart:convert';

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
