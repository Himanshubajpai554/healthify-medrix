import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class AppointmentAnalyticsSection extends StatelessWidget {
  final AppointmentAnalyticsModel appointments;

  const AppointmentAnalyticsSection({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return Column(
            children: [
              _buildTrendChart(isDark),
              const SizedBox(height: 16),
              _buildStatusBreakdown(isDark),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildTrendChart(isDark)),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildStatusBreakdown(isDark)),
          ],
        );
      },
    );
  }

  Widget _buildTrendChart(bool isDark) {
    final maxVal = 10;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isNarrow = headerConstraints.maxWidth < 600;

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointments Over Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recorded daily appointment volume and status breakdown',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _legendDot('Completed', const Color(0xFF10B981), isDark),
                        _legendDot('Upcoming', const Color(0xFF3B82F6), isDark),
                        _legendDot('Cancelled', const Color(0xFFEF4444), isDark),
                        _legendDot('No Show', Colors.amber.shade800, isDark),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointments Over Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Recorded daily appointment volume and status breakdown',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _legendDot('Completed', const Color(0xFF10B981), isDark),
                      _legendDot('Upcoming', const Color(0xFF3B82F6), isDark),
                      _legendDot('Cancelled', const Color(0xFFEF4444), isDark),
                      _legendDot('No Show', Colors.amber.shade800, isDark),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Custom Bar Chart Representation
          SizedBox(
            height: 195,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(appointments.trendDays.length, (index) {
                final day = appointments.trendDays[index];
                final completed = appointments.completedCounts[index];
                final upcoming = appointments.upcomingCounts[index];
                final cancelled = appointments.cancelledCounts[index];
                final noShow = appointments.noShowCounts[index];
                final total = completed + upcoming + cancelled + noShow;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Tooltip(
                      message: '$day: Total $total (Completed: $completed, Upcoming: $upcoming, Cancelled: $cancelled, No Show: $noShow)',
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (upcoming > 0)
                            _barSegment(height: (upcoming / maxVal) * 125, color: const Color(0xFF3B82F6)),
                          if (cancelled > 0)
                            _barSegment(height: (cancelled / maxVal) * 125, color: const Color(0xFFEF4444)),
                          if (noShow > 0)
                            _barSegment(height: (noShow / maxVal) * 125, color: Colors.amber.shade800),
                          if (completed > 0)
                            _barSegment(height: (completed / maxVal) * 125, color: const Color(0xFF10B981)),
                          if (total == 0)
                            Container(width: 20, height: 4, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barSegment({required double height, required Color color}) {
    return Container(
      width: 20,
      height: height.clamp(4.0, 125.0),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _legendDot(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white70 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(bool isDark) {
    final total = appointments.totalAppointments;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Text(
            'Distribution of recorded visit outcomes',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),

          _statusProgressRow('Completed', appointments.statusCompleted, total, const Color(0xFF10B981), isDark),
          const SizedBox(height: 12),
          _statusProgressRow('Upcoming', appointments.statusUpcoming, total, const Color(0xFF3B82F6), isDark),
          const SizedBox(height: 12),
          _statusProgressRow('Cancelled', appointments.statusCancelled, total, const Color(0xFFEF4444), isDark),
          const SizedBox(height: 12),
          _statusProgressRow('No Show', appointments.statusNoShow, total, Colors.amber.shade800, isDark),
        ],
      ),
    );
  }

  Widget _statusProgressRow(String label, int count, int total, Color color, bool isDark) {
    final pct = total > 0 ? (count / total) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count (${(pct * 100).toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
