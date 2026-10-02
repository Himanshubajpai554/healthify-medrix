import 'package:flutter/material.dart';
import '../utils/datetime_service.dart';

/// Reusable Data Freshness Indicator Badge for Medrix Platform
class FreshnessBadge extends StatelessWidget {
  final DateTime? timestamp;
  final String? customLabel;
  final bool isLive;

  const FreshnessBadge({
    super.key,
    this.timestamp,
    this.customLabel,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelText = customLabel ?? (timestamp != null ? DateTimeService.formatRelativeTime(timestamp!) : 'Updated just now');
    final color = isLive ? const Color(0xFF10B981) : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            labelText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
