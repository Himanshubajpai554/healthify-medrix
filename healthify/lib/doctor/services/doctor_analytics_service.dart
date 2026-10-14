import 'package:flutter/material.dart';
import '../../core/provider/repository_provider.dart';
import '../models/doctor_analytics_models.dart';

class DoctorAnalyticsService {
  static final DoctorAnalyticsService _instance = DoctorAnalyticsService._internal();
  factory DoctorAnalyticsService() => _instance;
  DoctorAnalyticsService._internal();

  Future<FullDoctorAnalyticsData> getDoctorAnalytics({
    required String doctorId,
    AnalyticsDateRange dateRange = AnalyticsDateRange.thisMonth,
  }) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    if (records != null && RepositoryContainer.instance.currentDoctorId.isNotEmpty) {
      return _liveAnalytics(records, dateRange);
    }
    await Future.delayed(const Duration(milliseconds: 300));

    return FullDoctorAnalyticsData(
      dateRange: dateRange,
      overview: const DoctorAnalyticsOverviewModel(
        totalPatients: MetricWithComparison(value: 124, comparisonText: '+14 from previous period'),
        totalAppointments: MetricWithComparison(value: 38, comparisonText: '+6 from previous period'),
        completedConsultations: MetricWithComparison(value: 31, comparisonText: '+4 from previous period'),
        followUps: MetricWithComparison(value: 16, comparisonText: '+2 from previous period'),
        reportsReviewed: MetricWithComparison(value: 27, comparisonText: '+5 from previous period'),
        emergencyCases: MetricWithComparison(value: 4, comparisonText: '+1 from previous period'),
      ),
      appointments: const AppointmentAnalyticsModel(
        trendDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        completedCounts: [5, 8, 4, 6, 7, 1, 0],
        cancelledCounts: [0, 1, 0, 1, 0, 0, 0],
        noShowCounts: [0, 0, 1, 0, 0, 0, 0],
        upcomingCounts: [0, 0, 0, 2, 4, 1, 0],
        statusCompleted: 31,
        statusUpcoming: 7,
        statusCancelled: 2,
        statusNoShow: 1,
      ),
      patientVolume: const PatientVolumeModel(
        newPatients: 24,
        returningPatients: 67,
        followUpVisits: 31,
      ),
      consultationActivity: const ConsultationActivityModel(
        consultationsCompleted: 31,
        draftConsultations: 3,
        avgDurationText: 'Duration data unavailable.',
        followUpsCreated: 16,
      ),
      departmentDistribution: const DepartmentDistributionModel(
        shares: [
          DepartmentShare(department: 'Cardiology', percentage: 42.0, count: 52),
          DepartmentShare(department: 'General Medicine', percentage: 28.0, count: 35),
          DepartmentShare(department: 'Emergency', percentage: 18.0, count: 22),
          DepartmentShare(department: 'Other', percentage: 12.0, count: 15),
        ],
      ),
      followUps: const FollowUpAnalyticsModel(
        scheduled: 24,
        completed: 31,
        due: 8,
        overdue: 5,
        cancelled: 2,
        trendDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        followUpCounts: [3, 5, 2, 4, 2],
      ),
      reports: const ReportReviewAnalyticsModel(
        reportsReceived: 34,
        reportsReviewed: 27,
        pendingReview: 7,
        trendDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        reviewedCounts: [4, 6, 5, 7, 5],
      ),
      emergencyCases: const EmergencyCaseAnalyticsModel(
        totalEmergencyCases: 4,
        resolved: 3,
        transferred: 1,
        currentlyActive: 0,
        dayLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        caseCounts: [1, 0, 2, 0, 1],
      ),
      prescriptions: const PrescriptionActivityAnalyticsModel(
        prescriptionsCreated: 32,
        activePrescriptions: 28,
        completedPrescriptions: 4,
        cancelledPrescriptions: 0,
        draftPrescriptions: 2,
        trendDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        prescriptionCounts: [6, 8, 5, 7, 6],
      ),
      workload: const WorkloadDistributionModel(
        appointmentsCount: 38,
        consultationsCount: 31,
        reportsCount: 27,
        followUpsCount: 16,
        emergencyCasesCount: 4,
      ),
      busiestDaysTimes: const BusiestDaysTimesModel(
        dayVolume: {'Monday': 8, 'Tuesday': 12, 'Wednesday': 7, 'Thursday': 9, 'Friday': 11},
        busiestDay: 'Tuesday',
        highestVolumeText: 'Highest recorded appointment volume: Tuesday',
        timeOfDayVolume: {'Morning': 18, 'Afternoon': 14, 'Evening': 6},
      ),
      recentActivity: [
        RecentDoctorActivityItem(
          id: 'ACT-1',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          title: 'Completed 4 consultations',
          subtitle: 'Cardiology & General OPD',
          icon: Icons.medical_services_rounded,
          iconColor: const Color(0xFF0D9488),
          targetRoute: '/doctor-consultation',
        ),
        RecentDoctorActivityItem(
          id: 'ACT-2',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          title: 'Reviewed 3 reports',
          subtitle: 'ECG & Lipid Panels',
          icon: Icons.assignment_rounded,
          iconColor: const Color(0xFF3B82F6),
          targetRoute: '/doctor-reports',
        ),
        RecentDoctorActivityItem(
          id: 'ACT-3',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          title: 'Completed 2 follow-ups',
          subtitle: 'Post-op & Hypertensive review',
          icon: Icons.event_repeat_rounded,
          iconColor: const Color(0xFFD97706),
          targetRoute: '/doctor-followups',
        ),
        RecentDoctorActivityItem(
          id: 'ACT-4',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
          title: 'Created 5 prescriptions',
          subtitle: 'E-prescriptions generated & dispatched',
          icon: Icons.medication_rounded,
          iconColor: const Color(0xFF8B5CF6),
          targetRoute: '/doctor-prescriptions',
        ),
      ],
      insights: const [
        ActivityInsightItem(
          id: 'INS-1',
          insightText: '12 appointments were recorded this week.',
          category: 'Appointments',
          icon: Icons.calendar_today_rounded,
        ),
        ActivityInsightItem(
          id: 'INS-2',
          insightText: '7 reports are currently pending review.',
          category: 'Reports',
          icon: Icons.pending_actions_rounded,
        ),
        ActivityInsightItem(
          id: 'INS-3',
          insightText: '5 follow-ups are scheduled for the next 7 days.',
          category: 'Follow-ups',
          icon: Icons.event_repeat_rounded,
        ),
      ],
      aiSummaryText:
          'During the selected period, 38 appointments were recorded. 31 consultations were completed and 7 appointments remain upcoming. 27 reports were reviewed.',
    );
  }

  Future<FullDoctorAnalyticsData> _liveAnalytics(dynamic records, AnalyticsDateRange range) async {
    final now = DateTime.now();
    final start = switch (range) {
      AnalyticsDateRange.today => DateTime(now.year, now.month, now.day),
      AnalyticsDateRange.thisWeek => DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1)),
      AnalyticsDateRange.thisMonth => DateTime(now.year, now.month),
      AnalyticsDateRange.last3Months => DateTime(now.year, now.month - 3),
      AnalyticsDateRange.custom => DateTime(now.year, now.month),
    };
    DateTime dateOf(Map<String, dynamic> row) => DateTime.tryParse('${row['dateTime'] ?? row['createdAt'] ?? row['arrivalTime'] ?? row['signedAt'] ?? row['followUpDate'] ?? ''}') ?? now;
    bool inRange(Map<String, dynamic> row) {
      final date = dateOf(row);
      return !date.isBefore(start) && !date.isAfter(now);
    }
    final appointmentRows = (await records.list('appointments', limit: 5000)).where(inRange).toList();
    final followRows = (await records.list('doctorFollowUps', limit: 5000)).where(inRange).toList();
    final reportRows = (await records.list('diagnosticReports', limit: 5000)).where(inRange).toList();
    final emergencyRows = (await records.list('emergencies', limit: 5000)).where(inRange).toList();
    final prescriptionRows = (await records.list('prescriptions', limit: 5000)).where(inRange).toList();
    int countWhere(List<Map<String, dynamic>> rows, bool Function(Map<String, dynamic>) test) => rows.where(test).length;
    final completed = countWhere(appointmentRows, (r) => '${r['status']}'.toLowerCase() == 'completed');
    final cancelled = countWhere(appointmentRows, (r) => '${r['status']}'.toLowerCase() == 'cancelled');
    final noShow = countWhere(appointmentRows, (r) => {'noshow', 'no_show', 'missed'}.contains('${r['status']}'.toLowerCase()));
    final upcoming = countWhere(appointmentRows, (r) => {'scheduled', 'pending', 'waiting', 'checkedin', 'checked_in'}.contains('${r['status']}'.toLowerCase()));
    final reviewed = countWhere(reportRows, (r) => {'verified', 'released', 'reviewed'}.contains('${r['verificationStatus'] ?? r['status']}'.toLowerCase()));
    final followCompleted = countWhere(followRows, (r) => '${r['status']}'.toLowerCase() == 'completed');
    final followCancelled = countWhere(followRows, (r) => '${r['status']}'.toLowerCase() == 'cancelled');
    final followOverdue = countWhere(followRows, (r) => '${r['status']}'.toLowerCase() == 'overdue');
    final activeEmergency = countWhere(emergencyRows, (r) => !{'resolved', 'discharged', 'cancelled', 'deceased'}.contains('${r['status']}'.toLowerCase()));
    final resolvedEmergency = countWhere(emergencyRows, (r) => {'resolved', 'discharged'}.contains('${r['status']}'.toLowerCase()));
    final transferredEmergency = countWhere(emergencyRows, (r) => '${r['status']}'.toLowerCase() == 'transferred');
    final activeRx = countWhere(prescriptionRows, (r) => '${r['status']}'.toLowerCase() == 'active');
    final draftRx = countWhere(prescriptionRows, (r) => '${r['status']}'.toLowerCase() == 'draft');
    final cancelledRx = countWhere(prescriptionRows, (r) => '${r['status']}'.toLowerCase() == 'cancelled');
    final completedRx = countWhere(prescriptionRows, (r) => '${r['status']}'.toLowerCase() == 'completed');
    final patients = appointmentRows.map((r) => '${r['patientId'] ?? ''}').where((id) => id.isNotEmpty).toSet();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    final labels = days.map((d) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1]).toList();
    List<int> daily(List<Map<String, dynamic>> rows, String status) => days.map((day) => rows.where((row) {
      final date = dateOf(row);
      final sameDay = date.year == day.year && date.month == day.month && date.day == day.day;
      return sameDay && (status.isEmpty || '${row['status']}'.toLowerCase() == status);
    }).length).toList();
    final departmentCounts = <String, int>{};
    for (final row in appointmentRows) {
      final department = '${row['department'] ?? row['departmentId'] ?? 'Other'}';
      departmentCounts[department] = (departmentCounts[department] ?? 0) + 1;
    }
    final departmentTotal = departmentCounts.values.fold<int>(0, (a, b) => a + b);
    final departments = departmentCounts.entries.map((entry) => DepartmentShare(
      department: entry.key,
      count: entry.value,
      percentage: departmentTotal == 0 ? 0 : entry.value * 100 / departmentTotal,
    )).toList();
    final insight = <ActivityInsightItem>[
      ActivityInsightItem(id: 'live-appointments', insightText: '$completed completed consultations in the selected period.', category: 'Appointments', icon: Icons.calendar_today_rounded),
      ActivityInsightItem(id: 'live-reports', insightText: '${reportRows.length - reviewed} reports need review.', category: 'Reports', icon: Icons.pending_actions_rounded),
      ActivityInsightItem(id: 'live-followups', insightText: '$followOverdue follow-ups are overdue.', category: 'Follow-ups', icon: Icons.event_repeat_rounded),
    ];
    return FullDoctorAnalyticsData(
      dateRange: range,
      overview: DoctorAnalyticsOverviewModel(
        totalPatients: MetricWithComparison(value: patients.length, comparisonText: 'Current assigned records'),
        totalAppointments: MetricWithComparison(value: appointmentRows.length, comparisonText: 'Current assigned records'),
        completedConsultations: MetricWithComparison(value: completed, comparisonText: 'Current assigned records'),
        followUps: MetricWithComparison(value: followRows.length, comparisonText: 'Current assigned records'),
        reportsReviewed: MetricWithComparison(value: reviewed, comparisonText: 'Current assigned records'),
        emergencyCases: MetricWithComparison(value: emergencyRows.length, comparisonText: 'Current assigned records'),
      ),
      appointments: AppointmentAnalyticsModel(trendDays: labels, completedCounts: daily(appointmentRows, 'completed'),
        cancelledCounts: daily(appointmentRows, 'cancelled'), noShowCounts: daily(appointmentRows, 'no_show'),
        upcomingCounts: daily(appointmentRows, 'scheduled'), statusCompleted: completed, statusUpcoming: upcoming,
        statusCancelled: cancelled, statusNoShow: noShow),
      patientVolume: PatientVolumeModel(newPatients: 0, returningPatients: patients.length, followUpVisits: followRows.length),
      consultationActivity: ConsultationActivityModel(consultationsCompleted: completed, draftConsultations: 0,
        avgDurationText: 'Duration data unavailable.', followUpsCreated: followRows.length),
      departmentDistribution: DepartmentDistributionModel(shares: departments),
      followUps: FollowUpAnalyticsModel(scheduled: countWhere(followRows, (r) => {'scheduled', 'rescheduled'}.contains('${r['status']}')),
        completed: followCompleted, due: countWhere(followRows, (r) => '${r['status']}' == 'dueToday'), overdue: followOverdue,
        cancelled: followCancelled, trendDays: labels, followUpCounts: daily(followRows, '')),
      reports: ReportReviewAnalyticsModel(reportsReceived: reportRows.length, reportsReviewed: reviewed,
        pendingReview: reportRows.length - reviewed, trendDays: labels, reviewedCounts: daily(reportRows, 'verified')),
      emergencyCases: EmergencyCaseAnalyticsModel(totalEmergencyCases: emergencyRows.length, resolved: resolvedEmergency,
        transferred: transferredEmergency, currentlyActive: activeEmergency, dayLabels: labels, caseCounts: daily(emergencyRows, '')),
      prescriptions: PrescriptionActivityAnalyticsModel(prescriptionsCreated: prescriptionRows.length,
        activePrescriptions: activeRx, completedPrescriptions: completedRx, cancelledPrescriptions: cancelledRx,
        draftPrescriptions: draftRx, trendDays: labels, prescriptionCounts: daily(prescriptionRows, '')),
      workload: WorkloadDistributionModel(appointmentsCount: appointmentRows.length, consultationsCount: completed,
        reportsCount: reportRows.length, followUpsCount: followRows.length, emergencyCasesCount: emergencyRows.length),
      busiestDaysTimes: BusiestDaysTimesModel(dayVolume: const {}, busiestDay: 'Not available',
        highestVolumeText: 'No historical comparison is available.', timeOfDayVolume: const {}),
      recentActivity: const [],
      insights: insight,
      aiSummaryText: 'Summary computed from assigned records only; no predictive model was used.',
    );
  }
}
