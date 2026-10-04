import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth/login/login_screen.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../doctor/doctors/doctors_screen.dart';
import '../../main.dart';
import '../../patient/patients/patients_screen.dart';
import '../../theme/app_theme.dart';
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
        selectedIcon: isDark
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
        label: isDark ? 'Light Mode' : 'Dark Mode',
      ),
    ];
  }

  void _toggleTheme() {
    final messenger = ScaffoldMessenger.of(context);
    final isDark = themeNotifier.value == ThemeMode.dark;
    themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isDark ? 'Switched to Light Mode' : 'Switched to Dark Mode',
        ),
        backgroundColor: HealthifyGlassTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
            Expanded(
              child: Text(
                'Logout Confirmation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of your hospital account portal?',
          style: TextStyle(color: HealthifyGlassTheme.getTextSecondary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
            ),
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
            color: isSelected
                ? color
                : HealthifyGlassTheme.getTextPrimary(isDark),
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
            : Icon(
                Icons.chevron_right_rounded,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
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
                color: HealthifyGlassTheme.primaryTeal.withValues(
                  alpha: isDark ? 0.20 : 0.12,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.local_hospital_rounded,
                    size: 15,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
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
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
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
                                ? HealthifyGlassTheme.primaryTeal.withValues(
                                    alpha: isDark ? 0.25 : 0.15,
                                  )
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HealthifyGlassTheme.primaryTeal.withValues(
                                alpha: isDark ? 0.25 : 0.15,
                              )
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
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? HealthifyGlassTheme.primaryTeal
                                    : HealthifyGlassTheme.getTextPrimary(
                                        isDark,
                                      ),
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
    const Color primary = Color(0xFF0D9488);
    const Color primaryDark = Color(0xFF0F766E);

    final Color drawerBackground = isDark
        ? const Color(0xFF071A19)
        : const Color(0xFFF4FAF9);

    final Color glassColor = isDark
        ? Colors.white.withValues(alpha: 0.055)
        : Colors.white.withValues(alpha: 0.72);

    final Color glassBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.85);

    final Color textPrimary = isDark ? Colors.white : AppTheme.textPrimary;

    final Color textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : AppTheme.textSecondary;

    return Drawer(
      width: 310,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: drawerBackground,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Stack(
          children: [
            // ================================================================
            // BACKGROUND GLOW 1
            // ================================================================
            Positioned(
              top: -100,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: isDark ? 0.13 : 0.08),
                ),
              ),
            ),

            // ================================================================
            // BACKGROUND GLOW 2
            // ================================================================
            Positioned(
              bottom: 80,
              right: -100,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: isDark ? 0.07 : 0.035),
                ),
              ),
            ),

            // ================================================================
            // BACKGROUND BLUR
            // ================================================================
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Colors.transparent),
              ),
            ),

            // ================================================================
            // MAIN CONTENT
            // ================================================================
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ==========================================================
                  // HEALTHIFY BRAND
                  // ==========================================================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [primary, primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.28),
                                blurRadius: 18,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Healthify',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              'Hospital operations, simplified.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ==========================================================
                  // HOSPITAL PROFILE GLASS CARD
                  // ==========================================================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primary, primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.22),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -25,
                              top: -35,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.07),
                                ),
                              ),
                            ),

                            Row(
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.local_hospital_rounded,
                                      color: Colors.white,
                                      size: 27,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.hospitalName.isNotEmpty
                                            ? widget.hospitalName
                                            : 'Hospital',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.13,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'HOSPITAL ADMIN • OPERATIONS',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==========================================================
                  // MAIN NAVIGATION
                  // ==========================================================
                  _hospitalDrawerSectionTitle('MAIN NAVIGATION', textSecondary),

                  const SizedBox(height: 7),

                  _hospitalDrawerGlassGroup(
                    isDark: isDark,
                    glassColor: glassColor,
                    glassBorder: glassBorder,
                    children: [
                      _hospitalDrawerItem(
                        icon: Icons.dashboard_rounded,
                        title: 'Overview',
                        index: 0,
                        selected: _selectedIndex == 0,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.verified_user_rounded,
                        title: 'Profile & Verification',
                        index: 1,
                        selected: _selectedIndex == 1,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.domain_rounded,
                        title: 'Departments',
                        index: 2,
                        selected: _selectedIndex == 2,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.badge_rounded,
                        title: 'Doctors',
                        index: 3,
                        selected: _selectedIndex == 3,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.groups_rounded,
                        title: 'Staff & Roster',
                        index: 4,
                        selected: _selectedIndex == 4,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.people_rounded,
                        title: 'Patients',
                        index: 5,
                        selected: _selectedIndex == 5,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ==========================================================
                  // CLINICAL OPERATIONS
                  // ==========================================================
                  _hospitalDrawerSectionTitle(
                    'CLINICAL OPERATIONS',
                    textSecondary,
                  ),

                  const SizedBox(height: 7),

                  _hospitalDrawerGlassGroup(
                    isDark: isDark,
                    glassColor: glassColor,
                    glassBorder: glassBorder,
                    children: [
                      _hospitalDrawerItem(
                        icon: Icons.calendar_month_rounded,
                        title: 'Appointments',
                        index: 6,
                        selected: _selectedIndex == 6,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.king_bed_rounded,
                        title: 'Beds & ICU',
                        index: 7,
                        selected: _selectedIndex == 7,
                        iconColor: Colors.indigo,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.bloodtype_rounded,
                        title: 'Blood Bank',
                        index: 8,
                        selected: _selectedIndex == 8,
                        iconColor: Colors.red,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.emergency_rounded,
                        title: 'Emergency & Triage',
                        index: 9,
                        selected: _selectedIndex == 9,
                        iconColor: Colors.redAccent,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.folder_shared_rounded,
                        title: 'Clinical Documents',
                        index: 10,
                        selected: _selectedIndex == 10,
                        iconColor: Colors.deepPurple,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ==========================================================
                  // EMERGENCY QUICK ACCESS
                  // ==========================================================
                  _hospitalEmergencyDrawerButton(
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedIndex = 9;
                      });
                    },
                  ),

                  const SizedBox(height: 22),

                  // ==========================================================
                  // RESOURCES & INTELLIGENCE
                  // ==========================================================
                  _hospitalDrawerSectionTitle(
                    'RESOURCES & INTELLIGENCE',
                    textSecondary,
                  ),

                  const SizedBox(height: 7),

                  _hospitalDrawerGlassGroup(
                    isDark: isDark,
                    glassColor: glassColor,
                    glassBorder: glassBorder,
                    children: [
                      _hospitalDrawerItem(
                        icon: Icons.account_tree_rounded,
                        title: 'Resource Allocation',
                        index: 11,
                        selected: _selectedIndex == 11,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.analytics_rounded,
                        title: 'Operational Analytics',
                        index: 12,
                        selected: _selectedIndex == 12,
                        iconColor: Colors.blue,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.psychology_rounded,
                        title: 'AI & Forecasting Center',
                        index: 13,
                        selected: _selectedIndex == 13,
                        iconColor: Colors.deepPurple,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.notifications_active_rounded,
                        title: 'Notification Center',
                        index: 14,
                        selected: _selectedIndex == 14,
                        iconColor: Colors.orange,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.business_rounded,
                        title: 'Facilities & Equipment',
                        index: 15,
                        selected: _selectedIndex == 15,
                        iconColor: Colors.blueGrey,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ==========================================================
                  // SECURITY & PREFERENCES
                  // ==========================================================
                  _hospitalDrawerSectionTitle(
                    'SECURITY & PREFERENCES',
                    textSecondary,
                  ),

                  const SizedBox(height: 7),

                  _hospitalDrawerGlassGroup(
                    isDark: isDark,
                    glassColor: glassColor,
                    glassBorder: glassBorder,
                    children: [
                      _hospitalDrawerItem(
                        icon: Icons.security_rounded,
                        title: 'Security & Governance',
                        index: 16,
                        selected: _selectedIndex == 16,
                        iconColor: Colors.blueGrey,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      _hospitalDrawerItem(
                        icon: Icons.settings_applications_rounded,
                        title: 'Settings & RBAC',
                        index: 17,
                        selected: _selectedIndex == 17,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.045)
                                : Colors.black.withValues(alpha: 0.018),
                          ),
                          child: Row(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Icon(
                                  isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_outlined,
                                  key: ValueKey(isDark),
                                  size: 21,
                                  color: isDark ? Colors.amber : textSecondary,
                                ),
                              ),

                              const SizedBox(width: 13),

                              Expanded(
                                child: Text(
                                  'Dark Theme',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ),

                              Transform.scale(
                                scale: 0.82,
                                child: Switch.adaptive(
                                  value: isDark,
                                  activeTrackColor: primary,
                                  onChanged: (_) {
                                    _toggleTheme();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ==========================================================
                  // LOGOUT
                  // ==========================================================
                  _hospitalLogoutDrawerButton(
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      _handleLogout();
                    },
                  ),

                  const SizedBox(height: 12),

                  // ==========================================================
                  // VERSION
                  // ==========================================================
                  Center(
                    child: Text(
                      'HEALTHIFY • HOSPITAL ADMIN PORTAL',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: textSecondary.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hospitalDrawerSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFF0D9488),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hospitalDrawerGlassGroup({
    required bool isDark,
    required Color glassColor,
    required Color glassBorder,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.035),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _hospitalDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required bool selected,
    required Color iconColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    const primary = Color(0xFF0D9488);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: selected ? 1 : 0),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.pop(context);

                setState(() {
                  _selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            primary.withValues(alpha: 0.18 + (value * 0.06)),
                            primary.withValues(alpha: 0.055),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  border: Border.all(
                    color: selected
                        ? primary.withValues(alpha: 0.18 + (value * 0.08))
                        : Colors.transparent,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.10 * value),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Active indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      width: selected ? 3 : 0,
                      height: selected ? 25 : 0,
                      margin: EdgeInsets.only(right: selected ? 9 : 0),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.55),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),

                    // Icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: selected ? 1 : 0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: 1 + (scale * 0.10),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? primary.withValues(alpha: 0.13)
                                  : Colors.transparent,
                            ),
                            child: Icon(
                              icon,
                              size: 20,
                              color: selected
                                  ? primary
                                  : iconColor.withValues(alpha: 0.78),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 9),

                    // Title
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? primary : textPrimary,
                          letterSpacing: -0.05,
                        ),
                      ),
                    ),

                    // Arrow
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: selected ? 1 : 0,
                      child: Transform.translate(
                        offset: Offset(selected ? 0 : -5, 0),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _hospitalEmergencyDrawerButton({
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.96 + (value * 0.04),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.redAccent.withValues(alpha: 0.15),
                          Colors.red.withValues(alpha: 0.055),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.92, end: 1.08),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.20,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.emergency_rounded,
                                  color: Colors.redAccent,
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency & Triage',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Open emergency management',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.60)
                                      : AppTheme.textSecondary,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _hospitalLogoutDrawerButton({
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : AppTheme.textSecondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: isDark ? 0.08 : 0.055),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color: textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBottomNav(bool isDark) {
    // Only the most important day-to-day hospital actions.
    // Everything else stays inside the drawer.
    const mobileItems = [
      _BottomNavItem(
        destinationIndex: 0,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        tooltip: 'Dashboard',
      ),
      _BottomNavItem(
        destinationIndex: 6,
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month_rounded,
        tooltip: 'Appointments',
      ),
      _BottomNavItem(
        destinationIndex: 5,
        icon: Icons.people_outline_rounded,
        selectedIcon: Icons.people_rounded,
        tooltip: 'Patients',
      ),
      _BottomNavItem(
        destinationIndex: 9,
        icon: Icons.emergency_outlined,
        selectedIcon: Icons.emergency_rounded,
        tooltip: 'Emergency',
      ),
    ];

    final currentIndex = mobileItems.indexWhere(
      (item) => item.destinationIndex == _selectedIndex,
    );

    final activeIndex = currentIndex == -1 ? 0 : currentIndex;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? HealthifyGlassTheme.darkBackground.withValues(alpha: 0.12)
                  : HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(
                  isDark,
                ).withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: HealthifyGlassTheme.primaryTeal.withValues(
                    alpha: isDark ? 0.08 : 0.05,
                  ),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Row(
              children: List.generate(mobileItems.length, (index) {
                final item = mobileItems[index];
                final isSelected = index == activeIndex;

                return Expanded(
                  child: _buildBottomNavItem(
                    item: item,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () {
                      _handleNavTap(item.destinationIndex);
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required _BottomNavItem item,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final primaryColor = HealthifyGlassTheme.primaryTeal;
    final secondaryColor = HealthifyGlassTheme.getTextSecondary(isDark);

    return Tooltip(
      message: item.tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: primaryColor.withValues(alpha: 0.08),
          highlightColor: primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: isSelected ? 58 : 48,
              height: isSelected ? 50 : 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? Border.all(
                        color: primaryColor.withValues(alpha: 0.28),
                        width: 1,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.16),
                          blurRadius: 14,
                          spreadRadius: -4,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.0 : 0.9,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      size: isSelected ? 26 : 23,
                      color: isSelected ? primaryColor : secondaryColor,
                    ),
                  ),

                  // Small active indicator
                  Positioned(
                    bottom: 5,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      width: isSelected ? 5 : 0,
                      height: isSelected ? 5 : 0,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

class _BottomNavItem {
  final int destinationIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String tooltip;

  const _BottomNavItem({
    required this.destinationIndex,
    required this.icon,
    required this.selectedIcon,
    required this.tooltip,
  });
}
