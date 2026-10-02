import 'package:flutter/material.dart';

enum AnalyticsDateRange {
  today,
  thisWeek,
  thisMonth,
  last3Months,
  custom,
}

extension AnalyticsDateRangeExtension on AnalyticsDateRange {
  String get label {
    switch (this) {
      case AnalyticsDateRange.today:
        return 'Today';
      case AnalyticsDateRange.thisWeek:
        return 'This Week';
      case AnalyticsDateRange.thisMonth:
        return 'This Month';
      case AnalyticsDateRange.last3Months:
        return 'Last 3 Months';
      case AnalyticsDateRange.custom:
        return 'Custom Range';
    }
  }

  String get dateRangeText {
    final now = DateTime.now();
    switch (this) {
      case AnalyticsDateRange.today:
        return '${now.day} ${_monthName(now.month)} ${now.year}';
      case AnalyticsDateRange.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return '${start.day} ${_monthName(start.month)} — ${now.day} ${_monthName(now.month)} ${now.year}';
      case AnalyticsDateRange.thisMonth:
        return '01 ${_monthName(now.month)} ${now.year} — ${now.day} ${_monthName(now.month)} ${now.year}';
      case AnalyticsDateRange.last3Months:
        final start = DateTime(now.year, now.month - 3, 1);
        return '01 ${_monthName(start.month)} ${start.year} — ${now.day} ${_monthName(now.month)} ${now.year}';
      case AnalyticsDateRange.custom:
        return '01 Sep 2026 — 30 Sep 2026';
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class MetricWithComparison {
  final int value;
  final String comparisonText; // e.g. "+6 from previous period"

  const MetricWithComparison({
    required this.value,
    required this.comparisonText,
  });
}

class DoctorAnalyticsOverviewModel {
  final MetricWithComparison totalPatients;
  final MetricWithComparison totalAppointments;
  final MetricWithComparison completedConsultations;
  final MetricWithComparison followUps;
  final MetricWithComparison reportsReviewed;
  final MetricWithComparison emergencyCases;

  const DoctorAnalyticsOverviewModel({
    required this.totalPatients,
    required this.totalAppointments,
    required this.completedConsultations,
    required this.followUps,
    required this.reportsReviewed,
    required this.emergencyCases,
  });
}

class AppointmentAnalyticsModel {
  final List<String> trendDays;
  final List<int> completedCounts;
  final List<int> cancelledCounts;
  final List<int> noShowCounts;
  final List<int> upcomingCounts;

  final int statusCompleted;
  final int statusUpcoming;
  final int statusCancelled;
  final int statusNoShow;

  const AppointmentAnalyticsModel({
    required this.trendDays,
    required this.completedCounts,
    required this.cancelledCounts,
    required this.noShowCounts,
    required this.upcomingCounts,
    required this.statusCompleted,
    required this.statusUpcoming,
    required this.statusCancelled,
    required this.statusNoShow,
  });

  int get totalAppointments => statusCompleted + statusUpcoming + statusCancelled + statusNoShow;
}

class PatientVolumeModel {
  final int newPatients;
  final int returningPatients;
  final int followUpVisits;

  const PatientVolumeModel({
    required this.newPatients,
    required this.returningPatients,
    required this.followUpVisits,
  });

  int get totalVisits => newPatients + returningPatients + followUpVisits;
}

class ConsultationActivityModel {
  final int consultationsCompleted;
  final int draftConsultations;
  final String avgDurationText; // "Duration data unavailable."
  final int followUpsCreated;

  const ConsultationActivityModel({
    required this.consultationsCompleted,
    required this.draftConsultations,
    required this.avgDurationText,
    required this.followUpsCreated,
  });
}

class DepartmentShare {
  final String department;
  final double percentage;
  final int count;

  const DepartmentShare({
    required this.department,
    required this.percentage,
    required this.count,
  });
}

class DepartmentDistributionModel {
  final List<DepartmentShare> shares;

  const DepartmentDistributionModel({
    required this.shares,
  });
}

class FollowUpAnalyticsModel {
  final int scheduled;
  final int completed;
  final int due;
  final int overdue;
  final int cancelled;
  final List<String> trendDays;
  final List<int> followUpCounts;

  const FollowUpAnalyticsModel({
    required this.scheduled,
    required this.completed,
    required this.due,
    required this.overdue,
    required this.cancelled,
    required this.trendDays,
    required this.followUpCounts,
  });
}

class ReportReviewAnalyticsModel {
  final int reportsReceived;
  final int reportsReviewed;
  final int pendingReview;
  final List<String> trendDays;
  final List<int> reviewedCounts;

  const ReportReviewAnalyticsModel({
    required this.reportsReceived,
    required this.reportsReviewed,
    required this.pendingReview,
    required this.trendDays,
    required this.reviewedCounts,
  });
}

class EmergencyCaseAnalyticsModel {
  final int totalEmergencyCases;
  final int resolved;
  final int transferred;
  final int currentlyActive;
  final List<String> dayLabels;
  final List<int> caseCounts;

  const EmergencyCaseAnalyticsModel({
    required this.totalEmergencyCases,
    required this.resolved,
    required this.transferred,
    required this.currentlyActive,
    required this.dayLabels,
    required this.caseCounts,
  });
}

class PrescriptionActivityAnalyticsModel {
  final int prescriptionsCreated;
  final int activePrescriptions;
  final int completedPrescriptions;
  final int cancelledPrescriptions;
  final int draftPrescriptions;
  final List<String> trendDays;
  final List<int> prescriptionCounts;

  const PrescriptionActivityAnalyticsModel({
    required this.prescriptionsCreated,
    required this.activePrescriptions,
    required this.completedPrescriptions,
    required this.cancelledPrescriptions,
    required this.draftPrescriptions,
    required this.trendDays,
    required this.prescriptionCounts,
  });
}

class WorkloadDistributionModel {
  final int appointmentsCount;
  final int consultationsCount;
  final int reportsCount;
  final int followUpsCount;
  final int emergencyCasesCount;

  const WorkloadDistributionModel({
    required this.appointmentsCount,
    required this.consultationsCount,
    required this.reportsCount,
    required this.followUpsCount,
    required this.emergencyCasesCount,
  });

  int get totalActions =>
      appointmentsCount + consultationsCount + reportsCount + followUpsCount + emergencyCasesCount;
}

class BusiestDaysTimesModel {
  final Map<String, int> dayVolume;
  final String busiestDay;
  final String highestVolumeText;
  final Map<String, int> timeOfDayVolume;

  const BusiestDaysTimesModel({
    required this.dayVolume,
    required this.busiestDay,
    required this.highestVolumeText,
    required this.timeOfDayVolume,
  });
}

class RecentDoctorActivityItem {
  final String id;
  final DateTime timestamp;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String targetRoute;

  const RecentDoctorActivityItem({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.targetRoute,
  });
}

class ActivityInsightItem {
  final String id;
  final String insightText;
  final String category;
  final IconData icon;

  const ActivityInsightItem({
    required this.id,
    required this.insightText,
    required this.category,
    required this.icon,
  });
}

class FullDoctorAnalyticsData {
  final AnalyticsDateRange dateRange;
  final DoctorAnalyticsOverviewModel overview;
  final AppointmentAnalyticsModel appointments;
  final PatientVolumeModel patientVolume;
  final ConsultationActivityModel consultationActivity;
  final DepartmentDistributionModel departmentDistribution;
  final FollowUpAnalyticsModel followUps;
  final ReportReviewAnalyticsModel reports;
  final EmergencyCaseAnalyticsModel emergencyCases;
  final PrescriptionActivityAnalyticsModel prescriptions;
  final WorkloadDistributionModel workload;
  final BusiestDaysTimesModel busiestDaysTimes;
  final List<RecentDoctorActivityItem> recentActivity;
  final List<ActivityInsightItem> insights;
  final String aiSummaryText;

  const FullDoctorAnalyticsData({
    required this.dateRange,
    required this.overview,
    required this.appointments,
    required this.patientVolume,
    required this.consultationActivity,
    required this.departmentDistribution,
    required this.followUps,
    required this.reports,
    required this.emergencyCases,
    required this.prescriptions,
    required this.workload,
    required this.busiestDaysTimes,
    required this.recentActivity,
    required this.insights,
    required this.aiSummaryText,
  });
}
