import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../models/doctor_dashboard_models.dart';

class DoctorSidebar extends StatelessWidget {
  final int selectedNavIndex;
  final ValueChanged<int> onNavItemSelected;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final DoctorAvailability availabilityStatus;
  final VoidCallback onLogout;
  final VoidCallback onRoleSwitcherTap;
  final String doctorName;
  final String specialty;

  const DoctorSidebar({
    super.key,
    required this.selectedNavIndex,
    required this.onNavItemSelected,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.availabilityStatus,
    required this.onLogout,
    required this.onRoleSwitcherTap,
    this.doctorName = 'Dr. Sarah Jenkins',
    this.specialty = 'Lead Cardiologist',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubic,
      width: isExpanded ? 260 : 80,
      decoration: BoxDecoration(
        color: isDark
            ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          right: BorderSide(
            color: HealthifyGlassTheme.getGlassBorder(isDark),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Sidebar Header: Logo & App Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 12),
            child: Row(
              children: [
                const GlassIconContainer(
                  icon: Icons.local_hospital_rounded,
                  size: 40,
                  iconSize: 22,
                  color: HealthifyGlassTheme.primaryTeal,
                  borderRadius: 12,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MEDRIX',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            fontSize: 17,
                            color: HealthifyGlassTheme.primaryTeal,
                          ),
                        ),
                        Text(
                          'Doctor Portal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: 20,
                      color: HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                    onPressed: onToggleExpand,
                    tooltip: 'Collapse Sidebar',
                  ),
                ],
              ],
            ),
          ),
          if (!isExpanded) ...[
            const SizedBox(height: 8),
            IconButton(
              icon: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
              onPressed: onToggleExpand,
              tooltip: 'Expand Sidebar',
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),

          // Doctor Profile Card in Sidebar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 12 : 8),
            child: InkWell(
              onTap: onRoleSwitcherTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HealthifyGlassTheme.primaryTeal.withValues(
                    alpha: isDark ? 0.15 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: isExpanded ? 20 : 18,
                          backgroundColor: HealthifyGlassTheme.primaryTeal,
                          child: Text(
                            doctorName.isNotEmpty ? doctorName[0] : 'D',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _getStatusColor(availabilityStatus),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isExpanded) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              specialty,
                              style: TextStyle(
                                fontSize: 11,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.swap_vert_rounded,
                        size: 16,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isExpanded ? 10 : 8),
              children: [
                if (isExpanded) _buildSectionHeader('MAIN', isDark),
                _buildNavItem(0, 'Dashboard', Icons.dashboard_rounded, isDark),
                _buildNavItem(1, 'Appointments', Icons.calendar_today_rounded, isDark),
                _buildNavItem(2, 'My Patients', Icons.people_alt_rounded, isDark),
                _buildNavItem(3, 'Medical Records', Icons.folder_shared_rounded, isDark),
                _buildNavItem(4, 'Reports', Icons.assignment_rounded, isDark),
                _buildNavItem(5, 'Prescriptions', Icons.medication_rounded, isDark),

                const SizedBox(height: 12),
                if (isExpanded) _buildSectionHeader('CARE', isDark),
                _buildNavItem(6, 'Emergency Cases', Icons.emergency_rounded, isDark, badge: '2'),
                _buildNavItem(7, 'Patient Follow-ups', Icons.health_and_safety_rounded, isDark),

                const SizedBox(height: 12),
                if (isExpanded) _buildSectionHeader('INSIGHTS', isDark),
                _buildNavItem(8, 'My Analytics', Icons.insights_rounded, isDark),

                const SizedBox(height: 12),
                if (isExpanded) _buildSectionHeader('SYSTEM', isDark),
                _buildNavItem(9, 'Notifications', Icons.notifications_rounded, isDark, badge: '4'),
                _buildNavItem(10, 'Settings', Icons.settings_rounded, isDark),
                _buildNavItem(11, 'Help & Support', Icons.help_outline_rounded, isDark),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 8),

          // Logout Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 10 : 8),
            child: InkWell(
              onTap: onLogout,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment:
                      isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
                    if (isExpanded) ...[
                      const SizedBox(width: 12),
                      const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
          color: HealthifyGlassTheme.getTextMuted(isDark),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData icon,
    bool isDark, {
    String? badge,
  }) {
    final isSelected = selectedNavIndex == index;
    final activeColor = HealthifyGlassTheme.primaryTeal;

    if (!isExpanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: () => onNavItemSelected(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: isDark ? 0.22 : 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: activeColor.withValues(alpha: 0.4))
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? activeColor
                        : HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 6,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => onNavItemSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withValues(alpha: isDark ? 0.22 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: activeColor.withValues(alpha: 0.35))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: isSelected
                    ? activeColor
                    : HealthifyGlassTheme.getTextSecondary(isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? (isDark ? Colors.white : activeColor)
                        : HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: index == 6 ? Colors.redAccent : activeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(DoctorAvailability status) {
    switch (status) {
      case DoctorAvailability.available:
        return const Color(0xFF10B981);
      case DoctorAvailability.busy:
        return Colors.amber;
      case DoctorAvailability.offline:
        return Colors.grey;
    }
  }
}
