import 'dart:convert';
import 'dart:typed_data';

import 'package:healthify_server_client/healthify_server_client.dart';

/// User-owned patient portal records. The server derives the account partition
/// from the authenticated session; a patient ID supplied by the app is never
/// used as an authorization boundary.
class ServerpodPatientPortalRepository {
  ServerpodPatientPortalRepository(this.client);

  final Client client;

  Future<List<Map<String, dynamic>>> list(String collection) async {
    final rows = await client.hospital.listMyPatientRecords(
      collection,
      limit: 500,
      offset: 0,
    );
    return rows.map(_decode).toList(growable: false);
  }

  Future<Map<String, dynamic>?> get(String collection, String id) async {
    final row = await client.hospital.getMyPatientRecord(collection, id);
    return row == null ? null : _decode(row);
  }

  Future<Map<String, dynamic>> save(
    String collection,
    String id,
    Map<String, dynamic> value,
  ) async {
    if (id.trim().isEmpty || id.length > 160) {
      throw ArgumentError.value(id, 'id', 'Must be 1–160 characters.');
    }
    final saved = await client.hospital.saveMyPatientRecord(
      collection,
      id,
      jsonEncode({...value, 'id': id}),
    );
    return _decode(saved);
  }

  Future<bool> delete(String collection, String id) =>
      client.hospital.deleteMyPatientRecord(collection, id);

  Future<String> requestHospitalAccountLink({
    required String hospitalKey,
    required String patientId,
  }) =>
      client.hospital.requestHospitalPatientAccountLink(hospitalKey, patientId);

  Future<List<Map<String, dynamic>>> listHospitalAccountLinks() async =>
      (jsonDecode(await client.hospital.listMyHospitalPatientAccountLinks())
              as List)
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false);

  Future<List<Map<String, dynamic>>> listHospitalAccountLinkRequests() async =>
      (jsonDecode(
                await client.hospital
                    .listMyHospitalPatientAccountLinkRequests(),
              )
              as List)
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList(growable: false);

  Future<bool> revokeHospitalAccountLink({
    required String hospitalKey,
    required String patientId,
  }) => client.hospital.revokeMyHospitalPatientAccountLink(
    hospitalKey,
    patientId,
  );

  Future<({Uint8List bytes, String fileName})> downloadSharedReport(
    String reportId,
  ) async {
    final metadata = await get('patientReports', reportId);
    if (metadata == null ||
        metadata['_owner'] == null ||
        metadata['hasAttachedFile'] != true) {
      throw StateError('This report has no downloadable file.');
    }
    final bytes = await client.hospital.getMySharedReportFileBytes(reportId);
    final name = '${metadata['title'] ?? 'medical-report'}'.replaceAll(
      RegExp(r'[^A-Za-z0-9._-]+'),
      '_',
    );
    final extension = '${metadata['fileFormat'] ?? 'pdf'}'.toLowerCase();
    return (
      bytes: bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      fileName: '$name.$extension',
    );
  }

  /// Uploads the actual file bytes for an already-saved patientReports record.
  ///
  /// The caller must call [save] with `isExternalUploaded: true` first to
  /// create the metadata row. Then pass [recordKey], the picked [fileName],
  /// the detected [mimeType], and the file [bytes] here. The server updates
  /// the patientReports record with a `fileReference` block on success and
  /// returns the file-reference JSON.
  Future<String> uploadReportFile({
    required String recordKey,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final byteData = ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.length);
    final dynamic hospital = client.hospital;
    final result = await hospital.uploadPatientReportFile(
      recordKey,
      fileName,
      mimeType,
      byteData,
    );
    return '$result';
  }

  /// Returns the raw bytes for a report the authenticated patient uploaded.
  Future<({Uint8List bytes, String fileName})> downloadOwnReportFile(
    String recordKey,
  ) async {
    final metadata = await get('patientReports', recordKey);
    if (metadata == null || metadata['hasAttachedFile'] != true) {
      throw StateError('This report does not have an attached file.');
    }
    final dynamic hospital = client.hospital;
    final ByteData bd = await hospital.getPatientReportFileBytes(recordKey) as ByteData;
    final rawBytes = bd.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes);
    final ref = metadata['fileReference'];
    String name = recordKey;
    if (ref is Map) {
      name = '${ref['fileName'] ?? recordKey}';
    }
    return (bytes: rawBytes, fileName: name);
  }

  Map<String, dynamic> _decode(HospitalOperationalRecord row) => {
    ...Map<String, dynamic>.from(jsonDecode(row.payload) as Map),
    '_key': row.recordKey,
    '_createdAt': row.createdAt.toIso8601String(),
    '_updatedAt': row.updatedAt.toIso8601String(),
  };
}
