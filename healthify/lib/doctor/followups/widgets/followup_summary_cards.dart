import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/followup_models.dart';

class FollowUpSummaryCards extends StatelessWidget {
  final int dueTodayCount;
  final int upcomingCount;
  final int overdueCount;
  final int completedThisWeekCount;
  final FollowUpStatus? selectedStatusFilter;
  final ValueChanged<FollowUpStatus?> onStatusFilterSelected;

  const FollowUpSummaryCards({
    super.key,
    required this.dueTodayCount,
    required this.upcomingCount,
    required this.overdueCount,
    required this.completedThisWeekCount,
    required this.selectedStatusFilter,
    required this.onStatusFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width > 1000 ? 4 : (width > 600 ? 2 : 2);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: width > 1000
              ? 2.1
              : (width > 600 ? 2.2 : (width < 380 ? 0.98 : 1.05)),
          children: [
            _buildCard(
              context: context,
              title: 'Due Today',
              count: dueTodayCount,
              icon: Icons.today_rounded,
              accentColor: const Color(0xFFD97706),
              isSelected: selectedStatusFilter == FollowUpStatus.dueToday,
              onTap: () {
                onStatusFilterSelected(
                  selectedStatusFilter == FollowUpStatus.dueToday ? null : FollowUpStatus.dueToday,
                );
              },
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'Upcoming',
              count: upcomingCount,
              icon: Icons.calendar_month_rounded,
              accentColor: const Color(0xFF3B82F6),
              isSelected: selectedStatusFilter == FollowUpStatus.scheduled,
              onTap: () {
                onStatusFilterSelected(
                  selectedStatusFilter == FollowUpStatus.scheduled ? null : FollowUpStatus.scheduled,
                );
              },
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'Overdue',
              count: overdueCount,
              icon: Icons.warning_amber_rounded,
              accentColor: const Color(0xFFEF4444),
              isSelected: selectedStatusFilter == FollowUpStatus.overdue,
              onTap: () {
                onStatusFilterSelected(
                  selectedStatusFilter == FollowUpStatus.overdue ? null : FollowUpStatus.overdue,
                );
              },
              isDark: isDark,
            ),
            _buildCard(
              context: context,
              title: 'Completed This Week',
              count: completedThisWeekCount,
              icon: Icons.task_alt_rounded,
              accentColor: const Color(0xFF10B981),
              isSelected: selectedStatusFilter == FollowUpStatus.completed,
              onTap: () {
                onStatusFilterSelected(
                  selectedStatusFilter == FollowUpStatus.completed ? null : FollowUpStatus.completed,
                );
              },
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
    required int count,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
