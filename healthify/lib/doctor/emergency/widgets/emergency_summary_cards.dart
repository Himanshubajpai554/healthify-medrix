import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/emergency_models.dart';

class EmergencySummaryCards extends StatelessWidget {
  final int activeCount;
  final int criticalCount;
  final int waitingCount;
  final int inTreatmentCount;
  final int resolvedTodayCount;
  final EmergencyCaseStatus? selectedStatusFilter;
  final ValueChanged<EmergencyCaseStatus?> onStatusFilterSelected;

  const EmergencySummaryCards({
    super.key,
    required this.activeCount,
    required this.criticalCount,
    required this.waitingCount,
    required this.inTreatmentCount,
    required this.resolvedTodayCount,
    required this.selectedStatusFilter,
    required this.onStatusFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 1100 ? 5 : (width > 650 ? 3 : 2);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: width > 1100 ? 1.8 : (width > 650 ? 2.0 : 1.6),
          children: [
            _buildCard(
              context: context,
              title: 'Active Emergencies',
              value: activeCount.toString(),
              subtitle: 'Open ER workflows',
              icon: Icons.emergency_rounded,
              color: Colors.redAccent,
              isSelected: selectedStatusFilter == null,
              onTap: () => onStatusFilterSelected(null),
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'Critical Attention',
              value: criticalCount.toString(),
              subtitle: 'Immediate priority cases',
              icon: Icons.error_rounded,
              color: Colors.red.shade700,
              isSelected: false,
              onTap: () => onStatusFilterSelected(null),
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'Waiting',
              value: waitingCount.toString(),
              subtitle: 'Triage pending treatment',
              icon: Icons.hourglass_top_rounded,
              color: Colors.amber.shade800,
              isSelected: selectedStatusFilter == EmergencyCaseStatus.waiting,
              onTap: () => onStatusFilterSelected(EmergencyCaseStatus.waiting),
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'In Treatment',
              value: inTreatmentCount.toString(),
              subtitle: 'Active intervention',
              icon: Icons.medical_services_rounded,
              color: Colors.blue.shade600,
              isSelected: selectedStatusFilter == EmergencyCaseStatus.inTreatment,
              onTap: () => onStatusFilterSelected(EmergencyCaseStatus.inTreatment),
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'Resolved Today',
              value: resolvedTodayCount.toString(),
              subtitle: 'Closed / Discharged',
              icon: Icons.task_alt_rounded,
              color: const Color(0xFF10B981),
              isSelected: selectedStatusFilter == EmergencyCaseStatus.resolved,
              onTap: () => onStatusFilterSelected(EmergencyCaseStatus.resolved),
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.85)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : HealthifyGlassTheme.getGlassBorder(isDark),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                color: HealthifyGlassTheme.getTextSecondary(isDark).withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
