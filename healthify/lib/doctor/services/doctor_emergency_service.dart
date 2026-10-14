import '../models/emergency_models.dart';
import '../../core/provider/repository_provider.dart';

class DoctorEmergencyService {
  static final DoctorEmergencyService _instance = DoctorEmergencyService._internal();
  factory DoctorEmergencyService() => _instance;
  DoctorEmergencyService._internal();

  final List<DoctorEmergencyCaseFullModel> _cases = [
    DoctorEmergencyCaseFullModel(
      id: 'EMR-2026-0042',
      patientId: 'MED-PAT-10482',
      patientName: 'Rahul Sharma',
      patientAge: 42,
      patientGender: 'Male',
      bloodGroup: 'B+',
      allergies: ['Penicillin'],
      knownConditions: ['Hypertension', 'Type 2 Diabetes Mellitus'],
      currentMedications: ['Amlodipine 5mg OD', 'Atorvastatin 10mg OD', 'Metformin 500mg BD'],
      emergencyContactName: 'Sunita Sharma',
      emergencyContactRelation: 'Spouse',
      emergencyContactPhone: '+91 98765 43210',
      arrivalTime: DateTime.now().subtract(const Duration(minutes: 45)),
      arrivalMethod: 'Ambulance - 108',
      referralSource: 'Self / Direct ER Walk-in',
      emergencyReason: 'Acute retrosternal chest pain radiating to left arm with diaphoresis.',
      patientReportedInfo: 'Severe pressure-like precordial pain started 1 hour ago while climbing stairs. Associated with nausea.',
      arrivalNotes: 'Triage Nurse K. Nair recorded elevated BP and tachycardia. ECG dispatched immediately.',
      priority: EmergencyOperationalPriority.immediate,
      status: EmergencyCaseStatus.inTreatment,
      assignedDoctor: 'Dr. Sarah Jenkins',
      department: 'Cardiology',
      location: 'Emergency Bay 01 (Resuscitation)',
      observations: EmergencyObservationsModel(
        bpSystolic: '158',
        bpDiastolic: '96',
        heartRate: '104',
        temperature: '37.1',
        respiratoryRate: '22',
        oxygenSaturation: '96',
        weight: '78',
        additionalObservations: 'Diaphoretic, mild distress. S1/S2 heard. Lungs clear to auscultation bilaterally.',
        recordedBy: 'Nurse K. Nair',
        recordedAt: DateTime.now().subtract(const Duration(minutes: 38)),
      ),
      notes: [
        EmergencyNoteModel(
          id: 'NOTE-101',
          noteType: EmergencyNoteType.emergencyNote,
          content: 'Initial STAT ECG shows ST segment elevation in leads V2-V5. Aspirin 325mg and Clopidogrel 300mg loading dose administered.',
          isInternalPrivate: true,
          author: 'Dr. Sarah Jenkins',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        EmergencyNoteModel(
          id: 'NOTE-102',
          noteType: EmergencyNoteType.clinicalNote,
          content: 'Cath lab alerted for primary PCI activation.',
          isInternalPrivate: true,
          author: 'Dr. Sarah Jenkins',
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
      timeline: [
        EmergencyTimelineItem(
          id: 'TL-1',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          actor: 'ER Triage Desk',
          action: 'Patient registered at ER desk',
          optionalNote: 'Arrived via 108 Ambulance service',
        ),
        EmergencyTimelineItem(
          id: 'TL-2',
          timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
          actor: 'Triage Nurse K. Nair',
          action: 'Emergency case EMR-2026-0042 created with Immediate priority',
        ),
        EmergencyTimelineItem(
          id: 'TL-3',
          timestamp: DateTime.now().subtract(const Duration(minutes: 38)),
          actor: 'System',
          action: 'Assigned to Lead Cardiologist Dr. Sarah Jenkins',
        ),
        EmergencyTimelineItem(
          id: 'TL-4',
          timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
          actor: 'Nurse K. Nair',
          action: 'Initial STAT vitals recorded',
        ),
        EmergencyTimelineItem(
          id: 'TL-5',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          actor: 'Dr. Sarah Jenkins',
          action: 'Emergency Consultation initiated',
        ),
      ],
      consultationId: 'CON-10029',
      attachedReportIds: ['REP-20260928-001', 'REP-20260928-002'],
      attachedPrescriptionIds: ['RX-2026-00982'],
      auditHistory: [
        EmergencyTimelineItem(
          id: 'AUD-EMR-1',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          actor: 'ER Desk',
          action: 'Case Created',
        ),
        EmergencyTimelineItem(
          id: 'AUD-EMR-2',
          timestamp: DateTime.now().subtract(const Duration(minutes: 38)),
          actor: 'Emergency Desk',
          action: 'Doctor Assigned',
        ),
      ],
    ),
    DoctorEmergencyCaseFullModel(
      id: 'EMR-2026-0043',
      patientId: 'MED-PAT-10391',
      patientName: 'Priya Patel',
      patientAge: 38,
      patientGender: 'Female',
      bloodGroup: 'O+',
      allergies: ['NSAIDs', 'Aspirin'],
      knownConditions: ['Migraine with Aura'],
      currentMedications: ['Propranolol 40mg BD'],
      emergencyContactName: 'Rajesh Patel',
      emergencyContactRelation: 'Spouse',
      emergencyContactPhone: '+91 98123 45678',
      arrivalTime: DateTime.now().subtract(const Duration(minutes: 20)),
      arrivalMethod: 'Self Walk-in',
      referralSource: 'Self',
      emergencyReason: 'Severe refractory headache with photo/phonophobia and nausea.',
      patientReportedInfo: 'Unrelenting throbbing left temporal headache for 6 hours, unresponsive to oral analgesics.',
      arrivalNotes: 'Patient sitting in quiet triage holding room. Neurologic screening intact.',
      priority: EmergencyOperationalPriority.high,
      status: EmergencyCaseStatus.waiting,
      assignedDoctor: 'Dr. Sarah Jenkins',
      department: 'Neurology / ER',
      location: 'Emergency Waiting Area - Station B',
      observations: EmergencyObservationsModel(
        bpSystolic: '132',
        bpDiastolic: '84',
        heartRate: '82',
        temperature: '36.8',
        respiratoryRate: '18',
        oxygenSaturation: '99',
        weight: '62',
        additionalObservations: 'Cranial nerves II-XII grossly intact. No nuchal rigidity.',
        recordedBy: 'Nurse R. Deshmukh',
        recordedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      notes: [],
      timeline: [
        EmergencyTimelineItem(
          id: 'TL-10',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          actor: 'ER Registration',
          action: 'Patient registered',
        ),
        EmergencyTimelineItem(
          id: 'TL-11',
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
          actor: 'Nurse R. Deshmukh',
          action: 'Vitals entered. Case status set to Waiting.',
        ),
      ],
      attachedReportIds: ['REP-20260927-003'],
      attachedPrescriptionIds: ['RX-2026-00975'],
      auditHistory: [
        EmergencyTimelineItem(
          id: 'AUD-43-1',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          actor: 'ER Desk',
          action: 'Case Created',
        ),
      ],
    ),
    DoctorEmergencyCaseFullModel(
      id: 'EMR-2026-0044',
      patientId: 'MED-PAT-10519',
      patientName: 'Amit Verma',
      patientAge: 56,
      patientGender: 'Male',
      bloodGroup: 'A+',
      allergies: [],
      knownConditions: ['Chronic Kidney Disease Stage 2'],
      currentMedications: ['Ramipril 2.5mg OD'],
      emergencyContactName: 'Deepa Verma',
      emergencyContactRelation: 'Spouse',
      emergencyContactPhone: '+91 99887 76655',
      arrivalTime: DateTime.now().subtract(const Duration(hours: 2)),
      arrivalMethod: 'Private Vehicle',
      referralSource: 'OPD Doctor Referral',
      emergencyReason: 'Hypertensive urgency (BP 185/110 mmHg) without acute target organ damage.',
      patientReportedInfo: 'Mild occipital headache after missing evening blood pressure medication.',
      arrivalNotes: 'Patient seated comfortably. Oral antihypertensive administered in ER.',
      priority: EmergencyOperationalPriority.standard,
      status: EmergencyCaseStatus.observation,
      assignedDoctor: 'Dr. Sarah Jenkins',
      department: 'General Medicine',
      location: 'Observation Bay 03',
      observations: EmergencyObservationsModel(
        bpSystolic: '154',
        bpDiastolic: '92',
        heartRate: '76',
        temperature: '36.9',
        respiratoryRate: '16',
        oxygenSaturation: '98',
        weight: '82',
        additionalObservations: 'BP improving following oral antihypertensive dose. Repeat reading scheduled in 30 mins.',
        recordedBy: 'Dr. Sarah Jenkins',
        recordedAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      notes: [
        EmergencyNoteModel(
          id: 'NOTE-301',
          noteType: EmergencyNoteType.clinicalNote,
          content: 'Repeat BP 154/92 mmHg. Patient asymptomatic. Prepare for discharge with outpatient follow-up.',
          isInternalPrivate: true,
          author: 'Dr. Sarah Jenkins',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
      timeline: [
        EmergencyTimelineItem(
          id: 'TL-20',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          actor: 'ER Desk',
          action: 'Case Created',
        ),
        EmergencyTimelineItem(
          id: 'TL-21',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          actor: 'Dr. Sarah Jenkins',
          action: 'Moved to Observation Bay 03',
        ),
      ],
      attachedReportIds: ['REP-20260927-004'],
      attachedPrescriptionIds: ['RX-2026-00962'],
      auditHistory: [
        EmergencyTimelineItem(
          id: 'AUD-44-1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          actor: 'ER Desk',
          action: 'Case Created',
        ),
      ],
    ),
    DoctorEmergencyCaseFullModel(
      id: 'EMR-2026-0040',
      patientId: 'MED-PAT-10220',
      patientName: 'Ananya Sen',
      patientAge: 29,
      patientGender: 'Female',
      bloodGroup: 'AB+',
      allergies: ['Amoxicillin'],
      knownConditions: ['Gastritis'],
      currentMedications: ['Pantoprazole 40mg OD'],
      emergencyContactName: 'Karan Sen',
      emergencyContactRelation: 'Brother',
      emergencyContactPhone: '+91 97654 32109',
      arrivalTime: DateTime.now().subtract(const Duration(hours: 5)),
      arrivalMethod: 'Self Walk-in',
      referralSource: 'Self',
      emergencyReason: 'Acute epigastric pain & persistent vomiting.',
      patientReportedInfo: 'Severe upper abdominal burning following food intake.',
      arrivalNotes: 'IV hydration completed. Abdominal ultrasound clear. Symptoms fully resolved.',
      priority: EmergencyOperationalPriority.standard,
      status: EmergencyCaseStatus.resolved,
      assignedDoctor: 'Dr. Sarah Jenkins',
      department: 'Gastroenterology / ER',
      location: 'Discharged Home',
      resolutionInfo: EmergencyResolutionInfoModel(
        resolutionNote: 'Epigastric pain resolved post IV PPI and antacids. Discharged with outpatient follow-up.',
        disposition: EmergencyDisposition.discharged,
        resolvedBy: 'Dr. Sarah Jenkins',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      notes: [],
      timeline: [
        EmergencyTimelineItem(
          id: 'TL-30',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          actor: 'ER Desk',
          action: 'Case Created',
        ),
        EmergencyTimelineItem(
          id: 'TL-31',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          actor: 'Dr. Sarah Jenkins',
          action: 'Case Resolved & Discharged Home',
        ),
      ],
      attachedReportIds: ['REP-20260926-005'],
      attachedPrescriptionIds: ['RX-2026-00910'],
      auditHistory: [
        EmergencyTimelineItem(
          id: 'AUD-40-1',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          actor: 'ER Desk',
          action: 'Case Created',
        ),
      ],
    ),
    DoctorEmergencyCaseFullModel(
      id: 'EMR-2026-0038',
      patientId: 'MED-PAT-10115',
      patientName: 'Vikram Malhotra',
      patientAge: 61,
      patientGender: 'Male',
      bloodGroup: 'O-',
      allergies: ['Codeine'],
      knownConditions: ['Osteoarthritis'],
      currentMedications: [],
      emergencyContactName: 'Meera Malhotra',
      emergencyContactRelation: 'Daughter',
      emergencyContactPhone: '+91 98450 12345',
      arrivalTime: DateTime.now().subtract(const Duration(hours: 6)),
      arrivalMethod: 'Ambulance - 108',
      referralSource: 'Community Clinic',
      emergencyReason: 'Suspected hip fracture following accidental slip and fall.',
      patientReportedInfo: 'Severe right groin pain, inability to bear weight on right leg.',
      arrivalNotes: 'X-ray confirmed right femoral neck fracture. Transferred to Orthopedics Trauma Surgery Unit.',
      priority: EmergencyOperationalPriority.high,
      status: EmergencyCaseStatus.transferred,
      assignedDoctor: 'Dr. Sarah Jenkins',
      department: 'Orthopedics / Trauma',
      location: 'Inpatient Ward 4B',
      transferInfo: EmergencyTransferInfoModel(
        transferredToDepartment: 'Orthopedics & Trauma Surgery',
        transferredToDoctor: 'Dr. K. Saxena (Orthopedic Surgeon)',
        transferredToWard: 'Trauma Unit Ward 4B',
        reason: 'Surgical fixation required for acute femoral neck fracture.',
        transferNotes: 'Pre-op clearance completed. Patient handed over to OT team.',
        transferredBy: 'Dr. Sarah Jenkins',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      notes: [],
      timeline: [
        EmergencyTimelineItem(
          id: 'TL-40',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          actor: 'ER Desk',
          action: 'Case Created',
        ),
        EmergencyTimelineItem(
          id: 'TL-41',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          actor: 'Dr. Sarah Jenkins',
          action: 'Transferred to Orthopedics Trauma Unit Ward 4B',
        ),
      ],
      attachedReportIds: ['REP-20260925-006'],
      attachedPrescriptionIds: ['RX-2026-00890'],
      auditHistory: [
        EmergencyTimelineItem(
          id: 'AUD-38-1',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          actor: 'ER Desk',
          action: 'Case Created',
        ),
      ],
    ),
  ];

  Future<List<DoctorEmergencyCaseFullModel>> getEmergencyCases() async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records != null && RepositoryContainer.instance.currentDoctorId.isNotEmpty) {
      final rows = await records.list('emergencies', limit: 500);
      _cases
        ..clear()
        ..addAll(rows.map(_fromRecord));
      return List.unmodifiable(_cases);
    }
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_cases);
  }

  Future<DoctorEmergencyCaseFullModel?> getEmergencyCase(String id) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records != null && RepositoryContainer.instance.currentDoctorId.isNotEmpty) {
      final row = await records.get('emergencies', id);
      return row == null ? null : _fromRecord(row);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _cases.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<DoctorEmergencyCaseFullModel>> searchEmergencyCases(String query) async {
    final all = await getEmergencyCases();
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((c) {
      return c.id.toLowerCase().contains(q) ||
          c.patientName.toLowerCase().contains(q) ||
          c.patientId.toLowerCase().contains(q) ||
          c.emergencyContactPhone.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<DoctorEmergencyCaseFullModel>> filterEmergencyCases({
    EmergencyCaseStatus? status,
    EmergencyOperationalPriority? priority,
    String? department,
    String? assignedDoctor,
  }) async {
    var list = await getEmergencyCases();
    if (status != null) {
      list = list.where((c) => c.status == status).toList();
    }
    if (priority != null) {
      list = list.where((c) => c.priority == priority).toList();
    }
    if (department != null) {
      list = list.where((c) => c.department == department).toList();
    }
    if (assignedDoctor != null) {
      list = list.where((c) => c.assignedDoctor == assignedDoctor).toList();
    }
    return list;
  }

  Future<DoctorEmergencyCaseFullModel> createEmergencyCase(DoctorEmergencyCaseFullModel newCase) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _cases.insert(0, newCase);
    await _persistCase(newCase);
    return newCase;
  }

  Future<void> assignEmergencyDoctor({
    required String caseId,
    required String doctorName,
    required String actor,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _cases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _cases[index];
      final newTimeline = List<EmergencyTimelineItem>.from(old.timeline)
        ..add(
          EmergencyTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: actor,
            action: 'Assigned doctor changed to $doctorName',
          ),
        );
      _cases[index] = old.copyWith(
        assignedDoctor: doctorName,
        timeline: newTimeline,
      );
      await _persistCase(_cases[index]);
    }
  }

  Future<void> updateEmergencyStatus({
    required String caseId,
    required EmergencyCaseStatus newStatus,
    required String reason,
    required String actor,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _cases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _cases[index];
      final newTimeline = List<EmergencyTimelineItem>.from(old.timeline)
        ..add(
          EmergencyTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: actor,
            action: 'Status updated to ${newStatus.label}',
            optionalNote: reason,
          ),
        );
      _cases[index] = old.copyWith(
        status: newStatus,
        timeline: newTimeline,
      );
      await _persistCase(_cases[index]);
    }
  }

  Future<void> addEmergencyObservation({
    required String caseId,
    required EmergencyObservationsModel obs,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _cases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _cases[index];
      final newTimeline = List<EmergencyTimelineItem>.from(old.timeline)
        ..add(
          EmergencyTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: obs.recordedBy,
            action: 'Emergency vitals & observations recorded (BP ${obs.bpText}, HR ${obs.heartRate}bpm)',
          ),
        );
      _cases[index] = old.copyWith(
        observations: obs,
        timeline: newTimeline,
      );
      await _persistCase(_cases[index]);
    }
  }

  Future<void> addEmergencyNote({
    required String caseId,
    required EmergencyNoteModel note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _cases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _cases[index];
      final newNotes = List<EmergencyNoteModel>.from(old.notes)..add(note);
      final newTimeline = List<EmergencyTimelineItem>.from(old.timeline)
        ..add(
          EmergencyTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: note.author,
            action: 'Added ${note.noteType.label} (${note.isInternalPrivate ? "Internal Private" : "Patient Visible"})',
          ),
        );
      _cases[index] = old.copyWith(
        notes: newNotes,
        timeline: newTimeline,
      );
      await _persistCase(_cases[index]);
    }
  }

  Future<void> transferEmergencyCase({
    required String caseId,
    required EmergencyTransferInfoModel transferInfo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _cases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _cases[index];
      final newTimeline = List<EmergencyTimelineItem>.from(old.timeline)
        ..add(
          EmergencyTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: transferInfo.transferredBy,
            action: 'Transferred to ${transferInfo.transferredToDepartment} (${transferInfo.transferredToWard})',
            optionalNote: 'Reason: ${transferInfo.reason}',
          ),
        );
      _cases[index] = old.copyWith(
        status: EmergencyCaseStatus.transferred,
        transferInfo: transferInfo,
        location: transferInfo.transferredToWard,
        timeline: newTimeline,
      );
      await _persistCase(_cases[index]);
    }
  }

  Future<void> resolveEmergencyCase({
    required String caseId,
    required EmergencyResolutionInfoModel resolutionInfo,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _cases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _cases[index];
      final newTimeline = List<EmergencyTimelineItem>.from(old.timeline)
        ..add(
          EmergencyTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: resolutionInfo.resolvedBy,
            action: 'Case Resolved (${resolutionInfo.disposition.label})',
            optionalNote: resolutionInfo.resolutionNote,
          ),
        );
      _cases[index] = old.copyWith(
        status: EmergencyCaseStatus.resolved,
        resolutionInfo: resolutionInfo,
        location: resolutionInfo.disposition.label,
        timeline: newTimeline,
      );
      await _persistCase(_cases[index]);
    }
  }

  Future<void> startEmergencyConsultation({
    required String caseId,
    required String consultationId,
    required String doctorName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _cases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final old = _cases[index];
      final newTimeline = List<EmergencyTimelineItem>.from(old.timeline)
        ..add(
          EmergencyTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: doctorName,
            action: 'Started Emergency Consultation ($consultationId)',
          ),
        );
      _cases[index] = old.copyWith(
        status: EmergencyCaseStatus.inTreatment,
        consultationId: consultationId,
        timeline: newTimeline,
      );
      await _persistCase(_cases[index]);
    }
  }

  Future<void> _persistCase(DoctorEmergencyCaseFullModel item) async {
    final container = RepositoryContainer.instance;
    final records = container.hospitalOperationalRepository;
    final doctorId = container.currentDoctorId;
    if (records == null || doctorId.isEmpty) return;
    final prior = await records.get('emergencies', item.id) ?? <String, dynamic>{};
    final status = switch (item.status) {
      EmergencyCaseStatus.waiting => 'waiting',
      EmergencyCaseStatus.inTreatment => 'inTreatment',
      EmergencyCaseStatus.observation => 'stabilizing',
      EmergencyCaseStatus.transferred => 'transferred',
      EmergencyCaseStatus.resolved => 'discharged',
      EmergencyCaseStatus.cancelled => 'cancelled',
    };
    final now = DateTime.now().toUtc();
    await records.save('emergencies', item.id, {
      ...prior,
      'id': item.id,
      'patientId': item.patientId,
      'patientName': item.patientName,
      'age': item.patientAge,
      'gender': item.patientGender,
      'bloodGroup': item.bloodGroup,
      'allergies': item.allergies,
      'knownConditions': item.knownConditions,
      'currentMedications': item.currentMedications,
      'emergencyContactName': item.emergencyContactName,
      'emergencyContactRelation': item.emergencyContactRelation,
      'emergencyContactPhone': item.emergencyContactPhone,
      'arrivalTime': item.arrivalTime.toUtc().toIso8601String(),
      'arrivalMode': item.arrivalMethod,
      'referralSource': item.referralSource,
      'chiefComplaint': item.emergencyReason,
      'patientReportedInfo': item.patientReportedInfo,
      'arrivalNotes': item.arrivalNotes,
      'priority': item.priority.name,
      'triageLevel': item.priority == EmergencyOperationalPriority.immediate ? 'level1Resuscitation' : item.priority == EmergencyOperationalPriority.high ? 'level2Emergent' : 'level3Urgent',
      'status': status,
      'doctorId': doctorId,
      'assignedDoctorId': doctorId,
      'assignedDoctor': item.assignedDoctor.isEmpty ? container.currentDoctorName : item.assignedDoctor,
      'department': item.department,
      'departmentId': item.department,
      'location': item.location,
      'locationBed': item.location,
      'vitals': item.observations == null ? (prior['vitals'] ?? <String, dynamic>{}) : {
        'bpSystolic': item.observations!.bpSystolic,
        'bpDiastolic': item.observations!.bpDiastolic,
        'heartRate': item.observations!.heartRate,
        'temperature': item.observations!.temperature,
        'respiratoryRate': item.observations!.respiratoryRate,
        'oxygenSaturation': item.observations!.oxygenSaturation,
        'weight': item.observations!.weight,
        'additionalObservations': item.observations!.additionalObservations,
        'recordedBy': item.observations!.recordedBy,
        'recordedAt': item.observations!.recordedAt.toUtc().toIso8601String(),
      },
      'observations': item.observations == null ? null : {
        'bpSystolic': item.observations!.bpSystolic,
        'bpDiastolic': item.observations!.bpDiastolic,
        'heartRate': item.observations!.heartRate,
        'temperature': item.observations!.temperature,
        'respiratoryRate': item.observations!.respiratoryRate,
        'oxygenSaturation': item.observations!.oxygenSaturation,
        'weight': item.observations!.weight,
        'additionalObservations': item.observations!.additionalObservations,
        'recordedBy': item.observations!.recordedBy,
        'recordedAt': item.observations!.recordedAt.toUtc().toIso8601String(),
      },
      'notes': item.notes.map((note) => {
        'id': note.id, 'noteType': note.noteType.name, 'content': note.content,
        'isInternalPrivate': note.isInternalPrivate, 'author': note.author,
        'createdAt': note.createdAt.toUtc().toIso8601String(),
      }).toList(),
      'timeline': item.timeline.map((event) => {
        'id': event.id, 'timestamp': event.timestamp.toUtc().toIso8601String(),
        'actor': event.actor, 'action': event.action, 'optionalNote': event.optionalNote,
      }).toList(),
      'consultationId': item.consultationId,
      'attachedReportIds': item.attachedReportIds,
      'attachedPrescriptionIds': item.attachedPrescriptionIds,
      'updatedAt': now.toIso8601String(),
      'createdAt': prior['createdAt'] ?? item.arrivalTime.toUtc().toIso8601String(),
    });
  }

  DoctorEmergencyCaseFullModel _fromRecord(Map<String, dynamic> row) {
    String str(Object? value, [String fallback = '']) => value?.toString() ?? fallback;
    DateTime date(Object? value) => DateTime.tryParse(str(value)) ?? DateTime.now();
    final priorityValue = str(row['priority'] ?? row['triageLevel']).toLowerCase();
    final priority = priorityValue.contains('immediate') || priorityValue.contains('level1')
        ? EmergencyOperationalPriority.immediate
        : priorityValue.contains('high') || priorityValue.contains('level2')
            ? EmergencyOperationalPriority.high
            : EmergencyOperationalPriority.standard;
    final rawStatus = str(row['status']).toLowerCase();
    final status = switch (rawStatus) {
      'intreatment' || 'in_treatment' || 'admitted' => EmergencyCaseStatus.inTreatment,
      'observation' || 'stabilizing' => EmergencyCaseStatus.observation,
      'transferred' => EmergencyCaseStatus.transferred,
      'resolved' || 'discharged' || 'deceased' => EmergencyCaseStatus.resolved,
      'cancelled' => EmergencyCaseStatus.cancelled,
      _ => EmergencyCaseStatus.waiting,
    };
    final notes = (row['notes'] as List? ?? const []).whereType<Map>().map((note) => EmergencyNoteModel(
      id: str(note['id']),
      noteType: EmergencyNoteType.values.where((value) => value.name == note['noteType']).firstOrNull ?? EmergencyNoteType.clinicalNote,
      content: str(note['content']),
      isInternalPrivate: note['isInternalPrivate'] as bool? ?? true,
      author: str(note['author']),
      createdAt: date(note['createdAt']),
    )).toList();
    final timeline = (row['timeline'] as List? ?? const []).whereType<Map>().map((event) => EmergencyTimelineItem(
      id: str(event['id']), timestamp: date(event['timestamp']), actor: str(event['actor']),
      action: str(event['action']), optionalNote: event['optionalNote'] as String?,
    )).toList();
    final rawVitals = (row['observations'] as Map?) ?? (row['vitals'] as Map?) ?? const {};
    final observations = rawVitals.isEmpty ? null : EmergencyObservationsModel(
      bpSystolic: str(rawVitals['bpSystolic']), bpDiastolic: str(rawVitals['bpDiastolic']),
      heartRate: str(rawVitals['heartRate']), temperature: str(rawVitals['temperature']),
      respiratoryRate: str(rawVitals['respiratoryRate']), oxygenSaturation: str(rawVitals['oxygenSaturation']),
      weight: str(rawVitals['weight']), additionalObservations: str(rawVitals['additionalObservations']),
      recordedBy: str(rawVitals['recordedBy']), recordedAt: date(rawVitals['recordedAt']),
    );
    return DoctorEmergencyCaseFullModel(
      id: str(row['id'] ?? row['_key']), patientId: str(row['patientId']),
      patientName: str(row['patientName'], 'Patient'), patientAge: (row['age'] as num?)?.toInt() ?? 0,
      patientGender: str(row['gender']), bloodGroup: str(row['bloodGroup']),
      allergies: (row['allergies'] as List? ?? const []).map(str).toList(),
      knownConditions: (row['knownConditions'] as List? ?? const []).map(str).toList(),
      currentMedications: (row['currentMedications'] as List? ?? const []).map(str).toList(),
      emergencyContactName: str(row['emergencyContactName']), emergencyContactRelation: str(row['emergencyContactRelation']),
      emergencyContactPhone: str(row['emergencyContactPhone']), arrivalTime: date(row['arrivalTime']),
      arrivalMethod: str(row['arrivalMode'] ?? row['arrivalMethod']), referralSource: str(row['referralSource']),
      emergencyReason: str(row['chiefComplaint'] ?? row['emergencyReason']), patientReportedInfo: str(row['patientReportedInfo']),
      arrivalNotes: str(row['arrivalNotes']), priority: priority, status: status,
      assignedDoctor: str(row['assignedDoctor'] ?? row['doctorName']), department: str(row['department'] ?? row['departmentId']),
      location: str(row['location'] ?? row['locationBed']), observations: observations, notes: notes,
      timeline: timeline, consultationId: row['consultationId'] as String?,
      attachedReportIds: (row['attachedReportIds'] as List? ?? const []).map(str).toList(),
      attachedPrescriptionIds: (row['attachedPrescriptionIds'] as List? ?? const []).map(str).toList(),
      auditHistory: const [],
    );
  }

  Map<String, int> getSummaryMetrics() {
    final active = _cases.where((c) => c.status != EmergencyCaseStatus.resolved && c.status != EmergencyCaseStatus.cancelled).length;
    final critical = _cases.where((c) => c.priority == EmergencyOperationalPriority.immediate && c.status != EmergencyCaseStatus.resolved).length;
    final waiting = _cases.where((c) => c.status == EmergencyCaseStatus.waiting).length;
    final inTreatment = _cases.where((c) => c.status == EmergencyCaseStatus.inTreatment).length;
    final resolvedToday = _cases.where((c) => c.status == EmergencyCaseStatus.resolved).length;

    return {
      'active': active,
      'critical': critical,
      'waiting': waiting,
      'inTreatment': inTreatment,
      'resolvedToday': resolvedToday,
    };
  }
}
