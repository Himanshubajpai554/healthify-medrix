import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/consultation_models.dart';

class ConsultationSummaryModal {
  static void show({
    required BuildContext context,
    required ConsultationFullModel consultation,
    required VoidCallback onEdit,
    required VoidCallback onConfirmComplete,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.fact_check_rounded, color: AppTheme.primaryTeal, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Consultation Pre-Completion Review',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          Text(
                            'Verify all clinical entries for ${consultation.patient.name} before signing EHR record',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.borderLight),
                const SizedBox(height: 16),

                // 1. Reason for Visit
                _buildSummarySection('1. REASON FOR TODAY\'S VISIT', consultation.reasonForVisit),
                const SizedBox(height: 12),

                // 2. Patient-Reported Information
                _buildSummarySection('2. PATIENT-REPORTED SYMPTOMS', '${consultation.patientReported.primaryConcern} (${consultation.patientReported.duration}) - ${consultation.patientReported.reportedSymptoms}'),
                const SizedBox(height: 12),

                // 3. Clinical Observations & Vitals
                _buildSummarySection(
                  '3. CLINICAL OBSERVATIONS & VITALS',
                  'BP: ${consultation.vitals.bpText} | Pulse: ${consultation.vitals.heartRate} bpm | SpO2: ${consultation.vitals.oxygenSaturation}% | Temp: ${consultation.vitals.temperature} °F | Weight: ${consultation.vitals.weight} kg',
                ),
                const SizedBox(height: 12),

                // 4. Clinical Notes & Visibility
                _buildSummarySection(
                  '4. DOCTOR CLINICAL NOTES',
                  '${consultation.clinicalNotes}\n[Visibility: ${consultation.noteVisibility == NoteVisibility.internalPrivate ? "Internal Private" : "Patient Visible"}]',
                ),
                const SizedBox(height: 12),

                // 5. Prescriptions
                const Text('5. PRESCRIBED MEDICATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: consultation.prescriptions.map((p) {
                    return Text('• ${p.drugName} ${p.dosage} - ${p.frequency} for ${p.duration}', style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary));
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // 6. Follow-Up
                _buildSummarySection('6. FOLLOW-UP SCHEDULE', 'Required: ${consultation.followUp.isRequired ? "Yes" : "No"} | Date: ${consultation.followUp.dueDate} | Reason: ${consultation.followUp.reason}'),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: GlassSecondaryButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onEdit();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note_rounded, size: 16, color: AppTheme.primaryTeal),
                            SizedBox(width: 6),
                            Text('Edit Entries'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GlassPrimaryButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showConfirmationDialog(context, onConfirmComplete);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 18),
                            SizedBox(width: 6),
                            Text('Sign & Complete Consultation'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSummarySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4)),
      ],
    );
  }

  static void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.help_outline_rounded, color: AppTheme.primaryTeal, size: 24),
              SizedBox(width: 10),
              Text('Complete this consultation?'),
            ],
          ),
          content: const Text(
            'After completion, the consultation record, notes, prescriptions, and attached reports will be permanently committed to the patient\'s EHR file.\n\nDo you wish to complete and sign now?',
            style: TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('Confirm & Sign EHR'),
            ),
          ],
        );
      },
    );
  }
}
