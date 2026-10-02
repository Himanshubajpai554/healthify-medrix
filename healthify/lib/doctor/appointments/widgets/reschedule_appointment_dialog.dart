import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class RescheduleAppointmentDialog {
  static void show({
    required BuildContext context,
    required DoctorAppointmentModel appointment,
    required ValueChanged<String> onRescheduled,
  }) {
    String selectedSlot = '04:00 PM';
    final reasonController = TextEditingController();

    final availableSlots = [
      '04:00 PM',
      '04:30 PM',
      '05:00 PM',
      '05:30 PM',
      '06:00 PM',
    ];

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
                              'Reschedule Appointment',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                            Text(
                              'Patient: ${appointment.patient.name} (Originally ${appointment.appointmentTime})',
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

                  Text(
                    'Select Available Slot',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableSlots.map((slot) {
                      final isSelected = selectedSlot == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        selectedColor: HealthifyGlassTheme.primaryTeal,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark),
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => selectedSlot = slot);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: reasonController,
                    decoration: GlassTextFieldTheme.getDecoration(
                      context: context,
                      hintText: 'e.g. Doctor emergency surgery / Patient request...',
                      labelText: 'Rescheduling Reason (Optional)',
                      prefixIcon: const Icon(Icons.note_alt_rounded),
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
                            onRescheduled(selectedSlot);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Appointment rescheduled successfully to $selectedSlot.'),
                                backgroundColor: HealthifyGlassTheme.primaryTeal,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text('Confirm Reschedule'),
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
