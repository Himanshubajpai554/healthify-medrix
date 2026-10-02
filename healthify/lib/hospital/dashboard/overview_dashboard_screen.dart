import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import './widgets/hospital_trend_charts.dart';
import './widgets/quick_actions_modals.dart';
import './widgets/simulator_widget.dart';
import './widgets/hospital_capacity_widget.dart';
import './widgets/patient_flow_widget.dart';
import './widgets/alerts_and_insights_widget.dart';

class OverviewDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const OverviewDashboardScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<OverviewDashboardScreen> createState() => _OverviewDashboardScreenState();
}

class _OverviewDashboardScreenState extends State<OverviewDashboardScreen> {
  final HospitalRepository _hospitalRepository = MockHospitalRepository();
  final AnalyticsRepository _analyticsRepository = MockAnalyticsRepository();
  final NotificationRepository _notificationRepository = MockNotificationRepository();

  UiState<HospitalOverviewMetrics> _metricsState = UiState.initial();
  String _selectedDateRange = 'Today (Day Shift)';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _metricsState = UiState.loading();
    });

    try {
      await _hospitalRepository.getHospitalInfo();
      final metrics = await _analyticsRepository.getOverviewMetrics();
      setState(() {
        _metricsState = UiState.success(metrics);
      });
    } catch (e) {
      setState(() {
        _metricsState = UiState.error('Failed to load dashboard analytics: ${e.toString()}');
      });
    }
  }

  void _showNotificationDrawer(BuildContext context) async {
    final isDark = HealthifyGlassTheme.isDark(context);
    final notifications = await _notificationRepository.getNotifications();
    if (!context.mounted) return;

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Hospital Notifications (${notifications.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(color: isDark ? Colors.white12 : AppTheme.borderLight),
            ...notifications.take(5).map((n) => _buildNotificationItem(
              isDark,
              title: n.title,
              subtitle: n.message,
              time: '${n.timestamp.minute}m ago',
              iconColor: n.priority == NotificationPriority.critical || n.priority == NotificationPriority.high
                  ? Colors.redAccent
                  : AppTheme.primaryColor,
              icon: n.priority == NotificationPriority.critical ? Icons.warning_rounded : Icons.info_rounded,
            )),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.launch_rounded, size: 16),
                label: const Text('Open Full Notification & Dispatch Center'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNavigateToTab?.call(14);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return ListTile(
      leading: GlassIconContainer(
        icon: icon,
        color: iconColor,
        size: 38,
        iconSize: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: isDark ? Colors.white : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white70 : AppTheme.textSecondary,
        ),
      ),
      trailing: Text(
        time,
        style: TextStyle(
          fontSize: 10,
          color: isDark ? Colors.white38 : AppTheme.textMuted,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showSnackBar(String msg) {
    final isDark = HealthifyGlassTheme.isDark(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        backgroundColor: isDark
            ? const Color(0xFF0F2928).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : AppTheme.borderLight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 950;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Page Header with Live Pulse & Filters
          _buildPageHeader(context),

          const SizedBox(height: 18),

          if (_metricsState.isLoading)
            const MedrixLoadingState(message: 'Loading hospital analytics & operational data...')
          else if (_metricsState.isError)
            MedrixErrorState(
              errorMessage: _metricsState.errorMessage ?? 'Error loading dashboard data',
              onRetry: _loadDashboardData,
            )
          else ...[
            // Section 2: Compact Hospital Status Bar
            _buildHospitalStatusBar(context),

            const SizedBox(height: 24),

            // Section 3: High-Priority KPI Cards Grid
            _buildKpiGrid(context),

            const SizedBox(height: 24),

            // Section 16: Quick Actions Bar
            _buildQuickActionsBar(context),

          const SizedBox(height: 24),

          // Main 2-Column Responsive Dashboard Body
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Primary Column (Charts, Flow, Simulator)
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      const BedOccupancyChartWidget(), // Section 13
                      const SizedBox(height: 20),
                      const LivePatientFlowWidget(), // Section 5
                      const SizedBox(height: 20),
                      const PatientActivityTrendChart(), // Section 12
                      const SizedBox(height: 20),
                      const WhatIfSimulatorWidget(), // Section 19
                      const SizedBox(height: 20),
                      const TodayAppointmentsWidget(), // Section 6
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right Secondary Column (Capacity, Alerts, Insights, Resources)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      CriticalAlertsWidget(onActionTap: _showSnackBar), // Section 8
                      const SizedBox(height: 20),
                      const AiHospitalInsightsWidget(), // Section 9
                      const SizedBox(height: 20),
                      const LiveHospitalCapacityWidget(), // Section 4
                      const SizedBox(height: 20),
                      const HospitalResourceSnapshotWidget(), // Section 10
                      const SizedBox(height: 20),
                      const DepartmentLoadWidget(), // Section 11
                      const SizedBox(height: 20),
                      const DoctorAvailabilityWidget(), // Section 7
                      const SizedBox(height: 20),
                      const BloodBankSnapshotWidget(), // Section 14
                      const SizedBox(height: 20),
                      const PatientAppSyncWidget(), // Section 17
                      const SizedBox(height: 20),
                      const AttentionTaskListWidget(), // Section 18
                      const SizedBox(height: 20),
                      const RecentActivityFeedWidget(), // Section 15
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                CriticalAlertsWidget(onActionTap: _showSnackBar),
                const SizedBox(height: 20),
                const BedOccupancyChartWidget(),
                const SizedBox(height: 20),
                const LivePatientFlowWidget(),
                const SizedBox(height: 20),
                const AiHospitalInsightsWidget(),
                const SizedBox(height: 20),
                const LiveHospitalCapacityWidget(),
                const SizedBox(height: 20),
                const WhatIfSimulatorWidget(),
                const SizedBox(height: 20),
                const PatientActivityTrendChart(),
                const SizedBox(height: 20),
                const HospitalResourceSnapshotWidget(),
                const SizedBox(height: 20),
                const DepartmentLoadWidget(),
                const SizedBox(height: 20),
                const TodayAppointmentsWidget(),
                const SizedBox(height: 20),
                const DoctorAvailabilityWidget(),
                const SizedBox(height: 20),
                const BloodBankSnapshotWidget(),
                const SizedBox(height: 20),
                const PatientAppSyncWidget(),
                const SizedBox(height: 20),
                const AttentionTaskListWidget(),
                const SizedBox(height: 20),
                const RecentActivityFeedWidget(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F766E), const Color(0xFF061817)]
              : [const Color(0xFF0D9488), const Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.2 : 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome Back, Administrator',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCCFBF1),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Hospital Operations Command Center',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'St. Jude Memorial Hospital — Main Campus (Building A & B)',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              // Live Status Badge & Date Range Filter & Notifications
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
                        SizedBox(width: 6),
                        Text(
                          '● LIVE • 2 min ago',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0B2928) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.transparent,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDateRange,
                        isDense: true,
                        dropdownColor: isDark ? const Color(0xFF0F2928) : Colors.white,
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryColor),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                        items: ['Today (Day Shift)', 'Last 24 Hours', '7 Days', '30 Days']
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : AppTheme.textPrimary,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDateRange = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showNotificationDrawer(context),
                    icon: const Icon(Icons.notifications_active_outlined, color: Colors.white),
                    tooltip: 'Open Notification Drawer',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalStatusBar(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusChip(context, 'Capacity Status', '84% High Volume', const Color(0xFFF59E0B)),
            _buildVerticalDivider(context),
            _buildStatusChip(context, 'ER Intake Load', '12 Waiting (Heavy)', const Color(0xFFEF4444)),
            _buildVerticalDivider(context),
            _buildStatusChip(context, 'ICU Readiness', '4 Beds Available', const Color(0xFF0D9488)),
            _buildVerticalDivider(context),
            _buildStatusChip(context, 'Nurse-Patient Ratio', '1 : 4.2 (Optimal)', const Color(0xFF10B981)),
            _buildVerticalDivider(context),
            _buildStatusChip(context, 'AI Surge Alert', '+15 Expected at 18:00', const Color(0xFF0284C7)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, String value, Color color) {
    final isDark = HealthifyGlassTheme.isDark(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.white60 : AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 24,
        child: VerticalDivider(
          color: isDark ? Colors.white12 : AppTheme.borderLight,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 1100 ? 4 : (constraints.maxWidth > 650 ? 2 : 1);

        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: count == 1 ? 2.2 : (count == 2 ? 1.6 : 1.55),
          children: [
            _KpiCard(
              title: 'Total Admitted Patients',
              value: '1,284',
              subvalue: '840 Gen • 214 ICU • 230 Spec',
              trend: '+4.2% vs yesterday',
              icon: Icons.people_alt_outlined,
              color: AppTheme.primaryColor,
              onTap: () => widget.onNavigateToTab?.call(5), // Patients tab
            ),
            _KpiCard(
              title: "Today's Appointments",
              value: '146',
              subvalue: '98 Completed • 32 Pending',
              trend: '16 No-shows today',
              icon: Icons.calendar_today_outlined,
              color: AppTheme.accentColor,
            ),
            _KpiCard(
              title: 'Bed Availability',
              value: '42 Free Beds',
              subvalue: '16.8% Free • 4 ICU Free',
              trend: '84% Occupied',
              icon: Icons.king_bed_outlined,
              color: const Color(0xFFF59E0B),
              onTap: () => widget.onNavigateToTab?.call(6), // Beds tab
            ),
            _KpiCard(
              title: 'Doctors On Duty',
              value: '38 Active',
              subvalue: '8 Surgery • 4 On Call',
              trend: '52 Total Staff',
              icon: Icons.badge_outlined,
              color: const Color(0xFF0D9488),
              onTap: () => widget.onNavigateToTab?.call(3), // Doctors tab
            ),
            _KpiCard(
              title: 'ICU Capacity',
              value: '26 / 30 Occupied',
              subvalue: '4 Beds Free • 2 Ventilators',
              trend: '86.6% High Capacity',
              icon: Icons.local_hospital_outlined,
              color: const Color(0xFFEF4444),
              onTap: () => widget.onNavigateToTab?.call(6), // Beds tab
            ),
            _KpiCard(
              title: 'Blood Bank Stock',
              value: '342 Units',
              subvalue: 'O-ve & AB-ve Low',
              trend: '2 Critical Low Types',
              icon: Icons.bloodtype_outlined,
              color: const Color(0xFFE11D48),
              onTap: () => widget.onNavigateToTab?.call(7), // Blood bank tab
            ),
            _KpiCard(
              title: 'Emergency Department',
              value: '12 Active Triage',
              subvalue: '3 Critical L1 • 5 Urgent L2',
              trend: 'Avg Wait 14 min',
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFD97706),
            ),
            _KpiCard(
              title: 'Pending Lab Reports',
              value: '18 Unreviewed',
              subvalue: '4 Urgent High Priority',
              trend: 'CBC & MRI Pending',
              icon: Icons.science_outlined,
              color: const Color(0xFF8B5CF6),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsBar(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);
    return GlassCard(
      padding: const EdgeInsets.all(18.0),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospital Operational Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              GlassPrimaryButton(
                onPressed: () => QuickActionsModals.showRegisterPatientModal(context, onSuccess: _showSnackBar),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_rounded, size: 17),
                    SizedBox(width: 6),
                    Text('+ Admit Patient'),
                  ],
                ),
              ),
              GlassSecondaryButton(
                onPressed: () => QuickActionsModals.showAddDoctorModal(context, onSuccess: _showSnackBar),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.badge_outlined, size: 17),
                    SizedBox(width: 6),
                    Text('+ Schedule Doctor'),
                  ],
                ),
              ),
              GlassSecondaryButton(
                onPressed: () => QuickActionsModals.showAllocateBedModal(context, onSuccess: _showSnackBar),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.king_bed_outlined, size: 17),
                    SizedBox(width: 6),
                    Text('+ Allocate Bed'),
                  ],
                ),
              ),
              GlassSecondaryButton(
                onPressed: () => QuickActionsModals.showRequestBloodModal(context, onSuccess: _showSnackBar),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bloodtype_outlined, size: 17),
                    SizedBox(width: 6),
                    Text('+ Request Blood'),
                  ],
                ),
              ),
              GlassSecondaryButton(
                onPressed: () => QuickActionsModals.showUploadReportModal(context, onSuccess: _showSnackBar),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upload_file_rounded, size: 17),
                    SizedBox(width: 6),
                    Text('+ Upload Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subvalue;
  final String trend;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subvalue,
    required this.trend,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDark(context);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GlassIconContainer(
                icon: icon,
                color: color,
                size: 34,
                iconSize: 18,
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          Text(
            subvalue,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            trend,
            style: TextStyle(
              fontSize: 11.5,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}