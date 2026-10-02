import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class PatientSnapshotCard extends StatelessWidget {
  final PatientModel patient;

  const PatientSnapshotCard({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_pin_rounded, color: AppTheme.primaryTeal, size: 18),
              SizedBox(width: 8),
              Text(
                'Recorded Patient Snapshot',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Spacer(),
              Text(
                'EHR Verified Data Only',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final colCount = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 600 ? 2 : 1);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: colCount,
                childAspectRatio: constraints.maxWidth >= 900 ? 3.2 : 2.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildSnapshotTile(
                    'RECORDED ALLERGIES',
                    patient.allergies.join(', '),
                    Icons.warning_amber_rounded,
                    const Color(0xFFEF4444),
                  ),
                  _buildSnapshotTile(
                    'KNOWN CONDITIONS',
                    patient.chronicConditions.join(' • '),
                    Icons.medical_services_rounded,
                    const Color(0xFF0284C7),
                  ),
                  _buildSnapshotTile(
                    'ACTIVE MEDICATIONS',
                    '${patient.currentMedications.length} active prescriptions',
                    Icons.medication_rounded,
                    const Color(0xFF10B981),
                  ),
                  _buildSnapshotTile(
                    'LAST VISIT & FOLLOW-UP',
                    'Last: ${patient.lastVisitDate} | ${patient.followUpStatus}',
                    Icons.event_repeat_rounded,
                    const Color(0xFFF59E0B),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
