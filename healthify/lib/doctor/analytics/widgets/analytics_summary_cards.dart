import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class AnalyticsSummaryCards extends StatelessWidget {
  final DoctorAnalyticsOverviewModel overview;

  const AnalyticsSummaryCards({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 1100 ? 6 : (width > 700 ? 3 : 2);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: width > 1100 ? 1.6 : (width > 700 ? 1.8 : 1.5),
          children: [
            _buildCard(
              title: 'Total Patients',
              value: overview.totalPatients.value,
              comparisonText: overview.totalPatients.comparisonText,
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF0D9488),
              isDark: isDark,
            ),
            _buildCard(
              title: 'Appointments',
              value: overview.totalAppointments.value,
              comparisonText: overview.totalAppointments.comparisonText,
              icon: Icons.calendar_today_rounded,
              color: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
            _buildCard(
              title: 'Completed Consults',
              value: overview.completedConsultations.value,
              comparisonText: overview.completedConsultations.comparisonText,
              icon: Icons.medical_services_rounded,
              color: const Color(0xFF10B981),
              isDark: isDark,
            ),
            _buildCard(
              title: 'Follow-ups',
              value: overview.followUps.value,
              comparisonText: overview.followUps.comparisonText,
              icon: Icons.event_repeat_rounded,
              color: const Color(0xFFD97706),
              isDark: isDark,
            ),
            _buildCard(
              title: 'Reports Reviewed',
              value: overview.reportsReviewed.value,
              comparisonText: overview.reportsReviewed.comparisonText,
              icon: Icons.assignment_rounded,
              color: const Color(0xFF8B5CF6),
              isDark: isDark,
            ),
            _buildCard(
              title: 'Emergency Cases',
              value: overview.emergencyCases.value,
              comparisonText: overview.emergencyCases.comparisonText,
              icon: Icons.emergency_rounded,
              color: Colors.redAccent,
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required int value,
    required String comparisonText,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Text(
            comparisonText,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
