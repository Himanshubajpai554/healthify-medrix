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
              color: HealthifyGlassTheme.primaryTeal,
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
              color: Colors.blueAccent,
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
              color: Colors.amber.shade800,
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
              color: const Color(0xFF10B981),
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
              color: Colors.redAccent,
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
              color: Colors.grey.shade700,
              isSelected: activeFilterStatus == AppointmentStatus.noShow,
              onTap: () => onSelectStatusFilter(AppointmentStatus.noShow),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: _buildCard(
              context: context,
              title: "Today's",
              count: totalCount,
              icon: Icons.calendar_month_rounded,
              color: HealthifyGlassTheme.primaryTeal,
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
              color: Colors.blueAccent,
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
              color: Colors.amber.shade800,
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
              color: const Color(0xFF10B981),
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
              color: Colors.redAccent,
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
              color: Colors.grey.shade700,
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

    return DynamicHoverGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? color : HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? color : HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
