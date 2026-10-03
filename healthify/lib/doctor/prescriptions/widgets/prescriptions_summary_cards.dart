import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/prescription_models.dart';

class PrescriptionsSummaryCards extends StatelessWidget {
  final int totalCount;
  final int createdTodayCount;
  final int activeCount;
  final int draftsCount;
  final PrescriptionStatus? selectedStatusFilter;
  final ValueChanged<PrescriptionStatus?> onStatusFilterSelected;

  const PrescriptionsSummaryCards({
    super.key,
    required this.totalCount,
    required this.createdTodayCount,
    required this.activeCount,
    required this.draftsCount,
    required this.selectedStatusFilter,
    required this.onStatusFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 900 ? 4 : (width > 550 ? 2 : 2);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: width > 900
              ? 2.1
              : (width > 550 ? 2.2 : (width < 380 ? 0.98 : 1.05)),
          children: [
            _buildCard(
              context: context,
              title: 'Total Prescriptions',
              value: totalCount.toString(),
              subtitle: 'All indexed clinical RX',
              icon: Icons.medication_rounded,
              color: HealthifyGlassTheme.primaryTeal,
              isSelected: selectedStatusFilter == null,
              onTap: () => onStatusFilterSelected(null),
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'Created Today',
              value: createdTodayCount.toString(),
              subtitle: 'Issued in last 24h',
              icon: Icons.today_rounded,
              color: Colors.blue.shade600,
              isSelected: false,
              onTap: () => onStatusFilterSelected(null),
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'Active',
              value: activeCount.toString(),
              subtitle: 'Ongoing therapy',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              isSelected: selectedStatusFilter == PrescriptionStatus.active,
              onTap: () => onStatusFilterSelected(PrescriptionStatus.active),
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'Drafts',
              value: draftsCount.toString(),
              subtitle: 'Pending activation',
              icon: Icons.edit,
              color: Colors.indigo.shade600,
              isSelected: selectedStatusFilter == PrescriptionStatus.draft,
              onTap: () => onStatusFilterSelected(PrescriptionStatus.draft),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.25 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 17, color: color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: HealthifyGlassTheme.getTextSecondary(
                    isDark,
                  ).withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
