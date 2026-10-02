import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_analytics_models.dart';

class AnalyticsHeader extends StatelessWidget {
  final AnalyticsDateRange selectedDateRange;
  final ValueChanged<AnalyticsDateRange> onDateRangeChanged;
  final VoidCallback onExportPressed;
  final VoidCallback onRefreshPressed;

  const AnalyticsHeader({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeChanged,
    required this.onExportPressed,
    required this.onRefreshPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 768;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  size: 26,
                  color: Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Analytics',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Understand your clinical workload and activity.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompact) ...[
                // Date Range Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      DropdownButton<AnalyticsDateRange>(
                        value: selectedDateRange,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                        items: AnalyticsDateRange.values.map((r) {
                          return DropdownMenuItem(value: r, child: Text(r.label));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) onDateRangeChanged(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GlassSecondaryButton(
                  onPressed: onRefreshPressed,
                  height: 42,
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Refresh'),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GlassPrimaryButton(
                  onPressed: onExportPressed,
                  height: 42,
                  child: const Row(
                    children: [
                      Icon(Icons.download_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Export'),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (isCompact) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButton<AnalyticsDateRange>(
                      value: selectedDateRange,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      items: AnalyticsDateRange.values.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r.label));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) onDateRangeChanged(val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GlassPrimaryButton(
                  onPressed: onExportPressed,
                  height: 42,
                  child: const Row(
                    children: [
                      Icon(Icons.download_rounded, size: 16),
                      SizedBox(width: 4),
                      Text('Export'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Selected Range Badge
          Text(
            'Selected period: ${selectedDateRange.dateRangeText}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
            ),
          ),
        ],
      ),
    );
  }
}
