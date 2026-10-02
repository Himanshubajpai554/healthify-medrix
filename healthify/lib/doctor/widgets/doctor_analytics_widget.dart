import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class DoctorAnalyticsWidget extends StatelessWidget {
  final DoctorAnalyticsModel analytics;

  const DoctorAnalyticsWidget({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.insights_rounded,
                size: 38,
                iconSize: 20,
                color: HealthifyGlassTheme.primaryTeal,
                borderRadius: 10,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor Performance & Practice Analytics',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Weekly clinical output and patient engagement indicators',
                      style: TextStyle(
                        fontSize: 12,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Top 3 Key Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Patients Seen',
                  value: '${analytics.patientsSeenThisWeek}',
                  subtitle: 'This week',
                  icon: Icons.groups_outlined,
                  color: HealthifyGlassTheme.primaryTeal,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'Completed Rate',
                  value: '${analytics.appointmentsCompletedPercent}%',
                  subtitle: 'On-time consults',
                  icon: Icons.task_alt_rounded,
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  title: 'Avg Consult Time',
                  value: analytics.avgConsultationTime,
                  subtitle: 'Per patient',
                  icon: Icons.timer_outlined,
                  color: Colors.blueAccent,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Secondary Indicators
          Row(
            children: [
              Expanded(
                child: _buildMetricProgress(
                  title: 'Follow-up Retention Rate',
                  percent: analytics.followUpRatePercent / 100,
                  label: '${analytics.followUpRatePercent}%',
                  color: HealthifyGlassTheme.primaryTeal,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricProgress(
                  title: 'Patient Feedback Rating',
                  percent: analytics.patientRating / 5.0,
                  label: '${analytics.patientRating} / 5.0 ★',
                  color: Colors.amber.shade700,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly Volume Chart
          Text(
            'Daily OPD Volume (Mon - Sun)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildWeeklyBarChart(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HealthifyGlassTheme.getGlassSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HealthifyGlassTheme.getGlassBorder(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricProgress({
    required String title,
    required double percent,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBarChart(BuildContext context, bool isDark) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final counts = analytics.dailyPatientsSeen;
    final maxVal = 15;

    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: HealthifyGlassTheme.getGlassBorder(isDark),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final count = counts[index];
          final heightRatio = count / maxVal;
          final isToday = index == 3;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isToday
                      ? HealthifyGlassTheme.primaryTeal
                      : HealthifyGlassTheme.getTextMuted(isDark),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 18,
                height: 60 * heightRatio + 4,
                decoration: BoxDecoration(
                  color: isToday
                      ? HealthifyGlassTheme.primaryTeal
                      : HealthifyGlassTheme.primaryTeal.withValues(
                          alpha: isDark ? 0.35 : 0.25,
                        ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                days[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isToday
                      ? HealthifyGlassTheme.primaryTeal
                      : HealthifyGlassTheme.getTextSecondary(isDark),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
