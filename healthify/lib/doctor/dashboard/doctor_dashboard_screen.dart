import 'package:flutter/material.dart';
import '../../auth/login/login_screen.dart';
import '../../hospital/dashboard/main_dashboard_screen.dart';
import '../../main.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../utils/page_transitions.dart';
import '../../utils/responsive.dart';
import '../data/doctor_mock_data.dart';
import '../modals/doctor_modals.dart';
import '../models/doctor_dashboard_models.dart';
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
  int _selectedNavIndex = 0;
  bool _isSidebarExpanded = true;
  DoctorAvailability _availabilityStatus = DoctorAvailability.available;
  int _mobileBottomNavIndex = 0;

  // Live State Data from Mock Provider
  late List<DoctorAppointmentModel> _appointments;
  late List<PatientQueueItemModel> _patientQueue;
  late List<DoctorEmergencyCaseModel> _emergencyCases;
  late List<PendingReportModel> _pendingReports;
  late AIPatientSummaryModel _aiSummary;
  late List<DoctorNotificationModel> _notifications;
  late DoctorAnalyticsModel _analytics;
  late DoctorAvailabilityConfig _availabilityConfig;

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

  void _toggleTheme() {
    setState(() {
      final isDark = themeNotifier.value == ThemeMode.dark;
      themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to sign out of the Doctor Portal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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
                    'MEDRIX Portal Switcher',
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
                  fontSize: 13,
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
                subtitle: 'Current Active Portal • Clinical Workspace',
                color: HealthifyGlassTheme.primaryTeal,
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
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: GlassTextFieldTheme.getDecoration(
                  context: context,
                  hintText: 'Search by Patient Name, MRN, Phone number...',
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: HealthifyGlassTheme.primaryTeal,
                  child: Text('R', style: TextStyle(color: Colors.white)),
                ),
                title: const Text('Rahul Sharma (MRN-2026-8812)'),
                subtitle: const Text('Cardiology • Next in line (Token #01)'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  DoctorModals.showPatientProfileModal(
                    context: context,
                    patient: DoctorMockData.patientRahul,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);
    final isDesktop = Responsive.isDesktop(context);
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
        body: AnimatedPulseBackground(
          child: Row(
            children: [
              // Desktop Persistent Left Sidebar
              DoctorSidebar(
                selectedNavIndex: _selectedNavIndex,
                onNavItemSelected: (index) {
                  if (index == 1) {
                    Navigator.pushNamed(context, '/doctor-appointments');
                  } else if (index == 2) {
                    Navigator.pushNamed(context, '/doctor-patients');
                  } else if (index == 3) {
                    Navigator.pushNamed(context, '/doctor-patient-profile');
                  } else if (index == 4) {
                    Navigator.pushNamed(context, '/doctor-reports');
                  } else if (index == 5) {
                    Navigator.pushNamed(context, '/doctor-prescriptions');
                  } else {
                    setState(() => _selectedNavIndex = index);
                  }
                },
                isExpanded: _isSidebarExpanded,
                onToggleExpand: () =>
                    setState(() => _isSidebarExpanded = !_isSidebarExpanded),
                availabilityStatus: _availabilityStatus,
                onLogout: _handleLogout,
                onRoleSwitcherTap: _showRoleSwitcherModal,
                doctorName: widget.doctorName,
                specialty: widget.specialty,
              ),

              // Main Workspace Content Area
              Expanded(
                child: Column(
                  children: [
                    // Desktop Top Header Bar
                    DoctorHeader(
                      doctorName: widget.doctorName,
                      title: 'Doctor Dashboard',
                      subtitle: 'Clinical Overview & OPD Queue',
                      availabilityStatus: _availabilityStatus,
                      onAvailabilityChanged: (status) {
                        setState(() => _availabilityStatus = status);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Status updated to ${status.name.toUpperCase()}',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onNotificationTap: () =>
                          DoctorModals.showNotificationsPane(
                            context: context,
                            notifications: _notifications,
                            onMarkAllRead: () {
                              setState(() {
                                _notifications = _notifications
                                    .map((n) => n.copyWith(isRead: true))
                                    .toList();
                              });
                              Navigator.pop(context);
                            },
                          ),
                      onSearchTap: _showSearchModal,
                      onProfileTap: _showRoleSwitcherModal,
                      onThemeToggle: _toggleTheme,
                      unreadNotificationsCount: unreadCount,
                    ),

                    // Scrollable Workspace Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1600),
                            child: _buildDesktopViewContent(),
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

    // Mobile & Tablet Responsive Layout
    return Scaffold(
      backgroundColor: HealthifyGlassTheme.getBackgroundColor(isDark),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: DoctorHeader(
          doctorName: widget.doctorName,
          title: 'Doctor Dashboard',
          subtitle: 'Clinical Overview & OPD Queue',
          availabilityStatus: _availabilityStatus,
          onAvailabilityChanged: (status) =>
              setState(() => _availabilityStatus = status),
          onNotificationTap: () => DoctorModals.showNotificationsPane(
            context: context,
            notifications: _notifications,
            onMarkAllRead: () {
              setState(() {
                _notifications = _notifications
                    .map((n) => n.copyWith(isRead: true))
                    .toList();
              });
              Navigator.pop(context);
            },
          ),
          onSearchTap: _showSearchModal,
          onProfileTap: _showRoleSwitcherModal,
          onThemeToggle: _toggleTheme,
          unreadNotificationsCount: unreadCount,
        ),
      ),
      body: AnimatedPulseBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildMobileTabContent(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: HealthifyGlassTheme.getGlassSurface(isDark, isStrong: true),
          border: Border(
            top: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _mobileBottomNavIndex,
          onTap: (index) => setState(() => _mobileBottomNavIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: HealthifyGlassTheme.primaryTeal,
          unselectedItemColor: HealthifyGlassTheme.getTextSecondary(isDark),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Appointments',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.emergency_rounded),
                  if (_emergencyCases.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Care & Emergency',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded),
              label: 'Insights',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopViewContent() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildMainDashboardTab();
      case 1:
        return TodayAppointmentsSection(
          appointments: _appointments,
          onStartConsultation: (apt) => DoctorModals.showStartConsultationModal(
            context: context,
            appointment: apt,
            onConsultationCompleted: () => _markAppointmentCompleted(apt),
          ),
          onViewPatient: (apt) => DoctorModals.showPatientProfileModal(
            context: context,
            patient: apt.patient,
          ),
          onReschedule: (apt) => DoctorModals.showRescheduleModal(
            context: context,
            appointment: apt,
            onRescheduled: () {},
          ),
          onMarkCompleted: (apt) => _markAppointmentCompleted(apt),
          onViewAll: () {},
        );
      case 2:
        return RecentPatientsWidget(
          patients: [
            DoctorMockData.patientRahul,
            DoctorMockData.patientPriya,
            DoctorMockData.patientAmit,
            DoctorMockData.patientNeha,
            DoctorMockData.patientRajesh,
          ],
          onPatientTap: (patient) => DoctorModals.showPatientProfileModal(
            context: context,
            patient: patient,
          ),
        );
      case 3:
      case 4:
        return PendingReportsWidget(
          reports: _pendingReports,
          onReviewReport: (report) => DoctorModals.showReviewReportModal(
            context: context,
            report: report,
            onReportReviewed: (notes) {
              setState(() {
                _pendingReports = _pendingReports.map((r) {
                  return r.id == report.id
                      ? r.copyWith(isReviewed: true, clinicalNotes: notes)
                      : r;
                }).toList();
              });
            },
          ),
        );
      case 6:
        return EmergencyCasesWidget(
          emergencyCases: _emergencyCases,
          onViewPatient: (item) => DoctorModals.showPatientProfileModal(
            context: context,
            patient: item.patient,
          ),
          onOpenMedicalRecord: (item) => DoctorModals.showPatientProfileModal(
            context: context,
            patient: item.patient,
          ),
        );
      case 8:
        return DoctorAnalyticsWidget(analytics: _analytics);
      default:
        return _buildMainDashboardTab();
    }
  }

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

    return GlassCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      borderRadius: 16,
      child: Row(
        children: [
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
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('👋', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.specialty} • OPD Room 402 • 18 Patients Scheduled Today',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13.5,
                    fontWeight: FontWeight.w500,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.3),
                ),
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
                        color: HealthifyGlassTheme.primaryTeal,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Friday, Oct 2, 2026',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Morning OPD • 09:00 AM - 01:00 PM',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: HealthifyGlassTheme.primaryTeal,
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

  Widget _buildMainDashboardTab() {
    final nextAppointment = _appointments.firstWhere(
      (a) => a.isNextUpcoming,
      orElse: () => _appointments.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0. Clean Dashboard Welcome & Greeting Hero Banner
        _buildDashboardWelcomeBanner(),

        // 1. Quick Overview Summary Cards Grid (5 Cards)
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
          onCardTap: (navIndex) => setState(() => _selectedNavIndex = navIndex),
        ),
        const SizedBox(height: 20),

        // 2. Quick Action Bar
        DoctorQuickActionsBar(
          onStartConsultation: () => DoctorModals.showStartConsultationModal(
            context: context,
            appointment: nextAppointment,
            onConsultationCompleted: () =>
                _markAppointmentCompleted(nextAppointment),
          ),
          onAddPatientNote: () => _showAddNoteDialog(),
          onWritePrescription: () => _showWritePrescriptionDialog(),
          onReviewReports: () => setState(() => _selectedNavIndex = 4),
          onViewSchedule: () => setState(() => _selectedNavIndex = 1),
        ),
        const SizedBox(height: 20),

        // 3. Desktop Two-Column Clinical Layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Main Column (62%)
            Expanded(
              flex: 62,
              child: Column(
                children: [
                  // Next Patient Prominent Hero Widget
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

                  // Today's Appointments Section
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
                      onRescheduled: () {},
                    ),
                    onMarkCompleted: (apt) => _markAppointmentCompleted(apt),
                    onViewAll: () => setState(() => _selectedNavIndex = 1),
                  ),
                  const SizedBox(height: 20),

                  // Pending Reports Requiring Review
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

                  // Emergency Cases Section
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

                  // Doctor Analytics Section
                  DoctorAnalyticsWidget(analytics: _analytics),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Right Contextual Column (38%)
            Expanded(
              flex: 38,
              child: Column(
                children: [
                  // OPD Live Queue Widget
                  PatientQueueWidget(
                    queue: _patientQueue,
                    onCallNext: (queueItem) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Calling ${queueItem.patient.name} to Consultation Room 1',
                          ),
                          backgroundColor: HealthifyGlassTheme.primaryTeal,
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

                  // AI Patient Summary Widget
                  AIPatientSummaryWidget(
                    aiSummary: _aiSummary,
                    onViewFullSummary: () =>
                        DoctorModals.showPatientProfileModal(
                          context: context,
                          patient: _aiSummary.patient,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Practice Availability Card
                  DoctorAvailabilityCard(
                    config: _availabilityConfig,
                    onStatusChanged: (status) =>
                        setState(() => _availabilityStatus = status),
                    onConfigureHours: () =>
                        DoctorModals.showConfigureHoursModal(
                          context: context,
                          currentConfig: _availabilityConfig,
                          onSave: (newConfig) =>
                              setState(() => _availabilityConfig = newConfig),
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Recent Patients Section
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

  Widget _buildMobileTabContent() {
    final nextAppointment = _appointments.firstWhere(
      (a) => a.isNextUpcoming,
      orElse: () => _appointments.first,
    );

    switch (_mobileBottomNavIndex) {
      case 0:
        return Column(
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
              pendingReports: _pendingReports
                  .where((r) => !r.isReviewed)
                  .length,
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
      case 1:
        return TodayAppointmentsSection(
          appointments: _appointments,
          onStartConsultation: (apt) => DoctorModals.showStartConsultationModal(
            context: context,
            appointment: apt,
            onConsultationCompleted: () => _markAppointmentCompleted(apt),
          ),
          onViewPatient: (apt) => DoctorModals.showPatientProfileModal(
            context: context,
            patient: apt.patient,
          ),
          onReschedule: (apt) => DoctorModals.showRescheduleModal(
            context: context,
            appointment: apt,
            onRescheduled: () {},
          ),
          onMarkCompleted: (apt) => _markAppointmentCompleted(apt),
          onViewAll: () {},
        );
      case 2:
        return RecentPatientsWidget(
          patients: [
            DoctorMockData.patientRahul,
            DoctorMockData.patientPriya,
            DoctorMockData.patientAmit,
            DoctorMockData.patientNeha,
            DoctorMockData.patientRajesh,
          ],
          onPatientTap: (p) => DoctorModals.showPatientProfileModal(
            context: context,
            patient: p,
          ),
        );
      case 3:
        return Column(
          children: [
            EmergencyCasesWidget(
              emergencyCases: _emergencyCases,
              onViewPatient: (item) => DoctorModals.showPatientProfileModal(
                context: context,
                patient: item.patient,
              ),
              onOpenMedicalRecord: (item) =>
                  DoctorModals.showPatientProfileModal(
                    context: context,
                    patient: item.patient,
                  ),
            ),
            const SizedBox(height: 16),
            PendingReportsWidget(
              reports: _pendingReports,
              onReviewReport: (r) => DoctorModals.showReviewReportModal(
                context: context,
                report: r,
                onReportReviewed: (notes) {},
              ),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            DoctorAnalyticsWidget(analytics: _analytics),
            const SizedBox(height: 16),
            DoctorAvailabilityCard(
              config: _availabilityConfig,
              onStatusChanged: (st) => setState(() => _availabilityStatus = st),
              onConfigureHours: () => DoctorModals.showConfigureHoursModal(
                context: context,
                currentConfig: _availabilityConfig,
                onSave: (cfg) => setState(() => _availabilityConfig = cfg),
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }

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

  void _showAddNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Clinical Note'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter clinical observations or notes...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clinical Note saved to EHR.')),
              );
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _showWritePrescriptionDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write E-Prescription'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter medication details, dosage & duration...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('E-Prescription generated & sent to pharmacy.'),
                ),
              );
            },
            child: const Text('Generate Prescription'),
          ),
        ],
      ),
    );
  }
}
