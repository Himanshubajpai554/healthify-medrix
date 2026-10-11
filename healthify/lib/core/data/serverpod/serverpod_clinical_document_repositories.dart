import '../../data/mock/mock_report_repository.dart';
import '../../data/mock/mock_prescription_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/prescription_model.dart';
import '../../models/report_model.dart';
import '../../queries/domain_queries.dart';
import 'hospital_operational_repository.dart';

class ServerpodReportRepository extends MockReportRepository {
  ServerpodReportRepository(this.records) : super.fallback();
  final HospitalOperationalRepository records;
  T _enum<T extends Enum>(List<T> values, Object? value, T fallback) => values.where((e) => e.name == value).firstOrNull ?? fallback;
  DateTime _date(Object? value) => value is String ? DateTime.tryParse(value) ?? DateTime.now() : DateTime.now();
  String _id(Map<String, dynamic> row) => '${row['id'] ?? row['_key'] ?? ''}';

  DiagnosticReport _from(Map<String, dynamic> r) {
    final file = r['fileReference'] as Map?;
    return DiagnosticReport(id: _id(r), hospitalId: records.hospitalKey,
      patientId: '${r['patientId'] ?? ''}', hospitalPatientLinkId: r['hospitalPatientLinkId'] as String?,
      appointmentId: r['appointmentId'] as String?, admissionId: r['admissionId'] as String?,
      orderingDoctorId: '${r['orderingDoctorId'] ?? r['doctorId'] ?? ''}',
      fulfillingStaffId: r['fulfillingStaffId'] as String?, departmentId: '${r['departmentId'] ?? ''}',
      reportType: _enum(ReportType.values, r['reportType'], ReportType.other), title: '${r['title'] ?? ''}',
      fileReference: file == null ? null : DocumentReference(id: '${file['id'] ?? ''}', fileName: '${file['fileName'] ?? ''}',
        mimeType: '${file['mimeType'] ?? 'application/octet-stream'}', size: (file['size'] as num?)?.toInt() ?? 0,
        storageKey: '${file['storageKey'] ?? ''}', createdAt: _date(file['createdAt'])),
      uploadedAt: _date(r['uploadedAt']), verifiedAt: r['verifiedAt'] == null ? null : _date(r['verifiedAt']),
      verifiedByDoctorId: r['verifiedByDoctorId'] as String?,
      verificationStatus: _enum(ReportVerificationStatus.values, r['verificationStatus'], ReportVerificationStatus.uploaded),
      isCritical: r['isCritical'] as bool? ?? false, releasedToPatient: r['releasedToPatient'] as bool? ?? false,
      summary: '${r['summary'] ?? ''}', resultData: Map<String, dynamic>.from(r['resultData'] as Map? ?? const {}),
      date: _date(r['date']), reportUrl: r['reportUrl'] as String?,
      status: _enum(ReportStatus.values, r['status'], ReportStatus.pending),
      createdAt: _date(r['createdAt']), updatedAt: _date(r['updatedAt']));
  }

  Map<String, dynamic> _json(DiagnosticReport r) => {'id': r.id, 'patientId': r.patientId,
    'hospitalPatientLinkId': r.hospitalPatientLinkId, 'appointmentId': r.appointmentId, 'admissionId': r.admissionId,
    'orderingDoctorId': r.orderingDoctorId, 'fulfillingStaffId': r.fulfillingStaffId, 'departmentId': r.departmentId,
    'reportType': r.reportType.name, 'title': r.title,
    'fileReference': r.fileReference == null ? null : {'id': r.fileReference!.id, 'fileName': r.fileReference!.fileName,
      'mimeType': r.fileReference!.mimeType, 'size': r.fileReference!.size, 'storageKey': r.fileReference!.storageKey,
      'createdAt': r.fileReference!.createdAt.toIso8601String()},
    'uploadedAt': r.uploadedAt.toIso8601String(), 'verifiedAt': r.verifiedAt?.toIso8601String(),
    'verifiedByDoctorId': r.verifiedByDoctorId, 'verificationStatus': r.verificationStatus.name,
    'isCritical': r.isCritical, 'releasedToPatient': r.releasedToPatient, 'summary': r.summary,
    'resultData': r.resultData, 'date': r.date.toIso8601String(), 'reportUrl': r.reportUrl,
    'status': r.status.name, 'createdAt': r.createdAt.toIso8601String(), 'updatedAt': r.updatedAt.toIso8601String()};

  @override
  Future<List<DiagnosticReport>> getReports({ReportQuery query = const ReportQuery()}) async {
    var rows = await records.list('diagnosticReports', limit: 500);
    if (query.patientId != null) rows = rows.where((r) => r['patientId'] == query.patientId).toList();
    if (query.doctorId != null) rows = rows.where((r) => (r['orderingDoctorId'] ?? r['doctorId']) == query.doctorId).toList();
    if (query.departmentId != null) rows = rows.where((r) => r['departmentId'] == query.departmentId).toList();
    if (query.reportType != null) rows = rows.where((r) => r['reportType'] == query.reportType!.name).toList();
    if (query.verificationStatus != null) rows = rows.where((r) => r['verificationStatus'] == query.verificationStatus!.name).toList();
    if (query.isCritical != null) rows = rows.where((r) => r['isCritical'] == query.isCritical).toList();
    if (query.releasedToPatient != null) rows = rows.where((r) => r['releasedToPatient'] == query.releasedToPatient).toList();
    final q = query.searchQuery?.toLowerCase();
    if (q != null && q.isNotEmpty) rows = rows.where((r) => [r['title'], r['patientId'], r['id'], r['summary']].any((v) => v?.toString().toLowerCase().contains(q) ?? false)).toList();
    final start = query.pagination.offset.clamp(0, rows.length);
    final end = (start + query.pagination.pageSize).clamp(start, rows.length);
    return rows.sublist(start, end).map(_from).toList();
  }

  @override
  Future<DiagnosticReport?> getReportById(String id) async { final r = await records.get('diagnosticReports', id); return r == null ? null : _from(r); }
  @override
  Future<DiagnosticReport> uploadReport(DiagnosticReport report) async { await records.save('diagnosticReports', report.id, _json(report)); return report; }
  @override
  Future<DiagnosticReport> updateReportMetadata(String reportId, Map<String, dynamic> metadata) async {
    final row = await records.get('diagnosticReports', reportId) ?? (throw StateError('Report not found.'));
    row.addAll(metadata); row['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    await records.save('diagnosticReports', reportId, row); return _from(row);
  }
  @override
  Future<DiagnosticReport> verifyReport(String reportId, String doctorId) async => updateReportMetadata(reportId, {'verificationStatus': ReportVerificationStatus.verified.name, 'verifiedByDoctorId': doctorId, 'verifiedAt': DateTime.now().toUtc().toIso8601String(), 'status': ReportStatus.verified.name});
  @override
  Future<DiagnosticReport> rejectReport(String reportId, String doctorId, String reason) async => updateReportMetadata(reportId, {'verificationStatus': ReportVerificationStatus.rejected.name, 'verifiedByDoctorId': doctorId, 'summary': reason});
  @override
  Future<DiagnosticReport> releaseReportToPatient(String reportId) async => updateReportMetadata(reportId, {'verificationStatus': ReportVerificationStatus.released.name, 'releasedToPatient': true});
  @override
  Future<List<DiagnosticReport>> getPatientReports(String patientId, {bool releasedOnly = true}) => getReports(query: ReportQuery(patientId: patientId, releasedToPatient: releasedOnly ? true : null));
  @override
  Future<List<DiagnosticReport>> getCriticalReports() => getReports(query: const ReportQuery(isCritical: true));
  @override
  Future<List<DocumentActivity>> getReportActivity(String reportId) async => (await records.list('documentActivities', limit: 500)).where((r) => r['documentId'] == reportId).map(_activity).toList();
  DocumentActivity _activity(Map<String, dynamic> r) => DocumentActivity(id: _id(r), documentId: '${r['documentId'] ?? ''}', documentType: '${r['documentType'] ?? 'Report'}', actorId: '${r['actorId'] ?? ''}', actorName: '${r['actorName'] ?? ''}', action: _enum(DocumentActivityAction.values, r['action'], DocumentActivityAction.viewed), timestamp: _date(r['timestamp']), notes: r['notes'] as String?);
}

class ServerpodPrescriptionRepository extends MockPrescriptionRepository {
  ServerpodPrescriptionRepository(this.records) : super.fallback();
  final HospitalOperationalRepository records;
  T _enum<T extends Enum>(List<T> values, Object? value, T fallback) => values.where((e) => e.name == value).firstOrNull ?? fallback;
  DateTime _date(Object? value) => value is String ? DateTime.tryParse(value) ?? DateTime.now() : DateTime.now();
  String _id(Map<String, dynamic> row) => '${row['id'] ?? row['_key'] ?? ''}';
  PrescriptionIndex _from(Map<String, dynamic> r) => PrescriptionIndex(id: _id(r), hospitalId: records.hospitalKey,
    patientId: '${r['patientId'] ?? ''}', hospitalPatientLinkId: r['hospitalPatientLinkId'] as String?,
    doctorId: '${r['doctorId'] ?? ''}', appointmentId: r['appointmentId'] as String?, admissionId: r['admissionId'] as String?,
    prescriptionReference: '${r['prescriptionReference'] ?? _id(r)}', signedAt: _date(r['signedAt']),
    status: _enum(PrescriptionStatus.values, r['status'], PrescriptionStatus.signed),
    pharmacyFulfillmentStatus: _enum(PharmacyFulfillmentStatus.values, r['pharmacyFulfillmentStatus'], PharmacyFulfillmentStatus.pending),
    medications: (r['medications'] as List? ?? const []).whereType<Map>().map((m) => PrescriptionItem(
      medicationName: '${m['medicationName'] ?? ''}', dosage: '${m['dosage'] ?? ''}', frequency: '${m['frequency'] ?? ''}',
      durationDays: (m['durationDays'] as num?)?.toInt() ?? 0, instructions: '${m['instructions'] ?? ''}')).toList(),
    clinicalNotes: r['clinicalNotes'] as String?, instructions: '${r['instructions'] ?? ''}', createdAt: _date(r['createdAt']), updatedAt: _date(r['updatedAt']));
  Map<String, dynamic> _json(PrescriptionIndex p) => {'id': p.id, 'patientId': p.patientId,
    'hospitalPatientLinkId': p.hospitalPatientLinkId, 'doctorId': p.doctorId, 'appointmentId': p.appointmentId,
    'admissionId': p.admissionId, 'prescriptionReference': p.prescriptionReference,
    'signedAt': p.signedAt.toIso8601String(), 'status': p.status.name,
    'pharmacyFulfillmentStatus': p.pharmacyFulfillmentStatus.name,
    'medications': p.medications.map((m) => {'medicationName': m.medicationName, 'dosage': m.dosage, 'frequency': m.frequency, 'durationDays': m.durationDays, 'instructions': m.instructions}).toList(),
    'clinicalNotes': p.clinicalNotes, 'instructions': p.instructions, 'createdAt': p.createdAt.toIso8601String(), 'updatedAt': p.updatedAt.toIso8601String()};
  @override
  Future<List<PrescriptionIndex>> getPrescriptions({PrescriptionQuery query = const PrescriptionQuery()}) async {
    var rows = await records.list('prescriptions', limit: 500);
    if (query.patientId != null) rows = rows.where((r) => r['patientId'] == query.patientId).toList();
    if (query.doctorId != null) rows = rows.where((r) => r['doctorId'] == query.doctorId).toList();
    if (query.status != null) rows = rows.where((r) => r['status'] == query.status!.name).toList();
    if (query.fulfillmentStatus != null) rows = rows.where((r) => r['pharmacyFulfillmentStatus'] == query.fulfillmentStatus!.name).toList();
    final q = query.searchQuery?.toLowerCase();
    if (q != null && q.isNotEmpty) rows = rows.where((r) => [r['id'], r['patientId'], r['doctorId'], r['prescriptionReference']].any((v) => v?.toString().toLowerCase().contains(q) ?? false)).toList();
    final start = query.pagination.offset.clamp(0, rows.length); final end = (start + query.pagination.pageSize).clamp(start, rows.length);
    return rows.sublist(start, end).map(_from).toList();
  }
  @override
  Future<PrescriptionIndex?> getPrescriptionById(String id) async { final r = await records.get('prescriptions', id); return r == null ? null : _from(r); }
  @override
  Future<List<PrescriptionIndex>> getPatientPrescriptions(String patientId) => getPrescriptions(query: PrescriptionQuery(patientId: patientId));
  @override
  Future<List<PrescriptionIndex>> getDoctorPrescriptions(String doctorId) => getPrescriptions(query: PrescriptionQuery(doctorId: doctorId));
  @override
  Future<List<DocumentActivity>> getPrescriptionHistory(String id) async => (await records.list('documentActivities', limit: 500)).where((r) => r['documentId'] == id).map((r) => DocumentActivity(id: _id(r), documentId: id, documentType: 'Prescription', actorId: '${r['actorId'] ?? ''}', actorName: '${r['actorName'] ?? ''}', action: _enum(DocumentActivityAction.values, r['action'], DocumentActivityAction.viewed), timestamp: _date(r['timestamp']), notes: r['notes'] as String?)).toList();
  @override
  Future<PharmacyFulfillmentStatus> getFulfillmentStatus(String id) async => (await getPrescriptionById(id))?.pharmacyFulfillmentStatus ?? PharmacyFulfillmentStatus.pending;
  @override
  Future<PrescriptionIndex> createPrescription(PrescriptionIndex p) async { await records.save('prescriptions', p.id, _json(p)); return p; }
  @override
  Future<PrescriptionIndex> updateFulfillmentStatus(String id, PharmacyFulfillmentStatus status) async { final row = await records.get('prescriptions', id) ?? (throw StateError('Prescription not found.')); row['pharmacyFulfillmentStatus'] = status.name; row['updatedAt'] = DateTime.now().toUtc().toIso8601String(); await records.save('prescriptions', id, row); return _from(row); }
  @override
  Future<void> cancelPrescription(String id) async { final row = await records.get('prescriptions', id) ?? (throw StateError('Prescription not found.')); row['status'] = PrescriptionStatus.cancelled.name; await records.save('prescriptions', id, row); }
}
