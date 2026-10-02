import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';
import '../../models/patient_profile_models.dart';
import 'create_prescription_modal.dart';

class PatientPrescriptionsTab extends StatelessWidget {
  final PatientModel patient;
  final List<PatientPrescriptionModel> prescriptions;
  final VoidCallback onPrescriptionCreated;

  const PatientPrescriptionsTab({
    super.key,
    required this.patient,
    required this.prescriptions,
    required this.onPrescriptionCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Bar with Create Prescription CTA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Prescriptions & Medication Logs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                Text(
                  'Active oral, sublingual, and injectable regimens',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            GlassPrimaryButton(
              onPressed: () {
                CreatePrescriptionModal.show(
                  context: context,
                  patient: patient,
                  onPrescriptionCreated: onPrescriptionCreated,
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, size: 16),
                  SizedBox(width: 4),
                  Text('Create New Prescription', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        if (prescriptions.isEmpty)
          const GlassCard(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No active or historical prescriptions found.', style: TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else
          Column(
            children: prescriptions.map((rx) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prescription Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (rx.isActive ? const Color(0xFF10B981) : AppTheme.textMuted).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.medication_rounded,
                                  color: rx.isActive ? const Color(0xFF10B981) : AppTheme.textMuted,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rx #${rx.id} • ${rx.diagnosis}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                  ),
                                  Text(
                                    'Issued ${rx.prescriptionDate} by ${rx.doctorName} (${rx.department})',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: rx.isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              rx.isActive ? 'Active (Valid ${rx.validityUntil})' : 'Expired / Completed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: rx.isActive ? const Color(0xFF15803D) : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(height: 1, color: AppTheme.borderLight),
                      const SizedBox(height: 14),

                      // Medications Table / Cards
                      const Text(
                        'PRESCRIBED DRUG DOSAGE & SCHEDULE',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 10),

                      Column(
                        children: rx.medications.map((med) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.medication_rounded, size: 18, color: AppTheme.primaryTeal),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${med.drugName} ${med.dosage}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Frequency: ${med.frequency} • Timing: ${med.timing} • Duration: ${med.duration}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                      ),
                                      if (med.specialInstructions != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Note: ${med.specialInstructions}',
                                          style: const TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        'General Instructions: ${rx.generalInstructions}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
