import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class ConsultationActivitySection extends StatelessWidget {
  final ConsultationActivityModel consultationActivity;

  const ConsultationActivitySection({
    super.key,
    required this.consultationActivity,
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
                    'Consultation Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Recorded OPD and emergency consultation output',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              GlassSecondaryButton(
                onPressed: () => Navigator.pushNamed(context, '/doctor-consultation'),
                height: 34,
                child: const Text('Open Consultation', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossCount = width > 700 ? 4 : 2;

              return GridView.count(
                crossAxisCount: crossCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: width > 700 ? 1.8 : 1.6,
                children: [
                  _metricBox(
                    label: 'Consultations Completed',
                    value: '${consultationActivity.consultationsCompleted}',
                    subtitle: 'Finalized clinical encounters',
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                  _metricBox(
                    label: 'Draft Consultations',
                    value: '${consultationActivity.draftConsultations}',
                    subtitle: 'Pending final sign-off',
                    icon: Icons.edit_note_rounded,
                    color: Colors.amber.shade800,
                    isDark: isDark,
                  ),
                  _metricBox(
                    label: 'Average Duration',
                    value: 'N/A',
                    subtitle: consultationActivity.avgDurationText, // "Consultation duration data unavailable."
                    icon: Icons.timer_outlined,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    isDark: isDark,
                    isUnavailable: true,
                  ),
                  _metricBox(
                    label: 'Follow-ups Created',
                    value: '${consultationActivity.followUpsCreated}',
                    subtitle: 'Triggered from consultations',
                    icon: Icons.event_repeat_rounded,
                    color: const Color(0xFF0D9488),
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metricBox({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool isUnavailable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isUnavailable ? 16 : 22,
              fontWeight: FontWeight.bold,
              color: isUnavailable
                  ? (isDark ? Colors.white54 : const Color(0xFF64748B))
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
