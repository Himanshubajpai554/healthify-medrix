import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../../core/provider/repository_provider.dart';
import '../../core/models/appointment_model.dart' as core;
import '../../core/enums/domain_enums.dart' as domain;
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
import 'widgets/add_clinical_note_modal.dart';
import 'widgets/create_prescription_modal.dart';
import 'widgets/find_request_patient_modal.dart';
import 'widgets/patient_profile_drawer.dart';
import 'widgets/patients_empty_state.dart';
import 'widgets/patients_filter_toolbar.dart';
import 'widgets/patients_header.dart';
import 'widgets/patients_summary_cards.dart';
import 'widgets/patients_table_view.dart';
import 'widgets/schedule_followup_modal.dart';

class MyPatientsScreen extends StatefulWidget {
  final bool embedInDashboard;
  final String doctorName;
  final String doctorId;
  final String specialty;

  const MyPatientsScreen({
    super.key,
    this.embedInDashboard = false,
    this.doctorName = 'Dr. Sarah Jenkins',
    this.doctorId = 'DOC-4019',
    this.specialty = 'Lead Cardiologist',
  });

  @override
  State<MyPatientsScreen> createState() => _MyPatientsScreenState();
}

class _MyPatientsScreenState extends State<MyPatientsScreen> {
  int _selectedNavIndex = 2; // 2 = My Patients
  bool _isSidebarExpanded = true;
  DoctorAvailability _availabilityStatus = DoctorAvailability.available;
  int _mobileBottomNavIndex = 2;

  // Filter State
  String _searchQuery = '';
  PatientCareStatus? _selectedCareStatusFilter;
  String _selectedGenderFilter = 'All Genders';
  String _selectedDepartmentFilter = 'All Departments';

  // Live Mock Data
  late List<PatientModel> _patients;
  late List<DoctorNotificationModel> _notifications;
  late List<DoctorAppointmentModel> _appointments;

  @override
  void initState() {
    super.initState();
    final connected = RepositoryContainer.instance.serverpodClient != null;
    _patients = connected ? <PatientModel>[] : DoctorMockData.getAllPatients();
    _notifications = connected ? <DoctorNotificationModel>[] : DoctorMockData.getNotifications();
    _appointments = connected ? <DoctorAppointmentModel>[] : DoctorMockData.getAppointments();
    if (connected) _loadDoctorPatients();
  }

  Future<void> _loadDoctorPatients() async {
    final container = RepositoryContainer.instance;
    try {
      final liveAppointments = await container.appointmentRepository
          .getAppointmentsByDoctor(widget.doctorId);
      final patients = <String, PatientModel>{};
      for (final appointment in liveAppointments) {
        final id = appointment.patientId.isEmpty ? appointment.id : appointment.patientId;
        patients[id] = PatientModel(
          id: id,
          name: appointment.patientName.isEmpty ? 'Patient' : appointment.patientName,
          age: 0,
          gender: 'Not reported',
          avatarUrl: '',
          phone: '',
          bloodGroup: '',
          mrn: id,
          lastVisitDate: 'Not available',
          lastVisitDoctor: widget.doctorName,
          primaryConcern: appointment.reason.isEmpty ? 'No reason provided' : appointment.reason,
          department: appointment.department.isEmpty ? widget.specialty : appointment.department,
        );
      }
      final hospitalPatients = await container.patientRepository.getPatients();
      for (final patient in hospitalPatients) {
        patients.putIfAbsent(patient.id, () => PatientModel(
          id: patient.id,
          name: patient.name,
          age: patient.age,
          gender: patient.gender,
          avatarUrl: '',
          phone: '',
          bloodGroup: patient.bloodGroup,
          mrn: patient.id,
          lastVisitDate: patient.admissionDate.toLocal().toString().split(' ').first,
          lastVisitDoctor: patient.doctorName,
          primaryConcern: patient.ward,
          department: widget.specialty,
        ));
      }
      final mappedAppointments = liveAppointments.map(_fromServerAppointment).toList();
      final schedule = await DoctorClinicalRecordsService.instance.loadAvailabilityConfig();
      if (!mounted) return;
      setState(() {
        _patients = patients.values.toList()
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _appointments = mappedAppointments;
        if (schedule != null) _availabilityStatus = schedule.status;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load assigned patients: $error')),
      );
    }
  }

  DoctorAppointmentModel _fromServerAppointment(core.AppointmentItem row) {
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
      'pending' || 'waiting' => AppointmentStatus.waiting,
      'checkedin' || 'checked_in' => AppointmentStatus.checkedIn,
      'inconsultation' || 'in_consultation' || 'inprogress' => AppointmentStatus.inConsultation,
      'completed' => AppointmentStatus.completed,
      'cancelled' => AppointmentStatus.cancelled,
      'noshow' || 'no_show' || 'missed' => AppointmentStatus.noShow,
      _ => AppointmentStatus.upcoming,
    };
    final time = TimeOfDay.fromDateTime(row.dateTime);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final timeText = '$hour:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
    return DoctorAppointmentModel(
      id: row.id,
      patient: patient,
      appointmentTime: timeText,
      appointmentType: row.type.isEmpty ? 'Consultation' : row.type,
      department: row.department,
      status: status,
      tokenNumber: '',
      reasonForVisit: row.reason,
      date: row.dateTime,
    );
  }

  Future<void> _setAvailability(DoctorAvailability status) async {
    setState(() => _availabilityStatus = status);
    if (RepositoryContainer.instance.serverpodClient == null) return;
    try {
      await DoctorClinicalRecordsService.instance.saveAvailability(status);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save availability: $error')),
        );
      }
    }
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
        content: const Text('Are you sure you want to sign out of the Doctor Portal?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
                style: TextStyle(color: HealthifyGlassTheme.getTextSecondary(isDark), fontSize: 13),
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
            color: isSelected ? color : HealthifyGlassTheme.getTextPrimary(isDark),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: color)
            : Icon(Icons.chevron_right_rounded, color: HealthifyGlassTheme.getTextSecondary(isDark)),
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
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: GlassTextFieldTheme.getDecoration(
                  context: context,
                  hintText: 'Search by Patient Name, MRN, Phone number...',
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

  List<PatientModel> get _filteredPatients {
    return _patients.where((p) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = p.name.toLowerCase().contains(query);
        final matchesMrn = p.mrn.toLowerCase().contains(query);
        final matchesPhone = p.phone.toLowerCase().contains(query);
        final matchesId = p.id.toLowerCase().contains(query);
        if (!matchesName && !matchesMrn && !matchesPhone && !matchesId) return false;
      }

      if (_selectedCareStatusFilter != null && p.careStatus != _selectedCareStatusFilter) {
        return false;
      }

      if (_selectedGenderFilter != 'All Genders' && p.gender != _selectedGenderFilter) {
        return false;
      }

      if (_selectedDepartmentFilter != 'All Departments' && p.department != _selectedDepartmentFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCareStatusFilter = null;
      _selectedGenderFilter = 'All Genders';
      _selectedDepartmentFilter = 'All Departments';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedInDashboard) {
      return SingleChildScrollView(
        child: _buildPatientsWorkspaceContent(),
      );
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
                  } else if (index == 1) {
                    Navigator.pushReplacementNamed(context, '/doctor-appointments');
                  } else {
                    setState(() => _selectedNavIndex = index);
                  }
                },
                isExpanded: _isSidebarExpanded,
                onToggleExpand: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
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
                    // Patients Header Bar
                    PatientsHeader(
                      doctorName: widget.doctorName,
                      availabilityStatus: _availabilityStatus,
                      onAvailabilityChanged: _setAvailability,
                      onNotificationTap: () => DoctorModals.showNotificationsPane(
                        context: context,
                        notifications: _notifications,
                        onMarkAllRead: () {
                          setState(() {
                            _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
                          });
                          Navigator.pop(context);
                        },
                      ),
                      onSearchTap: _showSearchModal,
                      onProfileTap: _showRoleSwitcherModal,
                      onThemeToggle: _toggleTheme,
                      onAddPatient: () => FindRequestPatientModal.show(
                        context: context,
                        onRequestSubmitted: (name) {},
                      ),
                      onImportRecords: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('EHR Records import wizard launched.')),
                        );
                      },
                      unreadNotificationsCount: unreadCount,
                    ),

                    // Scrollable Workspace Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1600),
                            child: _buildPatientsWorkspaceContent(),
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
        preferredSize: const Size.fromHeight(110),
        child: PatientsHeader(
          doctorName: widget.doctorName,
          availabilityStatus: _availabilityStatus,
          onAvailabilityChanged: _setAvailability,
          onNotificationTap: () => DoctorModals.showNotificationsPane(
            context: context,
            notifications: _notifications,
            onMarkAllRead: () {
              setState(() {
                _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
              });
              Navigator.pop(context);
            },
          ),
          onSearchTap: _showSearchModal,
          onProfileTap: _showRoleSwitcherModal,
          onThemeToggle: _toggleTheme,
          onAddPatient: () => FindRequestPatientModal.show(
            context: context,
            onRequestSubmitted: (name) {},
          ),
          onImportRecords: () {},
          unreadNotificationsCount: unreadCount,
        ),
      ),
      body: AnimatedPulseBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildPatientsWorkspaceContent(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: HealthifyGlassTheme.getGlassSurface(isDark, isStrong: true),
          border: Border(top: BorderSide(color: HealthifyGlassTheme.getGlassBorder(isDark))),
        ),
        child: BottomNavigationBar(
          currentIndex: _mobileBottomNavIndex,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/doctor');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/doctor-appointments');
            } else {
              setState(() => _mobileBottomNavIndex = index);
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: HealthifyGlassTheme.primaryTeal,
          unselectedItemColor: HealthifyGlassTheme.getTextSecondary(isDark),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Appointments'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Patients'),
            BottomNavigationBarItem(icon: Icon(Icons.emergency_rounded), label: 'Emergency'),
            BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Analytics'),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsWorkspaceContent() {
    final filteredList = _filteredPatients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Patient Summary Cards
        PatientsSummaryCards(
          totalPatients: _patients.length,
          todaysPatients: _appointments.where((appointment) => appointment.date.year == DateTime.now().year && appointment.date.month == DateTime.now().month && appointment.date.day == DateTime.now().day).length,
          newPatients: _patients.where((patient) => patient.careStatus == PatientCareStatus.newPatient).length,
          followUpsDue: _patients.where((patient) => patient.careStatus == PatientCareStatus.followUpDue).length,
          pendingReports: 0,
          activeCareStatusFilter: _selectedCareStatusFilter,
          onSelectCareStatusFilter: (status) => setState(() => _selectedCareStatusFilter = status),
        ),
        const SizedBox(height: 16),

        // 2. Search & Filter Toolbar
        PatientsFilterToolbar(
          searchQuery: _searchQuery,
          onSearchChanged: (query) => setState(() => _searchQuery = query),
          selectedCareStatus: _selectedCareStatusFilter,
          onCareStatusChanged: (status) => setState(() => _selectedCareStatusFilter = status),
          selectedGender: _selectedGenderFilter,
          onGenderChanged: (gender) => setState(() => _selectedGenderFilter = gender),
          selectedDepartment: _selectedDepartmentFilter,
          onDepartmentChanged: (dept) => setState(() => _selectedDepartmentFilter = dept),
          onClearFilters: _clearAllFilters,
        ),
        const SizedBox(height: 16),

        // 3. Patient Table View or Empty State
        if (filteredList.isEmpty)
          PatientsEmptyState(
            onClearFilters: _clearAllFilters,
          )
        else
          PatientsTableView(
            patients: filteredList,
            onViewPatientProfile: (patient) => PatientProfileDrawer.show(
              context: context,
              patient: patient,
              onStartConsultation: () => _startConsultationForPatient(patient),
              onWritePrescription: () => CreatePrescriptionModal.show(
                context: context,
                patient: patient,
                onPrescriptionCreated: () {},
              ),
              onAddClinicalNote: () => AddClinicalNoteModal.show(
                context: context,
                patient: patient,
                onNoteAdded: () {},
              ),
              onScheduleFollowUp: () => ScheduleFollowupModal.show(
                context: context,
                patient: patient,
                onFollowupScheduled: () {},
              ),
            ),
            onStartConsultation: (patient) => _startConsultationForPatient(patient),
            onWritePrescription: (patient) => CreatePrescriptionModal.show(
              context: context,
              patient: patient,
              onPrescriptionCreated: () {},
            ),
            onAddClinicalNote: (patient) => AddClinicalNoteModal.show(
              context: context,
              patient: patient,
              onNoteAdded: () {},
            ),
            onScheduleFollowUp: (patient) => ScheduleFollowupModal.show(
              context: context,
              patient: patient,
              onFollowupScheduled: () {},
            ),
          ),
      ],
    );
  }

  Future<void> _startConsultationForPatient(PatientModel patient) async {
    final isConnected = RepositoryContainer.instance.serverpodClient != null;
    final matchingAppointment = _appointments.where((a) => a.patient.id == patient.id).firstOrNull;
    if (isConnected && matchingAppointment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start a consultation from an assigned appointment.')),
      );
      return;
    }
    final matchingApt = matchingAppointment ?? DoctorAppointmentModel(
        id: 'APT-NEW',
        patient: patient,
        appointmentTime: '10:00 AM',
        appointmentType: 'Direct Consult',
        department: patient.department,
        status: AppointmentStatus.inConsultation,
        tokenNumber: '#01',
        reasonForVisit: patient.primaryConcern,
        date: DateTime.now(),
      );

    if (isConnected) {
      try {
        await RepositoryContainer.instance.appointmentRepository.updateAppointmentStatus(
          matchingApt.id, domain.AppointmentStatus.inConsultation,
        );
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not start consultation: $error')));
        return;
      }
    }
    if (!mounted) return;

    DoctorModals.showStartConsultationModal(
      context: context,
      appointment: matchingApt,
      onConsultationCompleted: () {},
    );
  }
}
