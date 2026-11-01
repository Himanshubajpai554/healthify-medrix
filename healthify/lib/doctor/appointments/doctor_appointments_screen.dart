import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../../core/enums/domain_enums.dart' as domain;
import '../../core/models/appointment_model.dart' as core;
import '../../core/provider/repository_provider.dart';
import '../../auth/login/login_screen.dart';
import '../../hospital/dashboard/main_dashboard_screen.dart';
import '../../main.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../shared/widgets/glass_components.dart';
import '../../utils/page_transitions.dart';
import '../../utils/responsive.dart';
import '../data/doctor_mock_data.dart';
import '../services/doctor_clinical_records_service.dart';
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
    final isConnected = RepositoryContainer.instance.serverpodClient != null;
    _appointments = isConnected ? <DoctorAppointmentModel>[] : DoctorMockData.getAppointments();
    if (isConnected) _loadAppointments();
    _patientQueue = isConnected ? <PatientQueueItemModel>[] : DoctorMockData.getPatientQueue();
    _emergencyCases = isConnected ? <DoctorEmergencyCaseModel>[] : DoctorMockData.getEmergencyCases();
    _notifications = isConnected ? <DoctorNotificationModel>[] : DoctorMockData.getNotifications();
    _availabilityConfig = DoctorMockData.getAvailabilityConfig();
  }

  Future<void> _loadAppointments() async {
    try {
      final rows = await RepositoryContainer.instance.appointmentRepository
          .getAppointmentsByDoctor(widget.doctorId);
      final appointments = rows.map(_fromServerAppointment).toList();
      final queueAppointments = appointments.where((appointment) =>
          appointment.status == AppointmentStatus.waiting ||
          appointment.status == AppointmentStatus.checkedIn).toList();
      final schedule = await DoctorClinicalRecordsService.instance.loadAvailabilityConfig();
      if (mounted) {
        setState(() {
          _appointments = appointments;
          if (schedule != null) _availabilityStatus = schedule.status;
          if (schedule != null) _availabilityConfig = schedule;
          _patientQueue = [
            for (var index = 0; index < queueAppointments.length; index++)
              PatientQueueItemModel(
                position: '${index + 1}',
                patient: queueAppointments[index].patient,
                appointmentTime: queueAppointments[index].appointmentTime,
                waitingTime: 'Not reported',
                status: queueAppointments[index].status,
              ),
          ];
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load appointments: $error')),
        );
      }
    }
  }

  DoctorAppointmentModel _fromServerAppointment(core.AppointmentItem row) {
    final time = TimeOfDay.fromDateTime(row.dateTime);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final timeText = '$hour:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
    final patient = PatientModel(
      id: row.patientId.isEmpty ? row.id : row.patientId,
      name: row.patientName.isEmpty ? 'Patient' : row.patientName,
      age: 0,
      gender: 'Not reported',
      avatarUrl: '',
      phone: '',
      bloodGroup: '',
      mrn: row.patientId,
      lastVisitDate: 'Not available',
      lastVisitDoctor: widget.doctorName,
      primaryConcern: row.reason.isEmpty ? 'No reason provided' : row.reason,
      department: row.department,
    );
    final status = switch (row.status.toLowerCase()) {
      'checkedin' || 'checked_in' => AppointmentStatus.checkedIn,
      'waiting' || 'pending' => AppointmentStatus.waiting,
      'inconsultation' || 'in_consultation' || 'inprogress' => AppointmentStatus.inConsultation,
      'completed' => AppointmentStatus.completed,
      'cancelled' => AppointmentStatus.cancelled,
      'noshow' || 'no_show' || 'missed' => AppointmentStatus.noShow,
      _ => AppointmentStatus.upcoming,
    };
    return DoctorAppointmentModel(
      id: row.id,
      patient: patient,
      appointmentTime: timeText,
      appointmentType: row.type.isEmpty ? 'Consultation' : row.type,
      department: row.department,
      status: status,
      tokenNumber: '',
      reasonForVisit: row.reason,
      cancellationReason: row.cancellationReason,
      date: row.dateTime,
    );
  }

  Future<bool> _persistStatus(
    DoctorAppointmentModel appointment,
    AppointmentStatus status,
  ) async {
    if (RepositoryContainer.instance.serverpodClient != null) {
      final mapped = switch (status) {
        AppointmentStatus.checkedIn => domain.AppointmentStatus.checkedIn,
        AppointmentStatus.waiting => domain.AppointmentStatus.checkedIn,
        AppointmentStatus.inConsultation => domain.AppointmentStatus.inConsultation,
        AppointmentStatus.completed => domain.AppointmentStatus.completed,
        AppointmentStatus.cancelled => domain.AppointmentStatus.cancelled,
        AppointmentStatus.noShow => domain.AppointmentStatus.noShow,
        _ => domain.AppointmentStatus.scheduled,
      };
      try {
        await RepositoryContainer.instance.appointmentRepository
            .updateAppointmentStatus(appointment.id, mapped);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Appointment update failed: $error')),
          );
        }
        return false;
      }
    }
    if (!mounted) return false;
    setState(() {
      _appointments = _appointments.map((item) => item.id == appointment.id
          ? item.copyWith(status: status)
          : item).toList();
    });
    return true;
  }

  Future<void> _startConsultation(DoctorAppointmentModel appointment) async {
    if (!await _persistStatus(appointment, AppointmentStatus.inConsultation) ||
        !mounted) {
      return;
    }
    DoctorModals.showStartConsultationModal(
      context: context,
      appointment: appointment.copyWith(status: AppointmentStatus.inConsultation),
      onConsultationCompleted: () => _markAppointmentCompleted(appointment),
    );
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
            onPressed: () async {
              final navigator = Navigator.of(context);
              Navigator.pop(context);
              try {
                await RepositoryContainer.instance.serverpodClient?.auth.signOutDevice();
              } catch (_) {}
              if (!mounted) return;
              navigator.pushAndRemoveUntil(
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
                    'HEALTHIFY Portal Switcher',
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
                      onAvailabilityChanged: (status) async {
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _availabilityStatus = status);
                        if (RepositoryContainer.instance.serverpodClient != null) {
                          try {
                            await DoctorClinicalRecordsService.instance.saveAvailability(status);
                          } catch (error) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Could not save availability: $error')),
                              );
                            }
                          }
                        }
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
                      onAddAvailability: () => AvailabilityPanelModal.show(
                        context: context,
                        currentConfig: _availabilityConfig,
                        onSave: (cfg) async {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _availabilityConfig = cfg);
                          if (RepositoryContainer.instance.serverpodClient != null) {
                            try {
                              await DoctorClinicalRecordsService.instance.saveAvailabilityConfig(cfg);
                            } catch (error) {
                              if (mounted) messenger.showSnackBar(SnackBar(content: Text('Could not save schedule: $error')));
                            }
                          }
                        },
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
          onStartConsultation: () => _startConsultation(nextAppointment),
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
              onStartConsultation: () => _startConsultation(apt),
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
                onConfirmedCancel: (reason) => _cancelAppointment(apt, reason),
              ),
            ),
          )
        else if (filteredList.isEmpty)
          AppointmentsEmptyState(
            onManageAvailability: () => AvailabilityPanelModal.show(
              context: context,
              currentConfig: _availabilityConfig,
              onSave: (cfg) async {
                setState(() => _availabilityConfig = cfg);
                if (RepositoryContainer.instance.serverpodClient != null) {
                  try {
                    await DoctorClinicalRecordsService.instance.saveAvailabilityConfig(cfg);
                  } catch (error) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save schedule: $error')));
                  }
                }
              },
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
                  onAccept: _acceptAppointment,
                  onStartConsultation: _startConsultation,
                  onViewPatient: (apt) => DoctorModals.showPatientProfileModal(
                    context: context,
                    patient: apt.patient,
                  ),
                  onViewDetails: (apt) => AppointmentDetailDrawer.show(
                    context: context,
                    appointment: apt,
                    onStartConsultation: () => _startConsultation(apt),
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
                      onConfirmedCancel: (reason) =>
                          _cancelAppointment(apt, reason),
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
                      _cancelAppointment(apt, reason);
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
                      _startConsultation(apt);
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

  Future<void> _markAppointmentCompleted(DoctorAppointmentModel appointment) async {
    await _persistStatus(appointment, AppointmentStatus.completed);
  }

  Future<void> _acceptAppointment(DoctorAppointmentModel appointment) async {
    if (await _persistStatus(appointment, AppointmentStatus.upcoming) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment request accepted.')),
      );
    }
  }

  Future<void> _cancelAppointment(
    DoctorAppointmentModel appointment,
    String reason,
  ) async {
    if (RepositoryContainer.instance.serverpodClient != null) {
      try {
        await RepositoryContainer.instance.appointmentRepository
            .cancelAppointment(appointment.id, reason);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not cancel appointment: $error')),
          );
        }
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _appointments = _appointments.map((item) => item.id == appointment.id
          ? item.copyWith(status: AppointmentStatus.cancelled, cancellationReason: reason)
          : item).toList();
    });
  }

  Future<void> _rescheduleAppointment(
    DoctorAppointmentModel appointment,
    String newSlot,
  ) async {
    var newDate = appointment.date;
    final parsedTime = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(newSlot.trim());
    if (parsedTime != null) {
      var hour = int.parse(parsedTime.group(1)!);
      final minute = int.parse(parsedTime.group(2)!);
      final period = parsedTime.group(3)!.toUpperCase();
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      newDate = DateTime(appointment.date.year, appointment.date.month,
          appointment.date.day, hour, minute);
      if (!newDate.isAfter(DateTime.now())) newDate = newDate.add(const Duration(days: 1));
    }
    if (RepositoryContainer.instance.serverpodClient != null) {
      try {
        final records = RepositoryContainer.instance.hospitalOperationalRepository!;
        final row = await records.get('appointments', appointment.id);
        if (row == null) throw StateError('Appointment not found.');
        await records.save('appointments', appointment.id, {
          ...row,
          'dateTime': newDate.toUtc().toIso8601String(),
          'appointmentTime': newSlot,
          'status': 'scheduled',
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not reschedule appointment: $error')),
          );
        }
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _appointments = _appointments.map((a) {
        if (a.id == appointment.id) {
          return a.copyWith(
            appointmentTime: newSlot,
            date: newDate,
            status: AppointmentStatus.upcoming,
          );
        }
        return a;
      }).toList();
    });
  }
}
