import 'dart:ui';

import 'package:flutter/material.dart';

import '../../shared/widgets/animated_pulse_background.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

class PatientDoctorProfileScreen extends StatefulWidget {
  final DoctorSearchResult doctor;
  final ValueChanged<PatientAppointment>? onAppointmentBooked;

  const PatientDoctorProfileScreen({
    super.key,
    required this.doctor,
    this.onAppointmentBooked,
  });

  @override
  State<PatientDoctorProfileScreen> createState() =>
      _PatientDoctorProfileScreenState();
}

class _PatientDoctorProfileScreenState
    extends State<PatientDoctorProfileScreen> {
  bool _isBookingSuccess = false;
  bool _isConfirmStep = false;
  String _consultationType = 'In-person';
  int _selectedDateIndex = 0;
  String _selectedSlot = '10:00 AM';
  final TextEditingController _reasonController = TextEditingController();
  late List<String> _availableSlots;
  PatientAppointment? _bookedAppointment;

  // ─────────────────────────────────────────────
  // COLORS & THEME (MATCHES APPOINTMENT DETAIL SCREEN)
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
    _availableSlots = widget.doctor.availableSlots.isNotEmpty
        ? widget.doctor.availableSlots
        : ['09:00 AM', '10:30 AM', '02:00 PM', '04:30 PM'];
    if (_availableSlots.isNotEmpty) {
      _selectedSlot = _availableSlots.first;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  String _doctorInitial() {
    final name = widget.doctor.name
        .replaceFirst(RegExp(r'^Dr\.\s*'), '')
        .trim();

    if (name.isEmpty) return 'D';

    return name[0].toUpperCase();
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
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
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  void _onConfirmBookingPressed() {
    final date = DateTime.now().add(Duration(days: _selectedDateIndex));
    final newAppt = PatientAppointment(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      doctorName: widget.doctor.name,
      specialty: widget.doctor.specialty,
      hospitalName: widget.doctor.hospitalName,
      dateTime: date,
      consultationType: _consultationType == 'Video'
          ? 'Video consultation'
          : 'In-person consultation',
      status: 'Confirmed',
      tokenNumber: '#${10 + (DateTime.now().second % 40)}',
      consultationFee: widget.doctor.consultationFee,
      reasonForVisit: _reasonController.text.trim().isNotEmpty
          ? _reasonController.text.trim()
          : 'Routine OPD Consultation',
    );

    widget.onAppointmentBooked?.call(newAppt);

    setState(() {
      _bookedAppointment = newAppt;
      _isBookingSuccess = true;
    });
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isBookingSuccess) {
      return _buildSuccessScreen(isDark);
    }

    if (_isConfirmStep) {
      return _buildConfirmationScreen(isDark);
    }

    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: _background(isDark),
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: _buildGlassAppBar(
          title: doctor.name,
          isDark: isDark,
          actions: [
            _glassIconButton(
              icon: Icons.bookmark_border_rounded,
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _glassIconButton(
              icon: Icons.share_outlined,
              isDark: isDark,
              onTap: () {},
            ),
          ],
        ),
      ),

      body: AnimatedPulseBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 88, 18, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorHero(isDark, doctor),

                const SizedBox(height: 18),

                _buildAboutDoctor(isDark, doctor),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  'Consultation Mode',
                  Icons.video_camera_front_rounded,
                  isDark,
                  subtitle: 'Choose how you want to meet your doctor',
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildConsultTypeCard(
                        icon: Icons.domain_rounded,
                        title: 'In-person',
                        subtitle: 'At ${doctor.hospitalName}',
                        isSelected: _consultationType == 'In-person',
                        isDark: isDark,
                        onTap: () {
                          setState(() {
                            _consultationType = 'In-person';
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildConsultTypeCard(
                        icon: Icons.videocam_rounded,
                        title: 'Video Call',
                        subtitle: 'HD Telehealth',
                        isSelected: _consultationType == 'Video',
                        isDark: isDark,
                        onTap: () {
                          setState(() {
                            _consultationType = 'Video';
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  'Choose Date',
                  Icons.calendar_month_rounded,
                  isDark,
                  subtitle: 'Select an available appointment day',
                ),

                const SizedBox(height: 12),

                _buildDateSelector(isDark),

                const SizedBox(height: 20),

                _buildSectionTitle(
                  'Available Time',
                  Icons.schedule_rounded,
                  isDark,
                  subtitle: 'Pick a convenient consultation slot',
                ),

                const SizedBox(height: 12),

                _buildTimeSlots(isDark),

                const SizedBox(height: 22),

                _buildHealthConcern(isDark),

                const SizedBox(height: 22),

                _buildHospitalAffiliation(isDark, doctor),

                const SizedBox(height: 22),

                _buildReviewsSection(isDark, doctor),

                const SizedBox(height: 22),

                _buildRelatedDoctors(isDark),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: _buildBookingBottomBar(isDark),
    );
  }

  // ─────────────────────────────────────────────
  // GLASS APP BAR
  // ─────────────────────────────────────────────

  Widget _buildGlassAppBar({
    required String title,
    required bool isDark,
    VoidCallback? onBack,
    List<Widget>? actions,
  }) {
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
                    onTap: onBack ?? () => Navigator.pop(context),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  if (actions != null) ...actions,
                ],
              ),
            ),
          ),
        ),
      ),
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
  // GLASS CARD
  // ─────────────────────────────────────────────

  Widget _glassCard({
    required bool isDark,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
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
  // BACKGROUND GLOW
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // SECTION TITLE
  // ─────────────────────────────────────────────

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    bool isDark, {
    String? subtitle,
  }) {
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

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // DOCTOR HERO CARD
  // ─────────────────────────────────────────────

  Widget _buildDoctorHero(bool isDark, DoctorSearchResult doctor) {
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
                    style: const TextStyle(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            doctor.department.toUpperCase(),
                            style: const TextStyle(
                              color: _primary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      doctor.name,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${doctor.specialty} • ${doctor.hospitalName}',
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 12.5,
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

          const SizedBox(height: 18),

          Container(height: 1, color: _border(isDark)),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _doctorStatTile(
                  icon: Icons.star_rounded,
                  value: '${doctor.rating}',
                  label: '${doctor.reviewsCount} Reviews',
                  color: Colors.amber,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _doctorStatTile(
                  icon: Icons.workspace_premium_rounded,
                  value: '${doctor.experienceYears}+ Yrs',
                  label: 'Experience',
                  color: _primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _doctorStatTile(
                  icon: Icons.payments_outlined,
                  value: '₹${doctor.consultationFee.toInt()}',
                  label: 'Consult Fee',
                  color: _primary,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _doctorStatTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: _secondaryText(isDark),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ABOUT DOCTOR
  // ─────────────────────────────────────────────

  Widget _buildAboutDoctor(bool isDark, DoctorSearchResult doctor) {
    return _glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'About Doctor',
            Icons.person_outline_rounded,
            isDark,
            subtitle: 'Professional experience & qualifications',
          ),

          const SizedBox(height: 14),

          Text(
            'Senior Consultant Specialist with expertise in preventive care, clinical diagnosis, and advanced treatment planning. Certified by the National Board of Medicine.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: _secondaryText(isDark),
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(Icons.translate_rounded, 'English, Hindi', isDark),
              _infoChip(Icons.school_rounded, 'MBBS, MD, DM', isDark),
              _infoChip(
                Icons.medical_services_outlined,
                'OPD & Telehealth',
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _primaryText(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CONSULT TYPE CARD
  // ─────────────────────────────────────────────

  Widget _buildConsultTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? _primary.withValues(alpha: 0.12)
              : _surface(isDark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primary : _border(isDark),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _primary
                        : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : _secondaryText(isDark),
                    size: 20,
                  ),
                ),

                const Spacer(),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? _primary
                          : _secondaryText(isDark).withValues(alpha: 0.3),
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
              ],
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? _primary : _primaryText(isDark),
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: _secondaryText(isDark)),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DATE SELECTOR
  // ─────────────────────────────────────────────

  Widget _buildDateSelector(bool isDark) {
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final selected = _selectedDateIndex == index;

          final dayLabel = index == 0
              ? 'Today'
              : index == 1
              ? 'Tomorrow'
              : _getWeekdayName(date.weekday);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 84,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [_primary, _primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : _surface(isDark),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? _primary : _border(isDark),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _primary.withValues(alpha: 0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _secondaryText(isDark),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : _primaryText(isDark),
                    ),
                  ),

                  Text(
                    _getMonthName(date.month),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.8)
                          : _secondaryText(isDark),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TIME SLOTS
  // ─────────────────────────────────────────────

  Widget _buildTimeSlots(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableSlots.map((slot) {
        final selected = _selectedSlot == slot;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSlot = slot;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? _primary : _surface(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? _primary : _border(isDark)),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _primary.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: selected ? Colors.white : _primary,
                ),
                const SizedBox(width: 6),
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _primaryText(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // HEALTH CONCERN FIELD
  // ─────────────────────────────────────────────

  Widget _buildHealthConcern(bool isDark) {
    return _glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Reason for Visit',
            Icons.edit_note_rounded,
            isDark,
            subtitle: 'Optional — helps the doctor prepare for your visit',
          ),

          const SizedBox(height: 14),

          TextField(
            controller: _reasonController,
            maxLines: 3,
            style: TextStyle(color: _primaryText(isDark), fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Describe your symptoms or health concern...',
              hintStyle: TextStyle(color: _secondaryText(isDark), fontSize: 12),
              filled: true,
              fillColor: _surfaceStrong(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _border(isDark)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: _border(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HOSPITAL AFFILIATION
  // ─────────────────────────────────────────────

  Widget _buildHospitalAffiliation(bool isDark, DoctorSearchResult doctor) {
    return _glassCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Hospital Affiliation',
            Icons.domain_rounded,
            isDark,
            subtitle: 'Where this doctor practice & consults',
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primary, _primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.hospitalName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _primaryText(isDark),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${doctor.distanceKm} km away • Open 24/7 Emergency',
                      style: TextStyle(
                        fontSize: 11,
                        color: _secondaryText(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['24/7 ER Care', 'Level-1 ICU', 'Cath Lab', 'Blood Bank']
                .map((text) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: _primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // REVIEWS SECTION
  // ─────────────────────────────────────────────

  Widget _buildReviewsSection(bool isDark, DoctorSearchResult doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Patient Reviews',
          Icons.star_rounded,
          isDark,
          subtitle: '${doctor.reviewsCount} verified patient ratings',
        ),

        const SizedBox(height: 14),

        _glassCard(
          isDark: isDark,
          accent: Colors.amber,
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Text(
                        '${doctor.rating}',
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: i < 4
                                ? Colors.amber
                                : Colors.amber.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Overall Rating',
                        style: TextStyle(
                          fontSize: 10,
                          color: _secondaryText(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 24),

                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar(5, 0.85, isDark),
                        _buildRatingBar(4, 0.10, isDark),
                        _buildRatingBar(3, 0.03, isDark),
                        _buildRatingBar(2, 0.01, isDark),
                        _buildRatingBar(1, 0.01, isDark),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Divider(color: _border(isDark)),

              const SizedBox(height: 14),

              _buildReviewTile(
                'Verified Patient (A. R.)',
                5.0,
                '2 weeks ago',
                'Dr. ${doctor.name.replaceFirst("Dr. ", "")} was exceptionally attentive and answered all my questions clearly. Minimal clinic wait time.',
                isDark,
              ),

              const SizedBox(height: 12),

              _buildReviewTile(
                'Marcus V.',
                5.0,
                '1 month ago',
                'Very professional treatment and diagnosis. Recommended the right diagnostic tests without unnecessary prescriptions.',
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double pct, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$stars ★',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _secondaryText(isDark),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: Colors.amber.withValues(alpha: 0.10),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTile(
    String author,
    double rating,
    String date,
    String text,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: _primary,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _primaryText(isDark),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 10,
                        color: _secondaryText(isDark),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⭐ $rating',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: _secondaryText(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // RELATED DOCTORS
  // ─────────────────────────────────────────────

  Widget _buildRelatedDoctors(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'You May Also Consider',
          Icons.people_alt_rounded,
          isDark,
          subtitle: 'Other doctors with similar specialty nearby',
        ),

        const SizedBox(height: 14),

        _buildRelatedDoctorCard(
          'Dr. Marcus Vance',
          'Orthopedics & Joint Specialist',
          'St. Jude Memorial Hospital',
          4.7,
          1.2,
          isDark,
        ),

        const SizedBox(height: 12),

        _buildRelatedDoctorCard(
          'Dr. Elena Rostova',
          'Neurologist & Stroke Specialist',
          'Apex Care Medical Center',
          4.9,
          5.8,
          isDark,
        ),
      ],
    );
  }

  Widget _buildRelatedDoctorCard(
    String name,
    String specialty,
    String hospital,
    double rating,
    double distance,
    bool isDark,
  ) {
    return _glassCard(
      isDark: isDark,
      radius: 19,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: _primary, size: 24),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _primaryText(isDark),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$specialty • $hospital',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: _secondaryText(isDark),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '⭐ $rating • $distance km away',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'View',
              style: TextStyle(
                color: _primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────

  Widget _buildBookingBottomBar(bool isDark) {
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
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isConfirmStep = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: _primary.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Proceed to Confirm Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
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
  // CONFIRMATION SCREEN (MATCHES THEME)
  // ─────────────────────────────────────────────

  Widget _buildConfirmationScreen(bool isDark) {
    final doctor = widget.doctor;
    final date = DateTime.now().add(Duration(days: _selectedDateIndex));
    final dateStr =
        '${_getWeekdayName(date.weekday)}, ${date.day} ${_getMonthName(date.month)} ${date.year}';
    final fee = doctor.consultationFee;
    const platformFee = 50.0;
    final totalFee = fee + platformFee;

    return Scaffold(
      backgroundColor: _background(isDark),
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: _buildGlassAppBar(
          title: 'Confirm Appointment',
          isDark: isDark,
          onBack: () {
            setState(() {
              _isConfirmStep = false;
            });
          },
        ),
      ),

      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: _buildGlow(
              size: 260,
              color: _primary,
              opacity: isDark ? 0.10 : 0.08,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 88, 18, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _glassCard(
                    isDark: isDark,
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _primary.withValues(alpha: 0.22),
                                _primaryDark.withValues(alpha: 0.10),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _primary.withValues(alpha: 0.20),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _doctorInitial(),
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: TextStyle(
                                  color: _primaryText(isDark),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${doctor.specialty} • ${doctor.hospitalName}',
                                style: TextStyle(
                                  color: _secondaryText(isDark),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _glassCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Appointment Overview',
                          Icons.event_available_rounded,
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        _confirmDetailRow(
                          Icons.calendar_month_rounded,
                          'Date',
                          dateStr,
                          isDark,
                        ),
                        _confirmDivider(isDark),
                        _confirmDetailRow(
                          Icons.schedule_rounded,
                          'Time Slot',
                          _selectedSlot,
                          isDark,
                        ),
                        _confirmDivider(isDark),
                        _confirmDetailRow(
                          _consultationType == 'Video'
                              ? Icons.videocam_rounded
                              : Icons.domain_rounded,
                          'Consultation Mode',
                          _consultationType == 'Video'
                              ? 'Video Telehealth'
                              : 'In-person (${doctor.hospitalName})',
                          isDark,
                        ),
                        if (_reasonController.text.trim().isNotEmpty) ...[
                          _confirmDivider(isDark),
                          _confirmDetailRow(
                            Icons.edit_note_rounded,
                            'Reason for Visit',
                            _reasonController.text.trim(),
                            isDark,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _glassCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Fee Breakup',
                          Icons.receipt_long_rounded,
                          isDark,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Doctor Consultation Fee',
                              style: TextStyle(
                                color: _secondaryText(isDark),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '₹${fee.toInt()}',
                              style: TextStyle(
                                color: _primaryText(isDark),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Platform Service Fee',
                              style: TextStyle(
                                color: _secondaryText(isDark),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '₹${platformFee.toInt()}',
                              style: TextStyle(
                                color: _primaryText(isDark),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: _border(isDark)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Payable',
                              style: TextStyle(
                                color: _primaryText(isDark),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '₹${totalFee.toInt()}',
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
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
          ),
        ],
      ),

      bottomNavigationBar: ClipRRect(
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
            ),
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _onConfirmBookingPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: _primary.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text(
                  'Confirm & Pay',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _confirmDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _confirmDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: _border(isDark)),
    );
  }

  // ─────────────────────────────────────────────
  // SUCCESS SCREEN (MATCHES THEME)
  // ─────────────────────────────────────────────

  Widget _buildSuccessScreen(bool isDark) {
    final appt = _bookedAppointment;

    return Scaffold(
      backgroundColor: _background(isDark),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: _buildGlow(
              size: 280,
              color: _primary,
              opacity: isDark ? 0.12 : 0.09,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _primary.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: _primary,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Your appointment has been successfully scheduled.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 13.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (appt != null)
                    _glassCard(
                      isDark: isDark,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Token Number',
                                style: TextStyle(
                                  color: _secondaryText(isDark),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _primary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  appt.tokenNumber,
                                  style: const TextStyle(
                                    color: _primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: _border(isDark)),
                          ),
                          _confirmDetailRow(
                            Icons.person_rounded,
                            'Doctor',
                            appt.doctorName,
                            isDark,
                          ),
                          _confirmDivider(isDark),
                          _confirmDetailRow(
                            Icons.local_hospital_rounded,
                            'Hospital',
                            appt.hospitalName,
                            isDark,
                          ),
                          _confirmDivider(isDark),
                          _confirmDetailRow(
                            Icons.schedule_rounded,
                            'Time Slot',
                            _selectedSlot,
                            isDark,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}