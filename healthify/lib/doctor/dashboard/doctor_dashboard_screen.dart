import 'dart:ui';

import 'package:flutter/material.dart';

import '../../auth/login/login_screen.dart';
import '../../hospital/dashboard/main_dashboard_screen.dart';
import '../../main.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../../utils/page_transitions.dart';
import '../../utils/responsive.dart';
import '../analytics/doctor_analytics_screen.dart';
import '../appointments/doctor_appointments_screen.dart';
import '../care/doctor_care_screen.dart';
import '../data/doctor_mock_data.dart';
import '../emergency/doctor_emergency_cases_screen.dart';
import '../followups/doctor_followups_screen.dart';
import '../help/doctor_help_support_screen.dart';
import '../modals/doctor_modals.dart';
import '../models/doctor_dashboard_models.dart';
import '../more/doctor_more_screen.dart';
import '../notifications/doctor_notifications_screen.dart';
import '../patients/my_patients_screen.dart';
import '../prescriptions/doctor_prescriptions_screen.dart';
import '../reports/doctor_reports_screen.dart';
import '../settings/doctor_profile_settings_screen.dart';
import '../widgets/ai_patient_summary_widget.dart';
import '../widgets/doctor_analytics_widget.dart';
import '../widgets/doctor_availability_card.dart';
import '../widgets/doctor_header.dart';
import '../widgets/doctor_quick_actions_bar.dart';
import '../widgets/doctor_quick_overview_cards.dart';
import '../widgets/doctor_sidebar.dart';
import '../widgets/emergency_cases_widget.dart';
import '../widgets/next_patient_hero_card.dart';
import '../widgets/patient_queue_widget.dart';
import '../widgets/pending_reports_widget.dart';
import '../widgets/recent_patients_widget.dart';
import '../widgets/today_appointments_section.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final String doctorName;
  final String doctorId;
  final String specialty;

  const DoctorDashboardScreen({
    super.key,
    this.doctorName = 'Dr. Sarah Jenkins',
    this.doctorId = 'DOC-4019',
    this.specialty = 'Lead Cardiologist',
  });

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  // ═══════════════════════════════════════════════════════════════
  // HEALTHIFY GLASS DESIGN SYSTEM
  // ═══════════════════════════════════════════════════════════════

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  Color _background(bool isDark) {
    return isDark ? const Color(0xFF061817) : const Color(0xFFF3FAF9);
  }

  Color _surface(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.72);
  }

  Color _surfaceStrong(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.075)
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

  Widget _glassCard({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry? margin,
    double radius = 22,
    Color? accent,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.035),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          if (accent != null)
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.055 : 0.035),
              blurRadius: 24,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: accent != null
                    ? accent.withValues(alpha: isDark ? 0.22 : 0.18)
                    : _border(isDark),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _glassBackground({required bool isDark, required Widget child}) {
    return Container(
      color: _background(isDark),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withValues(alpha: isDark ? 0.055 : 0.045),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -110,
            child: IgnorePointer(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo.withValues(
                    alpha: isDark ? 0.035 : 0.025,
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════

  int _selectedNavIndex = 0;
  bool _isSidebarExpanded = true;

  DoctorAvailability _availabilityStatus = DoctorAvailability.available;

  late List<DoctorAppointmentModel> _appointments;
  late List<PatientQueueItemModel> _patientQueue;
  late List<DoctorEmergencyCaseModel> _emergencyCases;
  late List<PendingReportModel> _pendingReports;
  late AIPatientSummaryModel _aiSummary;
  late List<DoctorNotificationModel> _notifications;
  late DoctorAnalyticsModel _analytics;
  late DoctorAvailabilityConfig _availabilityConfig;

  // ═══════════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    _appointments = DoctorMockData.getAppointments();
    _patientQueue = DoctorMockData.getPatientQueue();
    _emergencyCases = DoctorMockData.getEmergencyCases();
    _pendingReports = DoctorMockData.getPendingReports();
    _aiSummary = DoctorMockData.getAISummary();
    _notifications = DoctorMockData.getNotifications();
    _analytics = DoctorMockData.getAnalytics();
    _availabilityConfig = DoctorMockData.getAvailabilityConfig();
  }

  // ═══════════════════════════════════════════════════════════════
  // THEME
  // ═══════════════════════════════════════════════════════════════

  void _toggleTheme() {
    setState(() {
      final isDark = themeNotifier.value == ThemeMode.dark;

      themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: _surfaceStrong(isDark),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: _border(isDark)),
          ),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out of the Doctor Portal?',
            style: TextStyle(color: _secondaryText(isDark)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: _primary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
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
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ROLE SWITCHER
  // ═══════════════════════════════════════════════════════════════

  void _showRoleSwitcherModal() {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDarkMode(context);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: _background(isDark)),
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
                  Expanded(
                    child: Text(
                      'HEALTHIFY Portal Switcher',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryText(isDark),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Switch your view between Patient, Doctor, and Hospital Administrator screens.',
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              _buildRoleTile(
                context: context,
                icon: Icons.person_rounded,
                title: 'Patient Portal',
                subtitle: 'Appointments, health records & queue tracking',
                color: _primary,
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
                subtitle: 'Current Active Portal • Clinical Workspace',
                color: _primary,
                isSelected: true,
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              _buildRoleTile(
                context: context,
                icon: Icons.local_hospital_rounded,
                title: 'Hospital Admin Portal',
                subtitle: 'Full hospital ops, beds, doctors & blood bank',
                color: Colors.indigo,
                isSelected: false,
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushReplacement(
                    context,
                    FadePageRoute(page: const MainDashboardScreen()),
                  );
                },
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

    return _glassCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      radius: 17,
      accent: isSelected ? color : null,
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
            color: isSelected ? color : _primaryText(isDark),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: _secondaryText(isDark)),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: color)
            : Icon(Icons.chevron_right_rounded, color: _secondaryText(isDark)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════

  void _showSearchModal() {
    final searchController = TextEditingController();

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
              Text(
                'Clinical Patient Search',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryText(isDark),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: searchController,
                autofocus: true,
                style: TextStyle(color: _primaryText(isDark)),
                decoration: GlassTextFieldTheme.getDecoration(
                  context: context,
                  hintText: 'Search by Patient Name, MRN, Phone number...',
                  prefixIcon: Icon(Icons.search_rounded, color: _primary),
                ),
              ),

              const SizedBox(height: 16),

              _glassCard(
                isDark: isDark,
                padding: EdgeInsets.zero,
                radius: 16,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: HealthifyGlassTheme.primaryTeal,
                    child: Text('R', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(
                    'Rahul Sharma (MRN-2026-8812)',
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Cardiology • Next in line (Token #01)',
                    style: TextStyle(color: _secondaryText(isDark)),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: _secondaryText(isDark),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    DoctorModals.showPatientProfileModal(
                      context: context,
                      patient: DoctorMockData.patientRahul,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final isDesktop = Responsive.isDesktop(context);

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    if (isDesktop) {
      return _buildDesktopLayout(isDark: isDark, unreadCount: unreadCount);
    }

    return _buildMobileLayout(isDark: isDark);
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDesktopLayout({required bool isDark, required int unreadCount}) {
    return Scaffold(
      backgroundColor: _background(isDark),
      body: _glassBackground(
        isDark: isDark,
        child: Row(
          children: [
            DoctorSidebar(
              selectedNavIndex: _selectedNavIndex,
              onNavItemSelected: (index) {
                setState(() {
                  _selectedNavIndex = index;
                });
              },
              isExpanded: _isSidebarExpanded,
              onToggleExpand: () {
                setState(() {
                  _isSidebarExpanded = !_isSidebarExpanded;
                });
              },
              availabilityStatus: _availabilityStatus,
              onLogout: _handleLogout,
              onRoleSwitcherTap: _showRoleSwitcherModal,
              doctorName: widget.doctorName,
              specialty: widget.specialty,
            ),

            Expanded(
              child: Column(
                children: [
                  // ─────────────────────────────────────
                  // HEADER
                  // ─────────────────────────────────────
                  DoctorHeader(
                    doctorName: widget.doctorName,
                    title: 'Doctor Dashboard',
                    subtitle: 'Clinical Overview & OPD Queue',
                    availabilityStatus: _availabilityStatus,
                    onAvailabilityChanged: (status) {
                      setState(() {
                        _availabilityStatus = status;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Status updated to ${status.name.toUpperCase()}',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _primary,
                        ),
                      );
                    },
                    onNotificationTap: () => DoctorModals.showNotificationsPane(
                      context: context,
                      notifications: _notifications,
                      onMarkAllRead: () {
                        setState(() {
                          _notifications = _notifications.map((n) {
                            return n.copyWith(isRead: true);
                          }).toList();
                        });

                        Navigator.pop(context);
                      },
                    ),
                    onSearchTap: _showSearchModal,
                    onProfileTap: _showRoleSwitcherModal,
                    onThemeToggle: _toggleTheme,
                    unreadNotificationsCount: unreadCount,
                  ),

                  // ─────────────────────────────────────
                  // CONTENT
                  // ─────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1600),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                clipBehavior: Clip.none,
                                children: [
                                  ...previousChildren,
                                  ?currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.03),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey<int>(_selectedNavIndex),
                              child: _buildDesktopViewContent(),
                            ),
                          ),
                        ),
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

  // ═══════════════════════════════════════════════════════════════
  // MOBILE / TABLET
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileLayout({required bool isDark}) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isCompactMobile = screenWidth < 420;

    Color statusDotColor() {
      switch (_availabilityStatus) {
        case DoctorAvailability.available:
          return const Color(0xFF10B981);

        case DoctorAvailability.busy:
          return Colors.amber.shade800;

        case DoctorAvailability.offline:
          return Colors.grey.shade600;
      }
    }

    return Scaffold(
      backgroundColor: _background(isDark),

      // ═══════════════════════════════════════════════
      // MOBILE APP BAR
      // ═══════════════════════════════════════════════
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 8,

        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(22),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: _surfaceStrong(isDark),
                border: Border(bottom: BorderSide(color: _border(isDark))),
              ),
            ),
          ),
        ),

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: isDark ? 0.14 : 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _primary.withValues(alpha: 0.18)),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: _primary,
                size: 18,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'HEALTHIFY',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _primary,
                        fontSize: 16,
                      ),
                    ),
                    if (!isCompactMobile)
                      TextSpan(
                        text: ' | Doctor',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _primaryText(isDark),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),

        actions: [
          InkWell(
            onTap: _showRoleSwitcherModal,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompactMobile ? 8 : 10,
                vertical: 5,
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: isDark ? 0.10 : 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: statusDotColor(),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons.medical_services_rounded,
                    size: 15,
                    color: _primary,
                  ),

                  if (!isCompactMobile) ...[
                    const SizedBox(width: 4),
                    const Text(
                      'DOCTOR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                  ],

                  const SizedBox(width: 2),

                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: _primary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),
        ],
      ),

      // ═══════════════════════════════════════════════
      // BODY
      // ═══════════════════════════════════════════════
      body: _glassBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedNavIndex >= 5) ...[
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedNavIndex = 4;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _primary.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: _primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Back to More Hub',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      ...previousChildren,
                      ?currentChild,
                    ],
                  );
                },
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_selectedNavIndex),
                  child: _buildNavContent(_selectedNavIndex, isMobile: true),
                ),
              ),
            ],
          ),
        ),
      ),

      // ═══════════════════════════════════════════════
      // BOTTOM NAVIGATION
      // ═══════════════════════════════════════════════
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: _surfaceStrong(isDark),
              border: Border(top: BorderSide(color: _border(isDark))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.035),
                  blurRadius: 25,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedNavIndex < 5 ? _selectedNavIndex : 4,
              onTap: (index) {
                setState(() {
                  _selectedNavIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: _primary,
              unselectedItemColor: _secondaryText(isDark),
              selectedFontSize: 11,
              unselectedFontSize: 10,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_rounded),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_rounded),
                  label: 'Patients',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.medical_services_rounded),
                  label: 'Care',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP & UNIFIED NAV CONTENT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDesktopViewContent() {
    return _buildNavContent(_selectedNavIndex, isMobile: false);
  }

  Widget _buildNavContent(int index, {required bool isMobile}) {
    switch (index) {
      case 0:
        return isMobile ? _buildMobileDashboardTab() : _buildMainDashboardTab();
      case 1:
        return const DoctorAppointmentsScreen(embedInDashboard: true);
      case 2:
        return const MyPatientsScreen(embedInDashboard: true);
      case 3:
        return const DoctorCareScreen(embedInDashboard: true);
      case 4:
        return DoctorMoreScreen(
          embedInDashboard: true,
          onSelectFeature: (featureIndex) {
            setState(() {
              _selectedNavIndex = featureIndex;
            });
          },
          availabilityStatus: _availabilityStatus,
          doctorName: widget.doctorName,
          specialty: widget.specialty,
        );
      case 5:
        return const DoctorAnalyticsScreen(embedInDashboard: true);
      case 6:
        return const DoctorReportsScreen(embedInDashboard: true);
      case 7:
        return const DoctorEmergencyCasesScreen(embedInDashboard: true);
      case 8:
        return const DoctorFollowUpsScreen(embedInDashboard: true);
      case 9:
        return const DoctorPrescriptionsScreen(embedInDashboard: true);
      case 10:
        return const DoctorNotificationsScreen(embedInDashboard: true);
      case 11:
        return const DoctorProfileSettingsScreen(embedInDashboard: true);
      case 12:
        return const DoctorHelpSupportScreen(embedInDashboard: true);
      default:
        return isMobile ? _buildMobileDashboardTab() : _buildMainDashboardTab();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // WELCOME BANNER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDashboardWelcomeBanner() {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final screenWidth = MediaQuery.of(context).size.width;

    final isMobile = screenWidth < 650;

    final hour = DateTime.now().hour;

    final String greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return _glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      radius: 22,
      accent: _primary,
      child: Row(
        children: [
          // Avatar
          Container(
            width: isMobile ? 48 : 58,
            height: isMobile ? 48 : 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [_primary, _primaryDark]),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: isDark ? 0.20 : 0.14),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.doctorName
                    .replaceFirst('Dr. ', '')
                    .characters
                    .first
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$greeting, ${widget.doctorName}',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                          color: _primaryText(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('👋', style: TextStyle(fontSize: 20)),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  '${widget.specialty} • OPD Room 402 • 18 Patients Scheduled Today',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13.5,
                    fontWeight: FontWeight.w500,
                    color: _secondaryText(isDark),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          if (!isMobile) ...[
            const SizedBox(width: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: isDark ? 0.10 : 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _primary.withValues(alpha: 0.22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: _primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Friday, Oct 2, 2026',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _primaryText(isDark),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'Morning OPD • 09:00 AM - 01:00 PM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MAIN DASHBOARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMainDashboardTab() {
    final nextAppointment = _appointments.firstWhere(
      (a) => a.isNextUpcoming,
      orElse: () => _appointments.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDashboardWelcomeBanner(),

        DoctorQuickOverviewCards(
          totalAppointments: _appointments.length,
          completedAppointments: _appointments
              .where((a) => a.status == AppointmentStatus.completed)
              .length,
          upcomingAppointments: _appointments
              .where(
                (a) =>
                    a.status == AppointmentStatus.upcoming ||
                    a.status == AppointmentStatus.waiting,
              )
              .length,
          totalPatients: 18,
          newPatients: 4,
          followUpPatients: 8,
          pendingReports: _pendingReports.where((r) => !r.isReviewed).length,
          urgentReports: _pendingReports
              .where(
                (r) => r.priority == ReportPriority.urgent && !r.isReviewed,
              )
              .length,
          emergencyCount: _emergencyCases.length,
          criticalEmergencyCount: _emergencyCases
              .where((e) => e.severity == EmergencySeverity.critical)
              .length,
          followUpsToday: 6,
          onCardTap: (navIndex) {
            setState(() {
              _selectedNavIndex = navIndex;
            });
          },
        ),

        const SizedBox(height: 20),

        DoctorQuickActionsBar(
          onStartConsultation: () => DoctorModals.showStartConsultationModal(
            context: context,
            appointment: nextAppointment,
            onConsultationCompleted: () =>
                _markAppointmentCompleted(nextAppointment),
          ),
          onAddPatientNote: _showAddNoteDialog,
          onWritePrescription: _showWritePrescriptionDialog,
          onReviewReports: () {
            setState(() {
              _selectedNavIndex = 4;
            });
          },
          onViewSchedule: () {
            setState(() {
              _selectedNavIndex = 1;
            });
          },
        ),

        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════
            // LEFT COLUMN
            // ═══════════════════════════════
            Expanded(
              flex: 62,
              child: Column(
                children: [
                  NextPatientHeroCard(
                    appointment: nextAppointment,
                    onStartConsultation: () =>
                        DoctorModals.showStartConsultationModal(
                          context: context,
                          appointment: nextAppointment,
                          onConsultationCompleted: () =>
                              _markAppointmentCompleted(nextAppointment),
                        ),
                    onViewMedicalHistory: () =>
                        DoctorModals.showPatientProfileModal(
                          context: context,
                          patient: nextAppointment.patient,
                        ),
                  ),

                  const SizedBox(height: 20),

                  TodayAppointmentsSection(
                    appointments: _appointments,
                    onStartConsultation: (apt) =>
                        DoctorModals.showStartConsultationModal(
                          context: context,
                          appointment: apt,
                          onConsultationCompleted: () =>
                              _markAppointmentCompleted(apt),
                        ),
                    onViewPatient: (apt) =>
                        DoctorModals.showPatientProfileModal(
                          context: context,
                          patient: apt.patient,
                        ),
                    onReschedule: (apt) => DoctorModals.showRescheduleModal(
                      context: context,
                      appointment: apt,
                      onRescheduled: (newSlot) =>
                          _rescheduleAppointment(apt, newSlot),
                    ),
                    onMarkCompleted: (apt) => _markAppointmentCompleted(apt),
                    onViewAll: () {
                      setState(() {
                        _selectedNavIndex = 1;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  PendingReportsWidget(
                    reports: _pendingReports,
                    onReviewReport: (report) =>
                        DoctorModals.showReviewReportModal(
                          context: context,
                          report: report,
                          onReportReviewed: (notes) {
                            setState(() {
                              _pendingReports = _pendingReports.map((r) {
                                return r.id == report.id
                                    ? r.copyWith(
                                        isReviewed: true,
                                        clinicalNotes: notes,
                                      )
                                    : r;
                              }).toList();
                            });
                          },
                        ),
                  ),

                  const SizedBox(height: 20),

                  EmergencyCasesWidget(
                    emergencyCases: _emergencyCases,
                    onViewPatient: (item) =>
                        DoctorModals.showPatientProfileModal(
                          context: context,
                          patient: item.patient,
                        ),
                    onOpenMedicalRecord: (item) =>
                        DoctorModals.showPatientProfileModal(
                          context: context,
                          patient: item.patient,
                        ),
                  ),

                  const SizedBox(height: 20),

                  DoctorAnalyticsWidget(analytics: _analytics),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // ═══════════════════════════════
            // RIGHT COLUMN
            // ═══════════════════════════════
            Expanded(
              flex: 38,
              child: Column(
                children: [
                  PatientQueueWidget(
                    queue: _patientQueue,
                    onCallNext: (queueItem) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Calling ${queueItem.patient.name} to Consultation Room 1',
                          ),
                          backgroundColor: _primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onViewPatient: (queueItem) =>
                        DoctorModals.showPatientProfileModal(
                          context: context,
                          patient: queueItem.patient,
                        ),
                  ),

                  const SizedBox(height: 20),

                  AIPatientSummaryWidget(
                    aiSummary: _aiSummary,
                    onViewFullSummary: () =>
                        DoctorModals.showPatientProfileModal(
                          context: context,
                          patient: _aiSummary.patient,
                        ),
                  ),

                  const SizedBox(height: 20),

                  DoctorAvailabilityCard(
                    config: _availabilityConfig,
                    onStatusChanged: (status) {
                      setState(() {
                        _availabilityStatus = status;
                      });
                    },
                    onConfigureHours: () =>
                        DoctorModals.showConfigureHoursModal(
                          context: context,
                          currentConfig: _availabilityConfig,
                          onSave: (newConfig) {
                            setState(() {
                              _availabilityConfig = newConfig;
                            });
                          },
                        ),
                  ),

                  const SizedBox(height: 20),

                  RecentPatientsWidget(
                    patients: [
                      DoctorMockData.patientRahul,
                      DoctorMockData.patientPriya,
                      DoctorMockData.patientAmit,
                      DoctorMockData.patientNeha,
                      DoctorMockData.patientRajesh,
                    ],
                    onPatientTap: (patient) =>
                        DoctorModals.showPatientProfileModal(
                          context: context,
                          patient: patient,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE DASHBOARD TAB
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileDashboardTab() {
    final nextAppointment = _appointments.firstWhere(
      (a) => a.isNextUpcoming,
      orElse: () => _appointments.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDashboardWelcomeBanner(),

        NextPatientHeroCard(
          appointment: nextAppointment,
          onStartConsultation: () => DoctorModals.showStartConsultationModal(
            context: context,
            appointment: nextAppointment,
            onConsultationCompleted: () =>
                _markAppointmentCompleted(nextAppointment),
          ),
          onViewMedicalHistory: () => DoctorModals.showPatientProfileModal(
            context: context,
            patient: nextAppointment.patient,
          ),
        ),

        const SizedBox(height: 16),

        DoctorQuickOverviewCards(
          totalAppointments: _appointments.length,
          completedAppointments: _appointments
              .where((a) => a.status == AppointmentStatus.completed)
              .length,
          upcomingAppointments: _appointments
              .where(
                (a) =>
                    a.status == AppointmentStatus.upcoming ||
                    a.status == AppointmentStatus.waiting,
              )
              .length,
          totalPatients: 18,
          newPatients: 4,
          followUpPatients: 8,
          pendingReports: _pendingReports.where((r) => !r.isReviewed).length,
          urgentReports: _pendingReports
              .where(
                (r) => r.priority == ReportPriority.urgent && !r.isReviewed,
              )
              .length,
          emergencyCount: _emergencyCases.length,
          criticalEmergencyCount: _emergencyCases
              .where((e) => e.severity == EmergencySeverity.critical)
              .length,
          followUpsToday: 6,
          onCardTap: (index) {
            setState(() {
              _selectedNavIndex = index;
            });
          },
        ),

        const SizedBox(height: 16),

        DoctorQuickActionsBar(
          onStartConsultation: () => DoctorModals.showStartConsultationModal(
            context: context,
            appointment: nextAppointment,
            onConsultationCompleted: () =>
                _markAppointmentCompleted(nextAppointment),
          ),
          onAddPatientNote: _showAddNoteDialog,
          onWritePrescription: _showWritePrescriptionDialog,
          onReviewReports: () {
            setState(() {
              _selectedNavIndex = 6;
            });
          },
          onViewSchedule: () {
            setState(() {
              _selectedNavIndex = 1;
            });
          },
        ),

        const SizedBox(height: 16),

        PatientQueueWidget(
          queue: _patientQueue,
          onCallNext: (q) {},
          onViewPatient: (q) => DoctorModals.showPatientProfileModal(
            context: context,
            patient: q.patient,
          ),
        ),

        const SizedBox(height: 16),

        AIPatientSummaryWidget(
          aiSummary: _aiSummary,
          onViewFullSummary: () => DoctorModals.showPatientProfileModal(
            context: context,
            patient: _aiSummary.patient,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // APPOINTMENT
  // ═══════════════════════════════════════════════════════════════

  void _markAppointmentCompleted(DoctorAppointmentModel appointment) {
    setState(() {
      _appointments = _appointments.map((a) {
        if (a.id == appointment.id) {
          return a.copyWith(status: AppointmentStatus.completed);
        }

        return a;
      }).toList();
    });
  }

  void _rescheduleAppointment(
      DoctorAppointmentModel appointment, String newSlot) {
    setState(() {
      _appointments = _appointments.map((a) {
        if (a.id == appointment.id) {
          return a.copyWith(
            appointmentTime: newSlot,
            status: AppointmentStatus.upcoming,
          );
        }

        return a;
      }).toList();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // ADD CLINICAL NOTE
  // ═══════════════════════════════════════════════════════════════

  void _showAddNoteDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: _surfaceStrong(isDark),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: _border(isDark)),
          ),
          title: Text(
            'Add Clinical Note',
            style: TextStyle(color: _primaryText(isDark)),
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            style: TextStyle(color: _primaryText(isDark)),
            decoration: InputDecoration(
              hintText: 'Enter clinical observations or notes...',
              hintStyle: TextStyle(color: _secondaryText(isDark)),
              filled: true,
              fillColor: _surface(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _border(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _border(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Clinical Note saved to EHR.'),
                    backgroundColor: _primary,
                  ),
                );
              },
              child: const Text('Save Note'),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PRESCRIPTION
  // ═══════════════════════════════════════════════════════════════

  void _showWritePrescriptionDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: _surfaceStrong(isDark),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: _border(isDark)),
          ),
          title: Text(
            'Write E-Prescription',
            style: TextStyle(color: _primaryText(isDark)),
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            style: TextStyle(color: _primaryText(isDark)),
            decoration: InputDecoration(
              hintText: 'Enter medication details, dosage & duration...',
              hintStyle: TextStyle(color: _secondaryText(isDark)),
              filled: true,
              fillColor: _surface(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _border(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _border(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'E-Prescription generated & sent to pharmacy.',
                    ),
                    backgroundColor: _primary,
                  ),
                );
              },
              child: const Text('Generate Prescription'),
            ),
          ],
        );
      },
    );
  }
}
