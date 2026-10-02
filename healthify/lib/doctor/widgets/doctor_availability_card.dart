import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class DoctorAvailabilityCard extends StatelessWidget {
  final DoctorAvailabilityConfig config;
  final ValueChanged<DoctorAvailability> onStatusChanged;
  final VoidCallback onConfigureHours;

  const DoctorAvailabilityCard({
    super.key,
    required this.config,
    required this.onStatusChanged,
    required this.onConfigureHours,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.schedule_rounded,
                    size: 38,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practice Schedule & Status',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        'Live patient booking status & shift configurations',
                        style: TextStyle(
                          fontSize: 12,
                          color: HealthifyGlassTheme.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GlassSecondaryButton(
                height: 36,
                onPressed: onConfigureHours,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_calendar_rounded, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Configure Hours',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Working Hours & Break Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HealthifyGlassTheme.getGlassSurface(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeInfo(
                      label: "Today's OPD Hours",
                      value: '${config.workingHoursStart} - ${config.workingHoursEnd}',
                      icon: Icons.access_time_filled_rounded,
                      isDark: isDark,
                    ),
                    _buildTimeInfo(
                      label: 'Break Interval',
                      value: '${config.breakStart} - ${config.breakEnd}',
                      icon: Icons.free_breakfast_rounded,
                      isDark: isDark,
                    ),
                    _buildTimeInfo(
                      label: 'Slot Duration',
                      value: '${config.slotDurationMinutes} mins',
                      icon: Icons.timer_rounded,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Patient App Visibility Indicator
                Row(
                  children: [
                    const Icon(
                      Icons.visibility_rounded,
                      size: 16,
                      color: HealthifyGlassTheme.primaryTeal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Patient App Live Preview:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: HealthifyGlassTheme.primaryTeal.withValues(
                            alpha: isDark ? 0.18 : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Doctor Status: Available • Next open slot: ${config.nextAvailableSlot}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.primaryTeal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: HealthifyGlassTheme.getTextPrimary(isDark),
          ),
        ),
      ],
    );
  }
}
