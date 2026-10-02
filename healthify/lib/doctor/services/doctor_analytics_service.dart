import 'package:flutter/material.dart';
import '../models/doctor_analytics_models.dart';

class DoctorAnalyticsService {
  static final DoctorAnalyticsService _instance = DoctorAnalyticsService._internal();
  factory DoctorAnalyticsService() => _instance;
  DoctorAnalyticsService._internal();

  Future<FullDoctorAnalyticsData> getDoctorAnalytics({
    required String doctorId,
    AnalyticsDateRange dateRange = AnalyticsDateRange.thisMonth,
  }) async {
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
}
