import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class WorkloadDistributionSection extends StatelessWidget {
  final WorkloadDistributionModel workload;

  const WorkloadDistributionSection({
    super.key,
    required this.workload,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final total = workload.totalActions;

    final items = [
      {'label': 'Appointments Scheduled', 'count': workload.appointmentsCount, 'color': const Color(0xFF3B82F6), 'icon': Icons.calendar_today_rounded},
      {'label': 'Consultations Conducted', 'count': workload.consultationsCount, 'color': const Color(0xFF10B981), 'icon': Icons.medical_services_rounded},
      {'label': 'Reports Reviewed', 'count': workload.reportsCount, 'color': const Color(0xFF8B5CF6), 'icon': Icons.assignment_rounded},
      {'label': 'Follow-ups Managed', 'count': workload.followUpsCount, 'color': const Color(0xFFD97706), 'icon': Icons.event_repeat_rounded},
      {'label': 'Emergency Cases Handled', 'count': workload.emergencyCasesCount, 'color': Colors.redAccent, 'icon': Icons.emergency_rounded},
    ];

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
                      'Clinical Workload Distribution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Recorded clinical tasks and encounter breakdown',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$total Total Clinical Actions',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final count = item['count'] as int;
              final color = item['color'] as Color;
              final icon = item['icon'] as IconData;
              final label = item['label'] as String;
              final pct = total > 0 ? (count / total) : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        '$count (${(pct * 100).toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: pct,
                    backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                    color: color,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
