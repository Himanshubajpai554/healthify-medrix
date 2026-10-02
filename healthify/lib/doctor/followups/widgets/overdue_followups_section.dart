import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/followup_models.dart';

class OverdueFollowUpsSection extends StatelessWidget {
  final List<DoctorFollowUpFullModel> overdueFollowUps;
  final ValueChanged<DoctorFollowUpFullModel> onOpenPatient;
  final ValueChanged<DoctorFollowUpFullModel> onReschedule;

  const OverdueFollowUpsSection({
    super.key,
    required this.overdueFollowUps,
    required this.onOpenPatient,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    if (overdueFollowUps.isEmpty) return const SizedBox();

    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Overdue Follow-ups',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${overdueFollowUps.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: overdueFollowUps.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final item = overdueFollowUps[index];
              return Row(
                children: [
                  // Days Overdue Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${item.daysOverdue} days overdue',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Patient & Original Date & Reason
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.patientName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• Orig: ${item.followUpDate.day}/${item.followUpDate.month}/${item.followUpDate.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${item.department} • ${item.reason}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GlassSecondaryButton(
                    onPressed: () => onOpenPatient(item),
                    height: 34,
                    child: const Text('Open Patient', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  GlassPrimaryButton(
                    onPressed: () => onReschedule(item),
                    height: 34,
                    child: const Text('Schedule New Date', style: TextStyle(fontSize: 11)),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
