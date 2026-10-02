import '../repositories/prescription_repository.dart';
import '../../enums/domain_enums.dart';
import '../../models/prescription_model.dart';
import '../../models/report_model.dart';
import '../../queries/domain_queries.dart';

class MockPrescriptionRepository implements PrescriptionRepository {
  final List<PrescriptionIndex> _prescriptions = [
    PrescriptionIndex(
      id: 'PRE-2026-001',
      hospitalId: 'HOSP-01',
      patientId: 'P101',
      hospitalPatientLinkId: 'LINK-P101',
      doctorId: 'DOC1',
      appointmentId: 'APT-1001',
      prescriptionReference: 'RX-2026-9481',
      signedAt: DateTime.now().subtract(const Duration(days: 3)),
      status: PrescriptionStatus.active,
      pharmacyFulfillmentStatus: PharmacyFulfillmentStatus.fulfilled,
      medications: const [
        PrescriptionItem(
          medicationName: 'Amoxicillin 500mg',
          dosage: '1 capsule',
          frequency: 'Three times daily',
          durationDays: 7,
          instructions: 'Take after meals with plenty of water.',
        ),
        PrescriptionItem(
          medicationName: 'Paracetamol 650mg',
          dosage: '1 tablet',
          frequency: 'As needed for fever/pain',
          durationDays: 5,
          instructions: 'Do not exceed 4 tablets in 24 hours.',
        ),
      ],
      clinicalNotes: 'Signed digital prescription for acute upper respiratory infection.',
      instructions: 'Complete full 7-day course of antibiotics even if symptoms improve.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PrescriptionIndex(
      id: 'PRE-2026-002',
      hospitalId: 'HOSP-01',
      patientId: 'P102',
      hospitalPatientLinkId: 'LINK-P102',
      doctorId: 'DOC2',
      admissionId: 'ADM-2001',
      prescriptionReference: 'RX-2026-9482',
      signedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: PrescriptionStatus.active,
      pharmacyFulfillmentStatus: PharmacyFulfillmentStatus.partiallyFulfilled,
      medications: const [
        PrescriptionItem(
          medicationName: 'Atorvastatin 20mg',
          dosage: '1 tablet',
          frequency: 'Once daily at bedtime',
          durationDays: 30,
          instructions: 'Avoid grapefruit products.',
        ),
        PrescriptionItem(
          medicationName: 'Metoprolol Succinate 50mg',
          dosage: '1 tablet',
          frequency: 'Once daily in the morning',
          durationDays: 30,
          instructions: 'Monitor blood pressure weekly.',
        ),
      ],
      clinicalNotes: 'Cardiovascular maintenance post-discharge order.',
      instructions: 'Cardiology follow-up in 2 weeks.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    PrescriptionIndex(
      id: 'PRE-2026-003',
      hospitalId: 'HOSP-01',
      patientId: 'P103',
      doctorId: 'DOC3',
      prescriptionReference: 'RX-2026-9483',
      signedAt: DateTime.now().subtract(const Duration(hours: 6)),
      status: PrescriptionStatus.signed,
      pharmacyFulfillmentStatus: PharmacyFulfillmentStatus.pending,
      medications: const [
        PrescriptionItem(
          medicationName: 'Loratadine 10mg',
          dosage: '1 tablet',
          frequency: 'Once daily',
          durationDays: 14,
          instructions: 'Take with or without food.',
        ),
      ],
      clinicalNotes: 'Allergic rhinitis seasonal management.',
      instructions: 'Store at room temperature away from direct sunlight.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  final List<DocumentActivity> _history = [
    DocumentActivity(
      id: 'ACT-P-001',
      documentId: 'PRE-2026-001',
      documentType: 'Prescription',
      actorId: 'DOC1',
      actorName: 'Dr. Sarah Connor',
      action: DocumentActivityAction.uploaded,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Prescription digitally signed and filed into prescription index.',
    ),
    DocumentActivity(
      id: 'ACT-P-002',
      documentId: 'PRE-2026-001',
      documentType: 'Prescription',
      actorId: 'PHARM-01',
      actorName: 'Marcus Vance (Pharmacist)',
      action: DocumentActivityAction.reviewed,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Pharmacy fulfillment completed.',
    ),
  ];

  @override
  Future<List<PrescriptionIndex>> getPrescriptions({PrescriptionQuery query = const PrescriptionQuery()}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    var results = List<PrescriptionIndex>.from(_prescriptions);

    if (query.searchQuery != null && query.searchQuery!.isNotEmpty) {
      final q = query.searchQuery!.toLowerCase();
      results = results.where((p) =>
        p.id.toLowerCase().contains(q) ||
        p.prescriptionReference.toLowerCase().contains(q) ||
        p.patientId.toLowerCase().contains(q) ||
        p.doctorId.toLowerCase().contains(q)
      ).toList();
    }

    if (query.patientId != null) {
      results = results.where((p) => p.patientId == query.patientId).toList();
    }

    if (query.doctorId != null) {
      results = results.where((p) => p.doctorId == query.doctorId).toList();
    }

    if (query.status != null) {
      results = results.where((p) => p.status == query.status).toList();
    }

    if (query.fulfillmentStatus != null) {
      results = results.where((p) => p.pharmacyFulfillmentStatus == query.fulfillmentStatus).toList();
    }

    return results;
  }

  @override
  Future<PrescriptionIndex?> getPrescriptionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _prescriptions.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PrescriptionIndex>> getPatientPrescriptions(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _prescriptions.where((p) => p.patientId == patientId).toList();
  }

  @override
  Future<List<PrescriptionIndex>> getDoctorPrescriptions(String doctorId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _prescriptions.where((p) => p.doctorId == doctorId).toList();
  }

  @override
  Future<List<DocumentActivity>> getPrescriptionHistory(String prescriptionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _history.where((a) => a.documentId == prescriptionId).toList();
  }

  @override
  Future<PharmacyFulfillmentStatus> getFulfillmentStatus(String prescriptionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final p = await getPrescriptionById(prescriptionId);
    return p?.pharmacyFulfillmentStatus ?? PharmacyFulfillmentStatus.pending;
  }

  @override
  Future<PrescriptionIndex> createPrescription(PrescriptionIndex prescription) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _prescriptions.insert(0, prescription);
    _history.insert(
      0,
      DocumentActivity(
        id: 'ACT-P-${DateTime.now().millisecondsSinceEpoch}',
        documentId: prescription.id,
        documentType: 'Prescription',
        actorId: prescription.doctorId,
        actorName: 'Dr. ${prescription.doctorId}',
        action: DocumentActivityAction.uploaded,
        timestamp: DateTime.now(),
        notes: 'Prescription index reference created and digitally signed.',
      ),
    );
    return prescription;
  }

  @override
  Future<PrescriptionIndex> updateFulfillmentStatus(String prescriptionId, PharmacyFulfillmentStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _prescriptions.indexWhere((p) => p.id == prescriptionId);
    if (index == -1) throw Exception('Prescription not found');
    final old = _prescriptions[index];
    final updated = old.copyWith(
      pharmacyFulfillmentStatus: status,
      updatedAt: DateTime.now(),
    );
    _prescriptions[index] = updated;
    _history.insert(
      0,
      DocumentActivity(
        id: 'ACT-P-${DateTime.now().millisecondsSinceEpoch}',
        documentId: prescriptionId,
        documentType: 'Prescription',
        actorId: 'PHARM-SYS',
        actorName: 'Pharmacy Operations',
        action: DocumentActivityAction.reviewed,
        timestamp: DateTime.now(),
        notes: 'Pharmacy fulfillment status updated to ${status.name}.',
      ),
    );
    return updated;
  }

  @override
  Future<void> cancelPrescription(String prescriptionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _prescriptions.indexWhere((p) => p.id == prescriptionId);
    if (index != -1) {
      final old = _prescriptions[index];
      _prescriptions[index] = old.copyWith(
        status: PrescriptionStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      _history.insert(
        0,
        DocumentActivity(
          id: 'ACT-P-${DateTime.now().millisecondsSinceEpoch}',
          documentId: prescriptionId,
          documentType: 'Prescription',
          actorId: old.doctorId,
          actorName: 'Dr. ${old.doctorId}',
          action: DocumentActivityAction.rejected,
          timestamp: DateTime.now(),
          notes: 'Prescription cancelled by ordering physician.',
        ),
      );
    }
  }

  // Legacy compatibility methods
  @override
  Future<List<PrescriptionRecordItem>> getPrescriptionsList() async {
    return _prescriptions.map((p) => PrescriptionRecordItem(
      id: p.id,
      patientId: p.patientId,
      patientName: 'Patient ${p.patientId}',
      doctorName: 'Dr. ${p.doctorId}',
      department: 'General Medicine',
      date: p.signedAt,
      diagnosis: p.instructions,
      medications: p.medications.map((m) => MedicationItem(
        drugName: m.medicationName,
        dosage: m.dosage,
        frequency: m.frequency,
        duration: '${m.durationDays} days',
        instructions: m.instructions,
      )).toList(),
      isActive: p.status == PrescriptionStatus.active,
    )).toList();
  }

  @override
  Future<List<PrescriptionRecordItem>> getPrescriptionsByPatient(String patientId) async {
    final list = await getPatientPrescriptions(patientId);
    return list.map((p) => PrescriptionRecordItem(
      id: p.id,
      patientId: p.patientId,
      patientName: 'Patient ${p.patientId}',
      doctorName: 'Dr. ${p.doctorId}',
      department: 'General Medicine',
      date: p.signedAt,
      diagnosis: p.instructions,
      medications: p.medications.map((m) => MedicationItem(
        drugName: m.medicationName,
        dosage: m.dosage,
        frequency: m.frequency,
        duration: '${m.durationDays} days',
        instructions: m.instructions,
      )).toList(),
      isActive: p.status == PrescriptionStatus.active,
    )).toList();
  }

  @override
  Future<PrescriptionRecordItem> createPrescriptionRecord(PrescriptionRecordItem prescription) async {
    final domain = PrescriptionIndex(
      id: prescription.id,
      hospitalId: 'HOSP-01',
      patientId: prescription.patientId,
      doctorId: prescription.doctorName,
      prescriptionReference: 'RX-${DateTime.now().millisecondsSinceEpoch}',
      signedAt: prescription.date,
      status: prescription.isActive ? PrescriptionStatus.active : PrescriptionStatus.signed,
      medications: prescription.medications.map((m) => PrescriptionItem(
        medicationName: m.drugName,
        dosage: m.dosage,
        frequency: m.frequency,
        durationDays: 7,
        instructions: m.instructions,
      )).toList(),
      instructions: prescription.diagnosis,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await createPrescription(domain);
    return prescription;
  }
}
