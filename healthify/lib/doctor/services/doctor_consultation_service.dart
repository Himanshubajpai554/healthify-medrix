import 'package:flutter/material.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/patient_profile_models.dart';
import '../models/consultation_models.dart';

class DoctorConsultationService {
  static final DoctorConsultationService _instance = DoctorConsultationService._internal();
  factory DoctorConsultationService() => _instance;
  DoctorConsultationService._internal();

  bool _initialized = false;
  late ConsultationFullModel _activeConsultation;

  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    final patient = PatientModel(
      id: 'MED-PAT-10482',
      name: 'Rahul Sharma',
      age: 42,
      gender: 'Male',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      phone: '+91 98765 12345',
      bloodGroup: 'B+',
      mrn: 'MRN-2026-10482',
      allergies: ['Penicillin', 'Sulfa Drugs'],
      chronicConditions: ['Hypertension (Stage 1)', 'Type 2 Diabetes Mellitus'],
      currentMedications: [
        'Atorvastatin 20mg (OD Night)',
        'Metoprolol 50mg (BD)',
        'Metformin 500mg (BD After Meal)',
      ],
      lastVisitDate: '28 Sep 2026',
      lastVisitDoctor: 'Dr. Sarah Jenkins',
      primaryConcern: 'Post-ECG exertional chest tightness & mild dyspnea on stairs',
      careStatus: PatientCareStatus.active,
      nextAppointmentText: '04 Oct 2026, 10:30 AM',
      followUpStatus: 'Due in 4 days',
      department: 'Cardiology',
      clinicalAlerts: ['Pending CBC & Lipid Profile', 'Allergy: Penicillin'],
    );

    _activeConsultation = ConsultationFullModel(
      id: 'CON-2026-9041',
      appointmentId: 'APT-CARD-10482',
      patient: patient,
      status: ConsultationStatus.inConsultation,
      startedAt: '10:30 AM',
      lastSavedAt: 'Just now',
      reasonForVisit: 'Exertional dyspnea and retrosternal tightness during moderate stair climbing',
      patientReported: const PatientReportedInfoModel(),
      vitals: const ConsultationVitalsModel(),
      clinicalNotes:
          'Patient evaluated in OPD. Reports insidious onset of exertional discomfort. No resting chest pain, no radiation to jaw/left arm. ECG shows ST-T baseline. Recommended 24-hr Holter and treadmill stress test.',
      noteVisibility: NoteVisibility.internalPrivate,
      reportsReferenced: const [
        PatientReportModel(
          id: 'REP-701',
          title: 'Comprehensive Lipid Panel & HbA1c',
          category: ReportCategory.laboratory,
          date: '28 Sep 2026',
          labName: 'Healthify Central Diagnostics Lab',
          orderingDoctor: 'Dr. Sarah Jenkins',
          status: 'Abnormal LDL',
          priority: ReportPriority.high,
          labValues: {
            'Total Cholesterol': '218 mg/dL (High)',
            'LDL Cholesterol': '142 mg/dL (Elevated)',
            'HDL Cholesterol': '44 mg/dL',
            'HbA1c': '6.6 %',
          },
          attachmentUrl: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=600&q=80',
          attachmentType: 'Lab PDF',
          clinicalNotes: 'Elevated LDL 142 mg/dL in high-risk patient.',
        ),
      ],
      prescriptions: const [
        ConsultationPrescriptionItemModel(
          id: 'MED-1',
          drugName: 'Atorvastatin',
          dosage: '40 mg',
          frequency: 'Once daily (OD)',
          duration: '90 Days',
          instructions: 'Take strictly at bedtime after dinner',
        ),
        ConsultationPrescriptionItemModel(
          id: 'MED-2',
          drugName: 'Metoprolol Succinate ER',
          dosage: '50 mg',
          frequency: 'Twice daily (BD)',
          duration: '90 Days',
          instructions: 'Take morning & evening after meals',
        ),
        ConsultationPrescriptionItemModel(
          id: 'MED-3',
          drugName: 'Metformin HCl',
          dosage: '500 mg',
          frequency: 'Twice daily (BD)',
          duration: '90 Days',
          instructions: 'Take with morning and evening meals',
        ),
      ],
      attachments: const [
        ConsultationAttachmentModel(
          id: 'ATT-1',
          fileName: 'Chest_XRay_PAView_25Sep.pdf',
          fileType: 'PDF Document',
          uploadDate: '25 Sep 2026',
          fileSize: '1.8 MB',
          category: 'Radiology',
          isAttachedToConsultation: true,
        ),
        ConsultationAttachmentModel(
          id: 'ATT-2',
          fileName: '12Lead_ECG_Waveform_28Sep.pdf',
          fileType: 'PDF Document',
          uploadDate: '28 Sep 2026',
          fileSize: '2.4 MB',
          category: 'Cardiology',
          isAttachedToConsultation: true,
        ),
      ],
      followUp: const ConsultationFollowUpModel(),
      aiSummary: AIPatientSummaryModel(
        patient: patient,
        previousVisitsCount: 6,
        recentLabReportsCount: 4,
        currentMedications: const [
          'Atorvastatin 20mg (OD Night)',
          'Metoprolol 50mg (BD)',
          'Metformin 500mg (BD After Meal)',
        ],
        lastConsultationText:
            'Evaluated for mild exertion dyspnea. ECG showed sinus rhythm with non-specific T-wave flattening in V4-V6.',
        recentReportAttention:
            'Lipid panel (28 Sep 2026) shows elevated LDL (142 mg/dL) despite statin therapy. HbA1c remains controlled at 6.6%.',
        keyFindings:
            'Previous records show three consultations during the last six months, with the latest visit recorded on 28 September 2026. Two laboratory reports were added during the same period. Stable hemodynamics.',
      ),
      auditLogs: [
        ConsultationAuditLogModel(
          id: 'AUD-01',
          action: 'Viewed Patient Record',
          timestamp: '10:30:05 AM',
          doctorName: 'Dr. Sarah Jenkins',
          patientId: 'MED-PAT-10482',
        ),
        ConsultationAuditLogModel(
          id: 'AUD-02',
          action: 'Started Consultation',
          timestamp: '10:30:12 AM',
          doctorName: 'Dr. Sarah Jenkins',
          patientId: 'MED-PAT-10482',
        ),
      ],
      isDraft: false,
    );
  }

  // Serverpod Service Operations

  Future<ConsultationFullModel> getConsultation(String consultationId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 150));
    return _activeConsultation;
  }

  Future<PatientModel> getPatientContext(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return _activeConsultation.patient;
  }

  Future<List<PatientReportModel>> getRecentReports(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return _activeConsultation.reportsReferenced;
  }

  Future<List<MedicalHistoryItemModel>> getMedicalHistory(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return const [
      MedicalHistoryItemModel(
        id: 'MH-101',
        date: '28 Sep 2026',
        title: 'Cardiology OPD Consultation',
        category: MedicalHistoryCategory.consultation,
        doctorName: 'Dr. Sarah Jenkins',
        department: 'Cardiology',
        summary: 'Exertional dyspnea evaluation. Resting 12-lead ECG conducted.',
        status: 'Completed',
        icon: Icons.medical_services_rounded,
        badgeColor: Color(0xFF0D9488),
      ),
      MedicalHistoryItemModel(
        id: 'MH-102',
        date: '28 Sep 2026',
        title: 'Lipid Profile & HbA1c Report',
        category: MedicalHistoryCategory.report,
        doctorName: 'Dr. Rajesh Patel (Pathology)',
        department: 'Laboratory',
        summary: 'Elevated LDL 142 mg/dL. HbA1c 6.6%.',
        status: 'Abnormal LDL',
        icon: Icons.science_rounded,
        badgeColor: Color(0xFFF59E0B),
      ),
    ];
  }

  Future<List<ConsultationPrescriptionItemModel>> getActivePrescriptions(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return _activeConsultation.prescriptions;
  }

  Future<ConsultationFullModel> saveConsultationDraft(ConsultationFullModel model) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 200));

    final timeNow = DateTime.now();
    final formattedTime = '${timeNow.hour.toString().padLeft(2, '0')}:${timeNow.minute.toString().padLeft(2, '0')}';

    final updatedAudit = [
      ...model.auditLogs,
      ConsultationAuditLogModel(
        id: 'AUD-${timeNow.millisecondsSinceEpoch.toString().substring(8)}',
        action: 'Updated Consultation Draft',
        timestamp: formattedTime,
        doctorName: 'Dr. Sarah Jenkins',
        patientId: model.patient.id,
      ),
    ];

    _activeConsultation = model.copyWith(
      status: ConsultationStatus.draft,
      lastSavedAt: 'Saved at $formattedTime',
      isDraft: true,
      auditLogs: updatedAudit,
    );

    return _activeConsultation;
  }

  Future<void> saveClinicalNotes({
    required String consultationId,
    required String notes,
    required NoteVisibility visibility,
  }) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 150));
    _activeConsultation = _activeConsultation.copyWith(
      clinicalNotes: notes,
      noteVisibility: visibility,
    );
  }

  Future<void> savePrescription({
    required String consultationId,
    required List<ConsultationPrescriptionItemModel> prescriptions,
  }) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 150));
    _activeConsultation = _activeConsultation.copyWith(
      prescriptions: prescriptions,
    );
  }

  Future<void> attachReport({
    required String consultationId,
    required String attachmentId,
  }) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    final updatedAttachments = _activeConsultation.attachments.map((att) {
      if (att.id == attachmentId) {
        return att.copyWith(isAttachedToConsultation: true);
      }
      return att;
    }).toList();

    _activeConsultation = _activeConsultation.copyWith(attachments: updatedAttachments);
  }

  Future<void> scheduleFollowUp({
    required String consultationId,
    required ConsultationFollowUpModel followUp,
  }) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 150));
    _activeConsultation = _activeConsultation.copyWith(followUp: followUp);
  }

  Future<ConsultationFullModel> completeConsultation(ConsultationFullModel model) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 350));

    final timeNow = DateTime.now();
    final formattedTime = '${timeNow.hour.toString().padLeft(2, '0')}:${timeNow.minute.toString().padLeft(2, '0')}';

    final finalAudit = [
      ...model.auditLogs,
      ConsultationAuditLogModel(
        id: 'AUD-${timeNow.millisecondsSinceEpoch.toString().substring(8)}',
        action: 'Completed Consultation & Signed EHR Record',
        timestamp: formattedTime,
        doctorName: 'Dr. Sarah Jenkins',
        patientId: model.patient.id,
      ),
    ];

    _activeConsultation = model.copyWith(
      status: ConsultationStatus.completed,
      lastSavedAt: 'Completed at $formattedTime',
      isDraft: false,
      auditLogs: finalAudit,
    );

    return _activeConsultation;
  }

  Future<void> logAuditEvent({
    required String action,
    required String patientId,
  }) async {
    _ensureInitialized();
    final timeNow = DateTime.now();
    final formattedTime = '${timeNow.hour.toString().padLeft(2, '0')}:${timeNow.minute.toString().padLeft(2, '0')}';

    final newAudit = ConsultationAuditLogModel(
      id: 'AUD-${timeNow.millisecondsSinceEpoch.toString().substring(8)}',
      action: action,
      timestamp: formattedTime,
      doctorName: 'Dr. Sarah Jenkins',
      patientId: patientId,
    );

    _activeConsultation = _activeConsultation.copyWith(
      auditLogs: [..._activeConsultation.auditLogs, newAudit],
    );
  }
}
