import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class PrescriptionAnalyticsSection extends StatelessWidget {
  final PrescriptionActivityAnalyticsModel prescriptions;

  const PrescriptionAnalyticsSection({
    super.key,
    required this.prescriptions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        return GlassCard(
          padding: EdgeInsets.all(isCompact ? 14 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCompact) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prescription Activity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'E-prescriptions generated, active, and completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassSecondaryButton(
                      onPressed: () => Navigator.pushNamed(context, '/doctor-prescriptions'),
                      height: 32,
                      child: const Text('View Prescriptions', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prescription Activity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'E-prescriptions generated, active, and completed',
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
                      onPressed: () => Navigator.pushNamed(context, '/doctor-prescriptions'),
                      height: 34,
                      child: const Text('View Prescriptions', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _chip('Created', prescriptions.prescriptionsCreated, const Color(0xFF8B5CF6), isDark, isCompact)),
                  const SizedBox(width: 6),
                  Expanded(child: _chip('Active Rx', prescriptions.activePrescriptions, const Color(0xFF0D9488), isDark, isCompact)),
                  const SizedBox(width: 6),
                  Expanded(child: _chip('Completed', prescriptions.completedPrescriptions, const Color(0xFF10B981), isDark, isCompact)),
                  const SizedBox(width: 6),
                  Expanded(child: _chip('Drafts', prescriptions.draftPrescriptions, Colors.amber.shade800, isDark, isCompact)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label, int count, Color color, bool isDark, bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 2 : 8, vertical: isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: isCompact ? 14 : 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: isCompact ? 9.5 : 11, color: isDark ? Colors.white70 : const Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}
