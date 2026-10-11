import '../repositories/report_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/report_model.dart';
import '../../queries/domain_queries.dart';

class MockReportRepository implements ReportRepository {
  static MockReportRepository Function()? serverpodFactory;
  factory MockReportRepository() => serverpodFactory?.call() ?? MockReportRepository.fallback();
  MockReportRepository.fallback();

  final List<DiagnosticReport> _reports = [
    DiagnosticReport(
      id: 'REP-2026-001',
      hospitalId: 'HOSP-01',
      patientId: 'P101',
      hospitalPatientLinkId: 'LINK-P101',
      appointmentId: 'APT-1001',
      orderingDoctorId: 'DOC1',
      departmentId: 'DEP-LAB-01',
      reportType: ReportType.laboratory,
      title: 'Complete Blood Count (CBC) & Metabolic Panel',
      fileReference: DocumentReference(
        id: 'DOC-REF-001',
        fileName: 'cbc_panel_p101.pdf',
        mimeType: 'application/pdf',
        size: 1048576,
        storageKey: 'reports/2026/cbc_panel_p101.pdf',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
      verifiedAt: DateTime.now().subtract(const Duration(days: 1)),
      verifiedByDoctorId: 'DOC1',
      verificationStatus: ReportVerificationStatus.released,
      isCritical: false,
      releasedToPatient: true,
      summary: 'Normal WBC count. Slight hemoglobin elevation. Electrolytes within target range.',
      resultData: {'wbc': '6.5 K/uL', 'rbc': '4.8 M/uL', 'hemoglobin': '15.2 g/dL', 'platelets': '250 K/uL'},
      date: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    DiagnosticReport(
      id: 'REP-2026-002',
      hospitalId: 'HOSP-01',
      patientId: 'P102',
      hospitalPatientLinkId: 'LINK-P102',
      admissionId: 'ADM-2001',
      orderingDoctorId: 'DOC2',
      departmentId: 'DEP-RAD-01',
      reportType: ReportType.radiology,
      title: 'Chest CT Scan High Resolution',
      fileReference: DocumentReference(
        id: 'DOC-REF-002',
        fileName: 'chest_ct_scan_p102.dicom',
        mimeType: 'application/dicom',
        size: 15728640,
        storageKey: 'reports/2026/chest_ct_scan_p102.dicom',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      uploadedAt: DateTime.now().subtract(const Duration(hours: 18)),
      verifiedAt: DateTime.now().subtract(const Duration(hours: 4)),
      verifiedByDoctorId: 'DOC2',
      verificationStatus: ReportVerificationStatus.verified,
      isCritical: true,
      releasedToPatient: false,
      summary: 'Bilateral lung basilar infiltrates observed with minor pleural effusion.',
      resultData: {'infiltrates': 'Bilateral Basilar', 'effusion': 'Minor Pleural Right Side'},
      date: DateTime.now().subtract(const Duration(hours: 18)),
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    DiagnosticReport(
      id: 'REP-2026-003',
      hospitalId: 'HOSP-01',
      patientId: 'P103',
      orderingDoctorId: 'DOC1',
      departmentId: 'DEP-CARD-01',
      reportType: ReportType.cardiology,
      title: '12-Lead Electrocardiogram (ECG)',
      fileReference: DocumentReference(
        id: 'DOC-REF-003',
        fileName: 'ecg_trace_p103.pdf',
        mimeType: 'application/pdf',
        size: 524288,
        storageKey: 'reports/2026/ecg_trace_p103.pdf',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      uploadedAt: DateTime.now().subtract(const Duration(hours: 5)),
      verificationStatus: ReportVerificationStatus.underReview,
      isCritical: false,
      releasedToPatient: false,
      summary: 'Sinus rhythm with rare PACs. Under specialist review.',
      resultData: {'heartRate': '72 bpm', 'rhythm': 'Normal Sinus', 'qtInterval': '410 ms'},
      date: DateTime.now().subtract(const Duration(hours: 5)),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    DiagnosticReport(
      id: 'REP-2026-004',
      hospitalId: 'HOSP-01',
      patientId: 'P104',
      orderingDoctorId: 'DOC3',
      departmentId: 'DEP-PATH-01',
      reportType: ReportType.pathology,
      title: 'Skin Lesion Biopsy Histopathology',
      fileReference: DocumentReference(
        id: 'DOC-REF-004',
        fileName: 'biopsy_report_p104.pdf',
        mimeType: 'application/pdf',
        size: 2097152,
        storageKey: 'reports/2026/biopsy_report_p104.pdf',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      uploadedAt: DateTime.now().subtract(const Duration(days: 3)),
      verificationStatus: ReportVerificationStatus.uploaded,
      isCritical: false,
      releasedToPatient: false,
      summary: 'Biopsy specimen uploaded awaiting physician assignment.',
      resultData: {'specimenType': 'Dermal Biopsy', 'margins': 'Pending'},
      date: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  final List<DocumentActivity> _activities = [
    DocumentActivity(
      id: 'ACT-001',
      documentId: 'REP-2026-001',
      documentType: 'Report',
      actorId: 'LAB-TECH-01',
      actorName: 'Sarah Jenkins (Lab Tech)',
      action: DocumentActivityAction.uploaded,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Initial lab report upload completed.',
    ),
    DocumentActivity(
      id: 'ACT-002',
      documentId: 'REP-2026-001',
      documentType: 'Report',
      actorId: 'DOC1',
      actorName: 'Dr. Sarah Connor',
      action: DocumentActivityAction.verified,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Clinical verification completed with full sign-off.',
    ),
    DocumentActivity(
      id: 'ACT-003',
      documentId: 'REP-2026-001',
      documentType: 'Report',
      actorId: 'DOC1',
      actorName: 'Dr. Sarah Connor',
      action: DocumentActivityAction.released,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Report released to patient portal view.',
    ),
  ];

  @override
  Future<List<DiagnosticReport>> getReports({ReportQuery query = const ReportQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<DiagnosticReport>.from(_reports);

    if (query.searchQuery != null && query.searchQuery!.isNotEmpty) {
      final q = query.searchQuery!.toLowerCase();
      results = results.where((r) =>
        r.id.toLowerCase().contains(q) ||
        r.title.toLowerCase().contains(q) ||
        r.patientId.toLowerCase().contains(q) ||
        r.orderingDoctorId.toLowerCase().contains(q) ||
        r.departmentId.toLowerCase().contains(q)
      ).toList();
    }

    if (query.patientId != null) {
      results = results.where((r) => r.patientId == query.patientId).toList();
    }

    if (query.doctorId != null) {
      results = results.where((r) => r.orderingDoctorId == query.doctorId).toList();
    }

    if (query.departmentId != null) {
      results = results.where((r) => r.departmentId == query.departmentId).toList();
    }

    if (query.reportType != null) {
      results = results.where((r) => r.reportType == query.reportType).toList();
    }

    if (query.verificationStatus != null) {
      results = results.where((r) => r.verificationStatus == query.verificationStatus).toList();
    }

    if (query.isCritical == true) {
      results = results.where((r) => r.isCritical).toList();
    }

    if (query.releasedToPatient != null) {
      results = results.where((r) => r.releasedToPatient == query.releasedToPatient).toList();
    }

    return results;
  }

  @override
  Future<DiagnosticReport?> getReportById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<DiagnosticReport> uploadReport(DiagnosticReport report) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _reports.insert(0, report);
    _activities.insert(
      0,
      DocumentActivity(
        id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
        documentId: report.id,
        documentType: 'Report',
        actorId: report.orderingDoctorId,
        actorName: 'Dr. ${report.orderingDoctorId}',
        action: DocumentActivityAction.uploaded,
        timestamp: DateTime.now(),
        notes: 'Diagnostic report uploaded.',
      ),
    );
    return report;
  }

  @override
  Future<DiagnosticReport> updateReportMetadata(String reportId, Map<String, dynamic> metadata) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) throw Exception('Report not found');
    final old = _reports[index];
    final updated = old.copyWith(
      title: metadata['title'] as String? ?? old.title,
      summary: metadata['summary'] as String? ?? old.summary,
      isCritical: metadata['isCritical'] as bool? ?? old.isCritical,
      updatedAt: DateTime.now(),
    );
    _reports[index] = updated;
    return updated;
  }

  @override
  Future<DiagnosticReport> verifyReport(String reportId, String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) throw Exception('Report not found');
    final old = _reports[index];
    final updated = old.copyWith(
      verificationStatus: ReportVerificationStatus.verified,
      verifiedAt: DateTime.now(),
      verifiedByDoctorId: doctorId,
      updatedAt: DateTime.now(),
    );
    _reports[index] = updated;
    _activities.insert(
      0,
      DocumentActivity(
        id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
        documentId: reportId,
        documentType: 'Report',
        actorId: doctorId,
        actorName: 'Dr. $doctorId',
        action: DocumentActivityAction.verified,
        timestamp: DateTime.now(),
        notes: 'Verified by authorized clinical doctor.',
      ),
    );
    return updated;
  }

  @override
  Future<DiagnosticReport> rejectReport(String reportId, String doctorId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) throw Exception('Report not found');
    final old = _reports[index];
    final updated = old.copyWith(
      verificationStatus: ReportVerificationStatus.rejected,
      summary: 'REJECTED: $reason',
      updatedAt: DateTime.now(),
    );
    _reports[index] = updated;
    _activities.insert(
      0,
      DocumentActivity(
        id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
        documentId: reportId,
        documentType: 'Report',
        actorId: doctorId,
        actorName: 'Dr. $doctorId',
        action: DocumentActivityAction.rejected,
        timestamp: DateTime.now(),
        notes: 'Rejected: $reason',
      ),
    );
    return updated;
  }

  @override
  Future<DiagnosticReport> releaseReportToPatient(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) throw Exception('Report not found');
    final old = _reports[index];
    if (old.verificationStatus != ReportVerificationStatus.verified &&
        old.verificationStatus != ReportVerificationStatus.released) {
      throw Exception('Only verified reports can be released to patient.');
    }
    final updated = old.copyWith(
      releasedToPatient: true,
      verificationStatus: ReportVerificationStatus.released,
      updatedAt: DateTime.now(),
    );
    _reports[index] = updated;
    _activities.insert(
      0,
      DocumentActivity(
        id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
        documentId: reportId,
        documentType: 'Report',
        actorId: old.verifiedByDoctorId ?? 'STAFF',
        actorName: 'Authorized Medical Staff',
        action: DocumentActivityAction.released,
        timestamp: DateTime.now(),
        notes: 'Report released to patient mobile application.',
      ),
    );
    return updated;
  }

  @override
  Future<List<DiagnosticReport>> getPatientReports(String patientId, {bool releasedOnly = true}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _reports.where((r) => r.patientId == patientId && (!releasedOnly || r.releasedToPatient)).toList();
  }

  @override
  Future<List<DiagnosticReport>> getCriticalReports() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _reports.where((r) => r.isCritical).toList();
  }

  @override
  Future<List<DocumentActivity>> getReportActivity(String reportId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _activities.where((a) => a.documentId == reportId).toList();
  }

  // Legacy compatibility implementations
  @override
  Future<List<DiagnosticReportItem>> getReportsList() async {
    return _reports.map((r) => DiagnosticReportItem(
      id: r.id,
      patientId: r.patientId,
      patientName: r.patientName,
      title: r.title,
      category: r.reportType.name,
      orderingDoctor: r.doctorName,
      date: r.date,
      status: DiagnosticReportStatus.completed,
      labResults: Map<String, String>.from(r.resultData.map((k, v) => MapEntry(k, v.toString()))),
      fileUrl: r.fileReference?.storageKey,
    )).toList();
  }

  @override
  Future<List<DiagnosticReportItem>> getReportsByPatient(String patientId) async {
    final list = await getPatientReports(patientId, releasedOnly: false);
    return list.map((r) => DiagnosticReportItem(
      id: r.id,
      patientId: r.patientId,
      patientName: r.patientName,
      title: r.title,
      category: r.reportType.name,
      orderingDoctor: r.doctorName,
      date: r.date,
      status: DiagnosticReportStatus.completed,
      labResults: Map<String, String>.from(r.resultData.map((k, v) => MapEntry(k, v.toString()))),
      fileUrl: r.fileReference?.storageKey,
    )).toList();
  }

  @override
  Future<DiagnosticReportItem> uploadReportItem(DiagnosticReportItem report) async {
    final domain = DiagnosticReport(
      id: report.id,
      hospitalId: 'HOSP-01',
      patientId: report.patientId,
      orderingDoctorId: report.orderingDoctor,
      title: report.title,
      uploadedAt: DateTime.now(),
      date: report.date,
      resultData: report.labResults,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await uploadReport(domain);
    return report;
  }

  @override
  Future<void> updateReportStatus(String reportId, DiagnosticReportStatus status) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(updatedAt: DateTime.now());
    }
  }
}
