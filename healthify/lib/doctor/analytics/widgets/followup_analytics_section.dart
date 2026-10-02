import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class FollowUpAnalyticsSection extends StatelessWidget {
  final FollowUpAnalyticsModel followUps;

  const FollowUpAnalyticsSection({
    super.key,
    required this.followUps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Follow-up Activity Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Care continuity tracking and upcoming visit pipeline',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              GlassSecondaryButton(
                onPressed: () => Navigator.pushNamed(context, '/doctor-followups'),
                height: 34,
                child: const Text('View Follow-ups', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _chip('Upcoming', followUps.scheduled, const Color(0xFF3B82F6), isDark)),
              const SizedBox(width: 8),
              Expanded(child: _chip('Completed', followUps.completed, const Color(0xFF10B981), isDark)),
              const SizedBox(width: 8),
              Expanded(child: _chip('Due Today', followUps.due, const Color(0xFFD97706), isDark)),
              const SizedBox(width: 8),
              Expanded(child: _chip('Overdue', followUps.overdue, Colors.redAccent, isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, int count, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : const Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}
