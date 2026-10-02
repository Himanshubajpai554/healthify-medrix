import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';

class DoctorQuickOverviewCards extends StatelessWidget {
  final int totalAppointments;
  final int completedAppointments;
  final int upcomingAppointments;

  final int totalPatients;
  final int newPatients;
  final int followUpPatients;

  final int pendingReports;
  final int urgentReports;

  final int emergencyCount;
  final int criticalEmergencyCount;

  final int followUpsToday;

  final ValueChanged<int>? onCardTap;

  const DoctorQuickOverviewCards({
    super.key,
    this.totalAppointments = 14,
    this.completedAppointments = 8,
    this.upcomingAppointments = 6,
    this.totalPatients = 18,
    this.newPatients = 4,
    this.followUpPatients = 8,
    this.pendingReports = 5,
    this.urgentReports = 2,
    this.emergencyCount = 2,
    this.criticalEmergencyCount = 1,
    this.followUpsToday = 6,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return Row(
        children: [
          Expanded(child: _buildAppointmentsCard(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildPatientsCard(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildPendingReportsCard(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildEmergencyCard(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildFollowUpsCard(context)),
        ],
      );
    } else if (width >= 700) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildAppointmentsCard(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildPatientsCard(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildPendingReportsCard(context)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildEmergencyCard(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildFollowUpsCard(context)),
            ],
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 220, child: _buildAppointmentsCard(context)),
            const SizedBox(width: 10),
            SizedBox(width: 220, child: _buildPatientsCard(context)),
            const SizedBox(width: 10),
            SizedBox(width: 220, child: _buildPendingReportsCard(context)),
            const SizedBox(width: 10),
            SizedBox(width: 220, child: _buildEmergencyCard(context)),
            const SizedBox(width: 10),
            SizedBox(width: 220, child: _buildFollowUpsCard(context)),
          ],
        ),
      );
    }
  }

  Widget _buildAppointmentsCard(BuildContext context) {
    return _buildOverviewCard(
      context: context,
      title: "Today's Appointments",
      value: '$totalAppointments',
      subtitle: '$completedAppointments Done • $upcomingAppointments Next',
      trend: '+12% vs yesterday',
      trendIcon: Icons.trending_up_rounded,
      trendColor: const Color(0xFF10B981),
      icon: Icons.calendar_month_rounded,
      color: HealthifyGlassTheme.primaryTeal,
      onTap: () => onCardTap?.call(1),
    );
  }

  Widget _buildPatientsCard(BuildContext context) {
    return _buildOverviewCard(
      context: context,
      title: "Today's Patients",
      value: '$totalPatients',
      subtitle: '$newPatients New • $followUpPatients Follow-ups',
      trend: '4 OPD slots open',
      trendIcon: Icons.info_outline_rounded,
      trendColor: Colors.blueAccent,
      icon: Icons.groups_rounded,
      color: Colors.indigo,
      onTap: () => onCardTap?.call(2),
    );
  }

  Widget _buildPendingReportsCard(BuildContext context) {
    return _buildOverviewCard(
      context: context,
      title: 'Pending Reports',
      value: '$pendingReports',
      subtitle: '$urgentReports Urgent Review',
      badge: urgentReports > 0 ? '$urgentReports Urgent' : null,
      badgeColor: Colors.amber.shade800,
      icon: Icons.assignment_late_rounded,
      color: Colors.amber.shade700,
      onTap: () => onCardTap?.call(4),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    return _buildOverviewCard(
      context: context,
      title: 'Emergency Cases',
      value: '$emergencyCount',
      subtitle: '$criticalEmergencyCount Critical ICU',
      badge: criticalEmergencyCount > 0 ? 'Critical' : null,
      badgeColor: Colors.redAccent,
      icon: Icons.emergency_rounded,
      color: Colors.redAccent,
      onTap: () => onCardTap?.call(6),
    );
  }

  Widget _buildFollowUpsCard(BuildContext context) {
    return _buildOverviewCard(
      context: context,
      title: 'Patient Follow-ups',
      value: '$followUpsToday',
      subtitle: 'Required today',
      icon: Icons.health_and_safety_rounded,
      color: const Color(0xFF0284C7),
      onTap: () => onCardTap?.call(7),
    );
  }

  Widget _buildOverviewCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? trend,
    IconData? trendIcon,
    Color? trendColor,
    String? badge,
    Color? badgeColor,
    VoidCallback? onTap,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return DynamicHoverGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GlassIconContainer(
                icon: icon,
                size: 34,
                iconSize: 18,
                color: color,
                borderRadius: 10,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? Colors.redAccent).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (badgeColor ?? Colors.redAccent).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor ?? Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (trend != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (trendIcon != null)
                  Icon(
                    trendIcon,
                    size: 13,
                    color: trendColor ?? HealthifyGlassTheme.primaryTeal,
                  ),
                if (trendIcon != null) const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: trendColor ?? HealthifyGlassTheme.primaryTeal,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
