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

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  String _formatDateTitle(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, $monthName ${date.day}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _primaryColor(bool isDark) {
    return isDark ? _primaryDark : _primary;
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark);
  }

  Color _secondaryText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.55)
        : HealthifyGlassTheme.getTextSecondary(isDark);
  }

  Color _subtleSurface(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.55);
  }

  Color _borderColor(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.085)
        : Colors.white.withValues(alpha: 0.80);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final today = DateTime.now();
    final primary = _primaryColor(isDark);

    // Monday → Sunday around the selected date.
    final startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 640;

          return Column(
            children: [
              // ============================================================
              // HEADER / DATE NAVIGATION
              // ============================================================
              if (isCompact)
                Row(
                  children: [
                    _buildNavigationButton(
                      context,
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'Previous Day',
                      onPressed: () {
                        onDateSelected(
                          selectedDate.subtract(const Duration(days: 1)),
                        );
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        _formatDateTitle(selectedDate),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _primaryText(isDark),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    _buildNavigationButton(
                      context,
                      icon: Icons.chevron_right_rounded,
                      tooltip: 'Next Day',
                      onPressed: () {
                        onDateSelected(
                          selectedDate.add(const Duration(days: 1)),
                        );
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(width: 6),

                    GlassSecondaryButton(
                      height: 34,
                      onPressed: onSelectToday,
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    _buildNavigationButton(
                      context,
                      icon: Icons.chevron_left_rounded,
                      tooltip: 'Previous Day',
                      onPressed: () {
                        onDateSelected(
                          selectedDate.subtract(const Duration(days: 1)),
                        );
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      _formatDateTitle(selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _primaryText(isDark),
                        letterSpacing: -0.15,
                      ),
                    ),

                    const SizedBox(width: 4),

                    _buildNavigationButton(
                      context,
                      icon: Icons.chevron_right_rounded,
                      tooltip: 'Next Day',
                      onPressed: () {
                        onDateSelected(
                          selectedDate.add(const Duration(days: 1)),
                        );
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(width: 10),

                    GlassSecondaryButton(
                      height: 34,
                      onPressed: onSelectToday,
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'Today',
                              _isSameDay(selectedDate, today),
                              onSelectToday,
                              isDark,
                            ),
                            const SizedBox(width: 6),
                            _buildFilterChip(
                              'Tomorrow',
                              _isSameDay(
                                selectedDate,
                                today.add(const Duration(days: 1)),
                              ),
                              onSelectTomorrow,
                              isDark,
                            ),
                            const SizedBox(width: 6),
                            _buildFilterChip(
                              'This Week',
                              false,
                              onSelectThisWeek,
                              isDark,
                            ),
                            const SizedBox(width: 6),
                            _buildCustomDateButton(
                              isDark: isDark,
                              onTap: onSelectCustomDate,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              // ============================================================
              // MOBILE FILTERS
              // ============================================================
              if (isCompact) ...[
                const SizedBox(height: 10),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'Today',
                        _isSameDay(selectedDate, today),
                        onSelectToday,
                        isDark,
                      ),

                      const SizedBox(width: 6),

                      _buildFilterChip(
                        'Tomorrow',
                        _isSameDay(
                          selectedDate,
                          today.add(const Duration(days: 1)),
                        ),
                        onSelectTomorrow,
                        isDark,
                      ),

                      const SizedBox(width: 6),

                      _buildFilterChip(
                        'This Week',
                        false,
                        onSelectThisWeek,
                        isDark,
                      ),

                      const SizedBox(width: 6),

                      _buildCustomDateButton(
                        isDark: isDark,
                        onTap: onSelectCustomDate,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // ============================================================
              // DIVIDER
              // ============================================================
              Container(height: 1, color: _borderColor(isDark)),

              const SizedBox(height: 12),

              // ============================================================
              // WEEK SELECTOR
              // ============================================================
              Row(
                children: List.generate(7, (index) {
                  final date = weekDays[index];

                  final isSelected = _isSameDay(date, selectedDate);

                  final isToday = _isSameDay(date, today);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _buildDayItem(
                        date: date,
                        dayLabel: dayLabels[index],
                        isSelected: isSelected,
                        isToday: isToday,
                        isDark: isDark,
                        onTap: () => onDateSelected(date),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================================
  // NAVIGATION BUTTON
  // ==========================================================================

  Widget _buildNavigationButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _subtleSurface(isDark),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _borderColor(isDark), width: 0.8),
            ),
            child: Icon(icon, size: 20, color: _secondaryText(isDark)),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // FILTER CHIP
  // ==========================================================================

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GlassSelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      activeColor: _primaryColor(isDark),
    );
  }

  // ==========================================================================
  // CUSTOM DATE BUTTON
  // ==========================================================================

  Widget _buildCustomDateButton({
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final primary = _primaryColor(isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: _subtleSurface(isDark),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _borderColor(isDark), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_rounded, size: 14, color: primary),
              const SizedBox(width: 5),
              Text(
                'Custom Date',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _primaryText(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // WEEK DAY ITEM
  // ==========================================================================

  Widget _buildDayItem({
    required DateTime date,
    required String dayLabel,
    required bool isSelected,
    required bool isToday,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final primary = _primaryColor(isDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? primary
                : isToday
                ? primary.withValues(alpha: isDark ? 0.18 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: primary.withValues(alpha: 0.15))
                : isToday
                ? Border.all(
                    color: primary.withValues(alpha: isDark ? 0.40 : 0.28),
                  )
                : Border.all(color: Colors.transparent),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: isDark ? 0.20 : 0.14),
                      blurRadius: 12,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dayLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.90)
                      : _secondaryText(isDark),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? primary
                      : _primaryText(isDark),
                ),
              ),

              // Small today indicator.
              if (isToday && !isSelected) ...[
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ] else
                const SizedBox(height: 7),
            ],
          ),
        ),
      ),
    );
  }
}
