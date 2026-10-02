import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/notification_models.dart';

class NotificationsSummaryCards extends StatelessWidget {
  final int unreadCount;
  final int todayCount;
  final int emergencyCount;
  final int appointmentsCount;
  final NotificationCategory selectedCategory;
  final ValueChanged<NotificationCategory> onSelectCategory;

  const NotificationsSummaryCards({
    super.key,
    required this.unreadCount,
    required this.todayCount,
    required this.emergencyCount,
    required this.appointmentsCount,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 550 ? 2 : 2);
        final cardAspectRatio = constraints.maxWidth > 900 ? 2.1 : (constraints.maxWidth > 550 ? 2.2 : 1.9);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: cardAspectRatio,
          children: [
            _buildMetricCard(
              context: context,
              title: 'Unread',
              count: unreadCount,
              icon: Icons.mark_email_unread_rounded,
              color: HealthifyGlassTheme.primaryTeal,
              categoryTarget: NotificationCategory.unread,
              isSelected: selectedCategory == NotificationCategory.unread,
            ),
            _buildMetricCard(
              context: context,
              title: 'All Alerts',
              count: todayCount,
              icon: Icons.today_rounded,
              color: Colors.indigo,
              categoryTarget: NotificationCategory.all,
              isSelected: selectedCategory == NotificationCategory.all,
            ),
            _buildMetricCard(
              context: context,
              title: 'Emergency',
              count: emergencyCount,
              icon: Icons.emergency_rounded,
              color: Colors.redAccent,
              categoryTarget: NotificationCategory.emergency,
              isSelected: selectedCategory == NotificationCategory.emergency,
            ),
            _buildMetricCard(
              context: context,
              title: 'Appointments',
              count: appointmentsCount,
              icon: Icons.calendar_today_rounded,
              color: Colors.blue,
              categoryTarget: NotificationCategory.appointments,
              isSelected: selectedCategory == NotificationCategory.appointments,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required NotificationCategory categoryTarget,
    required bool isSelected,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(color: color, width: 2.0) : null,
      ),
      child: GlassCard(
        onTap: () => onSelectCategory(categoryTarget),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            GlassIconContainer(
              icon: icon,
              size: 40,
              iconSize: 20,
              color: color,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const SizedBox(height: 2),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? color : HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
