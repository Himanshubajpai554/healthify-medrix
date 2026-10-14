import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/models/appointment_model.dart' as core;
import '../../core/enums/domain_enums.dart' as domain;
import '../../core/provider/repository_provider.dart';
import '../../shared/widgets/glass_components.dart';
import '../data/doctor_mock_data.dart';
import '../services/doctor_emergency_service.dart';
import '../services/doctor_reports_service.dart';
import '../widgets/emergency_cases_widget.dart';
import '../modals/doctor_modals.dart';
import '../models/doctor_dashboard_models.dart';
import '../models/emergency_models.dart';
import '../models/reports_models.dart';
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

    final connected = RepositoryContainer.instance.serverpodClient != null;
    _appointments = connected ? <DoctorAppointmentModel>[] : DoctorMockData.getAppointments();
    _patientQueue = connected ? <PatientQueueItemModel>[] : DoctorMockData.getPatientQueue();
    _emergencyCases = connected ? <DoctorEmergencyCaseModel>[] : DoctorMockData.getEmergencyCases();
    _pendingReports = connected ? <PendingReportModel>[] : DoctorMockData.getPendingReports();
    _aiSummary = DoctorMockData.getAISummary();
    if (connected) _loadLiveCareData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _markAppointmentCompleted(DoctorAppointmentModel appointment) async {
    if (RepositoryContainer.instance.serverpodClient != null) {
      try {
        await RepositoryContainer.instance.appointmentRepository.updateAppointmentStatus(
          appointment.id, domain.AppointmentStatus.completed,
        );
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not complete appointment: $error')));
        return;
      }
    }
    setState(() {
      _appointments = _appointments.map((a) {
        if (a.id == appointment.id) {
          return a.copyWith(status: AppointmentStatus.completed);
        }

        return a;
      }).toList();
    });
  }

  Future<void> _loadLiveCareData() async {
    final container = RepositoryContainer.instance;
    try {
      final appointmentRows = await container.appointmentRepository
          .getAppointmentsByDoctor(widget.doctorId);
      final emergencyRows = await DoctorEmergencyService().getEmergencyCases();
      final reportRows = await DoctorReportsService().getReports();
      final appointments = appointmentRows.map(_appointmentFromRecord).toList();
      final activeEmergencies = emergencyRows.where((item) =>
          item.status != EmergencyCaseStatus.resolved &&
          item.status != EmergencyCaseStatus.cancelled).map((item) => DoctorEmergencyCaseModel(
            id: item.id,
            patient: PatientModel(
              id: item.patientId,
              name: item.patientName,
              age: item.patientAge,
              gender: item.patientGender,
              avatarUrl: '',
              phone: item.emergencyContactPhone,
              bloodGroup: item.bloodGroup,
              mrn: item.patientId,
              lastVisitDate: 'Not available',
              lastVisitDoctor: widget.doctorName,
              primaryConcern: item.emergencyReason,
              department: item.department,
            ),
            severity: item.priority == EmergencyOperationalPriority.immediate
                ? EmergencySeverity.critical
                : item.priority == EmergencyOperationalPriority.high
                    ? EmergencySeverity.high : EmergencySeverity.moderate,
            arrivalTime: item.arrivalTime.toLocal().toString(),
            assignedBed: item.location,
            department: item.department,
            assignedDoctor: item.assignedDoctor,
            currentStatus: item.status.label,
          )).toList();
      final pendingReports = reportRows.where((report) => report.status != ReportStatus.reviewed).map((report) => PendingReportModel(
        id: report.id,
        patient: PatientModel(
          id: report.patientId,
          name: report.patientName,
          age: report.patientAge,
          gender: report.patientGender,
          avatarUrl: '',
          phone: '',
          bloodGroup: '',
          mrn: report.patientId,
          lastVisitDate: 'Not available',
          lastVisitDoctor: widget.doctorName,
          primaryConcern: report.title,
          department: report.department,
        ),
        reportType: report.title,
        date: report.uploadedDate.toLocal().toString(),
        priority: ReportPriority.normal,
        isReviewed: report.status == ReportStatus.reviewed,
        clinicalNotes: report.reviewNotes,
        labValues: const {},
      )).toList();
      final summaryPatient = appointments.firstOrNull?.patient ?? PatientModel(
        id: '', name: 'No assigned patient', age: 0, gender: 'Not reported', avatarUrl: '',
        phone: '', bloodGroup: '', mrn: '', lastVisitDate: 'Not available',
        lastVisitDoctor: widget.doctorName, primaryConcern: '', department: widget.specialty,
      );
      final liveSummary = AIPatientSummaryModel(
        patient: summaryPatient,
        previousVisitsCount: appointments.where((item) => item.status == AppointmentStatus.completed).length,
        recentLabReportsCount: reportRows.length,
        currentMedications: const [],
        lastConsultationText: appointments.where((item) => item.status == AppointmentStatus.completed).firstOrNull?.reasonForVisit ?? 'No completed consultation is recorded.',
        recentReportAttention: pendingReports.isEmpty ? 'No reports are awaiting review.' : '${pendingReports.length} report(s) need review.',
        keyFindings: 'Summary of assigned hospital records. No AI clinical inference was performed.',
      );
      final waiting = appointments.where((item) => item.status == AppointmentStatus.waiting || item.status == AppointmentStatus.checkedIn).toList();
      if (!mounted) return;
      setState(() {
        _appointments = appointments;
        _patientQueue = [
          for (var i = 0; i < waiting.length; i++)
            PatientQueueItemModel(position: '${i + 1}', patient: waiting[i].patient,
              appointmentTime: waiting[i].appointmentTime, waitingTime: 'Not reported', status: waiting[i].status),
        ];
        _emergencyCases = activeEmergencies;
        _pendingReports = pendingReports;
        _aiSummary = liveSummary;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load clinical workspace: $error')),
        );
      }
    }
  }

  DoctorAppointmentModel _appointmentFromRecord(core.AppointmentItem row) {
    final time = TimeOfDay.fromDateTime(row.dateTime);
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final patient = PatientModel(id: row.patientId.isEmpty ? row.id : row.patientId,
      name: row.patientName.isEmpty ? 'Patient' : row.patientName, age: 0,
      gender: 'Not reported', avatarUrl: '', phone: '', bloodGroup: '', mrn: row.patientId,
      lastVisitDate: 'Not available', lastVisitDoctor: widget.doctorName,
      primaryConcern: row.reason, department: row.department);
    final status = switch (row.status.toLowerCase()) {
      'pending' || 'waiting' => AppointmentStatus.waiting,
      'checkedin' || 'checked_in' => AppointmentStatus.checkedIn,
      'inconsultation' || 'in_consultation' || 'inprogress' => AppointmentStatus.inConsultation,
      'completed' => AppointmentStatus.completed,
      'cancelled' => AppointmentStatus.cancelled,
      'noshow' || 'no_show' || 'missed' => AppointmentStatus.noShow,
      _ => AppointmentStatus.upcoming,
    };
    return DoctorAppointmentModel(id: row.id, patient: patient,
      appointmentTime: '$hour:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}',
      appointmentType: row.type.isEmpty ? 'Consultation' : row.type, department: row.department,
      status: status, tokenNumber: '', reasonForVisit: row.reason, date: row.dateTime);
  }

  Future<void> _startConsultation(DoctorAppointmentModel appointment) async {
    if (RepositoryContainer.instance.serverpodClient != null) {
      try {
        await RepositoryContainer.instance.appointmentRepository.updateAppointmentStatus(
          appointment.id, domain.AppointmentStatus.inConsultation,
        );
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not start consultation: $error')));
        return;
      }
    }
    if (!mounted) return;
    DoctorModals.showStartConsultationModal(
      context: context,
      appointment: appointment.copyWith(status: AppointmentStatus.inConsultation),
      onConsultationCompleted: () => _markAppointmentCompleted(appointment),
    );
  }

  Future<void> _rescheduleAppointment(
    DoctorAppointmentModel appointment,
    String newSlot,
  ) async {
    final records = RepositoryContainer.instance.hospitalOperationalRepository;
    var newDate = appointment.date;
    final parsed = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false).firstMatch(newSlot.trim());
    if (parsed != null) {
      var hour = int.parse(parsed.group(1)!);
      final minute = int.parse(parsed.group(2)!);
      final period = parsed.group(3)!.toUpperCase();
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      newDate = DateTime(appointment.date.year, appointment.date.month, appointment.date.day, hour, minute);
      if (!newDate.isAfter(DateTime.now())) newDate = newDate.add(const Duration(days: 1));
    }
    if (records != null) {
      try {
        final row = await records.get('appointments', appointment.id);
        if (row == null) throw StateError('Appointment not found.');
        await records.save('appointments', appointment.id, {
          ...row, 'dateTime': newDate.toUtc().toIso8601String(),
          'appointmentTime': newSlot, 'status': 'scheduled',
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not reschedule appointment: $error')));
        return;
      }
    }
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
            onStartConsultation: _startConsultation,
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
              onReportReviewed: (notes) async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await DoctorReportsService().markAsReviewed(
                    reportId: r.id,
                    reviewNotes: notes,
                    doctorName: widget.doctorName,
                  );
                  await _loadLiveCareData();
                } catch (error) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Could not review report: $error')),
                    );
                  }
                }
              },
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
