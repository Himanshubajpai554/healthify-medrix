import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/animated_pulse_background.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import './cancel_appointment_modal.dart';
import './reschedule_appointment_modal.dart';

class PatientAppointmentDetailScreen extends StatefulWidget {
  final PatientAppointment appointment;
  final Function(PatientAppointment updated)? onAppointmentUpdated;

  const PatientAppointmentDetailScreen({
    super.key,
    required this.appointment,
    this.onAppointmentUpdated,
  });

  @override
  State<PatientAppointmentDetailScreen> createState() =>
      _PatientAppointmentDetailScreenState();
}

class _PatientAppointmentDetailScreenState
    extends State<PatientAppointmentDetailScreen> {
  late PatientAppointment _currentAppt;

  // ─────────────────────────────────────────────
  // COLORS
  // ─────────────────────────────────────────────

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
        ? Colors.white.withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.88);
  }

  Color _border(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.075)
        : Colors.white.withValues(alpha: 0.90);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : AppTheme.textPrimary;
  }

  Color _secondaryText(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.55)
        : AppTheme.textSecondary;
  }

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _currentAppt = widget.appointment;
  }

  // ─────────────────────────────────────────────
  // RESCHEDULE
  // ─────────────────────────────────────────────

  void _openRescheduleModal() {
    RescheduleAppointmentModal.show(
      context,
      appointment: _currentAppt,
      onConfirmReschedule: (newDateTime) {
        final updated = _currentAppt.copyWith(
          dateTime: newDateTime,
          status: 'Rescheduled',
          rescheduledFrom: _currentAppt.dateTime,
        );

        setState(() {
          _currentAppt = updated;
        });

        if (widget.onAppointmentUpdated != null) {
          widget.onAppointmentUpdated!(updated);
        }
      },
    );
  }

  // ─────────────────────────────────────────────
  // CANCEL
  // ─────────────────────────────────────────────

  void _openCancelModal() {
    CancelAppointmentModal.show(
      context,
      appointment: _currentAppt,
      onConfirmCancel: (reason) {
        final updated = _currentAppt.copyWith(
          status: 'Cancelled',
          cancellationReason: reason,
          cancelledAt: DateTime.now(),
        );

        setState(() {
          _currentAppt = updated;
        });

        if (widget.onAppointmentUpdated != null) {
          widget.onAppointmentUpdated!(updated);
        }
      },
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isCancelled = _currentAppt.status == 'Cancelled';
    final isCompleted = _currentAppt.status == 'Completed';

    return Scaffold(
      backgroundColor: _background(isDark),
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: _buildGlassAppBar(isDark),
      ),

      body: AnimatedPulseBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 88, 18, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(
                    isDark: isDark,
                    isCancelled: isCancelled,
                    isCompleted: isCompleted,
                  ),

                  const SizedBox(height: 18),

                  _buildDoctorHospitalCard(isDark),

                  const SizedBox(height: 18),

                  _buildAppointmentOverview(isDark),

                  if (_currentAppt.generatedReportTitles.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _buildReportsSection(isDark),
                  ],

                  const SizedBox(height: 18),

                  _buildAppointmentIdCard(isDark),
                ],
              ),
            ),
          ),
        ),

      // ─────────────────────────────────────────
      // BOTTOM ACTIONS
      // ─────────────────────────────────────────
      bottomNavigationBar: !isCancelled && !isCompleted
          ? _buildBottomActions(isDark)
          : null,
    );
  }

  // ─────────────────────────────────────────────
  // GLASS APP BAR
  // ─────────────────────────────────────────────

  Widget _buildGlassAppBar(bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: _surface(isDark),
            border: Border(bottom: BorderSide(color: _border(isDark))),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _glassIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    isDark: isDark,
                    onTap: () => Navigator.pop(context),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Appointment Details',
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  _glassIconButton(
                    icon: Icons.share_outlined,
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STATUS BANNER
  // ─────────────────────────────────────────────

  Widget _buildStatusBanner({
    required bool isDark,
    required bool isCancelled,
    required bool isCompleted,
  }) {
    final statusColor = _getStatusColor(_currentAppt.status);

    final subtitle = isCancelled
        ? 'Reason: ${_currentAppt.cancellationReason ?? "Schedule conflict"}'
        : isCompleted
        ? 'Consultation completed successfully'
        : 'Token ${_currentAppt.tokenNumber} • Please arrive 15 mins early';

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: isDark ? 0.10 : 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: statusColor.withValues(alpha: 0.24)),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.06),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(_currentAppt.status),
                  color: statusColor,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentAppt.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DOCTOR + HOSPITAL
  // ─────────────────────────────────────────────

  Widget _buildDoctorHospitalCard(bool isDark) {
    return _glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primary.withValues(alpha: 0.22),
                      _primaryDark.withValues(alpha: 0.10),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: _primary.withValues(alpha: 0.20)),
                ),
                child: Center(
                  child: Text(
                    _doctorInitial(),
                    style: TextStyle(
                      color: _primary,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentAppt.doctorName,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _currentAppt.specialty,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: _primary,
                  size: 19,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(height: 1, color: _border(isDark)),

          const SizedBox(height: 18),

          _buildInfoTile(
            icon: Icons.local_hospital_rounded,
            label: 'Hospital',
            value: _currentAppt.hospitalName,
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          _buildInfoTile(
            icon: Icons.location_on_rounded,
            label: 'Hospital Address',
            value: _currentAppt.hospitalAddress,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // APPOINTMENT OVERVIEW
  // ─────────────────────────────────────────────

  Widget _buildAppointmentOverview(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Appointment Information',
          Icons.calendar_month_rounded,
          isDark,
        ),

        const SizedBox(height: 12),

        _glassCard(
          isDark: isDark,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildDetailRow(
                Icons.calendar_month_rounded,
                'Date & Time',
                _formatDateTime(_currentAppt.dateTime),
                isDark,
              ),

              _buildDetailDivider(isDark),

              _buildDetailRow(
                Icons.confirmation_number_rounded,
                'Token Number',
                _currentAppt.tokenNumber,
                isDark,
              ),

              _buildDetailDivider(isDark),

              _buildDetailRow(
                Icons.videocam_outlined,
                'Consultation Mode',
                _currentAppt.consultationType,
                isDark,
              ),

              _buildDetailDivider(isDark),

              _buildDetailRow(
                Icons.notes_rounded,
                'Reason for Visit',
                _currentAppt.reasonForVisit,
                isDark,
              ),

              _buildDetailDivider(isDark),

              _buildDetailRow(
                Icons.payments_outlined,
                'Consultation Fee',
                '₹${_currentAppt.consultationFee.toInt()}',
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // REPORTS
  // ─────────────────────────────────────────────

  Widget _buildReportsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Generated Medical Reports',
          Icons.description_outlined,
          isDark,
        ),

        const SizedBox(height: 12),

        ..._currentAppt.generatedReportTitles.map((title) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _glassCard(
              isDark: isDark,
              padding: const EdgeInsets.all(14),
              radius: 18,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: Colors.redAccent,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // APPOINTMENT ID
  // ─────────────────────────────────────────────

  Widget _buildAppointmentIdCard(bool isDark) {
    return _glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(17),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fingerprint_rounded,
              color: _primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appointment ID',
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _currentAppt.id,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.copy_rounded, color: _primary, size: 19),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM ACTIONS
  // ─────────────────────────────────────────────

  Widget _buildBottomActions(bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            14,
            16,
            14 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            border: Border(top: BorderSide(color: _border(isDark))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
                blurRadius: 25,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _openCancelModal,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.55),
                      ),
                      backgroundColor: Colors.redAccent.withValues(
                        alpha: isDark ? 0.04 : 0.025,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openRescheduleModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: _primary.withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                    label: const Text(
                      'Reschedule',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GLASS CARD
  // ─────────────────────────────────────────────

  Widget _glassCard({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 22,
    Color? accent,
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
            border: Border.all(
              color: accent != null
                  ? accent.withValues(alpha: 0.18)
                  : _border(isDark),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.045),
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

  // ─────────────────────────────────────────────
  // INFO TILE
  // ─────────────────────────────────────────────

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: _primary, size: 19),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // DETAIL ROW
  // ─────────────────────────────────────────────

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: _primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DETAIL DIVIDER
  // ─────────────────────────────────────────────

  Widget _buildDetailDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: _border(isDark)),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION TITLE
  // ─────────────────────────────────────────────

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _primary, size: 18),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: TextStyle(
            color: _primaryText(isDark),
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // GLASS ICON BUTTON
  // ─────────────────────────────────────────────

  Widget _glassIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _surfaceStrong(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border(isDark)),
            ),
            child: Icon(icon, size: 19, color: _primaryText(isDark)),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────


  // ─────────────────────────────────────────────
  // DOCTOR INITIAL
  // ─────────────────────────────────────────────

  String _doctorInitial() {
    final name = _currentAppt.doctorName
        .replaceFirst(RegExp(r'^Dr\.\s*'), '')
        .trim();

    if (name.isEmpty) return 'D';

    return name[0].toUpperCase();
  }

  // ─────────────────────────────────────────────
  // STATUS COLOR
  // ─────────────────────────────────────────────

  Color _getStatusColor(String status) {
    switch (status) {
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

  // ─────────────────────────────────────────────
  // STATUS ICON
  // ─────────────────────────────────────────────

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Confirmed':
        return Icons.check_circle_rounded;
      case 'Rescheduled':
        return Icons.edit_calendar_rounded;
      case 'Completed':
        return Icons.task_alt_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  // ─────────────────────────────────────────────
  // DATE FORMAT
  // ─────────────────────────────────────────────

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

    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);

    final period = date.hour >= 12 ? 'PM' : 'AM';

    final minuteStr = date.minute.toString().padLeft(2, '0');

    return '${date.day} ${months[date.month - 1]} '
        '${date.year} at $hour:$minuteStr $period';
  }
}