import '../models/followup_models.dart';

class DoctorFollowUpService {
  static final DoctorFollowUpService _instance = DoctorFollowUpService._internal();
  factory DoctorFollowUpService() => _instance;
  DoctorFollowUpService._internal();

  final List<DoctorFollowUpFullModel> _followUps = [
    DoctorFollowUpFullModel(
      id: 'FU-2026-00982',
      patientId: 'MED-PAT-10482',
      patientName: 'Rahul Sharma',
      patientAge: 42,
      patientGender: 'Male',
      bloodGroup: 'B+',
      allergies: ['Penicillin'],
      phone: '+91 98765 43210',
      followUpDate: DateTime(2026, 10, 4),
      followUpTime: '10:30 AM',
      department: 'Cardiology',
      doctorName: 'Dr. Sarah Jenkins',
      reason: 'Review progress and discuss recently completed cardiac biomarkers and ECG reports.',
      additionalNotes: 'Patient was advised to bring 7-day home BP monitoring log.',
      createdDate: DateTime(2026, 9, 28),
      createdBy: 'Dr. Sarah Jenkins',
      status: FollowUpStatus.scheduled,
      previousConsultation: PreviousConsultationSummaryModel(
        id: 'CON-10029',
        date: DateTime(2026, 9, 28),
        doctorName: 'Dr. Sarah Jenkins',
        department: 'Cardiology',
        reason: 'Acute chest discomfort and hypertension evaluation.',
        clinicalNotesSummary: 'Patient presented with mild precordial pressure. ECG normal, BP 142/88. Prescribed Amlodipine 5mg.',
        reportIds: ['REP-20260928-001', 'REP-20260928-002'],
        prescriptionIds: ['RX-2026-00982'],
      ),
      upcomingAppointment: UpcomingAppointmentInfoModel(
        id: 'APT-2026-0982',
        appointmentDate: DateTime(2026, 10, 4),
        timeSlot: '10:30 AM - 10:45 AM',
        department: 'Cardiology',
        doctorName: 'Dr. Sarah Jenkins',
        type: 'In-Person Consultation',
        status: 'Confirmed',
      ),
      timeline: [
        FollowUpTimelineItem(
          id: 'TL-1',
          timestamp: DateTime(2026, 9, 28, 11, 45),
          actor: 'Dr. Sarah Jenkins',
          action: 'Follow-up created during consultation CON-10029',
          optionalNote: 'Target date: 04 Oct 2026',
        ),
        FollowUpTimelineItem(
          id: 'TL-2',
          timestamp: DateTime(2026, 9, 28, 11, 48),
          actor: 'Reception Desk',
          action: 'Follow-up appointment APT-2026-0982 scheduled',
        ),
      ],
      rescheduleHistory: [],
      notes: [
        FollowUpNoteModel(
          id: 'FN-1',
          noteType: FollowUpNoteType.internal,
          content: 'Verify lipid panel results before patient intake.',
          author: 'Dr. Sarah Jenkins',
          createdAt: DateTime(2026, 9, 28, 12, 10),
        ),
      ],
      aiSummary: 'Patient has had 3 recorded follow-up visits during the last 6 months. The latest scheduled follow-up is 04 October 2026.',
    ),
    DoctorFollowUpFullModel(
      id: 'FU-2026-00983',
      patientId: 'MED-PAT-10391',
      patientName: 'Priya Verma',
      patientAge: 38,
      patientGender: 'Female',
      bloodGroup: 'O+',
      allergies: ['NSAIDs', 'Aspirin'],
      phone: '+91 98123 45678',
      followUpDate: DateTime.now(), // Due Today
      followUpTime: '02:00 PM',
      department: 'General Medicine',
      doctorName: 'Dr. Sarah Jenkins',
      reason: 'Review blood pressure log and evaluate headache recurrence.',
      additionalNotes: 'Check adherence to Propranolol prophylactic dosage.',
      createdDate: DateTime.now().subtract(const Duration(days: 7)),
      createdBy: 'Dr. Sarah Jenkins',
      status: FollowUpStatus.dueToday,
      previousConsultation: PreviousConsultationSummaryModel(
        id: 'CON-09941',
        date: DateTime.now().subtract(const Duration(days: 7)),
        doctorName: 'Dr. Sarah Jenkins',
        department: 'General Medicine',
        reason: 'Refractory migraine and fluctuating blood pressure.',
        clinicalNotesSummary: 'Neurological screening intact. Recommended salt restriction and daily BP tracking.',
        reportIds: ['REP-20260920-004'],
        prescriptionIds: ['RX-2026-00941'],
      ),
      upcomingAppointment: UpcomingAppointmentInfoModel(
        id: 'APT-2026-0983',
        appointmentDate: DateTime.now(),
        timeSlot: '02:00 PM - 02:15 PM',
        department: 'General Medicine',
        doctorName: 'Dr. Sarah Jenkins',
        type: 'OPD Follow-up',
        status: 'Checked-in',
      ),
      timeline: [
        FollowUpTimelineItem(
          id: 'TL-10',
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          actor: 'Dr. Sarah Jenkins',
          action: 'Follow-up created',
        ),
      ],
      rescheduleHistory: [],
      notes: [],
      aiSummary: 'Patient reported improved migraine frequency after starting prophylactic therapy. Today is the scheduled 1-week evaluation.',
    ),
    DoctorFollowUpFullModel(
      id: 'FU-2026-00984',
      patientId: 'MED-PAT-10214',
      patientName: 'Amit Kumar',
      patientAge: 56,
      patientGender: 'Male',
      bloodGroup: 'A+',
      allergies: ['Sulfa Drugs'],
      phone: '+91 97654 32109',
      followUpDate: DateTime(2026, 9, 26), // 5 days overdue
      followUpTime: '11:00 AM',
      department: 'Neurology',
      doctorName: 'Dr. Sarah Jenkins',
      reason: 'Post-stroke motor recovery assessment and carotid doppler review.',
      additionalNotes: 'Patient missed scheduled appointment on Sep 26.',
      createdDate: DateTime(2026, 9, 12),
      createdBy: 'Dr. Sarah Jenkins',
      status: FollowUpStatus.overdue,
      previousConsultation: PreviousConsultationSummaryModel(
        id: 'CON-09812',
        date: DateTime(2026, 9, 12),
        doctorName: 'Dr. Sarah Jenkins',
        department: 'Neurology',
        reason: 'Post-TIA follow-up and physical therapy progress review.',
        clinicalNotesSummary: 'Right hand grip strength 4/5. Physiotherapy continuing 3x weekly.',
        reportIds: ['REP-20260912-008'],
        prescriptionIds: ['RX-2026-00812'],
      ),
      upcomingAppointment: null, // No active appointment
      timeline: [
        FollowUpTimelineItem(
          id: 'TL-20',
          timestamp: DateTime(2026, 9, 12),
          actor: 'Dr. Sarah Jenkins',
          action: 'Follow-up scheduled for 26 Sep 2026',
        ),
        FollowUpTimelineItem(
          id: 'TL-21',
          timestamp: DateTime(2026, 9, 26, 17, 00),
          actor: 'System Auto-Tracker',
          action: 'Marked as Overdue (No appointment check-in recorded)',
        ),
      ],
      rescheduleHistory: [],
      notes: [],
      aiSummary: 'Patient missed 1 scheduled follow-up visit on 26 Sep 2026. Prior stroke rehabilitation notes indicate stable motor progress.',
    ),
    DoctorFollowUpFullModel(
      id: 'FU-2026-00985',
      patientId: 'MED-PAT-10871',
      patientName: 'Neha Gupta',
      patientAge: 29,
      patientGender: 'Female',
      bloodGroup: 'AB+',
      allergies: [],
      phone: '+91 98989 12345',
      followUpDate: DateTime.now().add(const Duration(days: 1)),
      followUpTime: '09:30 AM',
      department: 'Orthopedics',
      doctorName: 'Dr. Marcus Vance',
      reason: 'Post-operative arthroscopy suture check and weight-bearing evaluation.',
      createdDate: DateTime.now().subtract(const Duration(days: 14)),
      createdBy: 'Dr. Marcus Vance',
      status: FollowUpStatus.scheduled,
      previousConsultation: PreviousConsultationSummaryModel(
        id: 'CON-09750',
        date: DateTime.now().subtract(const Duration(days: 14)),
        doctorName: 'Dr. Marcus Vance',
        department: 'Orthopedics',
        reason: 'Left knee arthroscopic meniscus repair discharge evaluation.',
        clinicalNotesSummary: 'Surgical wound clean. Knee brace locked in extension.',
        reportIds: [],
        prescriptionIds: ['RX-2026-00750'],
      ),
      upcomingAppointment: UpcomingAppointmentInfoModel(
        id: 'APT-2026-0985',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '09:30 AM - 09:45 AM',
        department: 'Orthopedics',
        doctorName: 'Dr. Marcus Vance',
        type: 'Post-Op Follow-up',
        status: 'Scheduled',
      ),
      timeline: [
        FollowUpTimelineItem(
          id: 'TL-30',
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
          actor: 'Dr. Marcus Vance',
          action: 'Post-operative follow-up logged',
        ),
      ],
      rescheduleHistory: [],
      notes: [],
    ),
    DoctorFollowUpFullModel(
      id: 'FU-2026-00986',
      patientId: 'MED-PAT-10655',
      patientName: 'Rajesh Patel',
      patientAge: 51,
      patientGender: 'Male',
      bloodGroup: 'O-',
      allergies: ['Metformin'],
      phone: '+91 97123 98765',
      followUpDate: DateTime(2026, 9, 29), // 2 days overdue
      followUpTime: '04:00 PM',
      department: 'General Medicine',
      doctorName: 'Dr. Sarah Jenkins',
      reason: 'Glycemic control and HbA1c review.',
      createdDate: DateTime(2026, 9, 15),
      createdBy: 'Dr. Sarah Jenkins',
      status: FollowUpStatus.overdue,
      previousConsultation: PreviousConsultationSummaryModel(
        id: 'CON-09610',
        date: DateTime(2026, 9, 15),
        doctorName: 'Dr. Sarah Jenkins',
        department: 'General Medicine',
        reason: 'Type 2 Diabetes Mellitus medication adjustment.',
        clinicalNotesSummary: 'Fasting blood glucose 168 mg/dL. Adjusted insulin glargine to 14 units.',
        reportIds: ['REP-20260915-012'],
        prescriptionIds: ['RX-2026-00610'],
      ),
      upcomingAppointment: null,
      timeline: [
        FollowUpTimelineItem(
          id: 'TL-40',
          timestamp: DateTime(2026, 9, 15),
          actor: 'Dr. Sarah Jenkins',
          action: 'Follow-up created',
        ),
      ],
      rescheduleHistory: [],
      notes: [],
    ),
    DoctorFollowUpFullModel(
      id: 'FU-2026-00987',
      patientId: 'MED-PAT-10112',
      patientName: 'Sunita Rao',
      patientAge: 64,
      patientGender: 'Female',
      bloodGroup: 'A-',
      allergies: ['Contrast Dye'],
      phone: '+91 98450 11223',
      followUpDate: DateTime(2026, 9, 28),
      followUpTime: '03:30 PM',
      department: 'Pulmonology',
      doctorName: 'Dr. Sarah Jenkins',
      reason: 'Post-bronchitis spirometry & oxygen saturation evaluation.',
      createdDate: DateTime(2026, 9, 20),
      createdBy: 'Dr. Sarah Jenkins',
      status: FollowUpStatus.completed,
      completedDate: DateTime(2026, 9, 28, 16, 0),
      completedBy: 'Dr. Sarah Jenkins',
      completionNote: 'Spirometry FEV1/FVC ratio normal (82%). Patient fully recovered.',
      previousConsultation: PreviousConsultationSummaryModel(
        id: 'CON-09502',
        date: DateTime(2026, 9, 20),
        doctorName: 'Dr. Sarah Jenkins',
        department: 'Pulmonology',
        reason: 'Acute bronchitis review.',
        clinicalNotesSummary: 'Lungs clear bilaterally. Wheezing resolved.',
        reportIds: ['REP-20260920-009'],
        prescriptionIds: [],
      ),
      timeline: [
        FollowUpTimelineItem(
          id: 'TL-50',
          timestamp: DateTime(2026, 9, 20),
          actor: 'Dr. Sarah Jenkins',
          action: 'Follow-up created',
        ),
        FollowUpTimelineItem(
          id: 'TL-51',
          timestamp: DateTime(2026, 9, 28, 16, 0),
          actor: 'Dr. Sarah Jenkins',
          action: 'Follow-up completed with note',
        ),
      ],
      rescheduleHistory: [],
      notes: [],
    ),
    DoctorFollowUpFullModel(
      id: 'FU-2026-00988',
      patientId: 'MED-PAT-10901',
      patientName: 'Vikram Singh',
      patientAge: 48,
      patientGender: 'Male',
      bloodGroup: 'B+',
      allergies: [],
      phone: '+91 99001 22334',
      followUpDate: DateTime(2026, 10, 5),
      followUpTime: '11:30 AM',
      department: 'Cardiology',
      doctorName: 'Dr. Sarah Jenkins',
      reason: 'Post-PCI angina monitoring & dual antiplatelet therapy safety check.',
      createdDate: DateTime(2026, 9, 25),
      createdBy: 'Dr. Sarah Jenkins',
      status: FollowUpStatus.scheduled,
      previousConsultation: PreviousConsultationSummaryModel(
        id: 'CON-09411',
        date: DateTime(2026, 9, 25),
        doctorName: 'Dr. Sarah Jenkins',
        department: 'Cardiology',
        reason: 'Post coronary intervention check.',
        clinicalNotesSummary: 'Access site healed without hematoma. No chest pain reported.',
        reportIds: ['REP-20260925-015'],
        prescriptionIds: ['RX-2026-00411'],
      ),
      upcomingAppointment: UpcomingAppointmentInfoModel(
        id: 'APT-2026-0988',
        appointmentDate: DateTime(2026, 10, 5),
        timeSlot: '11:30 AM - 11:45 AM',
        department: 'Cardiology',
        doctorName: 'Dr. Sarah Jenkins',
        type: 'Specialist Consultation',
        status: 'Scheduled',
      ),
      timeline: [
        FollowUpTimelineItem(
          id: 'TL-60',
          timestamp: DateTime(2026, 9, 25),
          actor: 'Dr. Sarah Jenkins',
          action: 'Follow-up created',
        ),
      ],
      rescheduleHistory: [],
      notes: [],
    ),
  ];

  Future<List<DoctorFollowUpFullModel>> getFollowUps() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_followUps);
  }

  Future<DoctorFollowUpFullModel?> getFollowUp(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      return _followUps.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<DoctorFollowUpFullModel>> searchFollowUps(String query) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return getFollowUps();

    return _followUps.where((f) {
      return f.patientName.toLowerCase().contains(q) ||
          f.patientId.toLowerCase().contains(q) ||
          f.id.toLowerCase().contains(q) ||
          f.phone.contains(q) ||
          f.reason.toLowerCase().contains(q) ||
          f.department.toLowerCase().contains(q);
    }).toList();
  }

  Future<List<DoctorFollowUpFullModel>> filterFollowUps({
    FollowUpStatus? status,
    String? department,
    FollowUpSortOption sort = FollowUpSortOption.soonest,
  }) async {
    var list = await getFollowUps();
    if (status != null) {
      list = list.where((f) => f.status == status).toList();
    }
    if (department != null && department != 'All') {
      list = list.where((f) => f.department == department).toList();
    }

    switch (sort) {
      case FollowUpSortOption.soonest:
        list.sort((a, b) => a.followUpDate.compareTo(b.followUpDate));
        break;
      case FollowUpSortOption.latest:
        list.sort((a, b) => b.followUpDate.compareTo(a.followUpDate));
        break;
      case FollowUpSortOption.patientName:
        list.sort((a, b) => a.patientName.compareTo(b.patientName));
        break;
    }

    return list;
  }

  Future<List<DoctorFollowUpFullModel>> getTodayFollowUps() async {
    final list = await getFollowUps();
    final now = DateTime.now();
    return list.where((f) {
      return f.status == FollowUpStatus.dueToday ||
          (f.followUpDate.year == now.year && f.followUpDate.month == now.month && f.followUpDate.day == now.day);
    }).toList();
  }

  Future<List<DoctorFollowUpFullModel>> getUpcomingFollowUps() async {
    final list = await getFollowUps();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return list.where((f) => f.followUpDate.isAfter(today) && f.status != FollowUpStatus.completed && f.status != FollowUpStatus.cancelled).toList();
  }

  Future<List<DoctorFollowUpFullModel>> getOverdueFollowUps() async {
    final list = await getFollowUps();
    return list.where((f) => f.status == FollowUpStatus.overdue).toList();
  }

  Future<DoctorFollowUpFullModel> createFollowUp(DoctorFollowUpFullModel newFollowUp) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _followUps.insert(0, newFollowUp);
    return newFollowUp;
  }

  Future<void> rescheduleFollowUp({
    required String id,
    required DateTime newDate,
    required String newTimeSlot,
    required String reason,
    required String changedBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _followUps.indexWhere((f) => f.id == id);
    if (index != -1) {
      final old = _followUps[index];
      final rescheduleItem = FollowUpRescheduleHistoryModel(
        id: 'RSH-${DateTime.now().millisecondsSinceEpoch}',
        previousDate: old.followUpDate,
        previousTimeSlot: old.followUpTime,
        newDate: newDate,
        newTimeSlot: newTimeSlot,
        changedBy: changedBy,
        changedAt: DateTime.now(),
        reason: reason,
      );

      final newTimeline = List<FollowUpTimelineItem>.from(old.timeline)
        ..add(
          FollowUpTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: changedBy,
            action: 'Rescheduled follow-up to ${newDate.day}/${newDate.month}/${newDate.year} at $newTimeSlot',
            optionalNote: 'Reason: $reason',
          ),
        );

      final newReschedules = List<FollowUpRescheduleHistoryModel>.from(old.rescheduleHistory)..add(rescheduleItem);

      _followUps[index] = old.copyWith(
        followUpDate: newDate,
        followUpTime: newTimeSlot,
        status: FollowUpStatus.rescheduled,
        timeline: newTimeline,
        rescheduleHistory: newReschedules,
      );
    }
  }

  Future<void> cancelFollowUp({
    required String id,
    required String reason,
    required String cancelledBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _followUps.indexWhere((f) => f.id == id);
    if (index != -1) {
      final old = _followUps[index];
      final newTimeline = List<FollowUpTimelineItem>.from(old.timeline)
        ..add(
          FollowUpTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: cancelledBy,
            action: 'Follow-up cancelled',
            optionalNote: 'Reason: $reason',
          ),
        );

      _followUps[index] = old.copyWith(
        status: FollowUpStatus.cancelled,
        cancellationReason: reason,
        cancelledBy: cancelledBy,
        cancelledAt: DateTime.now(),
        timeline: newTimeline,
      );
    }
  }

  Future<void> completeFollowUp({
    required String id,
    required String completionNote,
    required String completedBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _followUps.indexWhere((f) => f.id == id);
    if (index != -1) {
      final old = _followUps[index];
      final newTimeline = List<FollowUpTimelineItem>.from(old.timeline)
        ..add(
          FollowUpTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: completedBy,
            action: 'Follow-up marked as Completed',
            optionalNote: completionNote,
          ),
        );

      _followUps[index] = old.copyWith(
        status: FollowUpStatus.completed,
        completedDate: DateTime.now(),
        completedBy: completedBy,
        completionNote: completionNote,
        timeline: newTimeline,
      );
    }
  }

  Future<void> addFollowUpNote({
    required String id,
    required FollowUpNoteModel note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _followUps.indexWhere((f) => f.id == id);
    if (index != -1) {
      final old = _followUps[index];
      final newNotes = List<FollowUpNoteModel>.from(old.notes)..add(note);
      final newTimeline = List<FollowUpTimelineItem>.from(old.timeline)
        ..add(
          FollowUpTimelineItem(
            id: 'TL-${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now(),
            actor: note.author,
            action: 'Added ${note.noteType.label}',
          ),
        );
      _followUps[index] = old.copyWith(
        notes: newNotes,
        timeline: newTimeline,
      );
    }
  }

  Map<String, int> getSummaryMetrics() {
    final dueToday = _followUps.where((f) => f.status == FollowUpStatus.dueToday).length;
    final upcoming = _followUps.where((f) => f.status == FollowUpStatus.scheduled || f.status == FollowUpStatus.rescheduled).length;
    final overdue = _followUps.where((f) => f.status == FollowUpStatus.overdue).length;
    final completedThisWeek = _followUps.where((f) => f.status == FollowUpStatus.completed).length;

    return {
      'dueToday': dueToday,
      'upcoming': upcoming,
      'overdue': overdue,
      'completedThisWeek': completedThisWeek,
    };
  }
}
