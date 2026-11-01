import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class AvailabilityPanelModal {
  static void show({
    required BuildContext context,
    required DoctorAvailabilityConfig currentConfig,
    required ValueChanged<DoctorAvailabilityConfig> onSave,
  }) {
    final startController = TextEditingController(text: currentConfig.workingHoursStart);
    final endController = TextEditingController(text: currentConfig.workingHoursEnd);
    final breakStartController = TextEditingController(text: currentConfig.breakStart);
    final breakEndController = TextEditingController(text: currentConfig.breakEnd);
    int slotDuration = currentConfig.slotDurationMinutes;
    List<String> selectedDays = List.from(currentConfig.workingDays);

    final allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const GlassIconContainer(
                          icon: Icons.edit_calendar_rounded,
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
                                'Manage Practice Availability',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                              Text(
                                'Configure your working days, OPD hours & consultation slot lengths',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Working Days Selection
                    Text(
                      'Working Days',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: allDays.map((day) {
                        final isSelected = selectedDays.contains(day);
                        return FilterChip(
                          label: Text(day.substring(0, 3)),
                          selected: isSelected,
                          selectedColor: HealthifyGlassTheme.primaryTeal,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Working Hours & Breaks
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startController,
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: '09:00 AM',
                              labelText: 'Start Time',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: endController,
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: '05:00 PM',
                              labelText: 'End Time',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: breakStartController,
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: '01:00 PM',
                              labelText: 'Break Start',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: breakEndController,
                            decoration: GlassTextFieldTheme.getDecoration(
                              context: context,
                              hintText: '02:00 PM',
                              labelText: 'Break End',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Consultation Slot Duration Slider
                    Text(
                      'Consultation Slot Duration: $slotDuration minutes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Slider(
                      value: slotDuration.toDouble(),
                      min: 15,
                      max: 45,
                      divisions: 6,
                      activeColor: HealthifyGlassTheme.primaryTeal,
                      label: '$slotDuration mins',
                      onChanged: (val) => setState(() => slotDuration = val.round()),
                    ),
                    const SizedBox(height: 20),

                    // Save Button
                    GlassPrimaryButton(
                      onPressed: () {
                        final newConfig = currentConfig.copyWith(
                          workingHoursStart: startController.text,
                          workingHoursEnd: endController.text,
                          breakStart: breakStartController.text,
                          breakEnd: breakEndController.text,
                          slotDurationMinutes: slotDuration,
                          workingDays: selectedDays,
                        );
                        onSave(newConfig);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Availability saved. Synced live with Healthify Patient App.'),
                            backgroundColor: HealthifyGlassTheme.primaryTeal,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Center(child: Text('Save Availability')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
