import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class ScheduleFollowupModal {
  static void show({
    required BuildContext context,
    required PatientModel patient,
    required VoidCallback onFollowupScheduled,
  }) {
    String selectedDateStr = 'Oct 08, 2026';
    final reasonController = TextEditingController(
      text: 'Review lab test results & blood pressure',
    );

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const GlassIconContainer(
                        icon: Icons.event_repeat_rounded,
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
                              'Schedule Patient Follow-up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(
                                  isDark,
                                ),
                              ),
                            ),
                            Text(
                              'Patient: ${patient.name} (${patient.mrn})',
                              style: TextStyle(
                                fontSize: 12,
                                color: HealthifyGlassTheme.getTextSecondary(
                                  isDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'Select Follow-up Timeframe',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('In 1 Week (Oct 08)'),
                        selected: selectedDateStr == 'Oct 08, 2026',
                        selectedColor: HealthifyGlassTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: selectedDateStr == 'Oct 15, 2026'
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => selectedDateStr = 'Oct 08, 2026');
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('In 2 Weeks (Oct 15)'),
                        selected: selectedDateStr == 'Oct 15, 2026',
                        selectedColor: HealthifyGlassTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: selectedDateStr == 'Oct 15, 2026'
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => selectedDateStr = 'Oct 15, 2026');
                          }
                        },
                      ),
                      ChoiceChip(
                        label: const Text('In 1 Month (Nov 01)'),
                        selected: selectedDateStr == 'Nov 01, 2026',
                        selectedColor: HealthifyGlassTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: selectedDateStr == 'Oct 15, 2026'
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => selectedDateStr = 'Nov 01, 2026');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: reasonController,
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'e.g. Review lab test results & blood pressure',
                      labelText: 'Follow-up Purpose / Clinical Reason',
                      prefixIcon: const Icon(
                        Icons.assignment_turned_in_rounded,
                      ),
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
                            onFollowupScheduled();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Follow-up for ${patient.name} scheduled for $selectedDateStr.',
                                ),
                                backgroundColor:
                                    HealthifyGlassTheme.primaryTeal,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text('Schedule Follow-up'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
