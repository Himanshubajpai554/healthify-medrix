import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/patient_profile_models.dart';

class PatientConsultationsTab extends StatelessWidget {
  final List<PatientConsultationRecordModel> consultations;

  const PatientConsultationsTab({
    super.key,
    required this.consultations,
  });

  void _showConsultationDetails(BuildContext context, PatientConsultationRecordModel consult) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Consultation Details • ${consult.date}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Header Info
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.12),
                      child: const Icon(Icons.person_rounded, color: AppTheme.primaryTeal),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consult.doctorName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        Text(
                          '${consult.doctorSpecialty} • ${consult.department}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.borderLight),
                const SizedBox(height: 16),

                // Vitals Grid
                const Text('Vitals Captured', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: consult.vitals.entries.map((v) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${v.key}: ${v.value}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Chief Complaint & Diagnosis
                _buildDetailSection('Chief Complaint', consult.chiefComplaint),
                const SizedBox(height: 12),
                _buildDetailSection('Primary Diagnosis', consult.diagnosis, isBold: true),
                const SizedBox(height: 12),
                _buildDetailSection('Clinical Notes & Observations', consult.clinicalNotes),
                const SizedBox(height: 16),

                // Prescriptions
                const Text('Prescribed Medications', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: consult.prescribedMedications.map((med) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.primaryTeal),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(med, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                if (consult.followUpDate != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_repeat_rounded, color: AppTheme.accentColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Next Follow-Up Date: ${consult.followUpDate}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (consultations.isEmpty) {
      return const GlassCard(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('No previous consultation records found.', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: consultations.map((consult) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.medical_services_rounded, color: AppTheme.primaryTeal, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consult.diagnosis,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            Text(
                              '${consult.date} at ${consult.time} • ${consult.doctorName}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GlassSecondaryButton(
                      onPressed: () => _showConsultationDetails(context, consult),
                      child: const Row(
                        children: [
                          Icon(Icons.visibility_rounded, size: 14, color: AppTheme.primaryTeal),
                          SizedBox(width: 4),
                          Text('View Record', style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Chief Complaint: ${consult.chiefComplaint}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
