import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/provider/repository_provider.dart';
import '../../core/queries/domain_queries.dart' as queries;
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../../utils/page_transitions.dart';
import '../models/patient_portal_models.dart';
import './patient_doctor_profile_screen.dart';
import '../appointments/book_appointment_modal.dart';
import './doctor_filter_modal.dart';
import '../emergency/emergency_hospitals_modal.dart';
import './find_by_concern_modal.dart';

class DoctorFinderWidget extends StatefulWidget {
  final Function(String)? onBookingSuccess;

  const DoctorFinderWidget({super.key, this.onBookingSuccess});

  @override
  State<DoctorFinderWidget> createState() => _DoctorFinderWidgetState();
}

class _DoctorFinderWidgetState extends State<DoctorFinderWidget> {
  String _searchQuery = '';
  String _selectedDept = 'All';
  DoctorFilterCriteria _filterCriteria = const DoctorFilterCriteria();

  final TextEditingController _searchController = TextEditingController();
  List<DoctorSearchResult> _directoryDoctors = [];
  bool _isLoadingDirectory = true;

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  Color _surface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.045)
      : Colors.white.withValues(alpha: 0.72);
  Color _surfaceStrong(bool isDark) => isDark
      ? Color(0xFF0D9488).withValues(alpha: 0.075)
      : Colors.white.withValues(alpha: 0.90);
  Color _border(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.085)
      : Colors.white.withValues(alpha: 0.88);
  Color _primaryText(bool isDark) =>
      isDark ? Colors.white : AppTheme.textPrimary;
  Color _secondaryText(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.textSecondary;

  Widget _glassBackground({required bool isDark, required Widget child}) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          right: -70,
          child: IgnorePointer(
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withValues(alpha: isDark ? 0.065 : 0.055),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -110,
          left: -80,
          child: IgnorePointer(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo.withValues(alpha: isDark ? 0.045 : 0.035),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }

  final List<String> _quickCategories = [
    'All',
    'Cardiology',
    'Dermatology',
    'Orthopedics',
    'Neurology',
    'Pediatrics',
    'ENT',
    'General Medicine',
    'Gynecology',
    'Pulmonology',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctorDirectory();
  }

  Future<void> _loadDoctorDirectory() async {
    try {
      final repository = RepositoryContainer.instance.patientDiscoveryRepository;
      final hospitals = await repository.searchHospitals(
        const queries.HospitalSearchQuery(pageSize: 100),
      );
      final hospitalNames = {for (final hospital in hospitals) hospital.id: hospital.name};
      final doctors = await repository.searchDoctors(
        const queries.DoctorSearchQuery(pageSize: 100),
      );
      final results = doctors.map((doctor) => DoctorSearchResult(
        id: doctor.id,
        name: doctor.name,
        specialty: doctor.specialization,
        department: doctor.departmentId.isEmpty ? doctor.specialization : doctor.departmentId,
        hospitalName: hospitalNames[doctor.hospitalId] ?? 'Verified hospital',
        distanceKm: 0,
        distanceAvailable: false,
        rating: doctor.rating,
        reviewsCount: doctor.reviewCount,
        experienceYears: doctor.experienceYears,
        consultationFee: doctor.consultationFee,
        availableSlots: const [],
        isTeleconsultAvailable: false,
        hospitalId: doctor.hospitalId,
        departmentId: doctor.departmentId,
      )).toList();
      if (!mounted) return;
      setState(() {
        _directoryDoctors = results;
        _isLoadingDirectory = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingDirectory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load doctors: $error')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DoctorSearchResult> get _filteredDoctors {
    final all = _directoryDoctors;
    var filtered = all.where((d) {
      // Category / Department check
      final targetDept = _selectedDept != 'All'
          ? _selectedDept
          : _filterCriteria.department;
      final matchesDept =
          targetDept == 'All' ||
          d.department.toLowerCase() == targetDept.toLowerCase();

      // Search query check
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.specialty.toLowerCase().contains(q) ||
          d.hospitalName.toLowerCase().contains(q);

      // Distance check
      final matchesDistance = !d.distanceAvailable ||
          d.distanceKm <= _filterCriteria.maxDistanceKm;

      // Rating check
      final matchesRating = d.rating >= _filterCriteria.minRating;

      return matchesDept && matchesQuery && matchesDistance && matchesRating;
    }).toList();

    // Sort options
    if (_filterCriteria.sortBy == 'distance') {
      filtered.sort((a, b) {
        if (a.distanceAvailable != b.distanceAvailable) {
          return a.distanceAvailable ? -1 : 1;
        }
        return a.distanceKm.compareTo(b.distanceKm);
      });
    } else if (_filterCriteria.sortBy == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return filtered;
  }

  void _openFilterModal() {
    DoctorFilterModal.show(
      context,
      initialCriteria: _filterCriteria,
      onApplyFilters: (updated) {
        setState(() {
          _filterCriteria = updated;
          if (updated.department != 'All') _selectedDept = updated.department;
        });
      },
    );
  }

  void _openFindByConcernModal() {
    FindByConcernModal.show(
      context,
      onDepartmentSelected: (department, suggestedDocs) {
        setState(() {
          _selectedDept = department;
          _filterCriteria = _filterCriteria.copyWith(department: department);
        });
      },
    );
  }

  void _openDoctorProfile(DoctorSearchResult doc) {
    Navigator.push(
      context,
      FadePageRoute(
        page: PatientDoctorProfileScreen(
          doctor: doc,
          onAppointmentBooked: (newAppt) => _persistAppointment(newAppt),
        ),
      ),
    );
  }

  Future<void> _persistAppointment(PatientAppointment appointment) async {
    final portal = RepositoryContainer.instance.patientPortalRepository;
    if (portal == null) {
      throw StateError('Serverpod patient account is not connected.');
    }
    await portal.save(
        'patientAppointments',
        appointment.id,
        {
          'id': appointment.id,
          'doctorId': appointment.doctorId,
          'hospitalId': appointment.hospitalId,
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
    widget.onBookingSuccess?.call(
      'Appointment request sent for ${appointment.doctorName}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doctors = _filteredDoctors;

    return _glassBackground(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER BAR & LOCATION INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find a Doctor',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.teal,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Near me (Sector 4, Medical District)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: _primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.tune_rounded, color: _primaryText(isDark)),
                onPressed: _openFilterModal,
                tooltip: 'Smart Filters & Sorting',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. SEARCH BAR
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: TextStyle(color: _primaryText(isDark), fontSize: 14),
            cursorColor: _primary,
            decoration: InputDecoration(
              hintText: 'Search doctors, specialties, or hospitals...',
              hintStyle: TextStyle(color: _secondaryText(isDark), fontSize: 13),

              prefixIcon: const Icon(Icons.search_rounded, color: _primary),

              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: _secondaryText(isDark),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
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
          ),

          const SizedBox(height: 16),

          // 3. AI HEALTH CONCERN ASSISTANT
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0D9488).withValues(alpha: 0.10)
                      : Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF5EEAD4).withValues(alpha: 0.14)
                        : const Color(0xFF0D9488).withValues(alpha: 0.16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF0D9488,
                      ).withValues(alpha: isDark ? 0.12 : 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // AI ICON
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? const [Color(0xFF0D9488), Color(0xFF0F766E)]
                              : const [Color(0xFF14B8A6), Color(0xFF0D9488)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0D9488,
                            ).withValues(alpha: isDark ? 0.25 : 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 13),

                    // CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Health Assistant',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _primaryText(isDark),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _primary.withValues(
                                    alpha: isDark ? 0.14 : 0.09,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  'AI',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF5EEAD4)
                                        : _primaryDark,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Not sure which specialist you need?',
                            style: TextStyle(
                              color: _secondaryText(isDark),
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ACTION
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openFindByConcernModal,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withValues(
                                  alpha: isDark ? 0.22 : 0.14,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Find',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 4. SPECIALTY CATEGORY — PREMIUM HORIZONTAL PILLS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _quickCategories.map((cat) {
                final isSelected = _selectedDept == cat;

                final icons = <String, IconData>{
                  'All': Icons.grid_view_rounded,
                  'Cardiology': Icons.favorite_rounded,
                  'Dermatology': Icons.face_retouching_natural_rounded,
                  'Orthopedics': Icons.accessibility_new_rounded,
                  'Neurology': Icons.psychology_rounded,
                  'Pediatrics': Icons.child_care_rounded,
                  'ENT': Icons.hearing_rounded,
                  'General Medicine': Icons.medical_services_rounded,
                  'Gynecology': Icons.female_rounded,
                  'Pulmonology': Icons.air_rounded,
                };

                final icon = icons[cat] ?? Icons.medical_services_rounded;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedDept = cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: isSelected
                            ? LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF0D9488),
                                        const Color(0xFF0F766E),
                                      ]
                                    : [
                                        const Color(0xFF0D9488),
                                        const Color(0xFF0F766E),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : _surfaceStrong(isDark),
                        border: Border.all(
                          color: isSelected
                              ? _primary.withValues(alpha: 0.75)
                              : _border(isDark),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _primary.withValues(
                                    alpha: isDark ? 0.28 : 0.18,
                                  ),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.08 : 0.025,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 17,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.72)
                                      : _primaryDark),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : _primaryText(isDark),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // 5. EMERGENCY ENTRY BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Need urgent medical care right now?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => EmergencyHospitalsModal.show(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    'Find ER Care',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 6. DOCTOR LIST OR EMPTY STATE
          if (doctors.isEmpty) ...[
          _isLoadingDirectory
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ))
              : _buildNoDoctorsState(),
          ] else if (MediaQuery.of(context).size.width >= 700) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final gridWidth = constraints.maxWidth;
                final int crossCount = gridWidth >= 1150 ? 3 : 2;
                final double extent = gridWidth >= 1150 ? 320.0 : 360.0;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: extent,
                  ),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    return _buildDoctorCard(doctors[index], isDark);
                  },
                );
              },
            ),
          ] else ...[
            ...doctors.map((doc) => _buildDoctorCard(doc, isDark)),
          ],
        ],
      ),
    );
  }

  // DOCTOR CARD WIDGET
  Widget _buildDoctorCard(DoctorSearchResult doc, bool isDark) {
    return DynamicHoverGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 22,
      padding: const EdgeInsets.all(16.0),
      onTap: () => _openDoctorProfile(doc),
      hasTealGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _primary.withValues(
                      alpha: isDark ? 0.14 : 0.10,
                    ),
                    child: Text(
                      doc.name.replaceFirst('Dr. ', '')[0],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF5EEAD4) : _primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: _primaryText(isDark),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doc.specialty} • ${doc.experienceYears} yrs exp.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF5EEAD4)
                                : _primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${doc.hospitalName}${doc.distanceAvailable ? ' (${doc.distanceKm} km away)' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _secondaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${doc.rating} (${doc.reviewsCount})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        doc.consultationFee > 0
                            ? '₹${doc.consultationFee.toInt()} Fee'
                            : 'Fee unavailable',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? const Color(0xFF5EEAD4) : _primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Available Slot Bar
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFF5EEAD4) : _primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    doc.availableSlots.isEmpty ? 'Schedule: ' : 'Available Today: ',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    doc.availableSlots.firstOrNull ?? 'Contact Clinic',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Action Buttons Row (View Profile vs Book)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openDoctorProfile(doc),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: BorderSide(
                          color: _primary.withValues(
                            alpha: isDark ? 0.55 : 0.45,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        BookAppointmentModal.show(
                          context,
                          doctor: doc,
                          onSuccess: widget.onBookingSuccess,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: const Text(
                        'Book Appointment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  // EMPTY NO DOCTORS STATE
  Widget _buildNoDoctorsState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_rounded,
            color: AppTheme.textMuted,
            size: 44,
          ),
          const SizedBox(height: 12),
          const Text(
            'No doctors found matching criteria',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'No doctor matches department "$_selectedDept" and distance filter ${_filterCriteria.maxDistanceKm.toInt()} km.',
            style: TextStyle(fontSize: 12.5, color: _secondaryText(isDark)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedDept = 'All';
                _searchQuery = '';
                _searchController.clear();
                _filterCriteria = const DoctorFilterCriteria();
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.indigo,
              side: const BorderSide(color: Colors.indigo),
            ),
            child: const Text('Reset Category & Smart Filters'),
          ),
        ],
      ),
    );
  }
}
