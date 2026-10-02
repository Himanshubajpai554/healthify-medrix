import '../models/prescription_models.dart';

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
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_prescriptions);
  }

  Future<DoctorPrescriptionFullModel?> getPrescription(String id) async {
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
    await Future.delayed(const Duration(milliseconds: 150));
    final patientRx = _prescriptions.where((p) => p.patientId == patientId).toList();

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
    await Future.delayed(const Duration(milliseconds: 250));
    _prescriptions.insert(0, draft);
    return draft;
  }

  Future<void> updatePrescriptionDraft(DoctorPrescriptionFullModel updated) async {
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
    await Future.delayed(const Duration(milliseconds: 250));
    final source = _prescriptions.firstWhere((p) => p.id == sourcePrescriptionId);
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
