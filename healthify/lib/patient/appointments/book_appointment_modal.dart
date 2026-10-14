import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import '../../core/provider/repository_provider.dart';

class BookAppointmentModal extends StatefulWidget {
  final DoctorSearchResult? initialDoctor;
  final Function(String message)? onSuccess;

  const BookAppointmentModal({super.key, this.initialDoctor, this.onSuccess});

  static void show(
    BuildContext context, {
    DoctorSearchResult? doctor,
    Function(String)? onSuccess,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) =>
          BookAppointmentModal(initialDoctor: doctor, onSuccess: onSuccess),
    );
  }

  @override
  State<BookAppointmentModal> createState() => _BookAppointmentModalState();
}

class _BookAppointmentModalState extends State<BookAppointmentModal> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedDoctorName;
  late String _selectedSpecialty;
  late String _selectedHospital;
  late String _selectedSlot;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  final List<String> _availableSlots = const [
    'Today 10:30 AM',
    'Today 02:00 PM',
    'Today 04:30 PM',
    'Tomorrow 09:30 AM',
    'Tomorrow 11:15 AM',
    'Tomorrow 03:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDoctorName = widget.initialDoctor?.name ?? 'Dr. Sarah Jenkins';
    _selectedSpecialty = widget.initialDoctor?.specialty ?? 'Cardiology';
    _selectedHospital =
        widget.initialDoctor?.hospitalName ?? 'St. Jude Memorial Hospital';
    _selectedSlot =
        widget.initialDoctor?.availableSlots.firstOrNull ??
        _availableSlots.first;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      Future.delayed(const Duration(milliseconds: 250), () async {
        if (!mounted) return;
        final tokenNum = '#${(10 + DateTime.now().second % 40)}';
        final doctor = widget.initialDoctor;
        final appointment = PatientAppointment(
          id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
          doctorId: doctor?.id,
          hospitalId: doctor?.hospitalId,
          doctorName: _selectedDoctorName,
          specialty: _selectedSpecialty,
          hospitalName: _selectedHospital,
          dateTime: _requestedDateTime(_selectedSlot),
          status: 'Requested',
          tokenNumber: tokenNum,
          consultationFee: doctor?.consultationFee ?? 0,
          reasonForVisit: _reasonController.text.trim().isEmpty
              ? 'Routine OPD Consultation'
              : _reasonController.text.trim(),
        );
        try {
          final portal = RepositoryContainer.instance.patientPortalRepository;
          if (portal == null) {
            throw StateError('Serverpod patient account is not connected.');
          }
          await portal.save(
            'patientAppointments',
            appointment.id,
            {
              'id': appointment.id,
              if (appointment.doctorId != null) 'doctorId': appointment.doctorId,
              if (appointment.hospitalId != null) 'hospitalId': appointment.hospitalId,
              'doctorName': appointment.doctorName,
              'specialty': appointment.specialty,
              'hospitalName': appointment.hospitalName,
              'hospitalAddress': appointment.hospitalAddress,
              'dateTime': appointment.dateTime.toIso8601String(),
              'consultationType': appointment.consultationType,
              'status': appointment.status,
              'tokenNumber': appointment.tokenNumber,
              'consultationFee': appointment.consultationFee,
              'reasonForVisit': appointment.reasonForVisit,
              'generatedReportTitles': appointment.generatedReportTitles,
            },
          );
        } catch (error) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Appointment request was not saved: $error')),
          );
          return;
        }
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        Navigator.pop(context);
        final msg =
            'Appointment request sent to $_selectedHospital for $_selectedSlot. Request $tokenNum.';
        if (widget.onSuccess != null) {
          widget.onSuccess!(msg);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: _primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  DateTime _requestedDateTime(String slot) {
    final now = DateTime.now();
    final day = slot.toLowerCase().startsWith('tomorrow')
        ? now.add(const Duration(days: 1))
        : now;
    final time = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)', caseSensitive: false)
        .firstMatch(slot);
    if (time == null) return DateTime(day.year, day.month, day.day, 12);
    var hour = int.parse(time.group(1)!);
    final minute = int.parse(time.group(2)!);
    final meridiem = time.group(3)!.toUpperCase();
    if (meridiem == 'PM' && hour != 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

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

  Widget _glassInput({
    required bool isDark,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: _primaryText(isDark), fontSize: 13.5),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: _secondaryText(isDark), fontSize: 12.5),
            filled: true,
            fillColor: _surfaceStrong(isDark),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: _border(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: _border(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: _primary.withValues(alpha: isDark ? 0.55 : 0.40),
                width: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: _border(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
                blurRadius: 34,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _border(isDark),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _primary.withValues(
                            alpha: isDark ? 0.13 : 0.09,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _primary.withValues(
                              alpha: isDark ? 0.18 : 0.12,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: _primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book Doctor Consultation',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _primaryText(isDark),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Choose a preferred time and send your request',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: _secondaryText(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: _secondaryText(isDark),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: _border(isDark), height: 1),
                  const SizedBox(height: 16),

                  // Doctor Info
                  _glassCard(
                    isDark: isDark,
                    padding: const EdgeInsets.all(16),
                    radius: 19,
                    accent: _primary,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primary, _primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withValues(alpha: 0.20),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
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
                                _selectedDoctorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _primaryText(isDark),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$_selectedSpecialty • $_selectedHospital',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: _secondaryText(isDark),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Select Slot
                  Text(
                    'Select Preferred Time Slot',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _primaryText(isDark),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSlots.map((slot) {
                      final isSelected = _selectedSlot == slot;

                      return ChoiceChip(
                        label: Text(slot),
                        selected: isSelected,
                        selectedColor: _primary,
                        backgroundColor: _surfaceStrong(isDark),
                        side: BorderSide(
                          color: isSelected ? _primary : _border(isDark),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : _primaryText(isDark),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12.5,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedSlot = slot);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Patient Reason / Symptoms
                  Text(
                    'Health Concern / Symptoms (Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _primaryText(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _glassInput(
                    isDark: isDark,
                    controller: _reasonController,
                    maxLines: 2,
                    hintText:
                        'e.g. Chest tightness, shortness of breath for 2 days...',
                  ),

                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        disabledBackgroundColor: _primary.withValues(
                          alpha: 0.55,
                        ),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: _primary.withValues(alpha: 0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded),
                      label: Text(
                        _isSubmitting
                            ? 'Booking Appointment...'
                            : 'Send Appointment Request',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
