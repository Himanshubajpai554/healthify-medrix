import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class EmergencyAnalyticsSection extends StatelessWidget {
  final EmergencyCaseAnalyticsModel emergencyCases;

  const EmergencyAnalyticsSection({
    super.key,
    required this.emergencyCases,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Case Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Operational volume of emergency room encounters',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GlassSecondaryButton(
                onPressed: () => Navigator.pushNamed(context, '/doctor-emergency'),
                height: 34,
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('View Emergency Cases', style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _chip('Total Cases', emergencyCases.totalEmergencyCases, Colors.redAccent, isDark)),
              const SizedBox(width: 8),
              Expanded(child: _chip('Resolved', emergencyCases.resolved, const Color(0xFF10B981), isDark)),
              const SizedBox(width: 8),
              Expanded(child: _chip('Transferred', emergencyCases.transferred, const Color(0xFF3B82F6), isDark)),
              const SizedBox(width: 8),
              Expanded(child: _chip('Active Now', emergencyCases.currentlyActive, Colors.amber.shade800, isDark)),
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
