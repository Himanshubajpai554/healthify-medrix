import 'package:flutter/material.dart';
import '../../core/provider/repository_provider.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/patient_profile_models.dart';
import 'doctor_clinical_records_service.dart';

class DoctorPatientService {
  static final DoctorPatientService _instance = DoctorPatientService._internal();
  factory DoctorPatientService() => _instance;
  DoctorPatientService._internal();

  // ---------------------------------------------------------------------------
  // Live-data helpers
  // ---------------------------------------------------------------------------

  bool get _isLive => RepositoryContainer.instance.serverpodClient != null;

  /// Builds a full patient chart from server-backed hospital operational records
  /// that belong to this doctor's authenticated hospital tenant.
  Future<PatientProfileFullModel> _loadLivePatientProfile(String patientId) async {
    final container = RepositoryContainer.instance;
    final records = container.hospitalOperationalRepository!;
    final patientRow = await records.get('patients', patientId);
    final appointmentRows = (await records.list('appointments', limit: 500))
        .where((row) => '${row['patientId'] ?? ''}' == patientId).toList();
    final prescriptionRows = (await records.list('prescriptions', limit: 500))
        .where((row) => '${row['patientId'] ?? ''}' == patientId).toList();
    final reportRows = (await records.list('diagnosticReports', limit: 500))
        .where((row) => '${row['patientId'] ?? ''}' == patientId).toList();
    final emergencyRows = (await records.list('emergencies', limit: 500))
        .where((row) => '${row['patientId'] ?? ''}' == patientId).toList();
    final now = DateTime.now();
    final patientMap = patientRow ?? <String, dynamic>{};
    final name =
        '${patientMap['name'] ?? appointmentRows.firstOrNull?['patientName'] ?? 'Patient'}';
    final patient = PatientModel(
      id: patientId,
      name: name,
      age: (patientMap['age'] as num?)?.toInt() ?? 0,
      gender: '${patientMap['gender'] ?? 'Not reported'}',
      avatarUrl: '${patientMap['profileImage'] ?? ''}',
      phone: '${patientMap['phone'] ?? ''}',
      bloodGroup: '${patientMap['bloodGroup'] ?? ''}',
      mrn: '${patientMap['mrn'] ?? patientMap['mrnNumber'] ?? patientId}',
      allergies:
          (patientMap['allergies'] as List? ?? const []).map((e) => '$e').toList(),
      chronicConditions:
          (patientMap['chronicConditions'] as List? ?? const []).map((e) => '$e').toList(),
      currentMedications:
          (patientMap['currentMedications'] as List? ?? const []).map((e) => '$e').toList(),
      lastVisitDate: appointmentRows.isEmpty
          ? 'Not available'
          : '${appointmentRows.first['dateTime'] ?? ''}',
      lastVisitDoctor: container.currentDoctorName,
      primaryConcern:
          '${appointmentRows.firstOrNull?['reason'] ?? patientMap['diagnosis'] ?? ''}',
      department:
          '${appointmentRows.firstOrNull?['department'] ?? container.currentDoctorSpecialty}',
    );
    final appointments = appointmentRows.map((row) {
      final date = DateTime.tryParse('${row['dateTime'] ?? ''}') ?? now;
      final statusText = '${row['status'] ?? ''}'.toLowerCase();
      final status = switch (statusText) {
        'pending' || 'waiting' => AppointmentStatus.waiting,
        'checkedin' || 'checked_in' => AppointmentStatus.checkedIn,
        'inconsultation' || 'in_consultation' => AppointmentStatus.inConsultation,
        'completed' => AppointmentStatus.completed,
        'cancelled' => AppointmentStatus.cancelled,
        'noshow' || 'no_show' => AppointmentStatus.noShow,
        _ => AppointmentStatus.upcoming,
      };
      final appointmentTime = TimeOfDay.fromDateTime(date);
      final displayHour =
          appointmentTime.hourOfPeriod == 0 ? 12 : appointmentTime.hourOfPeriod;
      final displayTime =
          '$displayHour:${appointmentTime.minute.toString().padLeft(2, '0')} '
          '${appointmentTime.period == DayPeriod.am ? 'AM' : 'PM'}';
      return DoctorAppointmentModel(
        id: '${row['id'] ?? ''}',
        patient: patient,
        appointmentTime: displayTime,
        appointmentType: '${row['type'] ?? 'Consultation'}',
        department: '${row['department'] ?? patient.department}',
        status: status,
        tokenNumber: '',
        reasonForVisit: '${row['reason'] ?? ''}',
        date: date,
      );
    }).toList();
    final consultations = appointments
        .where((a) => a.status == AppointmentStatus.completed)
        .map(
          (appointment) => PatientConsultationRecordModel(
            id: appointment.id,
            date: appointment.date.toLocal().toString().split(' ').first,
            time: appointment.appointmentTime,
            doctorName: container.currentDoctorName,
            doctorSpecialty: container.currentDoctorSpecialty,
            department: appointment.department,
            chiefComplaint: appointment.reasonForVisit,
            diagnosis: '',
            vitals: const {},
            clinicalNotes: appointment.reasonForVisit,
            prescribedMedications: const [],
            status: 'Completed',
          ),
        )
        .toList();
    final prescriptions = prescriptionRows.map((row) {
      final signed =
          DateTime.tryParse('${row['signedAt'] ?? row['createdAt'] ?? ''}') ?? now;
      final medications =
          (row['medications'] as List? ?? const []).whereType<Map>().map((med) =>
              PrescriptionMedicationItem(
                drugName: '${med['medicationName'] ?? ''}',
                dosage: '${med['dosage'] ?? ''}',
                frequency: '${med['frequency'] ?? ''}',
                duration: '${med['duration'] ?? med['durationDays'] ?? ''}',
                timing: '${med['instructions'] ?? ''}',
              )).toList();
      return PatientPrescriptionModel(
        id: '${row['id'] ?? ''}',
        prescriptionDate: signed.toLocal().toString(),
        doctorName: '${row['doctorName'] ?? container.currentDoctorName}',
        department: '${row['department'] ?? patient.department}',
        diagnosis: '${row['clinicalNotes'] ?? ''}',
        medications: medications,
        generalInstructions: '${row['instructions'] ?? ''}',
        isActive: '${row['status']}' == 'active',
        validityUntil: '',
      );
    }).toList();
    final reports = reportRows.map((row) {
      final reportDate =
          DateTime.tryParse('${row['date'] ?? row['uploadedAt'] ?? ''}') ?? now;
      final categoryName = '${row['reportType'] ?? 'other'}';
      final category = ReportCategory.values
              .where(
                  (item) => item.name.toLowerCase() == categoryName.toLowerCase())
              .firstOrNull ??
          ReportCategory.all;
      final reportStatus = '${row['verificationStatus'] ?? row['status'] ?? ''}'.toLowerCase();
      return PatientReportModel(
        id: '${row['id'] ?? ''}',
        title: '${row['title'] ?? ''}',
        category: category,
        date: reportDate.toLocal().toString(),
        labName: '${row['facility'] ?? ''}',
        orderingDoctor: '${row['orderingDoctorId'] ?? ''}',
        status: reportStatus == 'verified' || reportStatus == 'released'
            ? 'Reviewed'
            : 'Pending Review',
        priority: row['isCritical'] == true ? ReportPriority.urgent : ReportPriority.normal,
        labValues: Map<String, String>.from(
            (row['resultData'] as Map? ?? const {}).map((k, v) => MapEntry('$k', '$v'))),
        attachmentUrl: row['reportUrl'] as String?,
        clinicalNotes: row['summary'] as String?,
      );
    }).toList();
    final notes = await DoctorClinicalRecordsService.instance.getNotes(patientId);
    final vitals = Map<String, String>.from(
        (patientMap['vitals'] as Map? ?? const {}).map((k, v) => MapEntry('$k', '$v')));
    final summary = AIPatientSummaryModel(
      patient: patient,
      previousVisitsCount:
          appointments.where((a) => a.status == AppointmentStatus.completed).length,
      recentLabReportsCount: reports.length,
      currentMedications: prescriptions
          .where((rx) => rx.isActive)
          .expand((rx) => rx.medications)
          .map((m) => '${m.drugName} ${m.dosage}')
          .toList(),
      lastConsultationText: appointments
              .where((a) => a.status == AppointmentStatus.completed)
              .firstOrNull
              ?.reasonForVisit ??
          'No completed consultation is recorded.',
      recentReportAttention:
          reports.isEmpty ? 'No reports are recorded.' : reports.first.title,
      keyFindings:
          "Loaded from this hospital's patient, appointment, report, prescription, "
          "and clinical-note records.",
    );
    final activeEmergencyRow = emergencyRows
        .where((row) => !{'discharged', 'resolved', 'cancelled'}
            .contains('${row['status']}'.toLowerCase()))
        .firstOrNull;
    final emergency = activeEmergencyRow == null
        ? null
        : DoctorEmergencyCaseModel(
            id: '${activeEmergencyRow['id'] ?? ''}',
            patient: patient,
            severity: '${activeEmergencyRow['priority']}'.toLowerCase().contains('immediate')
                ? EmergencySeverity.critical
                : EmergencySeverity.high,
            arrivalTime: '${activeEmergencyRow['arrivalTime'] ?? ''}',
            assignedBed: '${activeEmergencyRow['location'] ?? ''}',
            department: '${activeEmergencyRow['department'] ?? patient.department}',
            assignedDoctor:
                '${activeEmergencyRow['assignedDoctor'] ?? container.currentDoctorName}',
            currentStatus: '${activeEmergencyRow['status'] ?? ''}',
          );
    final history = <MedicalHistoryItemModel>[
      for (final apt in appointments.where((a) => a.status == AppointmentStatus.completed))
        MedicalHistoryItemModel(
          id: apt.id,
          date: apt.date.toLocal().toString(),
          title: 'Consultation',
          category: MedicalHistoryCategory.consultation,
          doctorName: container.currentDoctorName,
          department: apt.department,
          summary: apt.reasonForVisit,
          status: 'Completed',
          icon: Icons.medical_services_rounded,
          badgeColor: const Color(0xFF0D9488),
        ),
      for (final report in reports)
        MedicalHistoryItemModel(
          id: report.id,
          date: report.date,
          title: report.title,
          category: MedicalHistoryCategory.report,
          doctorName: report.orderingDoctor,
          department: report.category.name,
          summary: report.clinicalNotes ?? '',
          status: report.status,
          icon: Icons.science_rounded,
          badgeColor: const Color(0xFF3B82F6),
        ),
    ];
    return PatientProfileFullModel(
      patient: patient,
      currentVitals: vitals,
      activeEmergency: emergency,
      summary: summary,
      medicalHistory: history,
      consultations: consultations,
      reports: reports,
      prescriptions: prescriptions,
      appointments: appointments,
      notes: notes,
      followUps: const [],
      documents: const [],
    );
  }

  // ---------------------------------------------------------------------------
  // Demo-mode fallback — used ONLY when no Serverpod client is active.
  // Fields are clearly labelled "[DEMO]" so they can never be mistaken for
  // real patient records.
  // ---------------------------------------------------------------------------

  static const PatientModel _demoPatient = PatientModel(
    id: 'PAT-DEMO-001',
    name: '[DEMO] Rahul Sharma',
    age: 42,
    gender: 'Male',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    phone: '+91 98765 12345',
    bloodGroup: 'B+',
    mrn: 'MRN-DEMO-001',
    allergies: ['Penicillin', 'Sulfa Drugs'],
    chronicConditions: ['Hypertension (Stage 1)', 'Type 2 Diabetes'],
    currentMedications: [
      'Atorvastatin 20mg (OD)',
      'Metoprolol 50mg (BD)',
      'Metformin 500mg (BD)',
    ],
    lastVisitDate: 'Sep 28',
    lastVisitDoctor: 'Dr. Sarah Jenkins',
    primaryConcern: '[DEMO] Post-ECG chest tightness, mild exertional dyspnea',
    careStatus: PatientCareStatus.followUpDue,
    nextAppointmentText: 'Oct 02, 10:30 AM',
    followUpStatus: 'Due',
    department: 'Cardiology',
    clinicalAlerts: ['[DEMO] Sample Record'],
  );

  static PatientProfileFullModel _buildDemoProfile() {
    final base = _demoPatient;
    return PatientProfileFullModel(
      patient: base,
      currentVitals: const {
        'Blood Pressure': '[DEMO] 138/88 mmHg',
        'Heart Rate': '[DEMO] 74 bpm',
        'SpO2': '[DEMO] 98%',
        'Temperature': '[DEMO] 98.4 °F',
      },
      activeEmergency: null,
      summary: AIPatientSummaryModel(
        patient: base,
        previousVisitsCount: 0,
        recentLabReportsCount: 0,
        currentMedications: const [],
        lastConsultationText: '[DEMO MODE — connect to backend to see real data]',
        recentReportAttention: '[DEMO MODE]',
        keyFindings:
            '[DEMO MODE — no real clinical data is loaded in offline mode]',
      ),
      medicalHistory: const [],
      consultations: const [],
      reports: const [],
      prescriptions: const [],
      appointments: const [],
      notes: const [],
      followUps: const [],
      documents: const [],
    );
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  Future<PatientProfileFullModel> getPatientProfile(String patientId) async {
    if (_isLive) return _loadLivePatientProfile(patientId);
    await Future.delayed(const Duration(milliseconds: 150));
    return _buildDemoProfile();
  }

  Future<List<MedicalHistoryItemModel>> getPatientMedicalHistory(
    String patientId, {
    MedicalHistoryCategory category = MedicalHistoryCategory.all,
  }) async {
    if (_isLive) {
      final profile = await _loadLivePatientProfile(patientId);
      if (category == MedicalHistoryCategory.all) return profile.medicalHistory;
      return profile.medicalHistory.where((m) => m.category == category).toList();
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return const [];
  }

  Future<List<PatientConsultationRecordModel>> getPatientConsultations(
      String patientId) async {
    if (_isLive) {
      final profile = await _loadLivePatientProfile(patientId);
      return profile.consultations;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return const [];
  }

  Future<List<PatientReportModel>> getPatientReports(
    String patientId, {
    ReportCategory category = ReportCategory.all,
  }) async {
    if (_isLive) {
      final profile = await _loadLivePatientProfile(patientId);
      if (category == ReportCategory.all) return profile.reports;
      return profile.reports.where((r) => r.category == category).toList();
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return const [];
  }

  Future<List<PatientPrescriptionModel>> getPatientPrescriptions(
      String patientId) async {
    if (_isLive) {
      final profile = await _loadLivePatientProfile(patientId);
      return profile.prescriptions;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return const [];
  }

  Future<List<DoctorAppointmentModel>> getPatientAppointments(
      String patientId) async {
    if (_isLive) {
      final profile = await _loadLivePatientProfile(patientId);
      return profile.appointments;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return const [];
  }

  Future<List<PatientNoteModel>> getPatientNotes(String patientId) async {
    if (_isLive) {
      return DoctorClinicalRecordsService.instance.getNotes(patientId);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return const [];
  }

  Future<List<PatientFollowUpModel>> getPatientFollowUps(String patientId) async {
    if (_isLive) {
      final profile = await _loadLivePatientProfile(patientId);
      return profile.followUps;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    return const [];
  }

  Future<AIPatientSummaryModel> generatePatientSummary(String patientId) async {
    if (_isLive) {
      final profile = await _loadLivePatientProfile(patientId);
      return profile.summary;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    return _buildDemoProfile().summary;
  }

  // ---------------------------------------------------------------------------
  // Write paths
  // ---------------------------------------------------------------------------

  Future<PatientNoteModel> addClinicalNote({
    required String patientId,
    required String content,
    required bool isInternalPrivate,
    required ClinicalNoteType noteType,
  }) async {
    if (_isLive) {
      final container = RepositoryContainer.instance;
      // Build a thin PatientModel for note metadata; full chart is not needed.
      final patientMap =
          await container.hospitalOperationalRepository!.get('patients', patientId) ??
              <String, dynamic>{};
      final patient = PatientModel(
        id: patientId,
        name: '${patientMap['name'] ?? 'Unknown Patient'}',
        age: 0,
        gender: '',
        avatarUrl: '',
        phone: '',
        bloodGroup: '',
        mrn: patientId,
        allergies: const [],
        chronicConditions: const [],
        currentMedications: const [],
        lastVisitDate: '',
        lastVisitDoctor: '',
        primaryConcern: '',
        department: '',
      );
      await DoctorClinicalRecordsService.instance.saveNote(
        patient: patient,
        patientRecordId: patientId,
        type: noteType,
        content: content,
      );
      final notes = await DoctorClinicalRecordsService.instance.getNotes(patientId);
      if (notes.isNotEmpty) return notes.first;
      throw StateError('Clinical note was not returned after saving.');
    }
    await Future.delayed(const Duration(milliseconds: 200));
    return PatientNoteModel(
      id: 'NTE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: 'Today',
      authorDoctor: '[DEMO]',
      authorSpecialty: '[DEMO]',
      content: content,
      isInternalPrivate: isInternalPrivate,
      noteType: noteType,
    );
  }

  Future<PatientPrescriptionModel> createPrescription({
    required String patientId,
    required String diagnosis,
    required List<PrescriptionMedicationItem> medications,
    required String generalInstructions,
  }) async {
    if (_isLive) {
      final container = RepositoryContainer.instance;
      final records = container.hospitalOperationalRepository!;
      final patientMap =
          await records.get('patients', patientId) ?? <String, dynamic>{};
      final now = DateTime.now().toUtc();
      final id = 'RX-${now.microsecondsSinceEpoch}';
      await records.save('prescriptions', id, {
        'id': id,
        'patientId': patientId,
        'patientName': '${patientMap['name'] ?? 'Unknown Patient'}',
        'doctorId': container.currentDoctorId,
        'doctorName': container.currentDoctorName,
        'department': container.currentDoctorSpecialty,
        'signedAt': now.toIso8601String(),
        'status': 'active',
        'clinicalNotes': diagnosis,
        'instructions': generalInstructions,
        'medications': medications
            .map((m) => {
                  'medicationName': m.drugName,
                  'dosage': m.dosage,
                  'frequency': m.frequency,
                  'duration': m.duration,
                  'durationDays': int.tryParse(
                          RegExp(r'\d+').firstMatch(m.duration)?.group(0) ?? '') ??
                      0,
                  'instructions': m.timing,
                })
            .toList(),
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
      return PatientPrescriptionModel(
        id: id,
        prescriptionDate: now.toLocal().toString(),
        doctorName: container.currentDoctorName,
        department: container.currentDoctorSpecialty,
        diagnosis: diagnosis,
        medications: medications,
        generalInstructions: generalInstructions,
        isActive: true,
        validityUntil: '90 Days',
      );
    }
    await Future.delayed(const Duration(milliseconds: 250));
    return PatientPrescriptionModel(
      id: 'RX-DEMO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      prescriptionDate: 'Today',
      doctorName: '[DEMO]',
      department: '[DEMO]',
      diagnosis: diagnosis,
      medications: medications,
      generalInstructions: generalInstructions,
      isActive: true,
      validityUntil: '30 Days',
    );
  }

  Future<void> markFollowUpCompleted(String followUpId) async {
    if (_isLive) {
      final records = RepositoryContainer.instance.hospitalOperationalRepository!;
      final row = await records.get('doctorFollowUps', followUpId);
      if (row != null) {
        await records.save('doctorFollowUps', followUpId, {
          ...row,
          'status': 'Completed',
          'completedAt': DateTime.now().toUtc().toIso8601String(),
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        });
      }
      return;
    }
    await Future.delayed(const Duration(milliseconds: 150));
    // No-op in demo mode — no in-memory state to mutate.
  }
}
