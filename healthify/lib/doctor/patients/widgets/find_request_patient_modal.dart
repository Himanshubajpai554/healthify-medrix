import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class FindRequestPatientModal {
  static void show({
    required BuildContext context,
    required ValueChanged<String> onRequestSubmitted,
  }) {
    final nameController = TextEditingController();
    final mrnController = TextEditingController();
    final reasonController = TextEditingController();

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
                    icon: Icons.person_search_rounded,
                    size: 40,
                    iconSize: 22,
                    color: HealthifyGlassTheme.primaryTeal,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find / Request Patient Access',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Request clinical access to an existing hospital patient record',
                          style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: GlassTextFieldTheme.getDecoration(
                  context: context,
                  hintText: 'e.g. Rahul Sharma',
                  labelText: 'Patient Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: mrnController,
                decoration: GlassTextFieldTheme.getDecoration(
                  context: context,
                  hintText: 'e.g. MRN-2026-8812 or Phone',
                  labelText: 'Patient ID / MRN / Phone',
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: reasonController,
                decoration: GlassTextFieldTheme.getDecoration(
                  context: context,
                  hintText: 'e.g. OPD Consultation / Emergency Referral',
                  labelText: 'Reason for Access Request',
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
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
                        onRequestSubmitted(nameController.text.isEmpty ? 'New Patient' : nameController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Access request sent. Patient record linked to your portal.'),
                            backgroundColor: HealthifyGlassTheme.primaryTeal,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Submit Request'),
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
