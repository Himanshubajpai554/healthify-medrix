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
import '../widgets/doctor_sidebar.dart';
import 'widgets/appointment_detail_drawer.dart';
import 'widgets/appointments_calendar_view.dart';
import 'widgets/appointments_empty_state.dart';
import 'widgets/appointments_filter_toolbar.dart';
import 'widgets/appointments_header.dart';
import 'widgets/appointments_summary_cards.dart';
import 'widgets/appointments_table_view.dart';
import 'widgets/availability_panel_modal.dart';
import 'widgets/cancel_appointment_dialog.dart';
import 'widgets/date_navigation_bar.dart';
import 'widgets/emergency_appointments_banner.dart';
import 'widgets/next_appointment_prominent_card.dart';
import 'widgets/reschedule_appointment_dialog.dart';
import 'widgets/waiting_queue_widget.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  final bool embedInDashboard;
  final String doctorName;
  final String doctorId;
  final String specialty;

  const DoctorAppointmentsScreen({
    super.key,
    this.embedInDashboard = false,
    this.doctorName = 'Dr. Sarah Jenkins',
    this.doctorId = 'DOC-4019',
    this.specialty = 'Lead Cardiologist',
  });

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  int _selectedNavIndex = 1; // 1 = Appointments tab
  bool _isSidebarExpanded = true;
  DoctorAvailability _availabilityStatus = DoctorAvailability.available;
  bool _isCalendarView = false;
  int _mobileBottomNavIndex = 1;

  // Filter State
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  AppointmentStatus? _selectedStatusFilter;
  String _selectedTypeFilter = 'All Types';
  String _selectedDepartmentFilter = 'All Departments';
  String _selectedModeFilter = 'All Modes';

  // Live Mock Data
  late List<DoctorAppointmentModel> _appointments;
  late List<PatientQueueItemModel> _patientQueue;
  late List<DoctorEmergencyCaseModel> _emergencyCases;
  late List<DoctorNotificationModel> _notifications;
  late DoctorAvailabilityConfig _availabilityConfig;

  @override
  void initState() {
    super.initState();
    _appointments = DoctorMockData.getAppointments();
    _patientQueue = DoctorMockData.getPatientQueue();
    _emergencyCases = DoctorMockData.getEmergencyCases();
    _notifications = DoctorMockData.getNotifications();
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
    final searchController = TextEditingController(text: _searchQuery);
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
                'Clinical Appointments Search',
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
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: GlassTextFieldTheme.getDecoration(
                  context: context,
                  hintText: 'Search by Patient Name, MRN, Appointment ID...',
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 16),
              GlassPrimaryButton(
                onPressed: () => Navigator.pop(context),
                child: const Center(child: Text('Apply Search')),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DoctorAppointmentModel> get _filteredAppointments {
    return _appointments.where((apt) {
      // Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = apt.patient.name.toLowerCase().contains(query);
        final matchesMrn = apt.patient.mrn.toLowerCase().contains(query);
        final matchesAptId = apt.id.toLowerCase().contains(query);
        if (!matchesName && !matchesMrn && !matchesAptId) return false;
      }

      // Status Filter
      if (_selectedStatusFilter != null &&
          apt.status != _selectedStatusFilter) {
        return false;
      }

      // Type Filter
      if (_selectedTypeFilter != 'All Types' &&
          apt.appointmentType != _selectedTypeFilter) {
        return false;
      }

      // Department Filter
      if (_selectedDepartmentFilter != 'All Departments' &&
          apt.department != _selectedDepartmentFilter) {
        return false;
      }

      // Mode Filter
      if (_selectedModeFilter != 'All Modes' &&
          apt.consultationMode != _selectedModeFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatusFilter = null;
      _selectedTypeFilter = 'All Types';
      _selectedDepartmentFilter = 'All Departments';
      _selectedModeFilter = 'All Modes';
      _selectedDate = DateTime.now();
    });
  }

  void _selectCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedInDashboard) {
      return SingleChildScrollView(child: _buildAppointmentsWorkspaceContent());
    }

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
                  if (index == 0) {
                    Navigator.pushReplacementNamed(context, '/doctor');
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
                    // Top Appointments Header Bar
                    AppointmentsHeader(
                      doctorName: widget.doctorName,
                      availabilityStatus: _availabilityStatus,
                      onAvailabilityChanged: (status) =>
                          setState(() => _availabilityStatus = status),
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
                      onAddAvailability: () => AvailabilityPanelModal.show(
                        context: context,
                        currentConfig: _availabilityConfig,
                        onSave: (cfg) =>
                            setState(() => _availabilityConfig = cfg),
                      ),
                      onViewSchedule: () =>
                          setState(() => _isCalendarView = !_isCalendarView),
                      isCalendarView: _isCalendarView,
                      onToggleCalendarView: () =>
                          setState(() => _isCalendarView = !_isCalendarView),
                      unreadNotificationsCount: unreadCount,
                    ),

                    // Scrollable Workspace Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1600),
                            child: _buildAppointmentsWorkspaceContent(),
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
      body: AnimatedPulseBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildAppointmentsWorkspaceContent(),
        ),
      ),
    );
  }

  Widget _buildAppointmentsWorkspaceContent() {
    final nextAppointment = _appointments.firstWhere(
      (a) => a.isNextUpcoming,
      orElse: () => _appointments.first,
    );

    final filteredList = _filteredAppointments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Emergency Admissions Banner (if active emergency cases exist)
        EmergencyAppointmentsBanner(
          emergencyCases: _emergencyCases,
          onViewPatient: (item) => DoctorModals.showPatientProfileModal(
            context: context,
            patient: item.patient,
          ),
          onOpenMedicalRecord: (item) => DoctorModals.showPatientProfileModal(
            context: context,
            patient: item.patient,
          ),
        ),

        // 2. Date Navigation Bar (Desktop & Mobile)
        DateNavigationBar(
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
          onSelectToday: () => setState(() => _selectedDate = DateTime.now()),
          onSelectTomorrow: () => setState(
            () => _selectedDate = DateTime.now().add(const Duration(days: 1)),
          ),
          onSelectThisWeek: () =>
              setState(() => _selectedDate = DateTime.now()),
          onSelectCustomDate: _selectCustomDate,
        ),
        const SizedBox(height: 16),

        // 3. Compact Appointments Summary Cards
        AppointmentsSummaryCards(
          totalCount: _appointments.length,
          upcomingCount: _appointments
              .where((a) => a.status == AppointmentStatus.upcoming)
              .length,
          waitingCount: _appointments
              .where(
                (a) =>
                    a.status == AppointmentStatus.waiting ||
                    a.status == AppointmentStatus.checkedIn,
              )
              .length,
          completedCount: _appointments
              .where((a) => a.status == AppointmentStatus.completed)
              .length,
          cancelledCount: _appointments
              .where((a) => a.status == AppointmentStatus.cancelled)
              .length,
          noShowCount: _appointments
              .where((a) => a.status == AppointmentStatus.noShow)
              .length,
          activeFilterStatus: _selectedStatusFilter,
          onSelectStatusFilter: (status) =>
              setState(() => _selectedStatusFilter = status),
        ),
        const SizedBox(height: 16),

        // 4. Prominent NEXT APPOINTMENT Hero Card
        NextAppointmentProminentCard(
          appointment: nextAppointment,
          onStartConsultation: () => DoctorModals.showStartConsultationModal(
            context: context,
            appointment: nextAppointment,
            onConsultationCompleted: () =>
                _markAppointmentCompleted(nextAppointment),
          ),
          onViewPatient: () => DoctorModals.showPatientProfileModal(
            context: context,
            patient: nextAppointment.patient,
          ),
        ),
        const SizedBox(height: 16),

        // 5. Interactive Filter Toolbar
        AppointmentsFilterToolbar(
          searchQuery: _searchQuery,
          onSearchChanged: (query) => setState(() => _searchQuery = query),
          selectedStatus: _selectedStatusFilter,
          onStatusChanged: (status) =>
              setState(() => _selectedStatusFilter = status),
          selectedType: _selectedTypeFilter,
          onTypeChanged: (type) => setState(() => _selectedTypeFilter = type),
          selectedDepartment: _selectedDepartmentFilter,
          onDepartmentChanged: (dept) =>
              setState(() => _selectedDepartmentFilter = dept),
          selectedMode: _selectedModeFilter,
          onModeChanged: (mode) => setState(() => _selectedModeFilter = mode),
          onClearFilters: _clearAllFilters,
        ),
        const SizedBox(height: 16),

        // 6. Main Appointments Display: Calendar View or Table View / Empty State
        if (_isCalendarView)
          AppointmentsCalendarView(
            appointments: filteredList,
            onSelectAppointment: (apt) => AppointmentDetailDrawer.show(
              context: context,
              appointment: apt,
              onStartConsultation: () =>
                  DoctorModals.showStartConsultationModal(
                    context: context,
                    appointment: apt,
                    onConsultationCompleted: () =>
                        _markAppointmentCompleted(apt),
                  ),
              onViewPatient: () => DoctorModals.showPatientProfileModal(
                context: context,
                patient: apt.patient,
              ),
              onReschedule: () => RescheduleAppointmentDialog.show(
                context: context,
                appointment: apt,
                onRescheduled: (newSlot) =>
                    _rescheduleAppointment(apt, newSlot),
              ),
              onCancel: () => CancelAppointmentDialog.show(
                context: context,
                appointment: apt,
                onConfirmedCancel: (_) {},
              ),
            ),
          )
        else if (filteredList.isEmpty)
          AppointmentsEmptyState(
            onManageAvailability: () => AvailabilityPanelModal.show(
              context: context,
              currentConfig: _availabilityConfig,
              onSave: (cfg) => setState(() => _availabilityConfig = cfg),
            ),
            onViewUpcoming: _clearAllFilters,
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Table View List (70%)
              Expanded(
                flex: 70,
                child: AppointmentsTableView(
                  appointments: filteredList,
                  onStartConsultation: (apt) =>
                      DoctorModals.showStartConsultationModal(
                        context: context,
                        appointment: apt,
                        onConsultationCompleted: () =>
                            _markAppointmentCompleted(apt),
                      ),
                  onViewPatient: (apt) => DoctorModals.showPatientProfileModal(
                    context: context,
                    patient: apt.patient,
                  ),
                  onViewDetails: (apt) => AppointmentDetailDrawer.show(
                    context: context,
                    appointment: apt,
                    onStartConsultation: () =>
                        DoctorModals.showStartConsultationModal(
                          context: context,
                          appointment: apt,
                          onConsultationCompleted: () =>
                              _markAppointmentCompleted(apt),
                        ),
                    onViewPatient: () => DoctorModals.showPatientProfileModal(
                      context: context,
                      patient: apt.patient,
                    ),
                    onReschedule: () => RescheduleAppointmentDialog.show(
                      context: context,
                      appointment: apt,
                      onRescheduled: (newSlot) =>
                          _rescheduleAppointment(apt, newSlot),
                    ),
                    onCancel: () => CancelAppointmentDialog.show(
                      context: context,
                      appointment: apt,
                      onConfirmedCancel: (_) {},
                    ),
                  ),
                  onReschedule: (apt) => RescheduleAppointmentDialog.show(
                    context: context,
                    appointment: apt,
                    onRescheduled: (newSlot) =>
                        _rescheduleAppointment(apt, newSlot),
                  ),
                  onCancel: (apt) => CancelAppointmentDialog.show(
                    context: context,
                    appointment: apt,
                    onConfirmedCancel: (reason) {
                      setState(() {
                        _appointments = _appointments.map((a) {
                          if (a.id == apt.id) {
                            return a.copyWith(
                              status: AppointmentStatus.cancelled,
                              cancellationReason: reason,
                            );
                          }
                          return a;
                        }).toList();
                      });
                    },
                  ),
                  onCallPatient: (apt) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Calling ${apt.patient.name} to Consultation Desk 1',
                        ),
                        backgroundColor: HealthifyGlassTheme.primaryTeal,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),

              // Side Contextual Queue (30%) on Desktop
              if (Responsive.isDesktop(context)) ...[
                const SizedBox(width: 20),
                Expanded(
                  flex: 30,
                  child: WaitingQueueWidget(
                    queue: _patientQueue,
                    onStartNextConsultation: (queueItem) {
                      final apt = _appointments.firstWhere(
                        (a) => a.patient.id == queueItem.patient.id,
                        orElse: () => _appointments.first,
                      );
                      DoctorModals.showStartConsultationModal(
                        context: context,
                        appointment: apt,
                        onConsultationCompleted: () =>
                            _markAppointmentCompleted(apt),
                      );
                    },
                    onViewPatient: (queueItem) =>
                        DoctorModals.showPatientProfileModal(
                          context: context,
                          patient: queueItem.patient,
                        ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
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

  void _rescheduleAppointment(
    DoctorAppointmentModel appointment,
    String newSlot,
  ) {
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
}
