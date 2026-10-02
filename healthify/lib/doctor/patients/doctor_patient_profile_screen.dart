import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../widgets/doctor_sidebar.dart';
import '../widgets/doctor_header.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/patient_profile_models.dart';
import '../services/doctor_patient_service.dart';
import 'widgets/patient_profile_header.dart';
import 'widgets/patient_overview_tab.dart';
import 'widgets/patient_medical_history_tab.dart';
import 'widgets/patient_consultations_tab.dart';
import 'widgets/patient_reports_tab.dart';
import 'widgets/patient_prescriptions_tab.dart';
import 'widgets/patient_appointments_tab.dart';
import 'widgets/patient_notes_tab.dart';
import 'widgets/patient_documents_section.dart';
import 'widgets/patient_emergency_banner.dart';
import 'widgets/add_clinical_note_modal.dart';
import 'widgets/create_prescription_modal.dart';
import 'widgets/schedule_followup_modal.dart';

class DoctorPatientProfileScreen extends StatefulWidget {
  final String patientId;

  const DoctorPatientProfileScreen({
    super.key,
    this.patientId = 'MED-PAT-10482',
  });

  @override
  State<DoctorPatientProfileScreen> createState() => _DoctorPatientProfileScreenState();
}

class _DoctorPatientProfileScreenState extends State<DoctorPatientProfileScreen> with SingleTickerProviderStateMixin {
  final DoctorPatientService _service = DoctorPatientService();
  late TabController _tabController;

  bool _isLoading = true;
  late PatientProfileFullModel _profileData;
  DoctorAvailability _doctorStatus = DoctorAvailability.available;
  bool _isSidebarExpanded = true;

  final List<String> _tabs = [
    'Overview',
    'Medical History',
    'Consultations',
    'Reports',
    'Prescriptions',
    'Appointments',
    'Notes',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadPatientProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientProfile() async {
    setState(() => _isLoading = true);
    final data = await _service.getPatientProfile(widget.patientId);
    setState(() {
      _profileData = data;
      _isLoading = false;
    });
  }

  void _handleStartConsultation() {
    Navigator.pushNamed(context, '/doctor-consultation');
  }

  void _handleAddNote() {
    AddClinicalNoteModal.show(
      context: context,
      patient: _profileData.patient,
      onNoteAdded: () => _loadPatientProfile(),
    );
  }

  void _handleCreatePrescription() {
    CreatePrescriptionModal.show(
      context: context,
      patient: _profileData.patient,
      onPrescriptionCreated: () => _loadPatientProfile(),
    );
  }

  void _handleScheduleFollowUp() {
    ScheduleFollowupModal.show(
      context: context,
      patient: _profileData.patient,
      onFollowupScheduled: () => _loadPatientProfile(),
    );
  }

  void _handleRefreshAISummary() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing AI clinical summary against latest lab & consultation logs...'),
        duration: Duration(seconds: 1),
      ),
    );
    final newSummary = await _service.generatePatientSummary(widget.patientId);
    setState(() {
      _profileData = PatientProfileFullModel(
        patient: _profileData.patient,
        currentVitals: _profileData.currentVitals,
        activeEmergency: _profileData.activeEmergency,
        summary: newSummary,
        medicalHistory: _profileData.medicalHistory,
        consultations: _profileData.consultations,
        reports: _profileData.reports,
        prescriptions: _profileData.prescriptions,
        appointments: _profileData.appointments,
        notes: _profileData.notes,
        followUps: _profileData.followUps,
        documents: _profileData.documents,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // Persistent Sidebar on Desktop
          if (isDesktop)
            DoctorSidebar(
              selectedNavIndex: 2,
              onNavItemSelected: (index) {
                if (index == 0) {
                  Navigator.pushReplacementNamed(context, '/doctor');
                } else if (index == 1) {
                  Navigator.pushReplacementNamed(context, '/doctor-appointments');
                } else if (index == 2) {
                  Navigator.pushReplacementNamed(context, '/doctor-patients');
                }
              },
              isExpanded: _isSidebarExpanded,
              onToggleExpand: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
              availabilityStatus: _doctorStatus,
              onLogout: () => Navigator.pushReplacementNamed(context, '/portal-select'),
              onRoleSwitcherTap: () {},
              doctorName: 'Dr. Sarah Jenkins',
              specialty: 'Lead Cardiologist',
            ),

          // Main Workspace View
          Expanded(
            child: Column(
              children: [
                // Top Doctor Header
                DoctorHeader(
                  doctorName: 'Dr. Sarah Jenkins',
                  title: 'Patient Profile',
                  subtitle: 'Electronic Health Record & History',
                  availabilityStatus: _doctorStatus,
                  onAvailabilityChanged: (status) => setState(() => _doctorStatus = status),
                  onNotificationTap: () {},
                  onSearchTap: () {},
                  onProfileTap: () {},
                  onThemeToggle: () {},
                  unreadNotificationsCount: 3,
                ),

                // Main Scrollable Area
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryTeal),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 24.0 : 16.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Optional Emergency Banner
                              if (_profileData.activeEmergency != null)
                                PatientEmergencyBanner(
                                  emergencyCase: _profileData.activeEmergency!,
                                  onTakeAction: () {},
                                ),

                              // Patient Identity Header & Quick Stats
                              PatientProfileHeader(
                                profileData: _profileData,
                                onStartConsultation: _handleStartConsultation,
                                onAddNote: _handleAddNote,
                                onCreatePrescription: _handleCreatePrescription,
                                onViewReports: () => _tabController.animateTo(3),
                                onActionSelected: (action) {
                                  if (action == 'reports') {
                                    _tabController.animateTo(3);
                                  } else if (action == 'schedule') {
                                    _handleScheduleFollowUp();
                                  } else if (action == 'documents') {
                                    // Scroll down to documents section
                                  }
                                },
                              ),

                              const SizedBox(height: 20),

                              // Horizontally Scrollable 7 Tabs Bar
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.borderLight),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  isScrollable: true,
                                  indicatorColor: AppTheme.primaryTeal,
                                  indicatorWeight: 3,
                                  labelColor: AppTheme.primaryTeal,
                                  unselectedLabelColor: AppTheme.textSecondary,
                                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Tab Content Subview
                              AnimatedBuilder(
                                animation: _tabController,
                                builder: (context, _) {
                                  switch (_tabController.index) {
                                    case 0:
                                      return PatientOverviewTab(
                                        profileData: _profileData,
                                        onRefreshSummary: _handleRefreshAISummary,
                                        onViewAllConsultations: () => _tabController.animateTo(2),
                                        onViewAllReports: () => _tabController.animateTo(3),
                                        onViewAllPrescriptions: () => _tabController.animateTo(4),
                                      );
                                    case 1:
                                      return PatientMedicalHistoryTab(
                                        historyItems: _profileData.medicalHistory,
                                      );
                                    case 2:
                                      return PatientConsultationsTab(
                                        consultations: _profileData.consultations,
                                      );
                                    case 3:
                                      return PatientReportsTab(
                                        reports: _profileData.reports,
                                      );
                                    case 4:
                                      return PatientPrescriptionsTab(
                                        patient: _profileData.patient,
                                        prescriptions: _profileData.prescriptions,
                                        onPrescriptionCreated: _loadPatientProfile,
                                      );
                                    case 5:
                                      return PatientAppointmentsTab(
                                        appointments: _profileData.appointments,
                                      );
                                    case 6:
                                      return PatientNotesTab(
                                        patient: _profileData.patient,
                                        notes: _profileData.notes,
                                        onNoteAdded: _loadPatientProfile,
                                      );
                                    default:
                                      return const SizedBox.shrink();
                                  }
                                },
                              ),

                              const SizedBox(height: 24),

                              // Uploaded Patient Documents Section
                              PatientDocumentsSection(
                                documents: _profileData.documents,
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
