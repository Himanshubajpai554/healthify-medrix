import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class FollowUpHeader extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onSchedulePressed;
  final VoidCallback onRefreshPressed;
  final bool isCalendarView;
  final ValueChanged<bool> onToggleCalendarView;

  const FollowUpHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSchedulePressed,
    required this.onRefreshPressed,
    required this.isCalendarView,
    required this.onToggleCalendarView,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 850;

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
                  Icons.event_repeat_rounded,
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
                      'Patient Follow-ups',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track and manage your patients\' upcoming care and follow-up visits.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompact) ...[
                // View Mode Toggle
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => onToggleCalendarView(false),
                        tooltip: 'Table List View',
                        icon: Icon(
                          Icons.table_rows_rounded,
                          size: 18,
                          color: !isCalendarView
                              ? const Color(0xFF0D9488)
                              : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                        ),
                      ),
                      IconButton(
                        onPressed: () => onToggleCalendarView(true),
                        tooltip: 'Calendar View',
                        icon: Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: isCalendarView
                              ? const Color(0xFF0D9488)
                              : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                        ),
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
                  onPressed: onSchedulePressed,
                  height: 42,
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('Schedule Follow-up'),
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
                  child: GlassSecondaryButton(
                    onPressed: onRefreshPressed,
                    height: 38,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassPrimaryButton(
                    onPressed: onSchedulePressed,
                    height: 38,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Schedule'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Search Input Bar
          TextFormField(
            initialValue: searchQuery,
            onChanged: onSearchChanged,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Search patient, patient ID, follow-up...',
              hintStyle: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
