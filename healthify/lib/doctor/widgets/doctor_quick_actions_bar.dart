import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';

class DoctorQuickActionsBar extends StatelessWidget {
  final VoidCallback onStartConsultation;
  final VoidCallback onAddPatientNote;
  final VoidCallback onWritePrescription;
  final VoidCallback onReviewReports;
  final VoidCallback onViewSchedule;

  const DoctorQuickActionsBar({
    super.key,
    required this.onStartConsultation,
    required this.onAddPatientNote,
    required this.onWritePrescription,
    required this.onReviewReports,
    required this.onViewSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.flash_on_rounded,
                size: 18,
                color: HealthifyGlassTheme.primaryTeal,
              ),
              const SizedBox(width: 6),
              Text(
                'Quick Actions:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          _buildActionButton(
            label: '+ Start Consultation',
            icon: Icons.video_call_rounded,
            isPrimary: true,
            onTap: onStartConsultation,
            isDark: isDark,
          ),
          _buildActionButton(
            label: '+ Add Patient Note',
            icon: Icons.note_add_rounded,
            onTap: onAddPatientNote,
            isDark: isDark,
          ),
          _buildActionButton(
            label: '+ Write Prescription',
            icon: Icons.medication_rounded,
            onTap: onWritePrescription,
            isDark: isDark,
          ),
          _buildActionButton(
            label: '+ Review Reports',
            icon: Icons.rate_review_rounded,
            onTap: onReviewReports,
            isDark: isDark,
          ),
          _buildActionButton(
            label: '+ View Schedule',
            icon: Icons.calendar_month_rounded,
            onTap: onViewSchedule,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: HealthifyGlassTheme.primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: HealthifyGlassTheme.primaryTeal),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: HealthifyGlassTheme.getTextPrimary(isDark),
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        visualDensity: VisualDensity.compact,
        side: BorderSide(
          color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.35),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
