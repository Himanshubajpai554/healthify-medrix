import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/provider/repository_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/page_transitions.dart';
import '../models/patient_portal_models.dart';
import './patient_appointment_detail_screen.dart';
import '../doctors/patient_doctor_profile_screen.dart';
import './book_appointment_modal.dart';
import './cancel_appointment_modal.dart';
import '../emergency/emergency_hospitals_modal.dart';
import './reschedule_appointment_modal.dart';

class PatientAppointmentsWidget extends StatefulWidget {
  final VoidCallback? onFindDoctorTap;
  final VoidCallback? onFindHospitalTap;

  const PatientAppointmentsWidget({
    super.key,
    this.onFindDoctorTap,
    this.onFindHospitalTap,
  });

  @override
  State<PatientAppointmentsWidget> createState() =>
      _PatientAppointmentsWidgetState();
}

class _PatientAppointmentsWidgetState extends State<PatientAppointmentsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  late List<PatientAppointment> _appointments;

  // ═══════════════════════════════════════════════
  // HEALTHIFY GLASS COLORS
  // ═══════════════════════════════════════════════

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
        ? Color(0xFF0D9488).withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.90);
  }

  Color _border(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.075)
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

  // ═══════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _appointments = <PatientAppointment>[];
    _loadAppointments();
  }

  Map<String, dynamic> _appointmentJson(PatientAppointment a) => {
        'id': a.id,
        if (a.doctorId != null) 'doctorId': a.doctorId,
        if (a.hospitalId != null) 'hospitalId': a.hospitalId,
        'doctorName': a.doctorName,
        'specialty': a.specialty,
        'hospitalName': a.hospitalName,
        'hospitalAddress': a.hospitalAddress,
        'dateTime': a.dateTime.toIso8601String(),
        'consultationType': a.consultationType,
        'status': a.status,
        'tokenNumber': a.tokenNumber,
        'consultationFee': a.consultationFee,
        'reasonForVisit': a.reasonForVisit,
        'rescheduledFrom': a.rescheduledFrom?.toIso8601String(),
        'cancellationReason': a.cancellationReason,
        'cancelledAt': a.cancelledAt?.toIso8601String(),
        'generatedReportTitles': a.generatedReportTitles,
      };

  PatientAppointment _appointmentFrom(Map<String, dynamic> row) => PatientAppointment(
        id: '${row['id']}',
        doctorId: row['doctorId'] as String?,
        hospitalId: row['hospitalId'] as String?,
        doctorName: '${row['doctorName'] ?? ''}',
        specialty: '${row['specialty'] ?? ''}',
        hospitalName: '${row['hospitalName'] ?? ''}',
        hospitalAddress: '${row['hospitalAddress'] ?? ''}',
        dateTime: DateTime.tryParse('${row['dateTime']}') ?? DateTime.now(),
        consultationType: '${row['consultationType'] ?? 'In-person consultation'}',
        status: '${row['status'] ?? 'Confirmed'}',
        tokenNumber: '${row['tokenNumber'] ?? ''}',
        consultationFee: (row['consultationFee'] as num?)?.toDouble() ?? 0,
        reasonForVisit: '${row['reasonForVisit'] ?? ''}',
        rescheduledFrom: row['rescheduledFrom'] == null ? null : DateTime.tryParse('${row['rescheduledFrom']}'),
        cancellationReason: row['cancellationReason'] as String?,
        cancelledAt: row['cancelledAt'] == null ? null : DateTime.tryParse('${row['cancelledAt']}'),
        generatedReportTitles: (row['generatedReportTitles'] as List? ?? const []).map((e) => e.toString()).toList(),
      );

  Future<void> _loadAppointments() async {
    final portal = RepositoryContainer.instance.patientPortalRepository;
    if (portal == null) return;
    try {
      final rows = await portal.list('patientAppointments');
      if (!mounted) return;
      setState(() => _appointments = rows.map(_appointmentFrom).toList());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load appointments: $error')),
        );
      }
    }
  }

  Future<void> _saveAppointment(PatientAppointment appointment) async {
    try {
      await RepositoryContainer.instance.patientPortalRepository?.save(
        'patientAppointments', appointment.id, _appointmentJson(appointment),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment was not saved: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════
  // FILTERS
  // ═══════════════════════════════════════════════

  List<PatientAppointment> get _upcomingAppointments {
    return _appointments
        .where(
          (a) =>
              (a.status == 'Requested' ||
                  a.status == 'Confirmed' ||
                  a.status == 'Rescheduled') &&
              _matchesQuery(a),
        )
        .toList();
  }

  List<PatientAppointment> get _pastAppointments {
    return _appointments
        .where((a) => a.status == 'Completed' && _matchesQuery(a))
        .toList();
  }

  List<PatientAppointment> get _cancelledAppointments {
    return _appointments
        .where((a) => a.status == 'Cancelled' && _matchesQuery(a))
        .toList();
  }

  bool _matchesQuery(PatientAppointment a) {
    final q = _searchQuery.trim().toLowerCase();

    if (q.isEmpty) return true;

    return a.doctorName.toLowerCase().contains(q) ||
        a.specialty.toLowerCase().contains(q) ||
        a.hospitalName.toLowerCase().contains(q) ||
        a.id.toLowerCase().contains(q);
  }

  // ═══════════════════════════════════════════════
  // DOCTOR PROFILE
  // ═══════════════════════════════════════════════

  void _openDoctorProfile(
    String doctorName,
    String specialty,
    String hospital,
  ) {
    final docResult = DoctorSearchResult(
      id: 'DOC-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      name: doctorName,
      specialty: specialty,
      department: specialty.split(' ')[0],
      hospitalName: hospital,
      distanceKm: 2.4,
      rating: 4.8,
      reviewsCount: 142,
      experienceYears: 12,
      consultationFee: 600,
      availableSlots: const ['Today 04:30 PM', 'Tomorrow 10:00 AM'],
    );

    Navigator.push(
      context,
      FadePageRoute(
        page: PatientDoctorProfileScreen(
          doctor: docResult,
          onAppointmentBooked: (newAppt) async {
            setState(() {
              _appointments.insert(0, newAppt);
            });
            await _saveAppointment(newAppt);
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // BOOK APPOINTMENT
  // ═══════════════════════════════════════════════

  void _openBookModal() {
    BookAppointmentModal.show(
      context,
      onSuccess: (msg) async {
        final portal = RepositoryContainer.instance.patientPortalRepository;
        if (portal != null) {
          final rows = await portal.list('patientAppointments');
          if (!mounted) return;
          setState(() => _appointments = rows.map(_appointmentFrom).toList());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════
  // MAIN BUILD
  // ═══════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: _background(isDark),
      child: Stack(
        children: [
          // BACKGROUND GLOWS
          Positioned(
            top: -90,
            right: -80,
            child: _buildGlow(
              size: 260,
              color: _primary,
              opacity: isDark ? 0.09 : 0.07,
            ),
          ),

          Positioned(
            top: 420,
            left: -120,
            child: _buildGlow(
              size: 260,
              color: const Color(0xFF14B8A6),
              opacity: isDark ? 0.055 : 0.045,
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),

                const SizedBox(height: 16),

                _buildEmergencyBanner(isDark),

                const SizedBox(height: 16),

                _buildSearchBar(isDark),
                const SizedBox(height: 16),

                _buildTabs(isDark),

                const SizedBox(height: 16),

                SizedBox(
                  height: 620,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUpcomingTab(isDark),
                      _buildPastTab(isDark),
                      _buildCancelledTab(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointments',
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Manage your doctor consultations & OPD tokens',
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: _openBookModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Book',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  // EMERGENCY BANNER
  // ═══════════════════════════════════════════════

  Widget _buildEmergencyBanner(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: isDark ? 0.075 : 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need Urgent Care Right Now?',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Colors.redAccent,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'For life-threatening emergencies, locate nearby 24/7 ER beds & ambulances.',
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 10.8,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () => EmergencyHospitalsModal.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    'Find ER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: TextStyle(color: _primaryText(isDark), fontSize: 14),
      cursorColor: _primary,
      decoration: InputDecoration(
        hintText: 'Search doctor, specialty or hospital...',
        hintStyle: TextStyle(color: _secondaryText(isDark), fontSize: 13),

        prefixIcon: const Icon(Icons.search_rounded, color: _primary),

        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, color: _secondaryText(isDark)),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,

        filled: true,
        fillColor: _surfaceStrong(isDark),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

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
          borderSide: BorderSide(
            color: _primary.withValues(alpha: isDark ? 0.55 : 0.40),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // TABS
  // ═══════════════════════════════════════════════

  Widget _buildTabs(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border(isDark)),
          ),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: _primary.withValues(alpha: isDark ? 0.18 : 0.11),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _primary.withValues(alpha: 0.16)),
            ),
            labelColor: _primary,
            unselectedLabelColor: _secondaryText(isDark),
            labelStyle: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'Upcoming (${_upcomingAppointments.length})'),
              Tab(text: 'Past (${_pastAppointments.length})'),
              Tab(text: 'Cancelled (${_cancelledAppointments.length})'),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // UPCOMING
  // ═══════════════════════════════════════════════

  Widget _buildUpcomingTab(bool isDark) {
    final list = _upcomingAppointments;

    if (list.isEmpty) {
      return _buildEmptyState(
        title: 'No upcoming appointments',
        subtitle: 'Book an appointment with a doctor or hospital near you.',
        showActions: true,
        isDark: isDark,
      );
    }

    if (MediaQuery.of(context).size.width >= 600) {
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width >= 1200 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 290,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(list[index], isDark);
        },
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(list[index], isDark);
      },
    );
  }

  // ═══════════════════════════════════════════════
  // PAST
  // ═══════════════════════════════════════════════

  Widget _buildPastTab(bool isDark) {
    final list = _pastAppointments;

    if (list.isEmpty) {
      return _buildEmptyState(
        title: 'No completed past appointments',
        subtitle:
            'Your completed consultations and medical history will appear here.',
        showActions: false,
        isDark: isDark,
      );
    }

    if (MediaQuery.of(context).size.width >= 600) {
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width >= 1200 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 290,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(list[index], isDark);
        },
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(list[index], isDark);
      },
    );
  }

  // ═══════════════════════════════════════════════
  // CANCELLED
  // ═══════════════════════════════════════════════

  Widget _buildCancelledTab(bool isDark) {
    final list = _cancelledAppointments;

    if (list.isEmpty) {
      return _buildEmptyState(
        title: 'No cancelled appointments',
        subtitle:
            'Appointments you cancel will be listed here for record keeping.',
        showActions: false,
        isDark: isDark,
      );
    }

    if (MediaQuery.of(context).size.width >= 600) {
      return GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width >= 1200 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 290,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(list[index], isDark);
        },
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(list[index], isDark);
      },
    );
  }

  // ═══════════════════════════════════════════════
  // APPOINTMENT CARD
  // ═══════════════════════════════════════════════

  Widget _buildAppointmentCard(PatientAppointment appt, bool isDark) {
    final isUpcoming =
        appt.status == 'Requested' ||
        appt.status == 'Confirmed' ||
        appt.status == 'Rescheduled';

    final isCancelled = appt.status == 'Cancelled';

    final statusColor = _getStatusColor(appt.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border(isDark)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.035),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  FadePageRoute(
                    page: PatientAppointmentDetailScreen(
                      appointment: appt,
                      onAppointmentUpdated: (updated) {
                        setState(() {
                          final idx = _appointments.indexWhere(
                            (a) => a.id == updated.id,
                          );

                          if (idx != -1) {
                            _appointments[idx] = updated;
                          }
                        });
                      _saveAppointment(updated);
                      },
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─────────────────────
                    // DOCTOR HEADER
                    // ─────────────────────
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _primary.withValues(alpha: 0.18),
                                _primaryDark.withValues(alpha: 0.08),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _primary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _doctorInitial(appt.doctorName),
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appt.doctorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _primaryText(isDark),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${appt.specialty} • ${appt.hospitalName}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _secondaryText(isDark),
                                  fontSize: 11.5,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        _statusBadge(appt.status, statusColor, isDark),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Container(height: 1, color: _border(isDark)),

                    const SizedBox(height: 14),

                    // ─────────────────────
                    // DATE CARD
                    // ─────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: _primary.withValues(
                          alpha: isDark ? 0.075 : 0.055,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _primary.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 37,
                            height: 37,
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.11),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.access_time_filled_rounded,
                              color: _primary,
                              size: 19,
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              _formatDateTime(appt.dateTime),
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _surfaceStrong(isDark),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: _primary.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Text(
                              appt.tokenNumber,
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─────────────────────
                    // REPORT
                    // ─────────────────────
                    if (appt.generatedReportTitles.isNotEmpty) ...[
                      const SizedBox(height: 11),

                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              '${appt.generatedReportTitles.length} Medical report${appt.generatedReportTitles.length > 1 ? 's' : ''} available',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.70)
                                    : Colors.blue,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 14),

                    // ─────────────────────
                    // FOOTER
                    // ─────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                appt.consultationType.toLowerCase().contains(
                                      'video',
                                    )
                                    ? Icons.videocam_outlined
                                    : Icons.local_hospital_outlined,
                                size: 16,
                                color: _secondaryText(isDark),
                              ),

                              const SizedBox(width: 6),

                              Expanded(
                                child: Text(
                                  appt.consultationType,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _secondaryText(isDark),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (isUpcoming) ...[
                          _cardActionButton(
                            label: 'Reschedule',
                            icon: Icons.edit_calendar_rounded,
                            color: _primary,
                            isDark: isDark,
                            onPressed: () {
                              RescheduleAppointmentModal.show(
                                context,
                                appointment: appt,
                                onConfirmReschedule: (newDateTime) {
                                  final updated = appt.copyWith(
                                    dateTime: newDateTime,
                                    status: 'Rescheduled',
                                  );

                                  setState(() {
                                    final idx = _appointments.indexWhere(
                                      (a) => a.id == appt.id,
                                    );

                                    if (idx != -1) {
                                      _appointments[idx] = updated;
                                    }
                                  });
                                  _saveAppointment(updated);
                                },
                              );
                            },
                          ),

                          const SizedBox(width: 7),

                          _cardActionButton(
                            label: 'Cancel',
                            icon: Icons.cancel_outlined,
                            color: Colors.redAccent,
                            isDark: isDark,
                            onPressed: () {
                              CancelAppointmentModal.show(
                                context,
                                appointment: appt,
                                onConfirmCancel: (reason) {
                                  final updated = appt.copyWith(
                                    status: 'Cancelled',
                                    cancellationReason: reason,
                                  );

                                  setState(() {
                                    final idx = _appointments.indexWhere(
                                      (a) => a.id == appt.id,
                                    );

                                    if (idx != -1) {
                                      _appointments[idx] = updated;
                                    }
                                  });
                                  _saveAppointment(updated);
                                },
                              );
                            },
                          ),
                        ] else if (isCancelled) ...[
                          _cardActionButton(
                            label: 'Rebook',
                            icon: Icons.refresh_rounded,
                            color: _primary,
                            isDark: isDark,
                            filled: true,
                            onPressed: () => _openDoctorProfile(
                              appt.doctorName,
                              appt.specialty,
                              appt.hospitalName,
                            ),
                          ),
                        ] else ...[
                          _cardActionButton(
                            label: 'View Details',
                            icon: Icons.arrow_forward_rounded,
                            color: _primary,
                            isDark: isDark,
                            onPressed: () {
                              Navigator.push(
                                context,
                                FadePageRoute(
                                  page: PatientAppointmentDetailScreen(
                                    appointment: appt,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // STATUS BADGE
  // ═══════════════════════════════════════════════

  Widget _statusBadge(String status, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // CARD ACTION
  // ═══════════════════════════════════════════════

  Widget _cardActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onPressed,
    bool filled = false,
  }) {
    return SizedBox(
      height: 34,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(icon, size: 14),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                backgroundColor: color.withValues(
                  alpha: isDark ? 0.045 : 0.025,
                ),
                side: BorderSide(color: color.withValues(alpha: 0.22)),
                padding: const EdgeInsets.symmetric(horizontal: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(icon, size: 13),
              label: Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required bool showActions,
    required bool isDark,
  }) {
    return Center(
      child: _glassCard(
        isDark: isDark,
        padding: const EdgeInsets.all(28),
        radius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: _primary.withValues(alpha: 0.12)),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: _primary,
                size: 34,
              ),
            ),

            const SizedBox(height: 17),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                height: 1.4,
              ),
            ),

            if (showActions) ...[
              const SizedBox(height: 20),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: widget.onFindDoctorTap ?? _openBookModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.person_search_rounded, size: 17),
                    label: const Text(
                      'Find a Doctor',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),

                  OutlinedButton.icon(
                    onPressed: widget.onFindHospitalTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: BorderSide(color: _primary.withValues(alpha: 0.30)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.domain_rounded, size: 17),
                    label: const Text(
                      'Find a Hospital',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }



  // ═══════════════════════════════════════════════
  // GLASS CARD
  // ═══════════════════════════════════════════════

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
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // GLOW
  // ═══════════════════════════════════════════════

  Widget _buildGlow({
    required double size,
    required Color color,
    required double opacity,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: opacity),
              blurRadius: size * 0.8,
              spreadRadius: size * 0.15,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // DOCTOR INITIAL
  // ═══════════════════════════════════════════════

  String _doctorInitial(String name) {
    final cleanName = name.replaceFirst(RegExp(r'^Dr\.\s*'), '').trim();

    if (cleanName.isEmpty) {
      return 'D';
    }

    return cleanName[0].toUpperCase();
  }

  // ═══════════════════════════════════════════════
  // STATUS COLOR
  // ═══════════════════════════════════════════════

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Requested':
        return Colors.amber.shade800;
      case 'Confirmed':
        return Colors.green;
      case 'Rescheduled':
        return Colors.orange;
      case 'Completed':
        return _primary;
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return _primary;
    }
  }

  // ═══════════════════════════════════════════════
  // DATE FORMAT
  // ═══════════════════════════════════════════════

  String _formatDateTime(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final now = DateTime.now();

    final isToday =
        date.day == now.day && date.month == now.month && date.year == now.year;

    final tomorrow = now.add(const Duration(days: 1));

    final isTomorrow =
        date.day == tomorrow.day &&
        date.month == tomorrow.month &&
        date.year == tomorrow.year;

    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);

    final period = date.hour >= 12 ? 'PM' : 'AM';

    final minuteStr = date.minute.toString().padLeft(2, '0');

    final dayPrefix = isToday
        ? 'Today'
        : isTomorrow
        ? 'Tomorrow'
        : '${date.day} ${months[date.month - 1]}';

    return '$dayPrefix · $hour:$minuteStr $period';
  }
}
