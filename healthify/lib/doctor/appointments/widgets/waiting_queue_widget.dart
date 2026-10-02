import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class WaitingQueueWidget extends StatelessWidget {
  final List<PatientQueueItemModel> queue;
  final ValueChanged<PatientQueueItemModel> onStartNextConsultation;
  final ValueChanged<PatientQueueItemModel> onViewPatient;

  const WaitingQueueWidget({
    super.key,
    required this.queue,
    required this.onStartNextConsultation,
    required this.onViewPatient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.queue_play_next_rounded,
                    size: 34,
                    iconSize: 18,
                    color: HealthifyGlassTheme.primaryTeal,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Live Waiting Queue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
              if (queue.isNotEmpty)
                GlassPrimaryButton(
                  height: 34,
                  onPressed: () => onStartNextConsultation(queue.first),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Start Next Consult',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (queue.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No patients currently waiting in queue.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: queue.length,
              separatorBuilder: (context, index) => const Divider(height: 12, thickness: 0.8),
              itemBuilder: (context, index) {
                final item = queue[index];
                return InkWell(
                  onTap: () => onViewPatient(item),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? Colors.amber.withValues(alpha: 0.2)
                                : isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.position,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: index == 0
                                  ? Colors.amber.shade900
                                  : HealthifyGlassTheme.getTextPrimary(isDark),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.patient.name,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
                              ),
                              Text(
                                '${item.appointmentTime} • Waiting: ${item.waitingTime}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Waiting',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
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
