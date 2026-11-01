import '../models/reports_models.dart';
import '../../core/provider/repository_provider.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../models/doctor_dashboard_models.dart';

class DoctorReportsService {
  static final DoctorReportsService _instance = DoctorReportsService._internal();
  factory DoctorReportsService() => _instance;
  DoctorReportsService._internal();

  Future<List<PatientModel>> getAssignablePatients() async {
    final container = RepositoryContainer.instance;
    final records = container.hospitalOperationalRepository;
    if (records == null || container.currentDoctorId.isEmpty) return const [];

    final patientsById = <String, PatientModel>{};
    final appointmentRows = await records.list('appointments', limit: 500);
    for (final row in appointmentRows) {
      final patientId = '${row['patientId'] ?? ''}'.trim();
      if (patientId.isEmpty) continue;
      patientsById.putIfAbsent(
        patientId,
        () => PatientModel(
          id: patientId,
          name: '${row['patientName'] ?? 'Patient'}',
          age: 0,
          gender: 'Not reported',
          avatarUrl: '',
          phone: '',
          bloodGroup: '',
          mrn: patientId,
          lastVisitDate: 'Not available',
          lastVisitDoctor: container.currentDoctorName,
          primaryConcern: '${row['reason'] ?? ''}',
          department: '${row['department'] ?? container.currentDoctorSpecialty}',
        ),
      );
    }

    final patientRows = await records.list('patients', limit: 500);
    for (final row in patientRows) {
      final patientId = '${row['id'] ?? row['_key'] ?? ''}'.trim();
      if (patientId.isEmpty) continue;
      final previous = patientsById[patientId];
      patientsById[patientId] = PatientModel(
        id: patientId,
        name: '${row['name'] ?? previous?.name ?? 'Patient'}',
        age: (row['age'] as num?)?.toInt() ?? previous?.age ?? 0,
        gender: '${row['gender'] ?? previous?.gender ?? 'Not reported'}',
        avatarUrl: '${row['profileImage'] ?? ''}',
        phone: '',
        bloodGroup: '${row['bloodGroup'] ?? ''}',
        mrn: '${row['mrn'] ?? row['mrnNumber'] ?? patientId}',
        lastVisitDate: previous?.lastVisitDate ?? 'Not available',
        lastVisitDoctor: container.currentDoctorName,
        primaryConcern: '${row['diagnosis'] ?? previous?.primaryConcern ?? ''}',
        department: '${row['department'] ?? previous?.department ?? container.currentDoctorSpecialty}',
      );
    }
    final result = patientsById.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  final List<DoctorReportFullModel> _reports = [
    DoctorReportFullModel(
      id: 'REP-20260928-001',
      title: 'Chest Radiograph (PA & Lateral View)',
      patientId: 'MED-PAT-10482',
      patientName: 'Rahul Sharma',
      patientAge: 42,
      patientGender: 'Male',
      category: ReportCategory.radiology,
      status: ReportStatus.pendingReview,
      modality: ReportModality.xray,
      uploadedDate: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
      uploadedBy: 'Radiology Technician - K. Nair',
      requestedBy: 'Dr. Sarah Jenkins',
      performedBy: 'Dr. R. Mehta (Radiologist)',
      department: 'Radiology',
      facility: 'Healthify Central Diagnostics, Bay 3',
      summaryAiText: 'Left lower lobe ground-glass opacity noted with minor costophrenic angle blunting. No overt pneumothorax or mediastinal shift.',
      findingsText: 'PA and lateral views of the chest demonstrate mild focal airspace opacity in the posterior segment of the left lower lobe. Trachea is midline. Cardiac size is within normal limits (CTR < 0.50). Right lung fields are clear without focal infiltrates. Mild subsegmental atelectasis in the left base. Diaphragm contours normal.',
      impressionText: 'Left lower lobe early pneumonitis or localized subsegmental atelectasis. Clinical correlation with fever and inflammatory markers recommended.',
      recommendationText: 'Follow-up chest radiography in 14 days or HRCT if symptoms worsen.',
      doctorNotesPrivate: 'Patient presented with mild dyspnea and cough. Check CRP levels.',
      doctorNotesPatientVisible: 'Chest X-ray shows minor inflammation in the lower left lung. Continue prescribed antibiotics.',
      auditHistory: [
        ReportAuditItem(
          id: 'AUD-001',
          timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
          action: 'Uploaded',
          performedBy: 'K. Nair (Tech)',
          details: 'Uploaded Digital X-Ray file DICOM-CX-9921',
        ),
        ReportAuditItem(
          id: 'AUD-002',
          timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
          action: 'Viewed',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Accessed image viewer and clinical notes',
        ),
      ],
    ),
    DoctorReportFullModel(
      id: 'REP-20260928-002',
      title: 'Comprehensive Lipid & Cardiac Risk Panel',
      patientId: 'MED-PAT-10482',
      patientName: 'Rahul Sharma',
      patientAge: 42,
      patientGender: 'Male',
      category: ReportCategory.laboratory,
      status: ReportStatus.reviewed,
      modality: ReportModality.labText,
      uploadedDate: DateTime.now().subtract(const Duration(hours: 18)),
      reviewedDate: DateTime.now().subtract(const Duration(hours: 4)),
      uploadedBy: 'Central Lab LIS System',
      requestedBy: 'Dr. Sarah Jenkins',
      performedBy: 'Dr. V. Gupta (Pathologist)',
      department: 'Biochemistry',
      facility: 'Healthify Pathology Lab A',
      summaryAiText: 'Total Cholesterol 245 mg/dL (Elevated), LDL 162 mg/dL (Elevated), HDL 42 mg/dL (Normal), Triglycerides 210 mg/dL (Elevated). High sensitivity CRP: 3.8 mg/L.',
      findingsText: 'Lipid Profile Analysis:\n• Total Cholesterol: 245 mg/dL [Ref: < 200]\n• HDL Cholesterol: 42 mg/dL [Ref: > 40]\n• LDL Cholesterol: 162 mg/dL [Ref: < 100]\n• Triglycerides: 210 mg/dL [Ref: < 150]\n• Non-HDL Cholesterol: 203 mg/dL\n• hs-CRP: 3.8 mg/L [Elevated Cardiovascular Risk]',
      impressionText: 'Hypercholesterolemia with mixed dyslipidemia and moderate systemic inflammatory response (elevated hs-CRP).',
      recommendationText: 'Initiate statin therapy (Atorvastatin 20mg) and dietary modifications.',
      reviewDoctorName: 'Dr. Sarah Jenkins',
      reviewNotes: 'Reviewed with patient during morning rounds. Prescribed Atorvastatin 20mg OD.',
      doctorNotesPrivate: 'Family history of CAD. Target LDL < 70 mg/dL.',
      doctorNotesPatientVisible: 'Cholesterol levels are elevated. Low-fat diet and statin medication started.',
      attachedConsultationId: 'CON-10029',
      auditHistory: [
        ReportAuditItem(
          id: 'AUD-101',
          timestamp: DateTime.now().subtract(const Duration(hours: 18)),
          action: 'Uploaded',
          performedBy: 'Central LIS System',
          details: 'Automated sync from Siemens Dimension Analyzer',
        ),
        ReportAuditItem(
          id: 'AUD-102',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          action: 'Reviewed',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Marked as reviewed with clinical sign-off',
        ),
        ReportAuditItem(
          id: 'AUD-103',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          action: 'Attached to Consultation',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Linked to Consultation CON-10029',
        ),
      ],
    ),
    DoctorReportFullModel(
      id: 'REP-20260927-003',
      title: 'Brain MRI (3T Contrast Enhanced)',
      patientId: 'MED-PAT-10391',
      patientName: 'Priya Patel',
      patientAge: 38,
      patientGender: 'Female',
      category: ReportCategory.imaging,
      status: ReportStatus.newReport,
      modality: ReportModality.mri,
      uploadedDate: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      uploadedBy: 'Neuroimaging Suite',
      requestedBy: 'Dr. Sarah Jenkins',
      performedBy: 'Dr. A. Roy (Neuroradiologist)',
      department: 'Radiology',
      facility: 'Advanced Imaging Wing - 3T MRI',
      summaryAiText: 'No acute intracranial hemorrhage or mass effect. Mild punctate T2/FLAIR hyperintensities in subcortical white matter, non-specific for age.',
      findingsText: 'Brain parenchyma demonstrates normal signal intensity across T1, T2, and FLAIR sequences. Ventricles and sulci are unremarkable for patient age. No midline shift. Post-contrast T1 sequences show no abnormal meningeal or parenchymal enhancement. Major intracranial arterial flows are void normally.',
      impressionText: 'Unremarkable 3T Brain MRI. Non-specific subcortical white matter hyperintensities commonly associated with migraine history.',
      recommendationText: 'Clinical correlation with headache patterns.',
      auditHistory: [
        ReportAuditItem(
          id: 'AUD-201',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
          action: 'Uploaded',
          performedBy: 'Neuroimaging Suite',
          details: 'DICOM transfer complete (480 slices)',
        ),
      ],
    ),
    DoctorReportFullModel(
      id: 'REP-20260927-004',
      title: '12-Lead Electrocardiogram (ECG)',
      patientId: 'MED-PAT-10519',
      patientName: 'Amit Verma',
      patientAge: 56,
      patientGender: 'Male',
      category: ReportCategory.cardiology,
      status: ReportStatus.pendingReview,
      modality: ReportModality.pdf,
      uploadedDate: DateTime.now().subtract(const Duration(hours: 5, minutes: 45)),
      uploadedBy: 'Cardiology OPD Nurse',
      requestedBy: 'Dr. Sarah Jenkins',
      performedBy: 'Dr. Sarah Jenkins',
      department: 'Cardiology',
      facility: 'ECG Station Room 104',
      summaryAiText: 'Normal sinus rhythm at 72 bpm. PR interval 156ms, QRS duration 88ms, QTc 412ms. Slight ST segment flattening in V5-V6 without acute ischemia.',
      findingsText: 'Sinus rhythm with rate of 72 bpm. Axis is normal (+45 degrees). No evidence of chamber hypertrophy or acute ST-T wave changes typical of myocardial infarction.',
      impressionText: 'Normal resting ECG with minor non-specific ST-T wave alterations.',
      recommendationText: 'Treadmill stress test if angina occurs during exertion.',
      auditHistory: [
        ReportAuditItem(
          id: 'AUD-301',
          timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 45)),
          action: 'Uploaded',
          performedBy: 'OPD Nurse',
          details: 'PDF scan attached from Philips PageWriter ECG machine',
        ),
      ],
    ),
    DoctorReportFullModel(
      id: 'REP-20260926-005',
      title: 'Whole Abdomen Ultrasound',
      patientId: 'MED-PAT-10220',
      patientName: 'Ananya Sen',
      patientAge: 29,
      patientGender: 'Female',
      category: ReportCategory.imaging,
      status: ReportStatus.reviewed,
      modality: ReportModality.ultrasound,
      uploadedDate: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      reviewedDate: DateTime.now().subtract(const Duration(days: 1)),
      uploadedBy: 'Ultrasound Bay 2',
      requestedBy: 'Dr. Sarah Jenkins',
      performedBy: 'Dr. S. Kulkarni',
      department: 'Radiology',
      facility: 'USG Diagnostic Room 3',
      summaryAiText: 'Liver, gallbladder, pancreas, spleen, and kidneys appear normal in size and echotexture. No gallstones, hydronephrosis, or free fluid in abdomen.',
      findingsText: 'Liver span is 13.2 cm with uniform parenchymal echogenicity. Gallbladder wall thickness < 3mm without calculi. Bilateral kidneys show normal corticomedullary differentiation.',
      impressionText: 'Normal abdominal ultrasound examination.',
      recommendationText: 'No immediate imaging follow-up required.',
      reviewDoctorName: 'Dr. Sarah Jenkins',
      reviewNotes: 'Patient reassured. Gastrointestinal workup cleared.',
      auditHistory: [
        ReportAuditItem(
          id: 'AUD-401',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
          action: 'Uploaded',
          performedBy: 'USG Tech',
          details: 'Captured 16 static ultrasound stills',
        ),
        ReportAuditItem(
          id: 'AUD-402',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          action: 'Reviewed',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Reviewed and confirmed clear findings',
        ),
      ],
    ),
    DoctorReportFullModel(
      id: 'REP-20260925-006',
      title: 'Skin Lesion Biopsy Histopathology',
      patientId: 'MED-PAT-10115',
      patientName: 'Vikram Malhotra',
      patientAge: 61,
      patientGender: 'Male',
      category: ReportCategory.pathology,
      status: ReportStatus.archived,
      modality: ReportModality.labText,
      uploadedDate: DateTime.now().subtract(const Duration(days: 3)),
      reviewedDate: DateTime.now().subtract(const Duration(days: 2)),
      uploadedBy: 'Histopathology Lab',
      requestedBy: 'Dr. Sarah Jenkins',
      performedBy: 'Dr. M. Chatterji (Chief Pathologist)',
      department: 'Pathology',
      facility: 'Central Pathology Annex',
      summaryAiText: 'Benign seborrheic keratosis with hyperkeratosis and acanthosis. No cellular atypia or malignancy detected.',
      findingsText: 'Specimen labeled "Dorsal forearm punch biopsy 4mm". Microscopic section reveals hyperkeratotic epidermis with horn cysts and uniform basaloid keratinocytes. Basement membrane is intact.',
      impressionText: 'Benign Seborrheic Keratosis. Completely excised.',
      recommendationText: 'Routine skin monitoring.',
      reviewDoctorName: 'Dr. Sarah Jenkins',
      reviewNotes: 'Benign pathology confirmed. Patient notified via SMS portal.',
      auditHistory: [
        ReportAuditItem(
          id: 'AUD-501',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          action: 'Uploaded',
          performedBy: 'Pathology Lab',
          details: 'Final biopsy report issued and signed',
        ),
      ],
    ),
  ];

  Future<List<DoctorReportFullModel>> getReports() async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records != null && RepositoryContainer.instance.currentDoctorId.isNotEmpty) {
      final rows = await records.list('diagnosticReports', limit: 500);
      return rows.map(_fromRecord).toList();
    }
    await Future.delayed(const Duration(milliseconds: 250));
    return List.from(_reports);
  }

  Future<DoctorReportFullModel?> getReportById(String id) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records != null && RepositoryContainer.instance.currentDoctorId.isNotEmpty) {
      final row = await records.get('diagnosticReports', id);
      return row == null ? null : _fromRecord(row);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> uploadReport(
    DoctorReportFullModel report,
    PlatformFile file,
  ) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records != null && RepositoryContainer.instance.currentDoctorId.isNotEmpty) {
      await records.save('diagnosticReports', report.id, _toRecord(report));
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) throw StateError('Selected report file is empty.');
      final extension = file.extension?.toLowerCase();
      final mimeType = switch (extension) {
        'pdf' => 'application/pdf',
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        'dcm' => 'application/dicom',
        _ => throw StateError('Unsupported report file type.'),
      };
      try {
        await records.uploadDoctorReportFile(
          report.id, file.name, mimeType, ByteData.sublistView(bytes),
        );
      } catch (_) {
        await records.delete('diagnosticReports', report.id);
        rethrow;
      }
      return;
    }
    if (file.bytes == null || file.bytes!.isEmpty) {
      throw StateError('Selected report file is empty.');
    }
    _reports.insert(0, report.copyWith(fileUrl: file.name));
  }

  Future<({Uint8List bytes, String fileName, String mimeType})> downloadReportFile(
    String reportId,
  ) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records == null || RepositoryContainer.instance.currentDoctorId.isEmpty) {
      throw StateError('Sign in to your doctor account to download report files.');
    }
    final report = await records.get('diagnosticReports', reportId);
    if (report == null) throw StateError('Report not found.');
    final reference = report['fileReference'];
    if (reference is! Map || reference['fileName'] is! String || reference['mimeType'] is! String) {
      throw StateError('No file is attached to this report.');
    }
    final data = await records.getDoctorReportFileBytes(reportId);
    return (
      bytes: data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      fileName: reference['fileName'] as String,
      mimeType: reference['mimeType'] as String,
    );
  }

  Future<void> setPatientSharing({
    required String reportId,
    required bool isShared,
  }) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records == null || RepositoryContainer.instance.currentDoctorId.isEmpty) {
      throw StateError('Sign in to your doctor account to share a report.');
    }
    await records.client.hospital.setDoctorReportPatientSharing(
      records.hospitalKey, reportId, isShared,
    );
  }

  Future<void> markAsReviewed({
    required String reportId,
    required String reviewNotes,
    required String doctorName,
  }) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records != null && RepositoryContainer.instance.currentDoctorId.isNotEmpty) {
      final row = await records.get('diagnosticReports', reportId);
      if (row == null) throw StateError('Report not found.');
      final now = DateTime.now().toUtc();
      await records.save('diagnosticReports', reportId, {
        ...row,
        'verificationStatus': 'verified',
        'status': 'verified',
        'verifiedByDoctorId': RepositoryContainer.instance.currentDoctorId,
        'verifiedAt': now.toIso8601String(),
        'reviewDoctorName': doctorName,
        'reviewNotes': reviewNotes,
        'updatedAt': now.toIso8601String(),
      });
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final old = _reports[index];
      final newAudit = List<ReportAuditItem>.from(old.auditHistory)
        ..add(
          ReportAuditItem(
            id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            action: 'Reviewed',
            performedBy: doctorName,
            details: 'Marked as reviewed with note: $reviewNotes',
          ),
        );
      _reports[index] = old.copyWith(
        status: ReportStatus.reviewed,
        reviewedDate: DateTime.now(),
        reviewDoctorName: doctorName,
        reviewNotes: reviewNotes,
        auditHistory: newAudit,
      );
    }
  }

  Future<void> addDoctorNote({
    required String reportId,
    required String noteText,
    required bool isPrivate,
  }) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records != null && RepositoryContainer.instance.currentDoctorId.isNotEmpty) {
      final row = await records.get('diagnosticReports', reportId);
      if (row == null) throw StateError('Report not found.');
      await records.save('diagnosticReports', reportId, {
        ...row,
        if (isPrivate) 'doctorNotesPrivate': noteText else 'doctorNotesPatientVisible': noteText,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
      if (!isPrivate && row['releasedToPatient'] == true) {
        await setPatientSharing(reportId: reportId, isShared: true);
      }
      return;
    }
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final old = _reports[index];
      if (isPrivate) {
        _reports[index] = old.copyWith(doctorNotesPrivate: noteText);
      } else {
        _reports[index] = old.copyWith(doctorNotesPatientVisible: noteText);
      }
    }
  }

  Future<void> attachToConsultation({
    required String reportId,
    required String consultationId,
    required String doctorName,
  }) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records != null && RepositoryContainer.instance.currentDoctorId.isNotEmpty) {
      final row = await records.get('diagnosticReports', reportId);
      if (row == null) throw StateError('Report not found.');
      await records.save('diagnosticReports', reportId, {
        ...row,
        'appointmentId': consultationId,
        'attachedConsultationId': consultationId,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final old = _reports[index];
      final newAudit = List<ReportAuditItem>.from(old.auditHistory)
        ..add(
          ReportAuditItem(
            id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            action: 'Attached to Consultation',
            performedBy: doctorName,
            details: 'Linked report to consultation $consultationId',
          ),
        );
      _reports[index] = old.copyWith(
        attachedConsultationId: consultationId,
        auditHistory: newAudit,
      );
    }
  }

  Map<String, int> getSummaryMetrics() {
    final total = _reports.length;
    final pending = _reports.where((r) => r.status == ReportStatus.pendingReview).length;
    final reviewedToday = _reports.where((r) {
      if (r.reviewedDate == null) return false;
      final now = DateTime.now();
      return r.reviewedDate!.year == now.year &&
          r.reviewedDate!.month == now.month &&
          r.reviewedDate!.day == now.day;
    }).length;
    final newReports = _reports.where((r) => r.status == ReportStatus.newReport).length;

    return {
      'total': total,
      'pending': pending,
      'reviewedToday': reviewedToday,
      'newReports': newReports,
    };
  }

  DoctorReportFullModel _fromRecord(Map<String, dynamic> row) {
    DateTime date(Object? value) => DateTime.tryParse('$value') ?? DateTime.now();
    final category = ReportCategory.values.where((value) => value.name == row['reportType']).firstOrNull ?? ReportCategory.other;
    final state = '${row['verificationStatus'] ?? row['status'] ?? 'uploaded'}'.toLowerCase();
    final status = state == 'verified' || state == 'released' || state == 'reviewed'
        ? ReportStatus.reviewed
        : state == 'rejected' ? ReportStatus.archived : ReportStatus.pendingReview;
    final reference = row['fileReference'];
    final mime = '${(reference is Map ? reference['mimeType'] : null) ?? ''}'.toLowerCase();
    final modality = mime.contains('pdf') ? ReportModality.pdf : ReportModality.labText;
    return DoctorReportFullModel(
      id: '${row['id'] ?? ''}',
      title: '${row['title'] ?? ''}',
      patientId: '${row['patientId'] ?? ''}',
      patientName: '${row['patientName'] ?? row['patientId'] ?? ''}',
      patientAge: (row['patientAge'] as num?)?.toInt() ?? 0,
      patientGender: '${row['patientGender'] ?? ''}',
      category: category,
      status: status,
      modality: modality,
      uploadedDate: date(row['uploadedAt'] ?? row['createdAt']),
      reviewedDate: row['verifiedAt'] == null ? null : date(row['verifiedAt']),
      uploadedBy: '${row['fulfillingStaffId'] ?? ''}',
      requestedBy: '${row['orderingDoctorId'] ?? ''}',
      performedBy: '${row['fulfillingStaffId'] ?? ''}',
      department: '${row['departmentId'] ?? ''}',
      facility: '${row['facility'] ?? ''}',
      fileUrl: (reference is Map ? reference['fileName'] : null) as String? ?? row['reportUrl'] as String?,
      isReleasedToPatient: row['releasedToPatient'] as bool? ?? false,
      summaryAiText: '${row['summary'] ?? ''}',
      findingsText: '${row['findingsText'] ?? ''}',
      impressionText: '${row['impressionText'] ?? ''}',
      recommendationText: '${row['recommendationText'] ?? ''}',
      doctorNotesPrivate: '${row['doctorNotesPrivate'] ?? ''}',
      doctorNotesPatientVisible: '${row['doctorNotesPatientVisible'] ?? ''}',
      reviewDoctorName: row['reviewDoctorName'] as String?,
      reviewNotes: row['reviewNotes'] as String?,
      attachedConsultationId: row['attachedConsultationId'] as String?,
      auditHistory: const [],
    );
  }

  Map<String, dynamic> _toRecord(DoctorReportFullModel report) {
    final now = DateTime.now().toUtc();
    return {
      'id': report.id,
      'patientId': report.patientId,
      'patientName': report.patientName,
      'patientAge': report.patientAge,
      'patientGender': report.patientGender,
      'orderingDoctorId': RepositoryContainer.instance.currentDoctorId,
      'doctorId': RepositoryContainer.instance.currentDoctorId,
      'departmentId': report.department,
      'reportType': report.category.name == 'all' ? 'other' : report.category.name,
      'title': report.title,
      'uploadedAt': report.uploadedDate.toUtc().toIso8601String(),
      'verifiedAt': report.reviewedDate?.toUtc().toIso8601String(),
      'verifiedByDoctorId': report.status == ReportStatus.reviewed ? RepositoryContainer.instance.currentDoctorId : null,
      'verificationStatus': report.status == ReportStatus.reviewed ? 'verified' : 'uploaded',
      'isCritical': false,
      'releasedToPatient': report.isReleasedToPatient,
      'summary': report.summaryAiText,
      'findingsText': report.findingsText,
      'impressionText': report.impressionText,
      'recommendationText': report.recommendationText,
      'doctorNotesPrivate': report.doctorNotesPrivate,
      'doctorNotesPatientVisible': report.doctorNotesPatientVisible,
      'date': report.uploadedDate.toUtc().toIso8601String(),
      'reportUrl': report.fileUrl,
      'status': report.status == ReportStatus.reviewed ? 'verified' : 'uploaded',
      'createdAt': report.uploadedDate.toUtc().toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
  }
}
