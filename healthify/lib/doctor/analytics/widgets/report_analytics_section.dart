import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class ReportAnalyticsSection extends StatelessWidget {
  final ReportReviewAnalyticsModel reports;

  const ReportAnalyticsSection({
    super.key,
    required this.reports,
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
                      'Report Review Activity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diagnostic reports received, reviewed, and pending',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassSecondaryButton(
                      onPressed: () => Navigator.pushNamed(context, '/doctor-reports'),
                      height: 32,
                      child: const Text('View Reports', style: TextStyle(fontSize: 11)),
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
                            'Report Review Activity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Diagnostic reports received, reviewed, and pending',
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
                      onPressed: () => Navigator.pushNamed(context, '/doctor-reports'),
                      height: 34,
                      child: const Text('View Reports', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _chip('Received', reports.reportsReceived, const Color(0xFF8B5CF6), isDark, isCompact)),
                  const SizedBox(width: 8),
                  Expanded(child: _chip('Reviewed', reports.reportsReviewed, const Color(0xFF10B981), isDark, isCompact)),
                  const SizedBox(width: 8),
                  Expanded(child: _chip('Pending', reports.pendingReview, Colors.amber.shade800, isDark, isCompact)),
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
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 10, vertical: isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: isCompact ? 15 : 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: isCompact ? 10 : 11, color: isDark ? Colors.white70 : const Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}
