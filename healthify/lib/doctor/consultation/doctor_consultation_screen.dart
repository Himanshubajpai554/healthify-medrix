import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../widgets/doctor_sidebar.dart';
import '../widgets/doctor_header.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/patient_profile_models.dart';
import '../models/consultation_models.dart';
import '../services/doctor_consultation_service.dart';
import 'widgets/consultation_header.dart';
import 'widgets/patient_snapshot_card.dart';
import 'widgets/consultation_overview_tab.dart';
import 'widgets/consultation_notes_tab.dart';
import 'widgets/consultation_reports_tab.dart';
import 'widgets/consultation_prescriptions_tab.dart';
import 'widgets/consultation_history_tab.dart';
import 'widgets/consultation_context_sidebar.dart';
import 'widgets/consultation_summary_modal.dart';

class DoctorConsultationScreen extends StatefulWidget {
  final String consultationId;

  const DoctorConsultationScreen({
    super.key,
    this.consultationId = 'CON-2026-9041',
  });

  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> with SingleTickerProviderStateMixin {
  final DoctorConsultationService _service = DoctorConsultationService();
  late TabController _tabController;
  Timer? _autosaveDebounce;

  bool _isLoading = true;
  late ConsultationFullModel _consultation;
  List<MedicalHistoryItemModel> _medicalHistory = [];
  AutosaveState _autosaveState = AutosaveState.saved;
  DoctorAvailability _doctorStatus = DoctorAvailability.busy;
  bool _isSidebarExpanded = true;

  final List<String> _tabs = [
    'Overview',
    'Clinical Notes',
    'Reports',
    'Prescriptions',
    'History',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _autosaveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _service.getConsultation(widget.consultationId);
    final history = await _service.getMedicalHistory(data.patient.id);

    setState(() {
      _consultation = data;
      _medicalHistory = history;
      _isLoading = false;
    });
  }

  void _onModelChanged(ConsultationFullModel updated) {
    setState(() {
      _consultation = updated;
      _autosaveState = AutosaveState.saving;
    });

    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(const Duration(milliseconds: 1200), () async {
      await _service.saveConsultationDraft(_consultation);
      if (mounted) {
        setState(() {
          _autosaveState = AutosaveState.saved;
        });
      }
    });
  }

  void _handleSaveDraftManually() async {
    setState(() => _autosaveState = AutosaveState.saving);
    await _service.saveConsultationDraft(_consultation);
    if (mounted) {
      setState(() => _autosaveState = AutosaveState.saved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation draft saved successfully.'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handlePause() {
    _service.logAuditEvent(action: 'Paused Consultation', patientId: _consultation.patient.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation paused. Draft saved to active doctor session.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pushReplacementNamed(context, '/doctor-appointments');
  }

  void _handleCompleteConsultation() {
    ConsultationSummaryModal.show(
      context: context,
      consultation: _consultation,
      onEdit: () => _tabController.animateTo(0),
      onConfirmComplete: () async {
        final completed = await _service.completeConsultation(_consultation);
        if (mounted) {
          setState(() => _consultation = completed);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Consultation completed successfully for ${_consultation.patient.name}. Saved to EHR record.'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacementNamed(context, '/doctor-appointments');
        }
      },
    );
  }

  void _handleRefreshAISummary() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing AI record summary...'), duration: Duration(seconds: 1)),
    );
    final history = await _service.getMedicalHistory(_consultation.patient.id);
    setState(() {
      _medicalHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isTablet = MediaQuery.of(context).size.width >= 750 && MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: isTablet
          ? Drawer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoading ? const SizedBox.shrink() : ConsultationContextSidebar(consultation: _consultation, history: _medicalHistory),
              ),
            )
          : null,
      body: Row(
        children: [
          // Persistent Doctor Sidebar on Desktop
          if (isDesktop)
            DoctorSidebar(
              selectedNavIndex: 1,
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

          // Main Screen Column
          Expanded(
            child: Column(
              children: [
                // Top Doctor Header Bar
                DoctorHeader(
                  doctorName: 'Dr. Sarah Jenkins',
                  title: 'Clinical Consultation',
                  subtitle: 'Active Patient Encounter Workspace',
                  availabilityStatus: _doctorStatus,
                  onAvailabilityChanged: (status) => setState(() => _doctorStatus = status),
                  onNotificationTap: () {},
                  onSearchTap: () {},
                  onProfileTap: () {},
                  onThemeToggle: () {},
                  unreadNotificationsCount: 2,
                ),

                // Main Workspace Scrollable
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Persistent Consultation Header
                              ConsultationHeader(
                                consultation: _consultation,
                                autosaveState: _autosaveState,
                                onSaveDraft: _handleSaveDraftManually,
                                onPause: _handlePause,
                                onCompleteConsultation: _handleCompleteConsultation,
                              ),
                              const SizedBox(height: 16),

                              // 2. Patient Snapshot Panel
                              PatientSnapshotCard(patient: _consultation.patient),
                              const SizedBox(height: 18),

                              // 3. Workspace 5 Tabs Header & Main Content Area
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Center Main Consultation Form Column
                                  Expanded(
                                    flex: 7,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 5 Tabs Navigation Bar
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.72),
                                            borderRadius: BorderRadius.circular(14),
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
                                            tabs: _tabs.map((t) => Tab(text: t)).toList(),
                                          ),
                                        ),
                                        const SizedBox(height: 18),

                                        // Tab Content Switcher
                                        AnimatedBuilder(
                                          animation: _tabController,
                                          builder: (context, _) {
                                            switch (_tabController.index) {
                                              case 0:
                                                return ConsultationOverviewTab(
                                                  consultation: _consultation,
                                                  onChanged: _onModelChanged,
                                                  onRefreshAISummary: _handleRefreshAISummary,
                                                  onSaveNote: _handleSaveDraftManually,
                                                );
                                              case 1:
                                                return ConsultationNotesTab(
                                                  consultation: _consultation,
                                                  onChanged: _onModelChanged,
                                                );
                                              case 2:
                                                return ConsultationReportsTab(
                                                  reports: _consultation.reportsReferenced,
                                                  attachments: _consultation.attachments,
                                                  onToggleAttachReport: (id) {
                                                    _service.attachReport(consultationId: _consultation.id, attachmentId: id);
                                                    _loadData();
                                                  },
                                                );
                                              case 3:
                                                return ConsultationPrescriptionsTab(
                                                  prescriptions: _consultation.prescriptions,
                                                  onChanged: (newRxList) {
                                                    _onModelChanged(_consultation.copyWith(prescriptions: newRxList));
                                                  },
                                                  onSavePrescription: () {
                                                    _service.savePrescription(consultationId: _consultation.id, prescriptions: _consultation.prescriptions);
                                                  },
                                                );
                                              case 4:
                                                return ConsultationHistoryTab(historyItems: _medicalHistory);
                                              default:
                                                return const SizedBox.shrink();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right-side Desktop Context Sidebar Panel
                                  if (isDesktop) ...[
                                    const SizedBox(width: 18),
                                    Expanded(
                                      flex: 3,
                                      child: ConsultationContextSidebar(
                                        consultation: _consultation,
                                        history: _medicalHistory,
                                      ),
                                    ),
                                  ],
                                ],
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
