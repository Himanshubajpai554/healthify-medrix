import 'package:flutter/material.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/patient_profile_models.dart';
import '../data/doctor_mock_data.dart';

class DoctorPatientService {
  static final DoctorPatientService _instance = DoctorPatientService._internal();
  factory DoctorPatientService() => _instance;
  DoctorPatientService._internal();

  // Simulated in-memory database state
  late PatientProfileFullModel _patientProfileData;

  bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    final basePatient = DoctorMockData.patientRahul.copyWith(
      followUpStatus: 'Due in 4 days',
      nextAppointmentText: '04 Oct 2026, 10:30 AM',
    );

    _patientProfileData = PatientProfileFullModel(
      patient: PatientModel(
        id: 'MED-PAT-10482',
        name: 'Rahul Sharma',
        age: 42,
        gender: 'Male',
        avatarUrl: 'https://i.pravatar.cc/150?img=11',
        phone: '+91 98765 12345',
        bloodGroup: 'B+',
        mrn: 'MRN-2026-10482',
        allergies: ['Penicillin', 'Sulfa Drugs', 'Latex (Mild)'],
        chronicConditions: ['Hypertension (Stage 1)', 'Type 2 Diabetes Mellitus', 'Dyslipidemia'],
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
        clinicalAlerts: ['Pending CBC & Lipid Profile', 'Allergy: Penicillin', 'High Risk BP'],
      ),
      currentVitals: {
        'Blood Pressure': '138/88 mmHg',
        'Heart Rate': '74 bpm',
        'SpO2': '98% Room Air',
        'Temperature': '98.4 °F',
        'Weight': '78.5 kg',
        'BMI': '25.6 kg/m²',
        'Blood Glucose (F)': '118 mg/dL',
      },
      activeEmergency: null,
      summary: AIPatientSummaryModel(
        patient: basePatient,
        previousVisitsCount: 6,
        recentLabReportsCount: 4,
        currentMedications: [
          'Atorvastatin 20mg (OD Night)',
          'Metoprolol 50mg (BD)',
          'Metformin 500mg (BD After Meal)',
        ],
        lastConsultationText:
            'Evaluated for mild exertion dyspnea. ECG showed sinus rhythm with non-specific T-wave flattening in V4-V6. Recommended 24-hr Holter and treadmill stress test.',
        recentReportAttention:
            'Lipid panel (28 Sep 2026) shows elevated LDL (142 mg/dL) despite statin therapy. HbA1c remains controlled at 6.6%.',
        keyFindings:
            '42yo male with known Stage 1 HTN & T2DM. Primary symptom: Grade II exertional dyspnea. Stable hemodynamics. Known Penicillin allergy. Needs lipid adjustment and stress ECHO review.',
      ),
      medicalHistory: const [
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
          title: 'Complete Blood Count (CBC) & Lipid Profile',
          category: MedicalHistoryCategory.report,
          doctorName: 'Dr. Rajesh Patel (Pathology)',
          department: 'Laboratory',
          summary: 'LDL elevated (142 mg/dL). HbA1c 6.6%. Hemoglobin 14.8 g/dL.',
          status: 'Abnormal LDL',
          icon: Icons.science_rounded,
          badgeColor: Color(0xFFF59E0B),
        ),
        MedicalHistoryItemModel(
          id: 'MH-103',
          date: '15 Aug 2026',
          title: '2D Echocardiogram & Color Doppler',
          category: MedicalHistoryCategory.procedure,
          doctorName: 'Dr. Sarah Jenkins',
          department: 'Cardiology Diagnostic',
          summary: 'Normal LVEF (62%), mild concentric LV hypertrophy, no wall motion abnormality.',
          status: 'Normal EF',
          icon: Icons.monitor_heart_rounded,
          badgeColor: Color(0xFF0284C7),
        ),
        MedicalHistoryItemModel(
          id: 'MH-104',
          date: '12 May 2026',
          title: 'Diabetes & Hypertension Quarterly Review',
          category: MedicalHistoryCategory.consultation,
          doctorName: 'Dr. Sarah Jenkins',
          department: 'Internal Medicine',
          summary: 'BP well controlled on Metoprolol. Dose of Metformin retained at 500mg BD.',
          status: 'Stable',
          icon: Icons.medical_services_rounded,
          badgeColor: Color(0xFF0D9488),
        ),
        MedicalHistoryItemModel(
          id: 'MH-105',
          date: '10 Jan 2026',
          title: 'Chest X-Ray PA View',
          category: MedicalHistoryCategory.report,
          doctorName: 'Dr. Vikram Malhotra (Radiology)',
          department: 'Radiology',
          summary: 'Clear lung fields, normal bronchovascular markings, cardiac size normal.',
          status: 'Normal',
          icon: Icons.receipt_long_rounded,
          badgeColor: Color(0xFF10B981),
        ),
        MedicalHistoryItemModel(
          id: 'MH-106',
          date: '04 Nov 2025',
          title: 'Prescription Issued: Anti-hypertensive Refill',
          category: MedicalHistoryCategory.prescription,
          doctorName: 'Dr. Sarah Jenkins',
          department: 'Cardiology',
          summary: '3-Month refill for Metoprolol 50mg & Atorvastatin 20mg.',
          status: 'Fulfilled',
          icon: Icons.medication_rounded,
          badgeColor: Color(0xFF6366F1),
        ),
      ],
      consultations: const [
        PatientConsultationRecordModel(
          id: 'CON-9901',
          date: '28 Sep 2026',
          time: '10:30 AM',
          doctorName: 'Dr. Sarah Jenkins',
          doctorSpecialty: 'Senior Cardiologist',
          department: 'Cardiology OPD',
          chiefComplaint: 'Chest tightness on climbing 2 flights of stairs, mild fatigue.',
          diagnosis: 'Exertional Angina Spectrum / Hypertensive Cardiovascular Disease',
          vitals: {
            'BP': '138/88 mmHg',
            'HR': '74 bpm',
            'SpO2': '98%',
            'BMI': '25.6',
          },
          clinicalNotes:
              'Patient reports insidious onset of exertional discomfort. No resting chest pain, no radiation to jaw/left arm. ECG shows ST-T baseline. Advised stress test & lipid optimizer.',
          prescribedMedications: [
            'Atorvastatin 40mg (OD Night) - Up-titrated',
            'Metoprolol 50mg (BD)',
            'Nitroglycerin Sublingual 0.5mg (PRN for Acute Pain)',
          ],
          followUpDate: '04 Oct 2026',
          status: 'Completed',
        ),
        PatientConsultationRecordModel(
          id: 'CON-8840',
          date: '12 May 2026',
          time: '11:15 AM',
          doctorName: 'Dr. Sarah Jenkins',
          doctorSpecialty: 'Senior Cardiologist',
          department: 'Cardiology OPD',
          chiefComplaint: 'Routine 3-month follow-up for Hypertension & Diabetes.',
          diagnosis: 'Essential Hypertension (Controlled), T2DM (Controlled)',
          vitals: {
            'BP': '126/82 mmHg',
            'HR': '70 bpm',
            'SpO2': '99%',
            'BMI': '25.4',
          },
          clinicalNotes:
              'Patient compliant with lifestyle modifications and prescribed oral hypoglycemics. Blood pressures consistently below 130/80 on home monitor.',
          prescribedMedications: [
            'Atorvastatin 20mg (OD)',
            'Metoprolol 50mg (BD)',
            'Metformin 500mg (BD)',
          ],
          followUpDate: '28 Sep 2026',
          status: 'Completed',
        ),
      ],
      reports: const [
        PatientReportModel(
          id: 'REP-701',
          title: 'Comprehensive Lipid Panel & HbA1c',
          category: ReportCategory.laboratory,
          date: '28 Sep 2026',
          labName: 'Medrix Central Diagnostics Lab',
          orderingDoctor: 'Dr. Sarah Jenkins',
          status: 'Abnormal LDL',
          priority: ReportPriority.high,
          labValues: {
            'Total Cholesterol': '218 mg/dL (High)',
            'LDL Cholesterol': '142 mg/dL (Elevated)',
            'HDL Cholesterol': '44 mg/dL (Desirable)',
            'Triglycerides': '165 mg/dL (Borderline High)',
            'HbA1c': '6.6 % (Good Glycemic Control)',
            'Fasting Blood Sugar': '114 mg/dL',
          },
          attachmentUrl: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=600&q=80',
          attachmentType: 'Lab PDF',
          clinicalNotes: 'Up-titrated Atorvastatin to 40mg daily based on 142 mg/dL LDL target in high-risk patient.',
        ),
        PatientReportModel(
          id: 'REP-702',
          title: '12-Lead Resting Electrocardiogram (ECG)',
          category: ReportCategory.cardiology,
          date: '28 Sep 2026',
          labName: 'Medrix Non-Invasive Cardiac Lab',
          orderingDoctor: 'Dr. Sarah Jenkins',
          status: 'Normal Baseline',
          priority: ReportPriority.normal,
          labValues: {
            'Heart Rate': '74 bpm',
            'PR Interval': '152 ms',
            'QRS Duration': '88 ms',
            'QT/QTc': '390/412 ms',
            'Axis': 'Normal (+45°)',
            'Rhythm': 'Normal Sinus Rhythm',
          },
          attachmentUrl: 'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?w=600&q=80',
          attachmentType: 'ECG Waveform',
          clinicalNotes: 'No acute ST elevation or depression. Mild non-specific T wave flattening in V5-V6.',
        ),
        PatientReportModel(
          id: 'REP-703',
          title: 'Chest Radiograph PA View',
          category: ReportCategory.radiology,
          date: '10 Jan 2026',
          labName: 'Medrix Radiology Wing',
          orderingDoctor: 'Dr. Vikram Malhotra',
          status: 'Normal',
          priority: ReportPriority.normal,
          labValues: {
            'Lungs': 'Clear vascular markings without consolidation or effusion',
            'Heart Size': 'Normal cardiothoracic ratio (< 0.50)',
            'Mediastinum': 'Unremarkable',
            'Bony Cage': 'Intact rib structure',
          },
          attachmentUrl: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?w=600&q=80',
          attachmentType: 'X-Ray Scan',
          clinicalNotes: 'Normal baseline chest film.',
        ),
      ],
      prescriptions: const [
        PatientPrescriptionModel(
          id: 'RX-9082',
          prescriptionDate: '28 Sep 2026',
          doctorName: 'Dr. Sarah Jenkins',
          department: 'Cardiology',
          diagnosis: 'Exertional Angina & Dyslipidemia',
          isActive: true,
          validityUntil: '28 Dec 2026',
          generalInstructions:
              'Take cholesterol medication strictly at bedtime. Avoid grapefruit juice. Continue low-salt diabetic diet.',
          medications: [
            PrescriptionMedicationItem(
              drugName: 'Atorvastatin',
              dosage: '40 mg',
              frequency: 'Once Daily (OD)',
              duration: '90 Days',
              timing: 'Night / After Dinner',
              specialInstructions: 'Increased from 20mg to lower target LDL < 100 mg/dL',
            ),
            PrescriptionMedicationItem(
              drugName: 'Metoprolol Succinate ER',
              dosage: '50 mg',
              frequency: 'Twice Daily (BD)',
              duration: '90 Days',
              timing: 'Morning & Evening',
              specialInstructions: 'Do not discontinue abruptly',
            ),
            PrescriptionMedicationItem(
              drugName: 'Metformin HCl',
              dosage: '500 mg',
              frequency: 'Twice Daily (BD)',
              duration: '90 Days',
              timing: 'With Meals',
              specialInstructions: 'Maintain glycemic log',
            ),
            PrescriptionMedicationItem(
              drugName: 'Nitroglycerin Sublingual',
              dosage: '0.5 mg',
              frequency: 'PRN (As Needed)',
              duration: 'Emergency Kit',
              timing: 'Under tongue for acute chest tightness',
              specialInstructions: 'Seek immediate ER if pain persists after 5 mins',
            ),
          ],
        ),
      ],
      appointments: [
        DoctorAppointmentModel(
          id: 'APT-501',
          patient: basePatient,
          appointmentTime: '10:30 AM',
          appointmentType: 'Follow-Up OPD',
          department: 'Cardiology',
          status: AppointmentStatus.upcoming,
          tokenNumber: 'CARD-12',
          isNextUpcoming: true,
          reasonForVisit: 'Review Stress Echocardiogram & Lipid Response',
          consultationMode: 'In-Person OPD',
          date: DateTime.now().add(const Duration(days: 4)),
        ),
        DoctorAppointmentModel(
          id: 'APT-482',
          patient: basePatient,
          appointmentTime: '10:30 AM',
          appointmentType: 'Consultation',
          department: 'Cardiology',
          status: AppointmentStatus.completed,
          tokenNumber: 'CARD-04',
          reasonForVisit: 'Exertional dyspnea & chest tightness',
          consultationMode: 'In-Person OPD',
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
      notes: const [
        PatientNoteModel(
          id: 'NTE-301',
          date: '28 Sep 2026',
          authorDoctor: 'Dr. Sarah Jenkins',
          authorSpecialty: 'Cardiologist',
          content:
              'Patient expresses high compliance but occasional work stress. Wife accompanying during visits. Recommended home BP logging twice daily.',
          isInternalPrivate: true,
          noteType: ClinicalNoteType.internalNote,
        ),
        PatientNoteModel(
          id: 'NTE-302',
          date: '28 Sep 2026',
          authorDoctor: 'Dr. Sarah Jenkins',
          authorSpecialty: 'Cardiologist',
          content:
              'Statin dose escalated to 40mg. Scheduled Treadmill Stress Test for 04 Oct 2026. Advised to avoid heavy unaccustomed weight training.',
          isInternalPrivate: false,
          noteType: ClinicalNoteType.consultationNote,
        ),
      ],
      followUps: const [
        PatientFollowUpModel(
          id: 'FLP-101',
          dueDate: '04 Oct 2026',
          reason: 'Review Stress Echo & Lipid Response to Atorvastatin 40mg',
          doctorName: 'Dr. Sarah Jenkins',
          department: 'Cardiology',
          status: 'Due',
          notes: 'Ensure patient fasting 8 hours if repeat lipid is requested.',
        ),
      ],
      documents: const [
        PatientDocumentModel(
          id: 'DOC-11',
          fileName: 'Previous_Discharge_Summary_2024.pdf',
          fileType: 'PDF Document',
          uploadDate: '15 Jan 2025',
          fileSize: '2.4 MB',
          category: 'Hospital Discharge',
        ),
        PatientDocumentModel(
          id: 'DOC-12',
          fileName: 'Insurance_PreAuth_Cardiology.pdf',
          fileType: 'PDF Document',
          uploadDate: '28 Sep 2026',
          fileSize: '1.1 MB',
          category: 'Insurance',
        ),
        PatientDocumentModel(
          id: 'DOC-13',
          fileName: 'Holter_24Hour_ECG_Trace.dicom',
          fileType: 'DICOM Image',
          uploadDate: '28 Sep 2026',
          fileSize: '18.5 MB',
          category: 'Diagnostics',
        ),
      ],
    );
  }

  // Serverpod Service APIs
  Future<PatientProfileFullModel> getPatientProfile(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 150));
    return _patientProfileData;
  }

  Future<List<MedicalHistoryItemModel>> getPatientMedicalHistory(
    String patientId, {
    MedicalHistoryCategory category = MedicalHistoryCategory.all,
  }) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    if (category == MedicalHistoryCategory.all) {
      return _patientProfileData.medicalHistory;
    }
    return _patientProfileData.medicalHistory.where((m) => m.category == category).toList();
  }

  Future<List<PatientConsultationRecordModel>> getPatientConsultations(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return _patientProfileData.consultations;
  }

  Future<List<PatientReportModel>> getPatientReports(
    String patientId, {
    ReportCategory category = ReportCategory.all,
  }) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    if (category == ReportCategory.all) {
      return _patientProfileData.reports;
    }
    return _patientProfileData.reports.where((r) => r.category == category).toList();
  }

  Future<List<PatientPrescriptionModel>> getPatientPrescriptions(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return _patientProfileData.prescriptions;
  }

  Future<List<DoctorAppointmentModel>> getPatientAppointments(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return _patientProfileData.appointments;
  }

  Future<List<PatientNoteModel>> getPatientNotes(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return _patientProfileData.notes;
  }

  Future<List<PatientFollowUpModel>> getPatientFollowUps(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 100));
    return _patientProfileData.followUps;
  }

  Future<AIPatientSummaryModel> generatePatientSummary(String patientId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 300));
    return _patientProfileData.summary;
  }

  Future<PatientNoteModel> addClinicalNote({
    required String patientId,
    required String content,
    required bool isInternalPrivate,
    required ClinicalNoteType noteType,
  }) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 200));

    final newNote = PatientNoteModel(
      id: 'NTE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: 'Today',
      authorDoctor: 'Dr. Sarah Jenkins',
      authorSpecialty: 'Cardiologist',
      content: content,
      isInternalPrivate: isInternalPrivate,
      noteType: noteType,
    );

    final updatedNotes = [newNote, ..._patientProfileData.notes];
    _patientProfileData = PatientProfileFullModel(
      patient: _patientProfileData.patient,
      currentVitals: _patientProfileData.currentVitals,
      activeEmergency: _patientProfileData.activeEmergency,
      summary: _patientProfileData.summary,
      medicalHistory: _patientProfileData.medicalHistory,
      consultations: _patientProfileData.consultations,
      reports: _patientProfileData.reports,
      prescriptions: _patientProfileData.prescriptions,
      appointments: _patientProfileData.appointments,
      notes: updatedNotes,
      followUps: _patientProfileData.followUps,
      documents: _patientProfileData.documents,
    );

    return newNote;
  }

  Future<PatientPrescriptionModel> createPrescription({
    required String patientId,
    required String diagnosis,
    required List<PrescriptionMedicationItem> medications,
    required String generalInstructions,
  }) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 250));

    final newRx = PatientPrescriptionModel(
      id: 'RX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      prescriptionDate: 'Today',
      doctorName: 'Dr. Sarah Jenkins',
      department: 'Cardiology',
      diagnosis: diagnosis,
      medications: medications,
      generalInstructions: generalInstructions,
      isActive: true,
      validityUntil: '30 Days',
    );

    final updatedRx = [newRx, ..._patientProfileData.prescriptions];
    _patientProfileData = PatientProfileFullModel(
      patient: _patientProfileData.patient,
      currentVitals: _patientProfileData.currentVitals,
      activeEmergency: _patientProfileData.activeEmergency,
      summary: _patientProfileData.summary,
      medicalHistory: _patientProfileData.medicalHistory,
      consultations: _patientProfileData.consultations,
      reports: _patientProfileData.reports,
      prescriptions: updatedRx,
      appointments: _patientProfileData.appointments,
      notes: _patientProfileData.notes,
      followUps: _patientProfileData.followUps,
      documents: _patientProfileData.documents,
    );

    return newRx;
  }

  Future<void> markFollowUpCompleted(String followUpId) async {
    _ensureInitialized();
    await Future.delayed(const Duration(milliseconds: 150));

    final updatedFollowUps = _patientProfileData.followUps.map((f) {
      if (f.id == followUpId) {
        return f.copyWith(status: 'Completed');
      }
      return f;
    }).toList();

    _patientProfileData = PatientProfileFullModel(
      patient: _patientProfileData.patient.copyWith(followUpStatus: 'Completed'),
      currentVitals: _patientProfileData.currentVitals,
      activeEmergency: _patientProfileData.activeEmergency,
      summary: _patientProfileData.summary,
      medicalHistory: _patientProfileData.medicalHistory,
      consultations: _patientProfileData.consultations,
      reports: _patientProfileData.reports,
      prescriptions: _patientProfileData.prescriptions,
      appointments: _patientProfileData.appointments,
      notes: _patientProfileData.notes,
      followUps: updatedFollowUps,
      documents: _patientProfileData.documents,
    );
  }
}
