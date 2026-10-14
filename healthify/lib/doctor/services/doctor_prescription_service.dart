import '../models/prescription_models.dart';
import '../../core/provider/repository_provider.dart';

Map<String, dynamic>? get _clinicalPrescriptionRecords =>
    RepositoryContainer.instance.hospitalOperationalRepository == null
        ? null
        : <String, dynamic>{
            'records': RepositoryContainer.instance.hospitalOperationalRepository,
            'doctorId': RepositoryContainer.instance.currentDoctorId,
            'doctorName': RepositoryContainer.instance.currentDoctorName,
            'specialty': RepositoryContainer.instance.currentDoctorSpecialty,
          };

class DoctorPrescriptionService {
  static final DoctorPrescriptionService _instance = DoctorPrescriptionService._internal();
  factory DoctorPrescriptionService() => _instance;
  DoctorPrescriptionService._internal();

  final List<DoctorPrescriptionFullModel> _prescriptions = [
    DoctorPrescriptionFullModel(
      id: 'RX-2026-00982',
      patientId: 'MED-PAT-10482',
      patientName: 'Rahul Sharma',
      patientAge: 42,
      patientGender: 'Male',
      bloodGroup: 'B+',
      allergies: ['Penicillin', 'Sulfa Drugs'],
      doctorName: 'Dr. Sarah Jenkins',
      doctorQualification: 'MD, DM (Cardiology), FACC',
      registrationNumber: 'MCI-REG-2018-9921',
      department: 'Cardiology',
      consultationId: 'CON-10029',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      status: PrescriptionStatus.active,
      medicines: [
        const PrescriptionMedicineModel(
          id: 'MED-001',
          medicineName: 'Amlodipine',
          dosage: '5 mg',
          frequency: 'Once daily',
          route: 'Oral',
          duration: '30 days',
          instructions: 'Take after breakfast.',
        ),
        const PrescriptionMedicineModel(
          id: 'MED-002',
          medicineName: 'Atorvastatin',
          dosage: '10 mg',
          frequency: 'Once daily',
          route: 'Oral',
          duration: '30 days',
          instructions: 'Take at night before sleep.',
        ),
        const PrescriptionMedicineModel(
          id: 'MED-003',
          medicineName: 'Metoprolol Succinate ER',
          dosage: '25 mg',
          frequency: 'Once daily',
          route: 'Oral',
          duration: '30 days',
          instructions: 'Take with morning food.',
        ),
      ],
      generalInstructions: 'Maintain low-sodium diet (<2g/day). Monitor daily blood pressure logs and avoid sudden strenuous exertion.',
      lastSaved: DateTime.now().subtract(const Duration(hours: 4)),
      auditHistory: [
        PrescriptionAuditItemModel(
          id: 'AUD-RX-1',
          timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
          action: 'Created Draft',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Initial prescription draft initialized for consultation CON-10029',
        ),
        PrescriptionAuditItemModel(
          id: 'AUD-RX-2',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          action: 'Activated',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Prescription verified and activated with digital sign-off.',
        ),
      ],
    ),
    DoctorPrescriptionFullModel(
      id: 'RX-2026-00975',
      patientId: 'MED-PAT-10391',
      patientName: 'Priya Patel',
      patientAge: 38,
      patientGender: 'Female',
      bloodGroup: 'O+',
      allergies: ['NSAIDs', 'Aspirin'],
      doctorName: 'Dr. Sarah Jenkins',
      doctorQualification: 'MD, DM (Cardiology), FACC',
      registrationNumber: 'MCI-REG-2018-9921',
      department: 'Cardiology',
      consultationId: 'CON-10018',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: PrescriptionStatus.active,
      medicines: [
        const PrescriptionMedicineModel(
          id: 'MED-010',
          medicineName: 'Propranolol Hydrochloride',
          dosage: '40 mg',
          frequency: 'Twice daily',
          route: 'Oral',
          duration: '14 days',
          instructions: 'Take after meals for migraine prophylaxis.',
        ),
      ],
      generalInstructions: 'Avoid caffeine and maintain hydration. Contact clinic if pulse drops below 55 bpm.',
      lastSaved: DateTime.now().subtract(const Duration(days: 1)),
      auditHistory: [
        PrescriptionAuditItemModel(
          id: 'AUD-RX-10',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          action: 'Activated',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Prescription activated.',
        ),
      ],
    ),
    DoctorPrescriptionFullModel(
      id: 'RX-2026-00962',
      patientId: 'MED-PAT-10519',
      patientName: 'Amit Verma',
      patientAge: 56,
      patientGender: 'Male',
      bloodGroup: 'A+',
      allergies: [],
      doctorName: 'Dr. Sarah Jenkins',
      doctorQualification: 'MD, DM (Cardiology), FACC',
      registrationNumber: 'MCI-REG-2018-9921',
      department: 'Cardiology',
      consultationId: 'CON-09988',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: PrescriptionStatus.draft,
      medicines: [
        const PrescriptionMedicineModel(
          id: 'MED-020',
          medicineName: 'Ramipril',
          dosage: '2.5 mg',
          frequency: 'Once daily',
          route: 'Oral',
          duration: '30 days',
          instructions: 'Take in the morning.',
        ),
      ],
      generalInstructions: 'Draft prescription pending renal function lab results.',
      lastSaved: DateTime.now().subtract(const Duration(minutes: 15)),
      auditHistory: [
        PrescriptionAuditItemModel(
          id: 'AUD-RX-20',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          action: 'Created Draft',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Saved draft prescription.',
        ),
      ],
    ),
    DoctorPrescriptionFullModel(
      id: 'RX-2026-00910',
      patientId: 'MED-PAT-10220',
      patientName: 'Ananya Sen',
      patientAge: 29,
      patientGender: 'Female',
      bloodGroup: 'AB+',
      allergies: ['Amoxicillin'],
      doctorName: 'Dr. Sarah Jenkins',
      doctorQualification: 'MD, DM (Cardiology), FACC',
      registrationNumber: 'MCI-REG-2018-9921',
      department: 'General Medicine',
      consultationId: 'CON-09855',
      date: DateTime.now().subtract(const Duration(days: 10)),
      status: PrescriptionStatus.completed,
      medicines: [
        const PrescriptionMedicineModel(
          id: 'MED-030',
          medicineName: 'Pantoprazole',
          dosage: '40 mg',
          frequency: 'Once daily',
          route: 'Oral',
          duration: '10 days',
          instructions: 'Take 30 mins before breakfast.',
        ),
      ],
      generalInstructions: '10-day course completed.',
      lastSaved: DateTime.now().subtract(const Duration(days: 10)),
      auditHistory: [
        PrescriptionAuditItemModel(
          id: 'AUD-RX-30',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          action: 'Activated',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Course completed.',
        ),
      ],
    ),
    DoctorPrescriptionFullModel(
      id: 'RX-2026-00890',
      patientId: 'MED-PAT-10115',
      patientName: 'Vikram Malhotra',
      patientAge: 61,
      patientGender: 'Male',
      bloodGroup: 'O-',
      allergies: ['Codeine'],
      doctorName: 'Dr. Sarah Jenkins',
      doctorQualification: 'MD, DM (Cardiology), FACC',
      registrationNumber: 'MCI-REG-2018-9921',
      department: 'Cardiology',
      consultationId: 'CON-09740',
      date: DateTime.now().subtract(const Duration(days: 15)),
      status: PrescriptionStatus.cancelled,
      medicines: [
        const PrescriptionMedicineModel(
          id: 'MED-040',
          medicineName: 'Ciprofloxacin',
          dosage: '500 mg',
          frequency: 'Twice daily',
          route: 'Oral',
          duration: '7 days',
          instructions: 'Take with plenty of water.',
        ),
      ],
      generalInstructions: 'Cancelled due to patient gastrointestinal intolerance.',
      lastSaved: DateTime.now().subtract(const Duration(days: 14)),
      cancelledBy: 'Dr. Sarah Jenkins',
      cancelledDate: DateTime.now().subtract(const Duration(days: 14)),
      cancellationReason: 'Patient reported severe nausea and gastric discomfort.',
      auditHistory: [
        PrescriptionAuditItemModel(
          id: 'AUD-RX-40',
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
          action: 'Activated',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Prescription activated.',
        ),
        PrescriptionAuditItemModel(
          id: 'AUD-RX-41',
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
          action: 'Cancelled',
          performedBy: 'Dr. Sarah Jenkins',
          details: 'Cancelled due to GI intolerance.',
        ),
      ],
    ),
  ];

  Future<List<DoctorPrescriptionFullModel>> getPrescriptions() async {
    final live = _clinicalPrescriptionRecords;
    if (live != null && '${live['doctorId']}'.isNotEmpty) {
      final records = live['records'] as dynamic;
      final rows = await records.list('prescriptions', limit: 500);
      return rows.map<DoctorPrescriptionFullModel>((row) => _fromRecord(row)).toList();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_prescriptions);
  }

  DoctorPrescriptionFullModel _fromRecord(Map<String, dynamic> row) {
    DateTime date(String? value) => DateTime.tryParse(value ?? '') ?? DateTime.now();
    final status = PrescriptionStatus.values.where((s) => s.name == row['status']).firstOrNull ?? PrescriptionStatus.active;
    final medications = (row['medications'] as List? ?? const []).whereType<Map>().map((med) => PrescriptionMedicineModel(
      id: '${med['id'] ?? med['medicationName'] ?? 'MED'}',
      medicineName: '${med['medicationName'] ?? ''}',
      dosage: '${med['dosage'] ?? ''}',
      frequency: '${med['frequency'] ?? ''}',
      route: '${med['route'] ?? ''}',
      duration: '${med['durationDays'] ?? med['duration'] ?? ''}',
      instructions: '${med['instructions'] ?? ''}',
    )).toList();
    return DoctorPrescriptionFullModel(
      id: '${row['id'] ?? ''}',
      patientId: '${row['patientId'] ?? ''}',
      patientName: '${row['patientName'] ?? row['patientId'] ?? ''}',
      patientAge: (row['patientAge'] as num?)?.toInt() ?? 0,
      patientGender: '${row['patientGender'] ?? ''}',
      bloodGroup: '${row['bloodGroup'] ?? ''}',
      allergies: (row['allergies'] as List? ?? const []).map((e) => '$e').toList(),
      doctorName: '${row['doctorName'] ?? RepositoryContainer.instance.currentDoctorName}',
      doctorQualification: '${row['doctorQualification'] ?? ''}',
      registrationNumber: '${row['registrationNumber'] ?? ''}',
      department: '${row['department'] ?? RepositoryContainer.instance.currentDoctorSpecialty}',
      consultationId: '${row['consultationId'] ?? row['appointmentId'] ?? ''}',
      date: date('${row['signedAt'] ?? row['createdAt']}'),
      status: status,
      medicines: medications,
      generalInstructions: '${row['instructions'] ?? ''}',
      lastSaved: date('${row['updatedAt'] ?? row['createdAt']}'),
      cancelledBy: row['cancelledBy'] as String?,
      cancelledDate: row['cancelledAt'] == null ? null : date('${row['cancelledAt']}'),
      cancellationReason: row['cancellationReason'] as String?,
      auditHistory: const [],
    );
  }

  Map<String, dynamic> _toRecord(DoctorPrescriptionFullModel p) => {
    'id': p.id,
    'patientId': p.patientId,
    'patientName': p.patientName,
    'patientAge': p.patientAge,
    'patientGender': p.patientGender,
    'bloodGroup': p.bloodGroup,
    'allergies': p.allergies,
    'doctorId': RepositoryContainer.instance.currentDoctorId,
    'doctorName': p.doctorName,
    'department': p.department,
    'consultationId': p.consultationId,
    'appointmentId': p.consultationId,
    'signedAt': p.date.toUtc().toIso8601String(),
    'status': p.status.name,
    'medications': p.medicines.map((m) => {
      'id': m.id,
      'medicationName': m.medicineName,
      'dosage': m.dosage,
      'frequency': m.frequency,
      'route': m.route,
      'duration': m.duration,
      'durationDays': int.tryParse(RegExp(r'\d+').firstMatch(m.duration)?.group(0) ?? '') ?? 0,
      'instructions': m.instructions,
    }).toList(),
    'instructions': p.generalInstructions,
    'cancelledBy': p.cancelledBy,
    'cancelledAt': p.cancelledDate?.toUtc().toIso8601String(),
    'cancellationReason': p.cancellationReason,
    'createdAt': p.date.toUtc().toIso8601String(),
    'updatedAt': p.lastSaved.toUtc().toIso8601String(),
  };

  Future<DoctorPrescriptionFullModel?> getPrescription(String id) async {
    final live = _clinicalPrescriptionRecords;
    if (live != null && '${live['doctorId']}'.isNotEmpty) {
      final row = await (live['records'] as dynamic).get('prescriptions', id);
      return row == null ? null : _fromRecord(row);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _prescriptions.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<DoctorPrescriptionFullModel>> searchPrescriptions(String query) async {
    final all = await getPrescriptions();
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((p) {
      final matchesMedicine = p.medicines.any((m) => m.medicineName.toLowerCase().contains(q));
      return p.id.toLowerCase().contains(q) ||
          p.patientName.toLowerCase().contains(q) ||
          p.patientId.toLowerCase().contains(q) ||
          matchesMedicine;
    }).toList();
  }

  Future<List<DoctorPrescriptionFullModel>> filterPrescriptions({
    PrescriptionStatus? status,
    String? patientId,
    String? department,
  }) async {
    var list = await getPrescriptions();
    if (status != null) {
      list = list.where((p) => p.status == status).toList();
    }
    if (patientId != null) {
      list = list.where((p) => p.patientId == patientId).toList();
    }
    if (department != null) {
      list = list.where((p) => p.department == department).toList();
    }
    return list;
  }

  Future<PatientMedicationHistoryModel> getPatientMedicationHistory(String patientId) async {
    final source = await getPrescriptions();
    await Future.delayed(const Duration(milliseconds: 150));
    final patientRx = source.where((p) => p.patientId == patientId).toList();

    final activeMeds = <PrescriptionMedicineModel>[];
    final previousMeds = <PrescriptionMedicineModel>[];
    final discontinuedMeds = <DiscontinuedMedicationModel>[];

    for (final rx in patientRx) {
      if (rx.status == PrescriptionStatus.active) {
        activeMeds.addAll(rx.medicines);
      } else if (rx.status == PrescriptionStatus.completed) {
        previousMeds.addAll(rx.medicines);
      } else if (rx.status == PrescriptionStatus.cancelled) {
        for (final m in rx.medicines) {
          discontinuedMeds.add(
            DiscontinuedMedicationModel(
              medicineName: m.medicineName,
              dosage: m.dosage,
              reason: rx.cancellationReason ?? 'Discontinued by physician',
              discontinuedDate: rx.cancelledDate ?? rx.lastSaved,
            ),
          );
        }
      }
    }

    return PatientMedicationHistoryModel(
      patientId: patientId,
      activeMedications: activeMeds,
      previousMedications: previousMeds,
      discontinuedMedications: discontinuedMeds,
    );
  }

  Future<DoctorPrescriptionFullModel> createPrescriptionDraft(DoctorPrescriptionFullModel draft) async {
    final live = _clinicalPrescriptionRecords;
    if (live != null && '${live['doctorId']}'.isNotEmpty) {
      await (live['records'] as dynamic).save('prescriptions', draft.id, _toRecord(draft));
      return draft;
    }
    await Future.delayed(const Duration(milliseconds: 250));
    _prescriptions.insert(0, draft);
    return draft;
  }

  Future<void> updatePrescriptionDraft(DoctorPrescriptionFullModel updated) async {
    final live = _clinicalPrescriptionRecords;
    if (live != null && '${live['doctorId']}'.isNotEmpty) {
      final row = await (live['records'] as dynamic).get('prescriptions', updated.id);
      if (row == null) throw StateError('Prescription not found.');
      await (live['records'] as dynamic).save('prescriptions', updated.id, {...row, ..._toRecord(updated), 'createdAt': row['createdAt']});
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _prescriptions.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      final audit = List<PrescriptionAuditItemModel>.from(updated.auditHistory)
        ..add(
          PrescriptionAuditItemModel(
            id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            action: 'Updated Draft',
            performedBy: 'Dr. Sarah Jenkins',
            details: 'Draft updated with ${updated.medicines.length} medicines.',
          ),
        );
      _prescriptions[index] = updated.copyWith(
        lastSaved: DateTime.now(),
        auditHistory: audit,
      );
    }
  }

  Future<void> activatePrescription(String prescriptionId) async {
    final live = _clinicalPrescriptionRecords;
    if (live != null && '${live['doctorId']}'.isNotEmpty) {
      final records = live['records'] as dynamic;
      final row = await records.get('prescriptions', prescriptionId);
      if (row == null) throw StateError('Prescription not found.');
      await records.save('prescriptions', prescriptionId, {...row, 'status': 'active', 'signedAt': DateTime.now().toUtc().toIso8601String(), 'updatedAt': DateTime.now().toUtc().toIso8601String()});
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _prescriptions.indexWhere((p) => p.id == prescriptionId);
    if (index != -1) {
      final old = _prescriptions[index];
      final audit = List<PrescriptionAuditItemModel>.from(old.auditHistory)
        ..add(
          PrescriptionAuditItemModel(
            id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            action: 'Activated',
            performedBy: 'Dr. Sarah Jenkins',
            details: 'Prescription active and digitally signed off.',
          ),
        );
      _prescriptions[index] = old.copyWith(
        status: PrescriptionStatus.active,
        lastSaved: DateTime.now(),
        auditHistory: audit,
      );
    }
  }

  Future<void> cancelPrescription({
    required String prescriptionId,
    required String reason,
    required String doctorName,
  }) async {
    final live = _clinicalPrescriptionRecords;
    if (live != null && '${live['doctorId']}'.isNotEmpty) {
      final records = live['records'] as dynamic;
      final row = await records.get('prescriptions', prescriptionId);
      if (row == null) throw StateError('Prescription not found.');
      final now = DateTime.now().toUtc();
      await records.save('prescriptions', prescriptionId, {...row, 'status': 'cancelled', 'cancelledBy': doctorName, 'cancelledAt': now.toIso8601String(), 'cancellationReason': reason, 'updatedAt': now.toIso8601String()});
      return;
    }
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _prescriptions.indexWhere((p) => p.id == prescriptionId);
    if (index != -1) {
      final old = _prescriptions[index];
      final audit = List<PrescriptionAuditItemModel>.from(old.auditHistory)
        ..add(
          PrescriptionAuditItemModel(
            id: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            action: 'Cancelled',
            performedBy: doctorName,
            details: 'Reason: $reason',
          ),
        );
      _prescriptions[index] = old.copyWith(
        status: PrescriptionStatus.cancelled,
        cancelledBy: doctorName,
        cancelledDate: DateTime.now(),
        cancellationReason: reason,
        lastSaved: DateTime.now(),
        auditHistory: audit,
      );
    }
  }

  Future<DoctorPrescriptionFullModel> duplicatePrescription({
    required String sourcePrescriptionId,
    required String doctorName,
  }) async {
    final source = await getPrescription(sourcePrescriptionId);
    if (source == null) throw StateError('Prescription not found.');
    final live = _clinicalPrescriptionRecords;
    if (live != null && '${live['doctorId']}'.isNotEmpty) {
      final now = DateTime.now();
      final newId = 'RX-${now.microsecondsSinceEpoch}';
      final duplicate = source.copyWith(
        id: newId,
        doctorName: doctorName,
        date: now,
        status: PrescriptionStatus.draft,
        lastSaved: now,
        cancelledBy: null,
        cancelledDate: null,
        cancellationReason: null,
        auditHistory: const [],
      );
      await createPrescriptionDraft(duplicate);
      return duplicate;
    }
    await Future.delayed(const Duration(milliseconds: 250));
    final newId = 'RX-2026-${(1000 + DateTime.now().millisecond % 8999).toString()}';

    final duplicate = DoctorPrescriptionFullModel(
      id: newId,
      patientId: source.patientId,
      patientName: source.patientName,
      patientAge: source.patientAge,
      patientGender: source.patientGender,
      bloodGroup: source.bloodGroup,
      allergies: List.from(source.allergies),
      doctorName: doctorName,
      doctorQualification: source.doctorQualification,
      registrationNumber: source.registrationNumber,
      department: source.department,
      consultationId: source.consultationId,
      date: DateTime.now(),
      status: PrescriptionStatus.draft, // Duplicates are strictly draft until doctor confirms
      medicines: List.from(source.medicines),
      generalInstructions: source.generalInstructions,
      lastSaved: DateTime.now(),
      auditHistory: [
        PrescriptionAuditItemModel(
          id: 'AUD-DUP-${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now(),
          action: 'Duplicated as Draft',
          performedBy: doctorName,
          details: 'Duplicated from $sourcePrescriptionId',
        ),
      ],
    );

    _prescriptions.insert(0, duplicate);
    return duplicate;
  }

  Map<String, int> getSummaryMetrics() {
    final total = _prescriptions.length;
    final createdToday = _prescriptions.where((p) {
      final now = DateTime.now();
      return p.date.year == now.year && p.date.month == now.month && p.date.day == now.day;
    }).length;
    final active = _prescriptions.where((p) => p.status == PrescriptionStatus.active).length;
    final drafts = _prescriptions.where((p) => p.status == PrescriptionStatus.draft).length;

    return {
      'total': total,
      'createdToday': createdToday,
      'active': active,
      'drafts': drafts,
    };
  }
}
