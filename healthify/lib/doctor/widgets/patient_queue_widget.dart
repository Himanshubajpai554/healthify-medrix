import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class PatientQueueWidget extends StatelessWidget {
  final List<PatientQueueItemModel> queue;
  final ValueChanged<PatientQueueItemModel>? onCallNext;
  final ValueChanged<PatientQueueItemModel>? onViewPatient;

  const PatientQueueWidget({
    super.key,
    required this.queue,
    this.onCallNext,
    this.onViewPatient,
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
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const GlassIconContainer(
                      icon: Icons.queue_play_next_rounded,
                      size: 36,
                      iconSize: 18,
                      color: HealthifyGlassTheme.primaryTeal,
                      borderRadius: 10,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OPD Patient Queue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            '${queue.length} Patients waiting in OPD waiting room',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.primaryTeal.withValues(
                    alpha: isDark ? 0.20 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.fiber_manual_record_rounded,
                      size: 10,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Live OPD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Queue Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: queue.length,
            separatorBuilder: (context, index) => const Divider(height: 16, thickness: 0.8),
            itemBuilder: (context, index) {
              final item = queue[index];
              return InkWell(
                onTap: () => onViewPatient?.call(item),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      // Position Token Number
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Colors.amber.withValues(alpha: 0.2)
                              : isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: index == 0
                              ? Border.all(color: Colors.amber.withValues(alpha: 0.5))
                              : null,
                        ),
                        child: Text(
                          item.position,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: index == 0
                                ? Colors.amber.shade800
                                : HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Patient Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.patient.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.appointmentTime} • Waited: ${item.waitingTime}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status & Call Button
                      if (index == 0)
                        ElevatedButton.icon(
                          onPressed: () => onCallNext?.call(item),
                          icon: const Icon(Icons.record_voice_over_rounded, size: 14),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HealthifyGlassTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            visualDensity: VisualDensity.compact,
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Waiting',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: HealthifyGlassTheme.primaryTeal,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
