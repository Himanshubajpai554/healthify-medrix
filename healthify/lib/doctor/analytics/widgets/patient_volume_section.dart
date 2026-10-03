import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class PatientVolumeSection extends StatelessWidget {
  final PatientVolumeModel patientVolume;

  const PatientVolumeSection({
    super.key,
    required this.patientVolume,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final total = patientVolume.totalVisits;

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
                      'Patient Visits & Volume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Activity count breakdown by patient visit type',
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
                  'Total: $total Visits',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D9488),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;

              if (isCompact) {
                return Column(
                  children: [
                    _buildVolumeTile(
                      label: 'New Patients',
                      count: patientVolume.newPatients,
                      total: total,
                      color: const Color(0xFF3B82F6),
                      icon: Icons.person_add_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildVolumeTile(
                      label: 'Returning Patients',
                      count: patientVolume.returningPatients,
                      total: total,
                      color: const Color(0xFF0D9488),
                      icon: Icons.people_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildVolumeTile(
                      label: 'Follow-up Visits',
                      count: patientVolume.followUpVisits,
                      total: total,
                      color: const Color(0xFFD97706),
                      icon: Icons.event_repeat_rounded,
                      isDark: isDark,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildVolumeTile(
                      label: 'New Patients',
                      count: patientVolume.newPatients,
                      total: total,
                      color: const Color(0xFF3B82F6),
                      icon: Icons.person_add_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVolumeTile(
                      label: 'Returning Patients',
                      count: patientVolume.returningPatients,
                      total: total,
                      color: const Color(0xFF0D9488),
                      icon: Icons.people_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVolumeTile(
                      label: 'Follow-up Visits',
                      count: patientVolume.followUpVisits,
                      total: total,
                      color: const Color(0xFFD97706),
                      icon: Icons.event_repeat_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeTile({
    required String label,
    required int count,
    required int total,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$pct% share',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
