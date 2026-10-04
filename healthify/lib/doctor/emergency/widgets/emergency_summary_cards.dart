import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../../theme/app_theme.dart';
import '../../models/emergency_models.dart';

class EmergencySummaryCards extends StatelessWidget {
  final int activeCount;
  final int criticalCount;
  final int waitingCount;
  final int inTreatmentCount;
  final int resolvedTodayCount;

  final EmergencyCaseStatus? selectedStatusFilter;
  final ValueChanged<EmergencyCaseStatus?> onStatusFilterSelected;

  const EmergencySummaryCards({
    super.key,
    required this.activeCount,
    required this.criticalCount,
    required this.waitingCount,
    required this.inTreatmentCount,
    required this.resolvedTodayCount,
    required this.selectedStatusFilter,
    required this.onStatusFilterSelected,
  });

  // ---------------------------------------------------------------------------
  // HEALTHIFY GLASS THEME
  // ---------------------------------------------------------------------------

  Color _surface(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.72);
  }

  Color _surfaceStrong(bool isDark) {
    return isDark
        ? const Color(0xFF0D9488).withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.90);
  }

  Color _border(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.085)
        : Colors.white.withValues(alpha: 0.88);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : AppTheme.textPrimary;
  }

  Color _secondaryText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppTheme.textSecondary;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final int crossAxisCount;

        if (width >= 1150) {
          crossAxisCount = 5;
        } else if (width >= 700) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: _getAspectRatio(width),
          children: [
            _buildCard(
              context: context,
              title: 'Active Emergencies',
              value: activeCount.toString(),
              subtitle: 'Open ER workflows',
              icon: Icons.emergency_rounded,
              color: Colors.redAccent,
              isSelected: selectedStatusFilter == null,
              onTap: () => onStatusFilterSelected(null),
              isDark: isDark,
            ),

            _buildCard(
              context: context,
              title: 'Critical Attention',
              value: criticalCount.toString(),
              subtitle: 'Immediate priority cases',
              icon: Icons.error_rounded,
              color: const Color(0xFFDC2626),
              isSelected: false,
              onTap: () => onStatusFilterSelected(null),
              isDark: isDark,
            ),

            _buildCard(
              context: context,
              title: 'Waiting',
              value: waitingCount.toString(),
              subtitle: 'Triage pending treatment',
              icon: Icons.hourglass_top_rounded,
              color: const Color(0xFFD97706),
              isSelected: selectedStatusFilter == EmergencyCaseStatus.waiting,
              onTap: () => onStatusFilterSelected(EmergencyCaseStatus.waiting),
              isDark: isDark,
            ),

            _buildCard(
              context: context,
              title: 'In Treatment',
              value: inTreatmentCount.toString(),
              subtitle: 'Active intervention',
              icon: Icons.medical_services_rounded,
              color: const Color(0xFF2563EB),
              isSelected:
                  selectedStatusFilter == EmergencyCaseStatus.inTreatment,
              onTap: () =>
                  onStatusFilterSelected(EmergencyCaseStatus.inTreatment),
              isDark: isDark,
            ),

            _buildCard(
              context: context,
              title: 'Resolved Today',
              value: resolvedTodayCount.toString(),
              subtitle: 'Closed / Discharged',
              icon: Icons.task_alt_rounded,
              color: const Color(0xFF10B981),
              isSelected: selectedStatusFilter == EmergencyCaseStatus.resolved,
              onTap: () => onStatusFilterSelected(EmergencyCaseStatus.resolved),
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // RESPONSIVE ASPECT RATIO
  // ---------------------------------------------------------------------------

  double _getAspectRatio(double width) {
    if (width >= 1150) {
      return 1.80;
    }

    if (width >= 700) {
      return 1.75;
    }

    if (width < 390) {
      return 1.05;
    }

    return 1.12;
  }

  // ---------------------------------------------------------------------------
  // CARD
  // ---------------------------------------------------------------------------

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return DynamicHoverGlassCard(
      margin: EdgeInsets.zero,
      borderRadius: 20,
      padding: EdgeInsets.zero,
      onTap: onTap,
      hasTealGlow: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: isDark ? 0.13 : 0.075)
                  : _surface(isDark),

              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: isDark ? 0.48 : 0.30)
                    : _border(isDark),
                width: isSelected ? 1.2 : 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? color.withValues(alpha: isDark ? 0.12 : 0.055)
                      : Colors.black.withValues(alpha: isDark ? 0.07 : 0.025),
                  blurRadius: isSelected ? 18 : 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),

            // ---------------------------------------------------------------
            // ORIGINAL STRUCTURE
            // ---------------------------------------------------------------
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // -----------------------------------------------------------
                // ICON + TITLE
                // -----------------------------------------------------------
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: color.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _secondaryText(isDark),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // -----------------------------------------------------------
                // VALUE
                // -----------------------------------------------------------
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: TextStyle(
                      fontSize: 23,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: _primaryText(isDark),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // -----------------------------------------------------------
                // SUBTITLE
                // -----------------------------------------------------------
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.15,
                    fontWeight: FontWeight.w500,
                    color: _secondaryText(isDark).withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
