import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class CreatePrescriptionModal {
  static void show({
    required BuildContext context,
    required PatientModel patient,
    required VoidCallback onPrescriptionCreated,
  }) {
    final medController = TextEditingController(text: 'Atorvastatin 20mg (OD)');
    final dosageController = TextEditingController(text: '1 tablet once daily at night');
    final durationController = TextEditingController(text: '30 Days');

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.medication_rounded,
                    size: 40,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Write E-Prescription',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Patient: ${patient.name} (${patient.mrn})',
                          style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              TextField(
                controller: medController,
                decoration: GlassTextFieldTheme.getDecoration(
                  context: context,
                  hintText: 'e.g. Atorvastatin 20mg / Metoprolol 50mg',
                  labelText: 'Medication Name & Strength',
                  prefixIcon: const Icon(Icons.medication_rounded),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dosageController,
                      decoration: GlassTextFieldTheme.getDecoration(
                        context: context,
                        hintText: '1 tablet BD after meals',
                        labelText: 'Dosage & Frequency',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      decoration: GlassTextFieldTheme.getDecoration(
                        context: context,
                        hintText: '30 Days',
                        labelText: 'Duration',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: GlassSecondaryButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GlassPrimaryButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onPrescriptionCreated();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('E-Prescription generated & sent to Pharmacy for ${patient.name}.'),
                            backgroundColor: HealthifyGlassTheme.primaryTeal,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Sign & Send E-Prescription'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
