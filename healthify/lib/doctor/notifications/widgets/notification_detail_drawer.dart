import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/notification_models.dart';

class NotificationDetailDrawer extends StatelessWidget {
  final DoctorNotificationFullModel notification;
  final VoidCallback onClose;
  final VoidCallback onMarkReadToggle;
  final VoidCallback onDismiss;
  final VoidCallback onPerformAction;

  const NotificationDetailDrawer({
    super.key,
    required this.notification,
    required this.onClose,
    required this.onMarkReadToggle,
    required this.onDismiss,
    required this.onPerformAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              GlassIconContainer(
                icon: notification.category.icon,
                size: 44,
                iconSize: 22,
                color: notification.category.color,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.category.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: notification.category.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Notification Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onClose,
                tooltip: 'Close Details',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Main Title & Priority
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: notification.priority.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: notification.priority.color.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  notification.priority.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: notification.priority.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Full Description
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Text(
              notification.fullDescription,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contextual Information & Patient Details
          if (notification.relatedPatientName != null || notification.relatedEntityId != null) ...[
            Text(
              'CLINICAL CONTEXT',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: HealthifyGlassTheme.getTextMuted(isDark),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: HealthifyGlassTheme.getGlassBorder(isDark),
                ),
              ),
              child: Column(
                children: [
                  if (notification.relatedPatientName != null) ...[
                    _buildMetaRow('Patient Name:', notification.relatedPatientName!, isDark),
                    if (notification.relatedPatientId != null)
                      _buildMetaRow('Patient ID:', notification.relatedPatientId!, isDark),
                  ],
                  if (notification.relatedEntityId != null)
                    _buildMetaRow('Reference Record ID:', notification.relatedEntityId!, isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Delivery & Read Audit History
          Text(
            'AUDIT HISTORY',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: HealthifyGlassTheme.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Column(
              children: [
                _buildMetaRow('Notification ID:', notification.id, isDark),
                _buildMetaRow('Created:', _formatDateTime(notification.auditCreated), isDark),
                _buildMetaRow('Delivered:', _formatDateTime(notification.auditDelivered), isDark),
                _buildMetaRow(
                  'Read Status:',
                  notification.isRead
                      ? 'Read at ${_formatDateTime(notification.auditRead ?? notification.timestamp)}'
                      : 'Unread',
                  isDark,
                  valueColor: notification.isRead ? Colors.green : Colors.amber.shade800,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Primary Navigation Button
          if (notification.actionLabel != null && notification.targetRoute != null) ...[
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPerformAction,
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Navigate to ${notification.actionLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Secondary Action Controls
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onMarkReadToggle,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            notification.isRead ? Icons.mark_email_unread_rounded : Icons.check_circle_outline_rounded,
                            size: 16,
                            color: HealthifyGlassTheme.primaryTeal,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              notification.isRead ? 'Mark Unread' : 'Mark as Read',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: HealthifyGlassTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDismiss,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: isDark ? 0.14 : 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Dismiss',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                              ),
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
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor ?? HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
