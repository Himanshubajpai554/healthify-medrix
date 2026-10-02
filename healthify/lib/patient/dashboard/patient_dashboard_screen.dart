import 'dart:ui';

import 'package:flutter/material.dart';
import '../../auth/login/login_screen.dart';
import '../../auth/patient/patient_profile_setup_screen.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../hospital/dashboard/main_dashboard_screen.dart';
import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../utils/page_transitions.dart';
import '../appointments/book_appointment_modal.dart';
import '../doctors/doctor_finder_widget.dart';
import '../emergency/emergency_hospitals_modal.dart';
import '../hospitals/hospital_finder_widget.dart';
import '../appointments/patient_appointments_widget.dart';
import '../beds/patient_bed_discovery_widget.dart';
import '../blood/patient_blood_discovery_widget.dart';
import '../reports/patient_reports_widget.dart';
import '../symptom_checker/symptom_checker_widget.dart';

class PatientDashboardScreen extends StatefulWidget {
  final String patientName;
  final String patientId;

  const PatientDashboardScreen({
    super.key,
    this.patientName = 'Alex Rivera',
    this.patientId = 'PAT-8842',
  });

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedTab = 0;
  bool _isSidebarCollapsed = false;
  bool _isInspectorOpen = false;
  String _inspectorTitle = 'Details Inspector';
  String? _inspectorSubtitle;
  IconData _inspectorIcon = Icons.info_outline_rounded;
  Widget? _inspectorContent;

  void openInspector({
    required String title,
    String? subtitle,
    required IconData icon,
    required Widget content,
  }) {
    setState(() {
      _inspectorTitle = title;
      _inspectorSubtitle = subtitle;
      _inspectorIcon = icon;
      _inspectorContent = content;
      _isInspectorOpen = true;
    });
  }

  void closeInspector() {
    setState(() {
      _isInspectorOpen = false;
    });
  }

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  Color _background(bool isDark) =>
      isDark ? const Color(0xFF061817) : const Color(0xFFF3FAF9);

  Color _surface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.045)
      : Colors.white.withValues(alpha: 0.72);

  Color _surfaceStrong(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.075)
      : Colors.white.withValues(alpha: 0.90);

  Color _border(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.075)
      : Colors.white.withValues(alpha: 0.88);

  Color _primaryText(bool isDark) =>
      isDark ? Colors.white : AppTheme.textPrimary;

  Color _secondaryText(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.textSecondary;

  Widget _glassCard({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 22,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _border(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.035),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      final isDark = themeNotifier.value == ThemeMode.dark;
      themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _showRoleSwitcherModal() {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) {
        final isDark = HealthifyGlassTheme.isDark(context);
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppTheme.primaryColor,
                    size: 28,
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
                icon: Icons.person_rounded,
                title: 'Patient Portal',
                subtitle: 'Current Active Portal',
                color: Colors.teal,
                isSelected: true,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              _buildRoleTile(
                icon: Icons.medical_services_rounded,
                title: 'Doctor Portal',
                subtitle: 'View doctor schedule, rounds & patient queue',
                color: Colors.indigo,
                isSelected: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/doctor');
                },
              ),
              const SizedBox(height: 10),
              _buildRoleTile(
                icon: Icons.local_hospital_rounded,
                title: 'Hospital Admin Portal',
                subtitle: 'Full hospital ops, beds, doctors & blood bank',
                color: AppTheme.primaryColor,
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
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    final textPrimary = _primaryText(isDark);
    final textSecondary = _secondaryText(isDark);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.14 : 0.10)
              : _surface(isDark),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.65)
                      : _border(isDark),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.16 : 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : textPrimary,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: color)
                    : Icon(Icons.chevron_right_rounded, color: textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (!isMobile) {
      return Scaffold(
        backgroundColor: _background(isDark),
        body: AnimatedPulseBackground(
          child: Stack(
            children: [
              Row(
                children: [
                  _buildDesktopSidebarNav(isDark, screenWidth),
                  Expanded(
                    child: Column(
                      children: [
                        _buildDesktopHeaderBar(isDark),
                        Expanded(
                          child: RepaintBoundary(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(
                                screenWidth >= 1024 ? 28 : 18,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1600,
                                  ),
                                  child: _buildSelectedTabContent(),
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
              GlassSideInspectorPane(
                isOpen: _isInspectorOpen,
                onClose: () => setState(() => _isInspectorOpen = false),
                title: _inspectorTitle,
                subtitle: _inspectorSubtitle,
                icon: _inspectorIcon,
                child: _inspectorContent ?? const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    final isCompact = screenWidth < 420;

    return Scaffold(
      backgroundColor: _background(isDark),
      drawer: _buildSideDrawer(isDark),
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: isDark ? 0.14 : 0.11),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _primary.withValues(alpha: 0.12)),
              ),
              child: const Icon(
                Icons.healing_rounded,
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
                    if (!isCompact)
                      TextSpan(
                        text: ' | Patient',
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
                horizontal: isCompact ? 8 : 10,
                vertical: 5,
              ),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: isDark ? 0.10 : 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_rounded, size: 15, color: _primary),
                  if (!isCompact) ...[
                    const SizedBox(width: 4),
                    const Text(
                      'PATIENT',
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
      body: AnimatedPulseBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _buildSelectedTabContent(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
    );
  }

  Widget _buildDesktopHeaderBar(bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            border: Border(bottom: BorderSide(color: _border(isDark))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getTabTitle(_selectedTab),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryText(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      // Emergency Quick Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => EmergencyHospitalsModal.show(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 16,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '24/7 ER Assist',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Persona Switcher Pill
                      InkWell(
                        onTap: _showRoleSwitcherModal,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _primary.withValues(
                              alpha: isDark ? 0.14 : 0.10,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person_rounded,
                                size: 16,
                                color: _primary,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'PATIENT PORTAL',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: _primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 18,
                                color: _primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Theme Toggle
                      IconButton(
                        icon: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: _primaryText(isDark),
                        ),
                        tooltip: isDark
                            ? 'Switch to Light Mode'
                            : 'Switch to Dark Mode',
                        onPressed: _toggleTheme,
                      ),

                      const SizedBox(width: 6),

                      // User Profile Shortcut
                      InkWell(
                        onTap: () => setState(() => _selectedTab = 6),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _surface(isDark),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedTab == 6
                                  ? _primary
                                  : _border(isDark),
                              width: _selectedTab == 6 ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: _primary,
                                child: Text(
                                  widget.patientName.isNotEmpty
                                      ? widget.patientName[0]
                                      : 'A',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.patientName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryText(isDark),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTabTitle(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Nearby Hospitals & ICU Beds';
      case 1:
        return 'Find & Book Specialist Doctors';
      case 2:
        return 'My Consultations & Appointments';
      case 3:
        return 'Medical Reports & Health Records';
      case 4:
        return 'AI Triage & Symptom Checker';
      case 5:
        return 'Hospital Bed Availability Discovery';
      case 6:
        return 'Patient Health Profile & Vitals';
      case 7:
        return 'Blood Bank Stock & Donor Directory';
      default:
        return 'Patient Care Portal';
    }
  }

  Widget _buildDesktopSidebarNav(bool isDark, double screenWidth) {
    final isExpanded = screenWidth >= 1024 && !_isSidebarCollapsed;
    final width = isExpanded ? 260.0 : 76.0;

    final navItems = [
      _DesktopNavItem(
        index: 0,
        title: 'Hospitals',
        icon: Icons.domain_rounded,
        category: 'DISCOVER',
      ),
      _DesktopNavItem(
        index: 1,
        title: 'Doctors',
        icon: Icons.medical_services_rounded,
        category: 'DISCOVER',
      ),
      _DesktopNavItem(
        index: 2,
        title: 'Appointments',
        icon: Icons.calendar_month_rounded,
        category: 'CARE',
      ),
      _DesktopNavItem(
        index: 4,
        title: 'AI Symptom Checker',
        icon: Icons.psychology_rounded,
        category: 'CARE',
      ),
      _DesktopNavItem(
        index: 3,
        title: 'Medical Reports',
        icon: Icons.folder_shared_rounded,
        category: 'RECORDS',
      ),
      _DesktopNavItem(
        index: 5,
        title: 'Bed Availability',
        icon: Icons.king_bed_rounded,
        category: 'EMERGENCY',
      ),
      _DesktopNavItem(
        index: 7,
        title: 'Blood Bank',
        icon: Icons.bloodtype_rounded,
        category: 'EMERGENCY',
      ),
      _DesktopNavItem(
        index: 6,
        title: 'Health Profile',
        icon: Icons.account_circle_rounded,
        category: 'RECORDS',
      ),
    ];

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF071A19) : const Color(0xFFF4FAF9),
          border: Border(right: BorderSide(color: _border(isDark))),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo & Collapse Toggle Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: isExpanded
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _primary.withValues(
                                alpha: isDark ? 0.16 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.healing_rounded,
                              color: _primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'HEALTHIFY',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: _primary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Patient Portal',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: _secondaryText(isDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          if (screenWidth >= 1024)
                            IconButton(
                              icon: Icon(
                                _isSidebarCollapsed
                                    ? Icons.chevron_right_rounded
                                    : Icons.chevron_left_rounded,
                                color: _secondaryText(isDark),
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () =>
                                    _isSidebarCollapsed = !_isSidebarCollapsed,
                              ),
                              tooltip: 'Collapse Sidebar',
                            ),
                        ],
                      ),
                    )
                  : Tooltip(
                      message: 'Expand Sidebar',
                      child: InkWell(
                        onTap: () => setState(
                          () => _isSidebarCollapsed = !_isSidebarCollapsed,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primary.withValues(
                              alpha: isDark ? 0.16 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.healing_rounded,
                            color: _primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Navigation items list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: navItems.length,
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  final isSelected = _selectedTab == item.index;

                  if (!isExpanded) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Tooltip(
                        message: item.title,
                        child: InkWell(
                          onTap: () =>
                              setState(() => _selectedTab = item.index),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _primary.withValues(
                                      alpha: isDark ? 0.2 : 0.12,
                                    )
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(
                                      color: _primary.withValues(alpha: 0.3),
                                    )
                                  : null,
                            ),
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? _primary
                                  : _secondaryText(isDark),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = item.index),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _primary.withValues(alpha: isDark ? 0.2 : 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? Border.all(
                                  color: _primary.withValues(alpha: 0.35),
                                )
                              : null,
                        ),
                        child: ClipRect(
                          child: SizedBox(
                            width: 212,
                            child: Row(
                              children: [
                                Icon(
                                  item.icon,
                                  color: isSelected
                                      ? _primary
                                      : _secondaryText(isDark),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? _primary
                                          : _primaryText(isDark),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: _primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_in_talk_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ER Hotline',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                                color: Colors.redAccent,
                              ),
                            ),
                            Text(
                              '108 / 112 Active',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    const primary = Color(0xFF0D9488);
    const primaryDark = Color(0xFF0F766E);

    final Color textPrimary = isDark ? Colors.white : AppTheme.textPrimary;

    final Color textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppTheme.textSecondary;

    final Color glassBackground = isDark
        ? Colors.white.withValues(alpha: 0.055)
        : Colors.white.withValues(alpha: 0.78);

    final Color glassBorder = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : Colors.white.withValues(alpha: 0.90);

    final int currentIndex = _selectedTab < 4 ? _selectedTab : 0;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            decoration: BoxDecoration(
              color: glassBackground,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: glassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: primary.withValues(alpha: isDark ? 0.07 : 0.045),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _bottomNavItem(
                    index: 0,
                    currentIndex: currentIndex,
                    icon: Icons.domain_outlined,
                    selectedIcon: Icons.domain_rounded,
                    label: 'Hospitals',
                    primary: primary,
                    primaryDark: primaryDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () {
                      setState(() {
                        _selectedTab = 0;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: _bottomNavItem(
                    index: 1,
                    currentIndex: currentIndex,
                    icon: Icons.medical_services_outlined,
                    selectedIcon: Icons.medical_services_rounded,
                    label: 'Doctors',
                    primary: primary,
                    primaryDark: primaryDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () {
                      setState(() {
                        _selectedTab = 1;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: _bottomNavItem(
                    index: 2,
                    currentIndex: currentIndex,
                    icon: Icons.calendar_today_outlined,
                    selectedIcon: Icons.calendar_month_rounded,
                    label: 'Appointments',
                    primary: primary,
                    primaryDark: primaryDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () {
                      setState(() {
                        _selectedTab = 2;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: _bottomNavItem(
                    index: 3,
                    currentIndex: currentIndex,
                    icon: Icons.folder_shared_outlined,
                    selectedIcon: Icons.folder_shared_rounded,
                    label: 'Reports',
                    primary: primary,
                    primaryDark: primaryDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () {
                      setState(() {
                        _selectedTab = 3;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required Color primary,
    required Color primaryDark,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    final bool selected = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: selected ? 1 : 0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Container(
            height: 58,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ==========================================================
                // ACTIVE GLASS PILL
                // ==========================================================
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    gradient: selected
                        ? LinearGradient(
                            colors: [
                              primary.withValues(alpha: 0.16 + (value * 0.04)),
                              primary.withValues(alpha: 0.055),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: selected
                        ? Border.all(color: primary.withValues(alpha: 0.16))
                        : null,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.12 * value),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                ),

                // ==========================================================
                // CONTENT
                // ==========================================================
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ------------------------------------------------------
                    // ICON
                    // ------------------------------------------------------
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: selected ? 1 : 0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: 1 + (scale * 0.08),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 34,
                            height: 30,
                            decoration: BoxDecoration(
                              color: selected
                                  ? primary.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              selected ? selectedIcon : icon,
                              size: 21,
                              color: selected ? primary : textSecondary,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 2),

                    // ------------------------------------------------------
                    // LABEL
                    // ------------------------------------------------------
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontSize: selected ? 10.5 : 10,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: selected ? primary : textSecondary,
                        letterSpacing: -0.05,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // ==========================================================
                // ACTIVE INDICATOR
                // ==========================================================
                Positioned(
                  bottom: 2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    width: selected ? 20 : 0,
                    height: selected ? 3 : 0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [primary, primaryDark]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.45),
                                blurRadius: 7,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSideDrawer(bool isDark) {
    final Color primary = const Color(0xFF0D9488);
    final Color primaryDark = const Color(0xFF0F766E);

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
            // ------------------------------------------------------------
            // BACKGROUND GLOW 1
            // ------------------------------------------------------------
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

            // ------------------------------------------------------------
            // BACKGROUND GLOW 2
            // ------------------------------------------------------------
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

            // ------------------------------------------------------------
            // BLUR THE BACKGROUND
            // ------------------------------------------------------------
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

            // ------------------------------------------------------------
            // MAIN CONTENT
            // ------------------------------------------------------------
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                physics: const BouncingScrollPhysics(),
                children: [
                  // ========================================================
                  // HEALTHIFY BRAND
                  // ========================================================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
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
                              'Your health, simplified.',
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

                  // ========================================================
                  // PATIENT PROFILE GLASS CARD
                  // ========================================================
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withValues(alpha: 0.92),
                              primaryDark.withValues(alpha: 0.90),
                            ],
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
                                  child: Center(
                                    child: Text(
                                      widget.patientName.isNotEmpty
                                          ? widget.patientName[0].toUpperCase()
                                          : 'A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
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
                                        widget.patientName.isNotEmpty
                                            ? widget.patientName
                                            : 'Patient',
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
                                        child: Text(
                                          'ID • ${widget.patientId}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
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

                  // ========================================================
                  // SECTION TITLE
                  // ========================================================
                  _drawerSectionTitle('MAIN NAVIGATION', textSecondary),

                  const SizedBox(height: 7),

                  // ========================================================
                  // MAIN NAVIGATION GLASS GROUP
                  // ========================================================
                  _drawerGlassGroup(
                    isDark: isDark,
                    glassColor: glassColor,
                    glassBorder: glassBorder,
                    children: [
                      _animatedDrawerItem(
                        icon: Icons.domain_rounded,
                        title: 'Hospitals',
                        index: 0,
                        selected: _selectedTab == 0,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTab = 0);
                        },
                      ),

                      _animatedDrawerItem(
                        icon: Icons.medical_services_rounded,
                        title: 'Doctors',
                        index: 1,
                        selected: _selectedTab == 1,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTab = 1);
                        },
                      ),

                      _animatedDrawerItem(
                        icon: Icons.calendar_month_rounded,
                        title: 'Appointments',
                        index: 2,
                        selected: _selectedTab == 2,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTab = 2);
                        },
                      ),

                      _animatedDrawerItem(
                        icon: Icons.folder_shared_rounded,
                        title: 'Reports',
                        index: 3,
                        selected: _selectedTab == 3,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTab = 3);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ========================================================
                  // HEALTHCARE SERVICES
                  // ========================================================
                  _drawerSectionTitle('HEALTHCARE SERVICES', textSecondary),

                  const SizedBox(height: 7),

                  _drawerGlassGroup(
                    isDark: isDark,
                    glassColor: glassColor,
                    glassBorder: glassBorder,
                    children: [
                      _animatedDrawerItem(
                        icon: Icons.psychology_rounded,
                        title: 'AI Triage & Symptom Checker',
                        index: 4,
                        selected: _selectedTab == 4,
                        iconColor: Colors.deepPurple,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTab = 4);
                        },
                      ),

                      _animatedDrawerItem(
                        icon: Icons.king_bed_rounded,
                        title: 'Hospital Bed Availability',
                        index: 5,
                        selected: _selectedTab == 5,
                        iconColor: Colors.indigo,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTab = 5);
                        },
                      ),

                      _animatedDrawerItem(
                        icon: Icons.bloodtype_rounded,
                        title: 'Blood Bank & Stock',
                        index: 7,
                        selected: _selectedTab == 7,
                        iconColor: Colors.red,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTab = 7);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ========================================================
                  // EMERGENCY BUTTON
                  // ========================================================
                  _emergencyDrawerButton(
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);
                      EmergencyHospitalsModal.show(context);
                    },
                  ),

                  const SizedBox(height: 22),

                  // ========================================================
                  // ACCOUNT
                  // ========================================================
                  _drawerSectionTitle('ACCOUNT & PREFERENCES', textSecondary),

                  const SizedBox(height: 7),

                  _drawerGlassGroup(
                    isDark: isDark,
                    glassColor: glassColor,
                    glassBorder: glassBorder,
                    children: [
                      _animatedDrawerItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Profile & Health Details',
                        index: 6,
                        selected: _selectedTab == 6,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedTab = 6);
                        },
                      ),

                      _animatedDrawerItem(
                        icon: Icons.swap_horiz_rounded,
                        title: 'Switch Portal / Persona',
                        index: 99,
                        selected: false,
                        iconColor: primary,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                          _showRoleSwitcherModal();
                        },
                      ),

                      // ----------------------------------------------------
                      // DARK MODE
                      // ----------------------------------------------------
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
                                transitionBuilder: (child, animation) {
                                  return RotationTransition(
                                    turns: Tween<double>(
                                      begin: 0.7,
                                      end: 1,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
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

                  // ========================================================
                  // LOGOUT
                  // ========================================================
                  _logoutDrawerButton(
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.pushAndRemoveUntil(
                        context,
                        FadePageRoute(page: const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ========================================================
                  // VERSION
                  // ========================================================
                  Center(
                    child: Text(
                      'HEALTHIFY • PATIENT PORTAL',
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

  Widget _drawerSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488),
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

  Widget _drawerGlassGroup({
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

  Widget _animatedDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required bool selected,
    required Color iconColor,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
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
              onTap: onTap,
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

  Widget _emergencyDrawerButton({
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
                                    alpha: 0.13,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                  size: 21,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency ER Assist',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Find emergency care nearby',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.redAccent,
                          size: 14,
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

  Widget _logoutDrawerButton({
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: Colors.redAccent.withValues(alpha: isDark ? 0.055 : 0.035),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withValues(alpha: 0.10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 19,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Colors.redAccent.withValues(alpha: 0.65),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalCard({
    required String title,
    required String value,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return _glassCard(
      isDark: isDark,
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: _secondaryText(isDark)),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.12 : 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: _primaryText(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_selectedTab) {
      case 0:
        return const HospitalFinderWidget();
      case 1:
        return DoctorFinderWidget(
          onBookingSuccess: (msg) {
            setState(() => _selectedTab = 2);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: _primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      case 2:
        return _buildAppointmentsTab();
      case 3:
        return _buildRecordsTab();
      case 4:
        return SymptomCheckerWidget(
          onBookingSuccess: (msg) {
            setState(() => _selectedTab = 2);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: _primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      case 5:
        return const PatientBedDiscoveryWidget();
      case 6:
        return _buildProfileTab();
      case 7:
        return const PatientBloodDiscoveryWidget();
      default:
        return const HospitalFinderWidget();
    }
  }

  Widget _buildProfileTab() {
    final isDark = themeNotifier.value == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _glassCard(
          isDark: isDark,
          radius: 24,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_primary, _primaryDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.patientName.isNotEmpty
                        ? widget.patientName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patientName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _primaryText(isDark),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'ID: ${widget.patientId} • Male • 32 Yrs',
                      style: TextStyle(
                        fontSize: 13,
                        color: _secondaryText(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    FadePageRoute(page: const PatientProfileSetupScreen()),
                  );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: _primary,
                ),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildWelcomeHeaderCard(),
        const SizedBox(height: 20),
        _buildPatientVitalsBar(),
        const SizedBox(height: 20),
        _glassCard(
          isDark: isDark,
          radius: 22,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal & Emergency Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _primaryText(isDark),
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileDetailRow(
                Icons.phone_outlined,
                'Phone',
                '+91 98765 43210',
              ),
              const SizedBox(height: 12),
              _buildProfileDetailRow(
                Icons.contact_emergency_outlined,
                'Emergency Contact',
                'Sarah Rivera (+91 98765 11111)',
              ),
              const SizedBox(height: 12),
              _buildProfileDetailRow(
                Icons.warning_amber_outlined,
                'Known Allergies',
                'Penicillin, Dust Mites',
              ),
              const SizedBox(height: 12),
              _buildProfileDetailRow(
                Icons.healing_outlined,
                'Chronic Conditions',
                'Mild Asthma',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeaderCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.22),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.favorite_rounded,
                  size: 160,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 8,
                    spacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Text(
                          'Patient ID: ${widget.patientId}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                EmergencyHospitalsModal.show(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              '🚨 Emergency ER Assist',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              BookAppointmentModal.show(
                                context,
                                onSuccess: (msg) {
                                  setState(() => _selectedTab = 2);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(msg),
                                      backgroundColor: _primary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.94,
                              ),
                              foregroundColor: _primaryDark,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'Book Appointment',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Hello, ${widget.patientName} 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your next appointment with Dr. Sarah Jenkins (Cardiology) is today at 10:30 AM.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientVitalsBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 800) {
          return Row(
            children: [
              Expanded(
                child: _buildVitalCard(
                  title: 'Heart Rate',
                  value: '72 bpm',
                  status: 'Normal',
                  icon: Icons.favorite_rounded,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  title: 'Blood Pressure',
                  value: '120/80',
                  status: 'Optimal',
                  icon: Icons.speed_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  title: 'Blood Type',
                  value: 'O+',
                  status: 'Universal Donor',
                  icon: Icons.bloodtype_rounded,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  title: 'OPD Queue',
                  value: '#18',
                  status: '2 Ahead',
                  icon: Icons.confirmation_number_rounded,
                  color: Colors.orange,
                ),
              ),
            ],
          );
        } else if (width >= 480) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildVitalCard(
                      title: 'Heart Rate',
                      value: '72 bpm',
                      status: 'Normal',
                      icon: Icons.favorite_rounded,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVitalCard(
                      title: 'Blood Pressure',
                      value: '120/80',
                      status: 'Optimal',
                      icon: Icons.speed_rounded,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildVitalCard(
                      title: 'Blood Type',
                      value: 'O+',
                      status: 'Universal Donor',
                      icon: Icons.bloodtype_rounded,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVitalCard(
                      title: 'OPD Queue',
                      value: '#18',
                      status: '2 Ahead',
                      icon: Icons.confirmation_number_rounded,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildVitalCard(
                title: 'Heart Rate',
                value: '72 bpm',
                status: 'Normal',
                icon: Icons.favorite_rounded,
                color: Colors.red,
              ),
              const SizedBox(height: 10),
              _buildVitalCard(
                title: 'Blood Pressure',
                value: '120/80',
                status: 'Optimal',
                icon: Icons.speed_rounded,
                color: Colors.blue,
              ),
              const SizedBox(height: 10),
              _buildVitalCard(
                title: 'Blood Type',
                value: 'O+',
                status: 'Universal Donor',
                icon: Icons.bloodtype_rounded,
                color: Colors.pink,
              ),
              const SizedBox(height: 10),
              _buildVitalCard(
                title: 'OPD Queue',
                value: '#18',
                status: '2 Ahead',
                icon: Icons.confirmation_number_rounded,
                color: Colors.orange,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: _primary),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _secondaryText(isDark),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _primaryText(isDark),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsTab() {
    return PatientAppointmentsWidget(
      onFindDoctorTap: () => setState(() => _selectedTab = 1),
      onFindHospitalTap: () => setState(() => _selectedTab = 0),
    );
  }

  Widget _buildRecordsTab() {
    return PatientReportsWidget(
      onFindHospitalTap: () => setState(() => _selectedTab = 0),
    );
  }
}

class _DesktopNavItem {
  final int index;
  final String title;
  final IconData icon;
  final String category;

  const _DesktopNavItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.category,
  });
}
