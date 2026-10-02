import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth/login/login_screen.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../doctor/doctors/doctors_screen.dart';
import '../../main.dart';
import '../../patient/patients/patients_screen.dart';
import '../../utils/page_transitions.dart';
import '../beds/beds_icu_screen.dart';
import '../blood/blood_bank_screen.dart';
import '../facilities/facilities_screen.dart';
import '../profile/hospital_profile_screen.dart';
import '../departments/departments_screen.dart';
import '../staff/staff_management_screen.dart';
import '../settings/hospital_settings_screen.dart';
import '../../doctor/emergency/doctor_emergency_cases_screen.dart';
import '../../doctor/appointments/doctor_appointments_screen.dart';
import '../reports/diagnostic_reports_screen.dart';
import '../resources/resource_allocation_screen.dart';
import '../analytics/operational_analytics_screen.dart';
import '../ai/ai_insights_center_screen.dart';
import '../notifications/notification_center_screen.dart';
import '../security/security_governance_screen.dart';
import './overview_dashboard_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  final String hospitalName;

  const MainDashboardScreen({
    super.key,
    this.hospitalName = 'St. Jude Memorial Hospital',
  });

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;

  List<_NavDestination> get _navDestinations {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return [
      const _NavDestination(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: 'Overview',
      ),
      const _NavDestination(
        icon: Icons.verified_user_outlined,
        selectedIcon: Icons.verified_user_rounded,
        label: 'Profile & Verification',
      ),
      const _NavDestination(
        icon: Icons.domain_outlined,
        selectedIcon: Icons.domain_rounded,
        label: 'Departments',
      ),
      const _NavDestination(
        icon: Icons.badge_outlined,
        selectedIcon: Icons.badge_rounded,
        label: 'Doctors',
      ),
      const _NavDestination(
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups_rounded,
        label: 'Staff & Roster',
      ),
      const _NavDestination(
        icon: Icons.people_outline,
        selectedIcon: Icons.people_rounded,
        label: 'Patients',
      ),
      const _NavDestination(
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        label: 'Appointments',
      ),
      const _NavDestination(
        icon: Icons.king_bed_outlined,
        selectedIcon: Icons.king_bed_rounded,
        label: 'Beds & ICU',
      ),
      const _NavDestination(
        icon: Icons.bloodtype_outlined,
        selectedIcon: Icons.bloodtype_rounded,
        label: 'Blood Bank',
      ),
      const _NavDestination(
        icon: Icons.emergency_outlined,
        selectedIcon: Icons.emergency_rounded,
        label: 'Emergency & Triage',
      ),
      const _NavDestination(
        icon: Icons.folder_shared_outlined,
        selectedIcon: Icons.folder_shared_rounded,
        label: 'Clinical Documents',
      ),
      const _NavDestination(
        icon: Icons.account_tree_outlined,
        selectedIcon: Icons.account_tree_rounded,
        label: 'Resource Allocation',
      ),
      const _NavDestination(
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics_rounded,
        label: 'Operational Analytics',
      ),
      const _NavDestination(
        icon: Icons.psychology_outlined,
        selectedIcon: Icons.psychology_rounded,
        label: 'AI & Forecasting Center',
      ),
      const _NavDestination(
        icon: Icons.notifications_active_outlined,
        selectedIcon: Icons.notifications_active_rounded,
        label: 'Notification Center',
      ),
      const _NavDestination(
        icon: Icons.business_outlined,
        selectedIcon: Icons.business_rounded,
        label: 'Facilities & Equipment',
      ),
      const _NavDestination(
        icon: Icons.security_outlined,
        selectedIcon: Icons.security_rounded,
        label: 'Security & Governance',
      ),
      const _NavDestination(
        icon: Icons.settings_applications_outlined,
        selectedIcon: Icons.settings_applications_rounded,
        label: 'Settings & RBAC',
      ),
      _NavDestination(
        icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        selectedIcon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        label: isDark ? 'Light Mode' : 'Dark Mode',
      ),
    ];
  }

  void _toggleTheme() {
    setState(() {
      final isDark = themeNotifier.value == ThemeMode.dark;
      themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDark ? 'Switched to Light Mode' : 'Switched to Dark Mode'),
          backgroundColor: HealthifyGlassTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _handleNavTap(int index, {bool closeDrawer = false}) {
    if (index == 18) {
      if (closeDrawer && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _toggleTheme();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      if (closeDrawer && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  void _handleLogout() {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            GlassIconContainer(
              icon: Icons.logout_rounded,
              size: 38,
              iconSize: 20,
              color: Colors.redAccent,
              borderRadius: 10,
            ),
            SizedBox(width: 10),
            Expanded(child: Text('Logout Confirmation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of your hospital account portal?',
          style: TextStyle(color: HealthifyGlassTheme.getTextSecondary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: HealthifyGlassTheme.getTextSecondary(isDark))),
          ),
          GlassPrimaryButton(
            height: 42,
            color: Colors.redAccent,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                FadePageRoute(page: const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showRoleSwitcherModal() {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.swap_horiz_rounded,
                    size: 40,
                    iconSize: 22,
                    color: HealthifyGlassTheme.primaryTeal,
                    borderRadius: 12,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'MEDRIX Persona Switcher',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Switch your view between Patient, Doctor, and Hospital Administrator screens.',
                style: TextStyle(
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 20),
              _buildRoleTile(
                context: context,
                icon: Icons.person_rounded,
                title: 'Patient Portal',
                subtitle: 'Appointments, health records & queue tracking',
                color: HealthifyGlassTheme.primaryTeal,
                isSelected: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/patient');
                },
              ),
              const SizedBox(height: 10),
              _buildRoleTile(
                context: context,
                icon: Icons.medical_services_rounded,
                title: 'Doctor Portal',
                subtitle: 'Schedules, patient rounds & clinical notes',
                color: Colors.indigo,
                isSelected: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/doctor');
                },
              ),
              const SizedBox(height: 10),
              _buildRoleTile(
                context: context,
                icon: Icons.local_hospital_rounded,
                title: 'Hospital Admin Portal',
                subtitle: 'Current Active Portal (Full operations)',
                color: HealthifyGlassTheme.primaryTeal,
                isSelected: true,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: GlassIconContainer(
          icon: icon,
          size: 38,
          iconSize: 20,
          color: color,
          borderRadius: 10,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? color : HealthifyGlassTheme.getTextPrimary(isDark),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: HealthifyGlassTheme.getTextSecondary(isDark),
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: color)
            : Icon(Icons.chevron_right_rounded, color: HealthifyGlassTheme.getTextSecondary(isDark)),
      ),
    );
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return OverviewDashboardScreen(
          onNavigateToTab: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
      case 1:
        return const HospitalProfileScreen();
      case 2:
        return const DepartmentsScreen();
      case 3:
        return const DoctorsScreen();
      case 4:
        return const StaffManagementScreen();
      case 5:
        return const PatientsScreen();
      case 6:
        return const DoctorAppointmentsScreen();
      case 7:
        return const BedsIcuScreen();
      case 8:
        return const BloodBankScreen();
      case 9:
        return const DoctorEmergencyCasesScreen();
      case 10:
        return const DiagnosticReportsScreen();
      case 11:
        return const ResourceAllocationScreen();
      case 12:
        return const OperationalAnalyticsScreen();
      case 13:
        return const AIInsightsCenterScreen();
      case 14:
        return NotificationCenterScreen(
          onNavigateToTab: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
      case 15:
        return const FacilitiesScreen();
      case 16:
        return SecurityGovernanceScreen(
          onNavigateToTab: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
      case 17:
        return const HospitalSettingsScreen();
      default:
        return OverviewDashboardScreen(
          onNavigateToTab: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final primaryTextColor = HealthifyGlassTheme.getTextPrimary(isDark);
    final secondaryTextColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Scaffold(
      backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
      drawer: isDesktop ? null : _buildMobileDrawer(isDark),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isDesktop
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu_rounded, color: primaryTextColor),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        title: Row(
          children: [
            const GlassIconContainer(
              icon: Icons.local_hospital_rounded,
              size: 38,
              iconSize: 20,
              color: HealthifyGlassTheme.primaryTeal,
              borderRadius: 10,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'MEDRIX ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: HealthifyGlassTheme.primaryTeal,
                            fontSize: 17,
                          ),
                        ),
                        TextSpan(
                          text: '| ${widget.hospitalName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: primaryTextColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Multi-specialty Trauma & Care Center',
                    style: TextStyle(fontSize: 11, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: _showRoleSwitcherModal,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_hospital_rounded, size: 15, color: HealthifyGlassTheme.primaryTeal),
                  SizedBox(width: 5),
                  Text(
                    'HOSPITAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.primaryTeal,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded, size: 16, color: HealthifyGlassTheme.primaryTeal),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: primaryTextColor,
            ),
            onPressed: _toggleTheme,
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: AnimatedPulseBackground(
        child: isDesktop
            ? Row(
                children: [
                  _buildDesktopSidebar(isDark),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1600),
                        child: _buildSelectedScreen(),
                      ),
                    ),
                  ),
                ],
              )
            : _buildSelectedScreen(),
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(isDark),
    );
  }

  Widget _buildDesktopSidebar(bool isDark) {
    final width = _isSidebarExpanded ? 250.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: width,
      child: GlassCard(
        borderRadius: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  _isSidebarExpanded
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
                onPressed: () {
                  setState(() {
                    _isSidebarExpanded = !_isSidebarExpanded;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _navDestinations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final dest = _navDestinations[index];
                  final isSelected = _selectedIndex == index;

                  if (!_isSidebarExpanded) {
                    return Tooltip(
                      message: dest.label,
                      child: InkWell(
                        onTap: () => _handleNavTap(index),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isSelected ? dest.selectedIcon : dest.icon,
                            color: isSelected
                                ? HealthifyGlassTheme.primaryTeal
                                : HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ),
                    );
                  }

                  return InkWell(
                    onTap: () => _handleNavTap(index),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? HealthifyGlassTheme.primaryTeal
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? dest.selectedIcon : dest.icon,
                            color: isSelected
                                ? HealthifyGlassTheme.primaryTeal
                                : HealthifyGlassTheme.getTextSecondary(isDark),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              dest.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? HealthifyGlassTheme.primaryTeal
                                    : HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(bool isDark) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            color: isDark
                ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.92),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [HealthifyGlassTheme.primaryTeal, HealthifyGlassTheme.primaryDarkTeal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        widget.hospitalName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'MEDRIX Hospital Admin Portal',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                ...List.generate(_navDestinations.length, (index) {
                  final dest = _navDestinations[index];
                  final isSelected = _selectedIndex == index;

                  return ListTile(
                    leading: Icon(
                      isSelected ? dest.selectedIcon : dest.icon,
                      color: isSelected
                          ? HealthifyGlassTheme.primaryTeal
                          : HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                    title: Text(
                      dest.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? HealthifyGlassTheme.primaryTeal
                            : HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    onTap: () => _handleNavTap(index, closeDrawer: true),
                  );
                }),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBottomNav(bool isDark) {
    final mobileIndices = [0, 1, 3, 5, 6, 9];
    final currentMobileIndex = mobileIndices.indexOf(_selectedIndex);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: HealthifyGlassTheme.getGlassSurface(isDark, isStrong: true),
            border: Border(
              top: BorderSide(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
                width: 1.0,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentMobileIndex == -1 ? 0 : currentMobileIndex,
            onDestinationSelected: (index) => _handleNavTap(mobileIndices[index]),
            backgroundColor: Colors.transparent,
            indicatorColor: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.15),
            destinations: mobileIndices.map((destIndex) {
              final dest = _navDestinations[destIndex];
              return NavigationDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon, color: HealthifyGlassTheme.primaryTeal),
                label: dest.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}