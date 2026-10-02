import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/notification_models.dart';
import 'notification_list_item.dart';

class GroupedNotificationsList extends StatelessWidget {
  final List<DoctorNotificationFullModel> notifications;
  final String? selectedNotificationId;
  final ValueChanged<DoctorNotificationFullModel> onSelectNotification;
  final ValueChanged<String> onMarkRead;
  final ValueChanged<String> onDismiss;
  final ValueChanged<DoctorNotificationFullModel> onPerformAction;

  const GroupedNotificationsList({
    super.key,
    required this.notifications,
    required this.selectedNotificationId,
    required this.onSelectNotification,
    required this.onMarkRead,
    required this.onDismiss,
    required this.onPerformAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    if (notifications.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    final groupedMap = _groupNotificationsChronologically(notifications);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedMap.keys.length,
      itemBuilder: (context, groupIndex) {
        final groupTitle = groupedMap.keys.elementAt(groupIndex);
        final groupItems = groupedMap[groupTitle]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 8, left: 4),
              child: Row(
                children: [
                  Text(
                    groupTitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: HealthifyGlassTheme.getTextMuted(isDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${groupItems.length}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notification Items
            ...groupItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NotificationListItem(
                  notification: item,
                  isSelected: selectedNotificationId == item.id,
                  onTap: () => onSelectNotification(item),
                  onMarkRead: () => onMarkRead(item.id),
                  onDismiss: () => onDismiss(item.id),
                  onPerformAction: () => onPerformAction(item),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassIconContainer(
              icon: Icons.notifications_none_rounded,
              size: 64,
              iconSize: 32,
              color: HealthifyGlassTheme.getTextMuted(isDark),
            ),
            const SizedBox(height: 16),
            Text(
              'No Notifications Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'There are no alerts matching your selected filter or search terms.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<DoctorNotificationFullModel>> _groupNotificationsChronologically(
    List<DoctorNotificationFullModel> items,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    final Map<String, List<DoctorNotificationFullModel>> grouped = {
      'TODAY': [],
      'YESTERDAY': [],
      'EARLIER THIS WEEK': [],
      'OLDER': [],
    };

    for (final item in items) {
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );

      if (itemDate.isAtSameMomentAs(today)) {
        grouped['TODAY']!.add(item);
      } else if (itemDate.isAtSameMomentAs(yesterday)) {
        grouped['YESTERDAY']!.add(item);
      } else if (itemDate.isAfter(startOfWeek)) {
        grouped['EARLIER THIS WEEK']!.add(item);
      } else {
        grouped['OLDER']!.add(item);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }
}
