import 'package:flutter/material.dart';
import '../utils/status_system.dart';

class HealthifyStatusBadge extends StatelessWidget {
  final HealthifyStatusConfig config;
  final bool showIcon;

  const HealthifyStatusBadge({
    super.key,
    required this.config,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.color.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, size: 13, color: config.color),
            const SizedBox(width: 5),
          ],
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }
}
