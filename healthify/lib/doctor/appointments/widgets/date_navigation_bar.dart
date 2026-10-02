import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class DateNavigationBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onSelectToday;
  final VoidCallback onSelectTomorrow;
  final VoidCallback onSelectThisWeek;
  final VoidCallback onSelectCustomDate;

  const DateNavigationBar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onSelectToday,
    required this.onSelectTomorrow,
    required this.onSelectThisWeek,
    required this.onSelectCustomDate,
  });

  String _formatDateTitle(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, $monthName ${date.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final today = DateTime.now();

    // Generate current week days (Mon-Sun around selectedDate)
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Row 1: Left/Right Arrows + Date Title + Today Button + Quick Filters
          Row(
            children: [
              // Previous Day Arrow
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                onPressed: () => onDateSelected(selectedDate.subtract(const Duration(days: 1))),
                tooltip: 'Previous Day',
              ),

              // Date Title
              Text(
                _formatDateTitle(selectedDate),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),

              // Next Day Arrow
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                onPressed: () => onDateSelected(selectedDate.add(const Duration(days: 1))),
                tooltip: 'Next Day',
              ),
              const SizedBox(width: 8),

              // "Today" Button
              GlassSecondaryButton(
                height: 34,
                onPressed: onSelectToday,
                child: const Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),

              // Quick Presets (Today, Tomorrow, This Week, Custom Date)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Today', _isSameDay(selectedDate, today), onSelectToday, isDark),
                    const SizedBox(width: 6),
                    _buildFilterChip('Tomorrow', _isSameDay(selectedDate, today.add(const Duration(days: 1))), onSelectTomorrow, isDark),
                    const SizedBox(width: 6),
                    _buildFilterChip('This Week', false, onSelectThisWeek, isDark),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onSelectCustomDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 14, color: HealthifyGlassTheme.primaryTeal),
                            SizedBox(width: 4),
                            Text('Custom Date', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Row 2: Compact Weekly Date Selector (Mon 28, Tue 29, Wed 30, Thu 01, Fri 02, Sat 03, Sun 04)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = weekDays[index];
              final isSelected = _isSameDay(date, selectedDate);
              final isToday = _isSameDay(date, today);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => onDateSelected(date),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HealthifyGlassTheme.primaryTeal
                            : (isToday
                                ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.20 : 0.10)
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? null
                            : (isToday
                                ? Border.all(color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4))
                                : null),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dayLabels[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : HealthifyGlassTheme.getTextSecondary(isDark),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isToday
                                      ? HealthifyGlassTheme.primaryTeal
                                      : HealthifyGlassTheme.getTextPrimary(isDark)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GlassSelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      activeColor: HealthifyGlassTheme.primaryTeal,
    );
  }
}
