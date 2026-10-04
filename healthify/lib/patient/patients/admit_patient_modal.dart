import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';

class AdmitPatientModal extends StatefulWidget {
  final Function(PatientItem) onPatientAdmitted;

  const AdmitPatientModal({super.key, required this.onPatientAdmitted});

  @override
  State<AdmitPatientModal> createState() => _AdmitPatientModalState();
}

class _AdmitPatientModalState extends State<AdmitPatientModal>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;

  final _formKey = GlobalKey<FormState>();

  // ---------------------------------------------------------------------------
  // NEW PATIENT
  // ---------------------------------------------------------------------------

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _doctorController = TextEditingController(text: 'Dr. Sarah Jenkins');

  String _gender = 'Female';
  String _bloodGroup = 'O+';
  String _ward = 'General Ward A';

  PatientStatus _status = PatientStatus.admitted;

  final DateTime _admissionDate = DateTime.now();

  // ---------------------------------------------------------------------------
  // EXISTING PATIENT
  // ---------------------------------------------------------------------------

  final _lookupSearchController = TextEditingController();

  List<Patient> _matchingPatients = [];

  Patient? _selectedExistingPatient;

  bool _isSearching = false;

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _wards = [
    'General Ward A',
    'General Ward B',
    'ICU Main',
    'ICU Emergency',
    'Observation Unit',
    'Private Suite 101',
    'Pediatric Ward',
  ];

  // ---------------------------------------------------------------------------
  // ANIMATION
  // ---------------------------------------------------------------------------

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();

    _nameController.dispose();
    _ageController.dispose();
    _doctorController.dispose();
    _lookupSearchController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // PATIENT LOOKUP
  // ===========================================================================

  Future<void> _performPatientLookup(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _matchingPatients = [];
        _isSearching = false;
        _selectedExistingPatient = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final repo = RepositoryScope.of(context).patientRepository;

    final allGlobal = await repo.getGlobalPatients();

    final q = query.trim().toLowerCase();

    if (!mounted) return;

    setState(() {
      _matchingPatients = allGlobal
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.id.toLowerCase().contains(q) ||
                p.phone.contains(q),
          )
          .toList();

      _isSearching = false;
    });
  }

  // ===========================================================================
  // SUBMIT
  // ===========================================================================

  void _submitForm() {
    if (_tabIndex == 0) {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      final newId =
          'PT-${1000 + (DateTime.now().millisecondsSinceEpoch % 8999)}';

      final newPatient = PatientItem(
        id: newId,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 30,
        gender: _gender,
        bloodGroup: _bloodGroup,
        ward: _ward,
        admissionDate: _admissionDate,
        status: _status,
        doctorName: _doctorController.text.trim(),
        vitals: {
          'BP': '120/80',
          'Heart Rate': '75 bpm',
          'SpO2': '98%',
          'Temp': '98.6 °F',
        },
      );

      widget.onPatientAdmitted(newPatient);

      Navigator.pop(context);
      return;
    }

    if (_selectedExistingPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('Please select an existing patient to admit.'),
              ),
            ],
          ),
        ),
      );

      return;
    }

    final p = _selectedExistingPatient!;

    final admittedPatient = PatientItem(
      id: p.id,
      name: p.name,
      age: p.age,
      gender: p.gender,
      bloodGroup: p.bloodGroup,
      ward: _ward,
      admissionDate: DateTime.now(),
      status: _status,
      doctorName: _doctorController.text.trim(),
      vitals: {
        'BP': '120/80',
        'Heart Rate': '75 bpm',
        'SpO2': '98%',
        'Temp': '98.6 °F',
      },
    );

    widget.onPatientAdmitted(admittedPatient);

    Navigator.pop(context);
  }

  // ===========================================================================
  // MAIN
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final width = media.size.width;
    final height = media.size.height;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1000;
    final isDesktop = width >= 1000;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final horizontalPadding = isMobile
        ? 16.0
        : isTablet
        ? 24.0
        : 30.0;

    final maxWidth = isMobile
        ? width
        : isTablet
        ? 720.0
        : 1050.0;

    final maxHeight = isMobile
        ? height * 0.94
        : isTablet
        ? height * 0.88
        : height * 0.86;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 24,
        vertical: isMobile ? 8 : 24,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: _buildGlassShell(
                context,
                isDark: isDark,
                isMobile: isMobile,
                isTablet: isTablet,
                isDesktop: isDesktop,
                horizontalPadding: horizontalPadding,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // GLASS SHELL
  // ===========================================================================

  Widget _buildGlassShell(
    BuildContext context, {
    required bool isDark,
    required bool isMobile,
    required bool isTablet,
    required bool isDesktop,
    required double horizontalPadding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isMobile ? 24 : 30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.48)
                : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(isMobile ? 24 : 30),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.65),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                blurRadius: 50,
                spreadRadius: -10,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: AppTheme.primaryColor.withValues(
                  alpha: isDark ? 0.10 : 0.06,
                ),
                blurRadius: 50,
                spreadRadius: -15,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(isDark: isDark, isMobile: isMobile),

              _buildModeSelector(
                isDark: isDark,
                isMobile: isMobile,
                horizontalPadding: horizontalPadding,
              ),

              Expanded(
                child: isDesktop
                    ? _buildDesktopBody(
                        isDark: isDark,
                        horizontalPadding: horizontalPadding,
                      )
                    : _buildResponsiveBody(
                        isDark: isDark,
                        isMobile: isMobile,
                        horizontalPadding: horizontalPadding,
                      ),
              ),

              _buildBottomActions(
                isDark: isDark,
                isMobile: isMobile,
                horizontalPadding: horizontalPadding,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader({required bool isDark, required bool isMobile}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 26,
        isMobile ? 18 : 24,
        isMobile ? 12 : 20,
        isMobile ? 14 : 18,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: isDark ? 0.16 : 0.09),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildAnimatedHeaderIcon(),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admit Patient',
                  style: TextStyle(
                    fontSize: isMobile ? 19 : 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Create a new admission or find a registered patient',
                  maxLines: isMobile ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.60)
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.70)
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeaderIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withValues(alpha: 0.72),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.28),
                  blurRadius: 18,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MODE SELECTOR
  // ===========================================================================

  Widget _buildModeSelector({
    required bool isDark,
    required bool isMobile,
    required double horizontalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.055)
              : Colors.black.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildModeButton(
                index: 0,
                icon: Icons.person_add_alt_1_rounded,
                title: 'New Patient',
                isDark: isDark,
                isMobile: isMobile,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildModeButton(
                index: 1,
                icon: Icons.search_rounded,
                title: 'Existing Patient',
                isDark: isDark,
                isMobile: isMobile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required int index,
    required IconData icon,
    required String title,
    required bool isDark,
    required bool isMobile,
  }) {
    final selected = _tabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: isMobile ? 11 : 12,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.82),
                  ],
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.24),
                    blurRadius: 14,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? Colors.white
                  : isDark
                  ? Colors.white.withValues(alpha: 0.55)
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isMobile ? 11.5 : 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : isDark
                      ? Colors.white.withValues(alpha: 0.65)
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BODY
  // ===========================================================================

  Widget _buildResponsiveBody({
    required bool isDark,
    required bool isMobile,
    required double horizontalPadding,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        10,
        horizontalPadding,
        18,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.025, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _tabIndex == 0
            ? _buildNewPatientForm(isDark: isDark, isMobile: isMobile)
            : _buildLookupExistingPatientForm(
                isDark: isDark,
                isMobile: isMobile,
              ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP BODY
  // ===========================================================================

  Widget _buildDesktopBody({
    required bool isDark,
    required double horizontalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        14,
        horizontalPadding,
        20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(right: 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _tabIndex == 0
                    ? _buildNewPatientForm(isDark: isDark, isMobile: false)
                    : _buildLookupExistingPatientForm(
                        isDark: isDark,
                        isMobile: false,
                      ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(flex: 3, child: _buildAdmissionSummary(isDark: isDark)),
        ],
      ),
    );
  }

  // ===========================================================================
  // NEW PATIENT FORM
  // ===========================================================================

  Widget _buildNewPatientForm({required bool isDark, required bool isMobile}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.person_rounded,
            title: 'Patient Information',
            subtitle: 'Basic identity and demographic details',
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          _buildGlassField(
            label: 'Patient Full Name',
            icon: Icons.person_outline_rounded,
            controller: _nameController,
            hint: 'e.g. Jane Cooper',
            isDark: isDark,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter patient name';
              }

              return null;
            },
          ),

          const SizedBox(height: 12),

          _buildResponsiveFieldRow(
            isMobile: isMobile,
            first: _buildGlassField(
              label: 'Age',
              icon: Icons.cake_outlined,
              controller: _ageController,
              hint: '45',
              keyboardType: TextInputType.number,
              isDark: isDark,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter age';
                }

                if (int.tryParse(value.trim()) == null) {
                  return 'Invalid age';
                }

                return null;
              },
            ),
            second: _buildDropdownField(
              label: 'Gender',
              icon: Icons.wc_rounded,
              value: _gender,
              items: const ['Female', 'Male', 'Other'],
              isDark: isDark,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _gender = value;
                  });
                }
              },
            ),
          ),

          const SizedBox(height: 12),

          _buildResponsiveFieldRow(
            isMobile: isMobile,
            first: _buildDropdownField(
              label: 'Blood Group',
              icon: Icons.bloodtype_outlined,
              value: _bloodGroup,
              items: _bloodGroups,
              isDark: isDark,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _bloodGroup = value;
                  });
                }
              },
            ),
            second: _buildDropdownField(
              label: 'Admission Status',
              icon: Icons.monitor_heart_outlined,
              value: _statusLabel(_status),
              items: const ['Admitted', 'ICU (Critical)', 'Observation'],
              isDark: isDark,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  if (value == 'ICU (Critical)') {
                    _status = PatientStatus.icu;
                  } else if (value == 'Observation') {
                    _status = PatientStatus.observation;
                  } else {
                    _status = PatientStatus.admitted;
                  }
                });
              },
            ),
          ),

          const SizedBox(height: 18),

          _buildSectionHeader(
            icon: Icons.local_hospital_outlined,
            title: 'Admission Details',
            subtitle: 'Assign the patient to a unit and physician',
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          _buildDropdownField(
            label: 'Assigned Ward / Unit',
            icon: Icons.meeting_room_outlined,
            value: _ward,
            items: _wards,
            isDark: isDark,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _ward = value;
                });
              }
            },
          ),

          const SizedBox(height: 12),

          _buildGlassField(
            label: 'Attending Physician',
            icon: Icons.medical_services_outlined,
            controller: _doctorController,
            hint: 'Dr. Sarah Jenkins',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EXISTING PATIENT
  // ===========================================================================

  Widget _buildLookupExistingPatientForm({
    required bool isDark,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.manage_search_rounded,
          title: 'Find Registered Patient',
          subtitle: 'Search by name, patient ID or phone number',
          isDark: isDark,
        ),

        const SizedBox(height: 12),

        _buildGlassField(
          label: 'Patient Search',
          icon: Icons.search_rounded,
          controller: _lookupSearchController,
          hint: 'Search name, ID, or phone...',
          isDark: isDark,
          onChanged: _performPatientLookup,
          suffix: _isSearching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),

        const SizedBox(height: 16),

        if (_matchingPatients.isNotEmpty) ...[
          Text(
            'Matching Patients',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.78)
                  : AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 9),

          ..._matchingPatients.map(
            (patient) => _buildPatientResult(patient, isDark: isDark),
          ),
        ] else if (_lookupSearchController.text.isNotEmpty &&
            !_isSearching) ...[
          _buildEmptySearchState(isDark: isDark),
        ],

        if (_selectedExistingPatient != null) ...[
          const SizedBox(height: 18),

          _buildSectionHeader(
            icon: Icons.assignment_rounded,
            title: 'Admission Assignment',
            subtitle: 'Configure the new admission',
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          _buildDropdownField(
            label: 'Assigned Ward / Unit',
            icon: Icons.meeting_room_outlined,
            value: _ward,
            items: _wards,
            isDark: isDark,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _ward = value;
                });
              }
            },
          ),

          const SizedBox(height: 12),

          _buildGlassField(
            label: 'Attending Physician',
            icon: Icons.medical_services_outlined,
            controller: _doctorController,
            hint: 'Dr. Sarah Jenkins',
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // PATIENT RESULT
  // ===========================================================================

  Widget _buildPatientResult(Patient patient, {required bool isDark}) {
    final selected = _selectedExistingPatient?.id == patient.id;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedExistingPatient = patient;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 9),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor.withValues(alpha: isDark ? 0.16 : 0.08)
                : isDark
                ? Colors.white.withValues(alpha: 0.045)
                : Colors.white.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryColor.withValues(alpha: 0.65)
                  : isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              width: selected ? 1.3 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      blurRadius: 16,
                      spreadRadius: -5,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.72),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    patient.name.isNotEmpty
                        ? patient.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
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
                      patient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${patient.id}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.55)
                            : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${patient.age} yrs • ${patient.gender} • ${patient.bloodGroup}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              AnimatedScale(
                scale: selected ? 1 : 0.7,
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected
                      ? AppTheme.primaryColor
                      : isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.20),
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY SEARCH
  // ===========================================================================

  Widget _buildEmptySearchState({required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.035)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 42,
            color: isDark
                ? Colors.white.withValues(alpha: 0.25)
                : AppTheme.textSecondary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 10),
          Text(
            'No patient found',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.75)
                  : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching with another name, ID, or phone number.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ADMISSION SUMMARY
  // ===========================================================================

  Widget _buildAdmissionSummary({required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.045)
            : Colors.white.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.055),
        ),
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
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Admission Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _buildSummaryItem(
            icon: Icons.person_outline_rounded,
            label: 'Patient',
            value: _nameController.text.isEmpty
                ? 'Not entered'
                : _nameController.text,
            isDark: isDark,
          ),

          _buildSummaryItem(
            icon: Icons.bloodtype_outlined,
            label: 'Blood Group',
            value: _bloodGroup,
            isDark: isDark,
          ),

          _buildSummaryItem(
            icon: Icons.meeting_room_outlined,
            label: 'Ward',
            value: _ward,
            isDark: isDark,
          ),

          _buildSummaryItem(
            icon: Icons.medical_services_outlined,
            label: 'Physician',
            value: _doctorController.text,
            isDark: isDark,
          ),

          _buildSummaryItem(
            icon: Icons.monitor_heart_outlined,
            label: 'Status',
            value: _statusLabel(_status),
            isDark: isDark,
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.withValues(alpha: 0.16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.green,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Admission data will be added to the hospital patient registry.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.60)
                          : AppTheme.textSecondary,
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

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 9),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.40)
                  : AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.82)
                    : AppTheme.textPrimary,
              ),
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
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
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
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.42)
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _buildGlassField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    Widget? suffix,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isDark
                ? Colors.white.withValues(alpha: 0.72)
                : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withValues(alpha: 0.88)
                : AppTheme.textPrimary,
          ),
          decoration: _inputDecoration(
            hint: hint,
            icon: icon,
            isDark: isDark,
            suffix: suffix,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // DROPDOWN
  // ===========================================================================

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isDark
                ? Colors.white.withValues(alpha: 0.72)
                : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark
                ? Colors.white.withValues(alpha: 0.50)
                : AppTheme.textSecondary,
          ),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withValues(alpha: 0.88)
                : AppTheme.textPrimary,
          ),
          decoration: _inputDecoration(hint: value, icon: icon, isDark: isDark),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 12,
        color: isDark
            ? Colors.white.withValues(alpha: 0.32)
            : AppTheme.textSecondary.withValues(alpha: 0.70),
      ),
      prefixIcon: Icon(
        icon,
        size: 19,
        color: AppTheme.primaryColor.withValues(alpha: 0.85),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.045)
          : Colors.white.withValues(alpha: 0.48),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
      ),
    );
  }

  // ===========================================================================
  // RESPONSIVE ROW
  // ===========================================================================

  Widget _buildResponsiveFieldRow({
    required bool isMobile,
    required Widget first,
    required Widget second,
  }) {
    if (isMobile) {
      return Column(children: [first, const SizedBox(height: 12), second]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }

  // ===========================================================================
  // BOTTOM ACTIONS
  // ===========================================================================

  Widget _buildBottomActions({
    required bool isDark,
    required bool isMobile,
    required double horizontalPadding,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        isMobile ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.20),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: isMobile
          ? Column(
              children: [
                _buildPrimaryButton(isDark: isDark),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.60)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.60)
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                _buildPrimaryButton(isDark: isDark),
              ],
            ),
    );
  }

  Widget _buildPrimaryButton({required bool isDark}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _submitForm,
        icon: Icon(
          _tabIndex == 0
              ? Icons.person_add_alt_1_rounded
              : Icons.check_circle_outline_rounded,
          size: 19,
        ),
        label: Text(_tabIndex == 0 ? 'Admit Patient' : 'Confirm Readmission'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _statusLabel(PatientStatus status) {
    switch (status) {
      case PatientStatus.admitted:
        return 'Admitted';

      case PatientStatus.icu:
        return 'ICU (Critical)';

      case PatientStatus.observation:
        return 'Observation';

      default:
        return 'Admitted';
    }
  }
}
