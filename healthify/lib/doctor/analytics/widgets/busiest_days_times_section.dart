import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class BusiestDaysTimesSection extends StatelessWidget {
  final BusiestDaysTimesModel busiestDaysTimes;

  const BusiestDaysTimesSection({
    super.key,
    required this.busiestDaysTimes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment Distribution by Day & Time',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Recorded visit frequency patterns across the week',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  busiestDaysTimes.highestVolumeText,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Day Volume Bar Visualizer
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volume by Day of Week',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: busiestDaysTimes.dayVolume.entries.map((e) {
                        final isBusiest = e.key == busiestDaysTimes.busiestDay;
                        final height = (e.value / 15.0) * 100.0;

                        return Column(
                          children: [
                            Text(
                              '${e.value}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isBusiest ? const Color(0xFF0D9488) : (isDark ? Colors.white70 : const Color(0xFF475569)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 24,
                              height: height.clamp(12.0, 100.0),
                              decoration: BoxDecoration(
                                color: isBusiest
                                    ? const Color(0xFF0D9488)
                                    : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              e.key.substring(0, 3),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isBusiest ? FontWeight.bold : FontWeight.normal,
                                color: isBusiest ? const Color(0xFF0D9488) : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              const SizedBox(height: 120, child: VerticalDivider(width: 1)),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time of Day Breakdown',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    ...busiestDaysTimes.timeOfDayVolume.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                            Text('${e.value} visits', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
