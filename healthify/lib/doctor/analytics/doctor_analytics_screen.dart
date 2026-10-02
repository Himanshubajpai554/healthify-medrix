import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_analytics_models.dart';
import '../models/doctor_dashboard_models.dart';
import '../services/doctor_analytics_service.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_sidebar.dart';
import 'widgets/activity_insights_section.dart';
import 'widgets/ai_activity_summary_card.dart';
import 'widgets/analytics_header.dart';
import 'widgets/analytics_summary_cards.dart';
import 'widgets/appointment_analytics_section.dart';
import 'widgets/busiest_days_times_section.dart';
import 'widgets/consultation_activity_section.dart';
import 'widgets/department_distribution_section.dart';
import 'widgets/emergency_analytics_section.dart';
import 'widgets/export_analytics_modal.dart';
import 'widgets/followup_analytics_section.dart';
import 'widgets/patient_volume_section.dart';
import 'widgets/prescription_analytics_section.dart';
import 'widgets/recent_activity_timeline.dart';
import 'widgets/report_analytics_section.dart';
import 'widgets/workload_distribution_section.dart';

class DoctorAnalyticsScreen extends StatefulWidget {
  const DoctorAnalyticsScreen({super.key});

  @override
  State<DoctorAnalyticsScreen> createState() => _DoctorAnalyticsScreenState();
}

class _DoctorAnalyticsScreenState extends State<DoctorAnalyticsScreen> {
  final DoctorAnalyticsService _analyticsService = DoctorAnalyticsService();

  FullDoctorAnalyticsData? _data;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isSidebarExpanded = true;

  AnalyticsDateRange _selectedDateRange = AnalyticsDateRange.thisMonth;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await _analyticsService.getDoctorAnalytics(
        doctorId: 'DR-SARAH-JENKINS',
        dateRange: _selectedDateRange,
      );
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: isDark ? HealthifyGlassTheme.darkBackground : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Row(
          children: [
            // Desktop Left Sidebar
            if (isDesktop)
              DoctorSidebar(
                selectedNavIndex: 8, // Index 8 is My Analytics
                onNavItemSelected: (index) => _navigateToIndex(context, index),
                isExpanded: _isSidebarExpanded,
                onToggleExpand: () {
                  setState(() => _isSidebarExpanded = !_isSidebarExpanded);
                },
                availabilityStatus: DoctorAvailability.available,
                onLogout: () => Navigator.pushReplacementNamed(context, '/portal-select'),
                onRoleSwitcherTap: () => Navigator.pushReplacementNamed(context, '/portal-select'),
              ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Doctor Top Navigation Header
                  DoctorHeader(
                    doctorName: 'Dr. Sarah Jenkins',
                    title: 'Personal Doctor Analytics',
                    subtitle: 'Workload Metrics & Clinical Trends',
                    availabilityStatus: DoctorAvailability.available,
                    onAvailabilityChanged: (_) {},
                    onNotificationTap: () {},
                    onSearchTap: () {},
                    onProfileTap: () {},
                    onThemeToggle: () {},
                    unreadNotificationsCount: 3,
                  ),

                  // Analytics Body
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: HealthifyGlassTheme.primaryTeal,
                            ),
                          )
                        : _hasError
                            ? _buildErrorView(isDark)
                            : _buildAnalyticsContent(context, isDark, isDesktop, isMobile),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    bool isDark,
    bool isDesktop,
    bool isMobile,
  ) {
    if (_data == null) return const SizedBox();
    final d = _data!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Page Header & Date Selector
          AnalyticsHeader(
            selectedDateRange: _selectedDateRange,
            onDateRangeChanged: (range) {
              setState(() => _selectedDateRange = range);
              _loadAnalytics();
            },
            onExportPressed: () => _openExportModal(context),
            onRefreshPressed: _loadAnalytics,
          ),
          const SizedBox(height: 20),

          // 2. Top Summary Metrics Cards
          AnalyticsSummaryCards(overview: d.overview),
          const SizedBox(height: 20),

          // 3. AI Activity Summary Card
          AIActivitySummaryCard(
            summaryText: d.aiSummaryText,
            onRefreshSummary: _loadAnalytics,
          ),
          const SizedBox(height: 20),

          // 4. Appointment Analytics (Trend & Status Breakdown)
          AppointmentAnalyticsSection(appointments: d.appointments),
          const SizedBox(height: 20),

          // 5. Patient Volume Breakdown
          PatientVolumeSection(patientVolume: d.patientVolume),
          const SizedBox(height: 20),

          // 6. Consultation Activity Section
          ConsultationActivitySection(consultationActivity: d.consultationActivity),
          const SizedBox(height: 20),

          // 7. Department Distribution & Workload
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: DepartmentDistributionSection(departmentDistribution: d.departmentDistribution)),
                const SizedBox(width: 16),
                Expanded(child: WorkloadDistributionSection(workload: d.workload)),
              ],
            )
          else ...[
            DepartmentDistributionSection(departmentDistribution: d.departmentDistribution),
            const SizedBox(height: 20),
            WorkloadDistributionSection(workload: d.workload),
          ],
          const SizedBox(height: 20),

          // 8. Busiest Days & Times Section
          BusiestDaysTimesSection(busiestDaysTimes: d.busiestDaysTimes),
          const SizedBox(height: 20),

          // 9. Follow-ups & Reports Review
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: FollowUpAnalyticsSection(followUps: d.followUps)),
                const SizedBox(width: 16),
                Expanded(child: ReportAnalyticsSection(reports: d.reports)),
              ],
            )
          else ...[
            FollowUpAnalyticsSection(followUps: d.followUps),
            const SizedBox(height: 20),
            ReportAnalyticsSection(reports: d.reports),
          ],
          const SizedBox(height: 20),

          // 10. Emergency & Prescriptions Activity
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: EmergencyAnalyticsSection(emergencyCases: d.emergencyCases)),
                const SizedBox(width: 16),
                Expanded(child: PrescriptionAnalyticsSection(prescriptions: d.prescriptions)),
              ],
            )
          else ...[
            EmergencyAnalyticsSection(emergencyCases: d.emergencyCases),
            const SizedBox(height: 20),
            PrescriptionAnalyticsSection(prescriptions: d.prescriptions),
          ],
          const SizedBox(height: 20),

          // 11. Activity Insights & Recent Activity Timeline
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ActivityInsightsSection(insights: d.insights)),
                const SizedBox(width: 16),
                Expanded(child: RecentActivityTimeline(activities: d.recentActivity)),
              ],
            )
          else ...[
            ActivityInsightsSection(insights: d.insights),
            const SizedBox(height: 20),
            RecentActivityTimeline(activities: d.recentActivity),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              'Analytics Unavailable',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to fetch activity records from server.',
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            GlassPrimaryButton(
              onPressed: _loadAnalytics,
              height: 40,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _openExportModal(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ExportAnalyticsModal(
          dateRange: _selectedDateRange,
          onExportConfirmed: (format) {
            messenger.showSnackBar(
              SnackBar(content: Text('Exporting analytics report as $format...')),
            );
          },
        );
      },
    );
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/doctor-appointments');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/doctor-patients');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/doctor-patient-profile');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/doctor-reports');
        break;
      case 5:
        Navigator.pushReplacementNamed(context, '/doctor-prescriptions');
        break;
      case 6:
        Navigator.pushReplacementNamed(context, '/doctor-emergency');
        break;
      case 7:
        Navigator.pushReplacementNamed(context, '/doctor-followups');
        break;
      case 8:
        // Already on My Analytics
        break;
      default:
        Navigator.pushReplacementNamed(context, '/doctor');
        break;
    }
  }
}
