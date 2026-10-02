import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

class CancelAppointmentModal extends StatefulWidget {
  final PatientAppointment appointment;
  final Function(String reason) onConfirmCancel;

  const CancelAppointmentModal({
    super.key,
    required this.appointment,
    required this.onConfirmCancel,
  });

  static void show(
    BuildContext context, {
    required PatientAppointment appointment,
    required Function(String reason) onConfirmCancel,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => CancelAppointmentModal(
        appointment: appointment,
        onConfirmCancel: onConfirmCancel,
      ),
    );
  }

  @override
  State<CancelAppointmentModal> createState() => _CancelAppointmentModalState();
}

class _CancelAppointmentModalState extends State<CancelAppointmentModal> {
  String _selectedReason = 'Schedule changed';
  final _otherReasonController = TextEditingController();

  final List<String> _reasons = [
    'Schedule changed',
    'Feeling better / Symptoms resolved',
    'Found another doctor / earlier slot',
    'Emergency / Travel conflict',
    'Other reason',
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _submitCancellation() {
    final finalReason =
        _selectedReason == 'Other reason' &&
            _otherReasonController.text.trim().isNotEmpty
        ? _otherReasonController.text.trim()
        : _selectedReason;

    widget.onConfirmCancel(finalReason);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment cancelled. You can rebook anytime.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  Color _background(bool isDark) =>
      isDark ? const Color(0xFF061817) : const Color(0xFFF3FAF9);

  Color _surface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.045)
      : Colors.white.withValues(alpha: 0.72);

  Color _surfaceStrong(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.075)
      : Colors.white.withValues(alpha: 0.90);

  Color _border(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.085)
      : Colors.white.withValues(alpha: 0.88);

  Color _primaryText(bool isDark) =>
      isDark ? Colors.white : AppTheme.textPrimary;

  Color _secondaryText(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.textSecondary;

  Color _mutedText(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.38) : AppTheme.textMuted;

  Widget _glassCard({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double radius = 20,
    Color? accent,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: accent != null
                  ? accent.withValues(alpha: isDark ? 0.22 : 0.18)
                  : _border(isDark),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.17 : 0.035),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
              if (accent != null)
                BoxShadow(
                  color: accent.withValues(alpha: isDark ? 0.055 : 0.035),
                  blurRadius: 22,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassIconButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: _surfaceStrong(isDark),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _border(isDark)),
              ),
              child: Icon(
                icon,
                size: 21,
                color: iconColor ?? _primaryText(isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _reasonTile({
    required bool isDark,
    required String reason,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedReason = reason),
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? _primary.withValues(alpha: isDark ? 0.15 : 0.09)
                  : _surfaceStrong(isDark),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected
                    ? _primary.withValues(alpha: isDark ? 0.50 : 0.32)
                    : _border(isDark),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _primary : _mutedText(isDark),
                      width: 1.6,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? _primary : _primaryText(isDark),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: _background(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withValues(
                    alpha: isDark ? 0.045 : 0.025,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -90,
            child: IgnorePointer(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withValues(alpha: isDark ? 0.045 : 0.025),
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                padding: EdgeInsets.only(
                  top: 12,
                  left: 20,
                  right: 20,
                  bottom: keyboardBottom + 20,
                ),
                decoration: BoxDecoration(
                  color: _surface(isDark),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(color: _border(isDark)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.22 : 0.06,
                      ),
                      blurRadius: 35,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.22)
                                : Colors.black.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(
                                alpha: isDark ? 0.14 : 0.09,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.redAccent.withValues(
                                  alpha: isDark ? 0.22 : 0.14,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.redAccent,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cancel Appointment?',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: _primaryText(isDark),
                                    letterSpacing: -0.25,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Are you sure you want to cancel this booking?',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _secondaryText(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _glassIconButton(
                            isDark: isDark,
                            icon: Icons.close_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _glassCard(
                        isDark: isDark,
                        padding: const EdgeInsets.all(14),
                        radius: 18,
                        accent: _primary,
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [_primary, _primaryDark],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primary.withValues(
                                      alpha: isDark ? 0.18 : 0.12,
                                    ),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.appointment.doctorName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: _primaryText(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${widget.appointment.specialty} • ${widget.appointment.hospitalName}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: _secondaryText(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 14,
                                        color: _primary,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          _formatDateTime(
                                            widget.appointment.dateTime,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: _primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Reason for Cancellation',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _primaryText(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Optional — select a reason to help us improve your experience.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _secondaryText(isDark),
                        ),
                      ),
                      const SizedBox(height: 11),
                      ..._reasons.map(
                        (reason) => _reasonTile(
                          isDark: isDark,
                          reason: reason,
                          isSelected: _selectedReason == reason,
                        ),
                      ),
                      if (_selectedReason == 'Other reason') ...[
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: TextField(
                              controller: _otherReasonController,
                              maxLines: 3,
                              style: TextStyle(
                                color: _primaryText(isDark),
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Please specify reason...',
                                hintStyle: TextStyle(
                                  color: _secondaryText(isDark),
                                ),
                                filled: true,
                                fillColor: _surfaceStrong(isDark),
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: _border(isDark),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: _border(isDark),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: _primary.withValues(alpha: 0.65),
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _primary,
                                backgroundColor: _surfaceStrong(isDark),
                                side: BorderSide(
                                  color: _primary.withValues(
                                    alpha: isDark ? 0.35 : 0.25,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Keep Appointment',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitCancellation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Cancel Booking',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    return '${date.day} ${months[date.month - 1]} at $hour:$minuteStr $period';
  }
}