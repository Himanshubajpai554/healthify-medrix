import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class AppointmentsSummaryCards extends StatelessWidget {
  final int totalCount;
  final int upcomingCount;
  final int completedCount;
  final int waitingCount;
  final int cancelledCount;
  final int noShowCount;
  final AppointmentStatus? activeFilterStatus;
  final ValueChanged<AppointmentStatus?> onSelectStatusFilter;

  const AppointmentsSummaryCards({
    super.key,
    required this.totalCount,
    required this.upcomingCount,
    required this.completedCount,
    required this.waitingCount,
    required this.cancelledCount,
    required this.noShowCount,
    required this.activeFilterStatus,
    required this.onSelectStatusFilter,
  });

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  static const Color _upcoming = Color(0xFF3B82F6);
  static const Color _waiting = Color(0xFFF59E0B);
  static const Color _completed = Color(0xFF10B981);
  static const Color _cancelled = Color(0xFFEF4444);
  static const Color _noShow = Color(0xFF64748B);

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1100) {
      return Row(
        children: [
          Expanded(
            child: _buildCard(
              context: context,
              title: "Today's Appointments",
              count: totalCount,
              icon: Icons.calendar_month_rounded,
              color: _primaryColor(HealthifyGlassTheme.isDarkMode(context)),
              isSelected: activeFilterStatus == null,
              onTap: () => onSelectStatusFilter(null),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildCard(
              context: context,
              title: 'Upcoming',
              count: upcomingCount,
              icon: Icons.schedule_rounded,
              color: _upcoming,
              isSelected: activeFilterStatus == AppointmentStatus.upcoming,
              onTap: () => onSelectStatusFilter(AppointmentStatus.upcoming),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildCard(
              context: context,
              title: 'Waiting',
              count: waitingCount,
              icon: Icons.access_time_filled_rounded,
              color: _waiting,
              isSelected: activeFilterStatus == AppointmentStatus.waiting,
              onTap: () => onSelectStatusFilter(AppointmentStatus.waiting),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildCard(
              context: context,
              title: 'Completed',
              count: completedCount,
              icon: Icons.task_alt_rounded,
              color: _completed,
              isSelected: activeFilterStatus == AppointmentStatus.completed,
              onTap: () => onSelectStatusFilter(AppointmentStatus.completed),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildCard(
              context: context,
              title: 'Cancelled',
              count: cancelledCount,
              icon: Icons.cancel_outlined,
              color: _cancelled,
              isSelected: activeFilterStatus == AppointmentStatus.cancelled,
              onTap: () => onSelectStatusFilter(AppointmentStatus.cancelled),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _buildCard(
              context: context,
              title: 'No Show',
              count: noShowCount,
              icon: Icons.person_off_rounded,
              color: _noShow,
              isSelected: activeFilterStatus == AppointmentStatus.noShow,
              onTap: () => onSelectStatusFilter(AppointmentStatus.noShow),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: _buildCard(
              context: context,
              title: "Today's",
              count: totalCount,
              icon: Icons.calendar_month_rounded,
              color: _primaryColor(HealthifyGlassTheme.isDarkMode(context)),
              isSelected: activeFilterStatus == null,
              onTap: () => onSelectStatusFilter(null),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 140,
            child: _buildCard(
              context: context,
              title: 'Upcoming',
              count: upcomingCount,
              icon: Icons.schedule_rounded,
              color: _upcoming,
              isSelected: activeFilterStatus == AppointmentStatus.upcoming,
              onTap: () => onSelectStatusFilter(AppointmentStatus.upcoming),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 140,
            child: _buildCard(
              context: context,
              title: 'Waiting',
              count: waitingCount,
              icon: Icons.access_time_filled_rounded,
              color: _waiting,
              isSelected: activeFilterStatus == AppointmentStatus.waiting,
              onTap: () => onSelectStatusFilter(AppointmentStatus.waiting),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 140,
            child: _buildCard(
              context: context,
              title: 'Completed',
              count: completedCount,
              icon: Icons.task_alt_rounded,
              color: _completed,
              isSelected: activeFilterStatus == AppointmentStatus.completed,
              onTap: () => onSelectStatusFilter(AppointmentStatus.completed),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 140,
            child: _buildCard(
              context: context,
              title: 'Cancelled',
              count: cancelledCount,
              icon: Icons.cancel_outlined,
              color: _cancelled,
              isSelected: activeFilterStatus == AppointmentStatus.cancelled,
              onTap: () => onSelectStatusFilter(AppointmentStatus.cancelled),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 140,
            child: _buildCard(
              context: context,
              title: 'No Show',
              count: noShowCount,
              icon: Icons.person_off_rounded,
              color: _noShow,
              isSelected: activeFilterStatus == AppointmentStatus.noShow,
              onTap: () => onSelectStatusFilter(AppointmentStatus.noShow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final textPrimary = _primaryText(isDark);
    final textSecondary = _secondaryText(isDark);

    return DynamicHoverGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(13),
      onTap: onTap,
      glowColor: color,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.085 : 0.045)
              : Colors.transparent,
          border: isSelected
              ? Border.all(
                  color: color.withValues(alpha: isDark ? 0.24 : 0.18),
                  width: 0.8,
                )
              : null,
        ),
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================================================
            // TITLE + ICON
            // =============================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected ? color : textSecondary,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                    ),
                  ),
                  child: Icon(icon, size: 15, color: color),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // =============================================================
            // COUNT + SELECTED INDICATOR
            // =============================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 23,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isSelected ? color : textPrimary,
                  ),
                ),

                if (isSelected) ...[
                  const SizedBox(width: 7),

                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: isDark ? 0.25 : 0.16),
                          blurRadius: 7,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 5),

            // =============================================================
            // ACTIVE FILTER LABEL
            // =============================================================
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: isSelected
                  ? Row(
                      key: const ValueKey('active'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Active filter',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: color.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Tap to filter',
                      key: const ValueKey('inactive'),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        color: textSecondary.withValues(alpha: 0.70),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
