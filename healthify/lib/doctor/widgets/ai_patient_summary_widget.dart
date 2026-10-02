import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class AIPatientSummaryWidget extends StatelessWidget {
  final AIPatientSummaryModel aiSummary;
  final VoidCallback onViewFullSummary;

  const AIPatientSummaryWidget({
    super.key,
    required this.aiSummary,
    required this.onViewFullSummary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final patient = aiSummary.patient;

    return GlassCard(
      borderRadius: 24,
      hasTealGlow: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & AI Sparkle Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            HealthifyGlassTheme.primaryTeal,
                            HealthifyGlassTheme.primaryDarkTeal,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Patient Summary',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            'Instant clinical synthesis of health records',
                            style: TextStyle(
                              fontSize: 12,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.primaryTeal.withValues(
                    alpha: isDark ? 0.20 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'Clinical AI Assistant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected Patient Header Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.getGlassSurface(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: HealthifyGlassTheme.primaryTeal,
                  backgroundImage: NetworkImage(patient.avatarUrl),
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: Text(
                    patient.name[0],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient: ${patient.name} (${patient.age} yrs)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'MRN: ${patient.mrn} • Primary Concern: ${patient.primaryConcern}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Structured AI Highlights Bullet Points
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryBullet(
                  icon: Icons.history_rounded,
                  text: '${aiSummary.previousVisitsCount} previous hospital visits logged',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildSummaryBullet(
                  icon: Icons.biotech_rounded,
                  text: '${aiSummary.recentLabReportsCount} recent laboratory reports available',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildSummaryBullet(
                  icon: Icons.medication_liquid_rounded,
                  text: 'Current active medications: ${aiSummary.currentMedications.length} (${aiSummary.currentMedications.join(", ")})',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildSummaryBullet(
                  icon: Icons.event_repeat_rounded,
                  text: 'Last consultation: ${aiSummary.lastConsultationText}',
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildSummaryBullet(
                  icon: Icons.priority_high_rounded,
                  iconColor: Colors.amber.shade800,
                  text: 'Recent report requiring attention: ${aiSummary.recentReportAttention}',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Mandatory Clinical AI Disclaimer Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.amber.withValues(alpha: 0.12)
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.amber.shade900,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI-generated summary. Review medical records before making clinical decisions.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          GlassPrimaryButton(
            height: 44,
            onPressed: onViewFullSummary,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 16),
                SizedBox(width: 8),
                Text(
                  'View Full Summary',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBullet({
    required IconData icon,
    required String text,
    required bool isDark,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? HealthifyGlassTheme.primaryTeal,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
        ),
      ],
    );
  }
}
