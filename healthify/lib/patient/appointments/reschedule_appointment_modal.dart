import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

class RescheduleAppointmentModal extends StatefulWidget {
  final PatientAppointment appointment;
  final Function(DateTime newDateTime) onConfirmReschedule;

  const RescheduleAppointmentModal({
    super.key,
    required this.appointment,
    required this.onConfirmReschedule,
  });

  static void show(
    BuildContext context, {
    required PatientAppointment appointment,
    required Function(DateTime newDateTime) onConfirmReschedule,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => RescheduleAppointmentModal(
        appointment: appointment,
        onConfirmReschedule: onConfirmReschedule,
      ),
    );
  }

  @override
  State<RescheduleAppointmentModal> createState() =>
      _RescheduleAppointmentModalState();
}

class _RescheduleAppointmentModalState
    extends State<RescheduleAppointmentModal> {
  late DateTime _selectedDate;
  String _selectedTimeSlot = '10:00 AM';

  final List<String> _timeSlots = [
    '09:30 AM',
    '10:00 AM',
    '11:30 AM',
    '02:30 PM',
    '04:30 PM',
    '06:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Default reschedule date to tomorrow
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  DateTime _computeNewDateTime() {
    final timeParts = _selectedTimeSlot.split(' ');
    final hm = timeParts[0].split(':');
    var hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final isPm = timeParts[1] == 'PM';
    if (isPm && hour < 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );
  }

  void _submitReschedule() {
    final newDateTime = _computeNewDateTime();
    widget.onConfirmReschedule(newDateTime);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Appointment rescheduled successfully!'),
        backgroundColor: Colors.teal,
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
              child: Icon(icon, size: 21, color: _primaryText(isDark)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateChip({
    required bool isDark,
    required DateTime date,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 74,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [_primary, _primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : _surfaceStrong(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? _primary.withValues(alpha: 0.75)
                    : _border(isDark),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _primary.withValues(alpha: isDark ? 0.18 : 0.10),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getWeekdayName(date.weekday),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.78)
                        : _secondaryText(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : _primaryText(isDark),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _getMonthName(date.month),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.78)
                        : _secondaryText(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeChip({
    required bool isDark,
    required String slot,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? _primary.withValues(alpha: isDark ? 0.18 : 0.10)
                : _surfaceStrong(isDark),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isSelected
                  ? _primary.withValues(alpha: isDark ? 0.55 : 0.35)
                  : _border(isDark),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.access_time_rounded,
                size: 15,
                color: isSelected ? _primary : _secondaryText(isDark),
              ),
              const SizedBox(width: 6),
              Text(
                slot,
                style: TextStyle(
                  color: isSelected ? _primary : _primaryText(isDark),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newDateTime = _computeNewDateTime();
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: _background(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary.withValues(alpha: isDark ? 0.055 : 0.025),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -90,
            child: IgnorePointer(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(
                    alpha: isDark ? 0.035 : 0.018,
                  ),
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

                      // Header.
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: _primary.withValues(
                                alpha: isDark ? 0.14 : 0.09,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _primary.withValues(
                                  alpha: isDark ? 0.25 : 0.16,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_calendar_rounded,
                              color: _primary,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reschedule Appointment',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: _primaryText(isDark),
                                    letterSpacing: -0.25,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.appointment.doctorName,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _secondaryText(isDark),
                                    fontWeight: FontWeight.w600,
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

                      // Current vs new time.
                      _glassCard(
                        isDark: isDark,
                        padding: const EdgeInsets.all(14),
                        radius: 18,
                        accent: _primary,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CURRENT TIME',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.7,
                                      color: _mutedText(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _formatDateTime(
                                      widget.appointment.dateTime,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _primary.withValues(
                                  alpha: isDark ? 0.13 : 0.08,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: _primary,
                                size: 17,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'NEW SELECTED TIME',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.7,
                                      color: _primary,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _formatDateTime(newDateTime),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 21),

                      Text(
                        '1. Choose New Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _primaryText(isDark),
                        ),
                      ),
                      const SizedBox(height: 10),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List.generate(7, (index) {
                            final date = DateTime.now().add(
                              Duration(days: index + 1),
                            );
                            final isSelected =
                                date.day == _selectedDate.day &&
                                date.month == _selectedDate.month &&
                                date.year == _selectedDate.year;

                            return _dateChip(
                              isDark: isDark,
                              date: date,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() => _selectedDate = date);
                              },
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 21),

                      Text(
                        '2. Choose Available Time Slot',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _primaryText(isDark),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _timeSlots.map((slot) {
                          final isSelected = _selectedTimeSlot == slot;
                          return _timeChip(
                            isDark: isDark,
                            slot: slot,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => _selectedTimeSlot = slot);
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Confirm button.
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withValues(
                                  alpha: isDark ? 0.15 : 0.09,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _submitReschedule,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              size: 20,
                            ),
                            label: const Text(
                              'Confirm New Time',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
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
    return '${date.day} ${months[date.month - 1]} · $hour:$minuteStr $period';
  }

  String _getWeekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
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
    return months[month - 1];
  }
}