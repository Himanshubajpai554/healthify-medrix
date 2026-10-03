import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../data/doctor_mock_data.dart';
import '../widgets/emergency_cases_widget.dart';
import '../modals/doctor_modals.dart';
import '../models/doctor_dashboard_models.dart';
import '../widgets/ai_patient_summary_widget.dart';
import '../widgets/patient_queue_widget.dart';
import '../widgets/pending_reports_widget.dart';
import '../widgets/today_appointments_section.dart';

class DoctorCareScreen extends StatefulWidget {
  final bool embedInDashboard;
  final String doctorName;
  final String doctorId;
  final String specialty;

  const DoctorCareScreen({
    super.key,
    this.embedInDashboard = false,
    this.doctorName = 'Dr. Sarah Jenkins',
    this.doctorId = 'DOC-4019',
    this.specialty = 'Lead Cardiologist',
  });

  @override
  State<DoctorCareScreen> createState() => _DoctorCareScreenState();
}

class _DoctorCareScreenState extends State<DoctorCareScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<DoctorAppointmentModel> _appointments;
  late List<PatientQueueItemModel> _patientQueue;
  late List<DoctorEmergencyCaseModel> _emergencyCases;
  late List<PendingReportModel> _pendingReports;
  late AIPatientSummaryModel _aiSummary;

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  static const Color _emergency = Color(0xFFEF4444);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _info = Color(0xFF3B82F6);
  static const Color _purple = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 5, vsync: this);

    _appointments = DoctorMockData.getAppointments();
    _patientQueue = DoctorMockData.getPatientQueue();
    _emergencyCases = DoctorMockData.getEmergencyCases();
    _pendingReports = DoctorMockData.getPendingReports();
    _aiSummary = DoctorMockData.getAISummary();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Color _primaryColor(bool isDark) {
    return isDark ? _primaryDark : _primary;
  }

  Color _background(bool isDark) {
    return isDark ? const Color(0xFF061817) : const Color(0xFFF3FAF9);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : HealthifyGlassTheme.getTextPrimary(isDark);
  }

  Color _secondaryText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.58)
        : HealthifyGlassTheme.getTextSecondary(isDark);
  }

  Color _mutedText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.38)
        : HealthifyGlassTheme.getTextMuted(isDark);
  }

  Color _glassSurface(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.045)
        : Colors.white.withValues(alpha: 0.72);
  }

  Color _glassBorder(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.085)
        : Colors.white.withValues(alpha: 0.82);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    final bodyContent = Stack(
      children: [
        _buildAmbientBackground(isDark),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.embedInDashboard ? 0 : 20,
            vertical: widget.embedInDashboard ? 0 : 20,
          ),
          child: _buildContent(context, isDark),
        ),
      ],
    );

    if (widget.embedInDashboard) {
      return Container(
        color: _background(isDark),
        child: bodyContent,
      );
    }

    return Scaffold(
      backgroundColor: _background(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          child: bodyContent,
        ),
      ),
    );
  }

  // ===========================================================================
  // MAIN CONTENT
  // ===========================================================================

  Widget _buildContent(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkspaceHeader(context, isDark),

        const SizedBox(height: 16),

        _buildClinicalTabs(context, isDark),

        const SizedBox(height: 16),

        _buildTabContent(context, isDark),
      ],
    );
  }

  // ===========================================================================
  // AMBIENT BACKGROUND
  // ===========================================================================

  Widget _buildAmbientBackground(bool isDark) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: _buildGlow(
                color: _primaryColor(isDark),
                size: 300,
                opacity: isDark ? 0.075 : 0.045,
              ),
            ),

            Positioned(
              top: 320,
              left: -160,
              child: _buildGlow(
                color: _info,
                size: 280,
                opacity: isDark ? 0.035 : 0.018,
              ),
            ),

            Positioned(
              bottom: -150,
              right: 120,
              child: _buildGlow(
                color: _purple,
                size: 300,
                opacity: isDark ? 0.025 : 0.015,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow({
    required Color color,
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: 100,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildWorkspaceHeader(BuildContext context, bool isDark) {
    final primary = _primaryColor(isDark);

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 46 : 54,
                    height: compact ? 46 : 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, primary.withValues(alpha: 0.68)],
                      ),
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(
                            alpha: isDark ? 0.25 : 0.14,
                          ),
                          blurRadius: 18,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.medical_services_rounded,
                      size: compact ? 23 : 27,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clinical Care Workspace',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 18 : 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.35,
                            color: _primaryText(isDark),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Integrated OPD consultations, emergency care, follow-ups & reports',
                          maxLines: compact ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: _secondaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!compact) ...[
                    const SizedBox(width: 16),
                    _buildDoctorIdentity(isDark, primary),
                  ],
                ],
              ),

              if (compact) ...[
                const SizedBox(height: 14),
                _buildDoctorIdentity(isDark, primary, expanded: true),
              ],

              const SizedBox(height: 18),

              _buildWorkspaceStats(isDark, primary),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDoctorIdentity(
    bool isDark,
    Color primary, {
    bool expanded = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: _glassSurface(isDark),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _glassBorder(isDark)),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: isDark ? 0.15 : 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, size: 17, color: primary),
          ),

          const SizedBox(width: 9),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _primaryText(isDark),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${widget.specialty} • ${widget.doctorId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: _secondaryText(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WORKSPACE STATS
  // ===========================================================================

  Widget _buildWorkspaceStats(bool isDark, Color primary) {
    final todayAppointments = _appointments.length;

    final emergencyCount = _emergencyCases.length;

    final pendingReports = _pendingReports.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        final cards = [
          _buildMiniStat(
            icon: Icons.calendar_today_rounded,
            title: "Today's Appointments",
            value: '$todayAppointments',
            color: primary,
            isDark: isDark,
          ),
          _buildMiniStat(
            icon: Icons.emergency_rounded,
            title: 'Emergency Cases',
            value: '$emergencyCount',
            color: _emergency,
            isDark: isDark,
          ),
          _buildMiniStat(
            icon: Icons.assignment_late_rounded,
            title: 'Pending Reports',
            value: '$pendingReports',
            color: _warning,
            isDark: isDark,
          ),
        ];

        if (compact) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  SizedBox(width: 175, child: cards[i]),
                  if (i != cards.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 8),
            Expanded(child: cards[1]),
            const SizedBox(width: 8),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _glassSurface(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _glassBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.12 : 0.075),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: _secondaryText(isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _primaryText(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TABS
  // ===========================================================================

  Widget _buildClinicalTabs(BuildContext context, bool isDark) {
    final primary = _primaryColor(isDark);

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(7),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: _glassSurface(isDark),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _glassBorder(isDark)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(3),
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withValues(alpha: 0.82)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
                    blurRadius: 12,
                    spreadRadius: -3,
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: _secondaryText(isDark),
              labelStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.all(3),
              tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.video_call_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Consultation'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emergency_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Emergency'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_repeat_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Follow-ups'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.medication_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Prescriptions'),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.assignment_rounded, size: 16),
                        SizedBox(width: 6),
                        Text('Reports'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB CONTENT
  // ===========================================================================

  Widget _buildTabContent(BuildContext context, bool isDark) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return SizedBox(
          height: 650,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildConsultationTab(context, isDark),
              _buildEmergencyTab(context, isDark),
              _buildFollowUpsTab(context, isDark),
              _buildPrescriptionsTab(context, isDark),
              _buildReportsTab(context, isDark),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // CONSULTATION
  // ===========================================================================

  Widget _buildConsultationTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildSectionHeader(
            icon: Icons.people_alt_rounded,
            title: 'Consultation Queue',
            subtitle: 'Manage patients waiting for consultation',
            color: _primaryColor(isDark),
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          PatientQueueWidget(
            queue: _patientQueue,
            onCallNext: (q) {},
            onViewPatient: (q) => DoctorModals.showPatientProfileModal(
              context: context,
              patient: q.patient,
            ),
          ),

          const SizedBox(height: 18),

          _buildSectionHeader(
            icon: Icons.auto_awesome_rounded,
            title: 'AI Patient Summary',
            subtitle: 'Clinical insights generated from patient data',
            color: _purple,
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          AIPatientSummaryWidget(
            aiSummary: _aiSummary,
            onViewFullSummary: () => DoctorModals.showPatientProfileModal(
              context: context,
              patient: _aiSummary.patient,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMERGENCY
  // ===========================================================================

  Widget _buildEmergencyTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildSectionHeader(
            icon: Icons.emergency_rounded,
            title: 'Emergency Care',
            subtitle: 'Prioritized cases requiring immediate attention',
            color: _emergency,
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          EmergencyCasesWidget(
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
        ],
      ),
    );
  }

  // ===========================================================================
  // FOLLOW UPS
  // ===========================================================================

  Widget _buildFollowUpsTab(BuildContext context, bool isDark) {
    final followUps = _appointments
        .where((a) => a.appointmentType.contains('Follow-up'))
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildSectionHeader(
            icon: Icons.event_repeat_rounded,
            title: 'Follow-up Care',
            subtitle: 'Track scheduled follow-ups and ongoing care',
            color: _info,
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          TodayAppointmentsSection(
            appointments: followUps,
            onStartConsultation: (apt) =>
                DoctorModals.showStartConsultationModal(
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
              onRescheduled: (newSlot) => _rescheduleAppointment(apt, newSlot),
            ),
            onMarkCompleted: (apt) => _markAppointmentCompleted(apt),
            onViewAll: () {},
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PRESCRIPTIONS
  // ===========================================================================

  Widget _buildPrescriptionsTab(BuildContext context, bool isDark) {
    final primary = _primaryColor(isDark);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: GlassCard(
        borderRadius: 22,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;

                final header = Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: isDark ? 0.13 : 0.08),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Icon(
                        Icons.medication_rounded,
                        size: 21,
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Clinical Prescriptions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _primaryText(isDark),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Manage current patient medication plans',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: _secondaryText(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final button = GlassPrimaryButton(
                  height: 36,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prescription module loaded.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Create Prescription',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [header, const SizedBox(height: 12), button],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: header),
                    const SizedBox(width: 12),
                    button,
                  ],
                );
              },
            ),

            const SizedBox(height: 18),

            Container(height: 1, color: _glassBorder(isDark)),

            const SizedBox(height: 14),

            ..._appointments
                .take(4)
                .map((apt) => _buildPrescriptionCard(context, apt, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(
    BuildContext context,
    DoctorAppointmentModel appointment,
    bool isDark,
  ) {
    final primary = _primaryColor(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _glassSurface(isDark),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _glassBorder(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: isDark ? 0.12 : 0.075),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.medication_rounded, size: 18, color: primary),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prescription for ${appointment.patient.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _primaryText(isDark),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Amlodipine 5mg • Metoprolol 25mg',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: _secondaryText(isDark),
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 11,
                      color: _mutedText(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.appointmentTime,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: _mutedText(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          GlassSecondaryButton(
            height: 32,
            onPressed: () => DoctorModals.showPatientProfileModal(
              context: context,
              patient: appointment.patient,
            ),
            child: const Text(
              'View',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // REPORTS
  // ===========================================================================

  Widget _buildReportsTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildSectionHeader(
            icon: Icons.assignment_rounded,
            title: 'Pending Reports',
            subtitle: 'Review diagnostic reports awaiting clinical action',
            color: _warning,
            isDark: isDark,
          ),

          const SizedBox(height: 10),

          PendingReportsWidget(
            reports: _pendingReports,
            onReviewReport: (r) => DoctorModals.showReviewReportModal(
              context: context,
              report: r,
              onReportReviewed: (notes) {},
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION HEADER
  // ===========================================================================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.11 : 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.16 : 0.10),
            ),
          ),
          child: Icon(icon, size: 17, color: color),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _primaryText(isDark),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: _secondaryText(isDark)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
