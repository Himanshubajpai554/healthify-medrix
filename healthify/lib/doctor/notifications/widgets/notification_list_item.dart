import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/notification_models.dart';

class NotificationListItem extends StatelessWidget {
  final DoctorNotificationFullModel notification;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final VoidCallback onDismiss;
  final VoidCallback onPerformAction;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.isSelected,
    required this.onTap,
    required this.onMarkRead,
    required this.onDismiss,
    required this.onPerformAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    Border? activeBorder;
    if (isSelected) {
      activeBorder = Border.all(color: HealthifyGlassTheme.primaryTeal, width: 2.0);
    } else if (!notification.isRead) {
      activeBorder = Border.all(
        color: notification.priority == NotificationPriority.urgent
            ? Colors.redAccent.withValues(alpha: 0.6)
            : HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
        width: 1.2,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: activeBorder,
      ),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread Indicator Dot
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 8),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !notification.isRead
                          ? (notification.priority == NotificationPriority.urgent
                              ? Colors.redAccent
                              : HealthifyGlassTheme.primaryTeal)
                          : Colors.transparent,
                    ),
                  ),
                ),

                // Category Icon Container
                GlassIconContainer(
                  icon: notification.category.icon,
                  size: 38,
                  iconSize: 19,
                  color: notification.category.color,
                  borderRadius: 10,
                ),
                const SizedBox(width: 12),

                // Title, Category Label & Priority Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Priority Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: notification.priority.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: notification.priority.color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              notification.priority.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: notification.priority.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Subtitle / Entity / Patient Info Badge & Relative Time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.relatedPatientName != null
                                  ? '${notification.category.label} • 👤 ${notification.relatedPatientName!}'
                                  : notification.category.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: notification.category.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatRelativeTime(notification.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: HealthifyGlassTheme.getTextMuted(isDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description (Privacy-aware, clean summary)
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                notification.shortDescription,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 12),

            // Action Toolbar (Redesigned modern glass pill buttons with guaranteed zero horizontal overflow)
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (notification.actionLabel != null && notification.targetRoute != null)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onPerformAction,
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  notification.actionLabel!,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (!notification.isRead)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onMarkRead,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.18 : 0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
                              width: 1.0,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 13, color: HealthifyGlassTheme.primaryTeal),
                              SizedBox(width: 4),
                              Text(
                                'Mark Read',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: HealthifyGlassTheme.primaryTeal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Dismiss Button
                  Tooltip(
                    message: 'Dismiss notification',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onDismiss,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: isDark ? 0.12 : 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.25),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Dismiss',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
