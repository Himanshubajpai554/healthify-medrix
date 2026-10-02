import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class PatientsSummaryCards extends StatelessWidget {
  final int totalPatients;
  final int todaysPatients;
  final int newPatients;
  final int followUpsDue;
  final int pendingReports;
  final PatientCareStatus? activeCareStatusFilter;
  final ValueChanged<PatientCareStatus?> onSelectCareStatusFilter;

  const PatientsSummaryCards({
    super.key,
    required this.totalPatients,
    required this.todaysPatients,
    required this.newPatients,
    required this.followUpsDue,
    required this.pendingReports,
    required this.activeCareStatusFilter,
    required this.onSelectCareStatusFilter,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1100) {
      return Row(
        children: [
          Expanded(
            child: _buildSummaryTile(
              context: context,
              title: 'Total Patients',
              count: totalPatients,
              icon: Icons.groups_rounded,
              color: HealthifyGlassTheme.primaryTeal,
              isSelected: activeCareStatusFilter == null,
              onTap: () => onSelectCareStatusFilter(null),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryTile(
              context: context,
              title: "Today's Patients",
              count: todaysPatients,
              icon: Icons.today_rounded,
              color: Colors.indigo,
              isSelected: activeCareStatusFilter == PatientCareStatus.active,
              onTap: () => onSelectCareStatusFilter(PatientCareStatus.active),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryTile(
              context: context,
              title: 'New Patients',
              count: newPatients,
              icon: Icons.person_add_alt_1_rounded,
              color: const Color(0xFF10B981),
              isSelected: activeCareStatusFilter == PatientCareStatus.newPatient,
              onTap: () => onSelectCareStatusFilter(PatientCareStatus.newPatient),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryTile(
              context: context,
              title: 'Follow-ups Due',
              count: followUpsDue,
              icon: Icons.health_and_safety_rounded,
              color: Colors.amber.shade800,
              isSelected: activeCareStatusFilter == PatientCareStatus.followUpDue,
              onTap: () => onSelectCareStatusFilter(PatientCareStatus.followUpDue),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryTile(
              context: context,
              title: 'Pending Reports',
              count: pendingReports,
              icon: Icons.assignment_late_rounded,
              color: Colors.redAccent,
              isSelected: activeCareStatusFilter == PatientCareStatus.emergency,
              onTap: () => onSelectCareStatusFilter(PatientCareStatus.emergency),
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
            child: _buildSummaryTile(
              context: context,
              title: 'Total Patients',
              count: totalPatients,
              icon: Icons.groups_rounded,
              color: HealthifyGlassTheme.primaryTeal,
              isSelected: activeCareStatusFilter == null,
              onTap: () => onSelectCareStatusFilter(null),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: _buildSummaryTile(
              context: context,
              title: "Today's",
              count: todaysPatients,
              icon: Icons.today_rounded,
              color: Colors.indigo,
              isSelected: activeCareStatusFilter == PatientCareStatus.active,
              onTap: () => onSelectCareStatusFilter(PatientCareStatus.active),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: _buildSummaryTile(
              context: context,
              title: 'New Patients',
              count: newPatients,
              icon: Icons.person_add_alt_1_rounded,
              color: const Color(0xFF10B981),
              isSelected: activeCareStatusFilter == PatientCareStatus.newPatient,
              onTap: () => onSelectCareStatusFilter(PatientCareStatus.newPatient),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: _buildSummaryTile(
              context: context,
              title: 'Follow-ups Due',
              count: followUpsDue,
              icon: Icons.health_and_safety_rounded,
              color: Colors.amber.shade800,
              isSelected: activeCareStatusFilter == PatientCareStatus.followUpDue,
              onTap: () => onSelectCareStatusFilter(PatientCareStatus.followUpDue),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: _buildSummaryTile(
              context: context,
              title: 'Pending Reports',
              count: pendingReports,
              icon: Icons.assignment_late_rounded,
              color: Colors.redAccent,
              isSelected: activeCareStatusFilter == PatientCareStatus.emergency,
              onTap: () => onSelectCareStatusFilter(PatientCareStatus.emergency),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile({
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
