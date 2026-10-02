import 'dart:ui';
import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../../utils/page_transitions.dart';
import '../models/patient_portal_models.dart';
import './patient_hospital_profile_screen.dart';
import '../symptom_checker/symptom_checker_service.dart';
import '../appointments/book_appointment_modal.dart';
import '../emergency/emergency_hospitals_modal.dart';
import './find_care_for_needs_modal.dart';
import './hospital_comparison_modal.dart';
import './hospital_filter_modal.dart';

class HospitalFinderWidget extends StatefulWidget {
  final Function(String message)? onBookingSuccess;

  const HospitalFinderWidget({super.key, this.onBookingSuccess});

  @override
  State<HospitalFinderWidget> createState() => _HospitalFinderWidgetState();
}

class _HospitalFinderWidgetState extends State<HospitalFinderWidget> {
  String _searchQuery = '';
  String _activeActionFilter = 'All';
  HospitalFilterCriteria _filterCriteria = const HospitalFilterCriteria();

  final TextEditingController _searchController = TextEditingController();

  // ─────────────────────────────────────────────────────────────
  // Healthify Glass Theme — Light + Dark
  // ─────────────────────────────────────────────────────────────
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

  Widget _glassIconButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceStrong(isDark),
        shape: BoxShape.circle,
        border: Border.all(color: _border(isDark)),
      ),
      child: IconButton(
        icon: Icon(icon, color: _primaryText(isDark)),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  final List<String> _quickActionFilters = [
    'All',
    '🏥 Nearby',
    '🚨 Emergency Care',
    '🛏️ Available Beds',
    '🩸 Blood Stock',
    '🧪 Diagnostic Labs',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<NearbyHospital> get _filteredHospitals {
    final all = SymptomCheckerService.getNearbyHospitals();
    var filtered = all.where((h) {
      // Quick Action chip filter
      bool matchesQuick = true;
      if (_activeActionFilter.contains('Emergency')) {
        matchesQuick = h.isEmergencyOpen;
      } else if (_activeActionFilter.contains('Beds')) {
        matchesQuick = h.icuAvailable > 0 || h.availableBeds > 0;
      } else if (_activeActionFilter.contains('Blood')) {
        matchesQuick =
            (h.bloodStock['O-'] ?? 0) > 0 || (h.bloodStock['O+'] ?? 0) > 0;
      } else if (_activeActionFilter.contains('Nearby')) {
        matchesQuick = h.distanceKm <= 3.0;
      }

      // Search Query
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          h.name.toLowerCase().contains(q) ||
          h.address.toLowerCase().contains(q) ||
          h.facilities.any((f) => f.toLowerCase().contains(q));

      // Filter criteria
      final matchesDistance = h.distanceKm <= _filterCriteria.maxDistanceKm;
      final matchesEr = !_filterCriteria.requiresEmergency || h.isEmergencyOpen;
      final matchesIcu = !_filterCriteria.requiresIcu || h.icuAvailable > 0;
      final matchesRating = h.rating >= _filterCriteria.minRating;

      return matchesQuick &&
          matchesQuery &&
          matchesDistance &&
          matchesEr &&
          matchesIcu &&
          matchesRating;
    }).toList();

    // Sort criteria
    if (_filterCriteria.sortBy == 'distance') {
      filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    } else if (_filterCriteria.sortBy == 'icu') {
      filtered.sort((a, b) => b.icuAvailable.compareTo(a.icuAvailable));
    } else if (_filterCriteria.sortBy == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return filtered;
  }

  void _openFilterModal() {
    HospitalFilterModal.show(
      context,
      initialCriteria: _filterCriteria,
      onApplyFilters: (updated) {
        setState(() => _filterCriteria = updated);
      },
    );
  }

  void _openFindCareModal() {
    FindCareForNeedsModal.show(
      context,
      onCareMatched: (department, matchingHospitals) {
        setState(() {
          _searchQuery = department;
        });
      },
    );
  }

  void _openComparisonModal() {
    HospitalComparisonModal.show(context, hospitals: _filteredHospitals);
  }

  void _openHospitalProfile(NearbyHospital hospital) {
    Navigator.push(
      context,
      FadePageRoute(
        page: PatientHospitalProfileScreen(
          hospital: hospital,
          onBookingSuccess: widget.onBookingSuccess,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hospitals = _filteredHospitals;

    return _glassBackground(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER & LOCATION INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find a Hospital',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primaryText(isDark),
                      ),
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
              Row(
                children: [
                  _glassIconButton(
                    isDark: isDark,
                    icon: Icons.compare_arrows_rounded,
                    onPressed: _openComparisonModal,
                    tooltip: 'Compare Hospitals Side-by-Side',
                  ),
                  const SizedBox(width: 8),
                  _glassIconButton(
                    isDark: isDark,
                    icon: Icons.tune_rounded,
                    onPressed: _openFilterModal,
                    tooltip: 'Smart Filters & Sorting',
                  ),
                ],
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
              hintText: 'Search hospitals, ICU, labs, facilities...',
              hintStyle: TextStyle(color: _secondaryText(isDark), fontSize: 13),

              prefixIcon: Icon(Icons.search_rounded, color: _primary),

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

          // 3. CARE MATCHING ASSISTANT
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
                      color: _primary.withValues(alpha: isDark ? 0.12 : 0.06),
                      blurRadius: 24,
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
                            color: _primary.withValues(
                              alpha: isDark ? 0.25 : 0.18,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.manage_search_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Care Assistant',
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
                                  'SMART',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF5EEAD4)
                                        : _primaryDark,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find a hospital based on your care needs.',
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
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openFindCareModal,
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
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Match',
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

          // 4. QUICK ACTION FILTERS — PREMIUM GLASS PILLS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _quickActionFilters.map((action) {
                final isSelected = _activeActionFilter == action;

                final icons = <String, IconData>{
                  'All': Icons.grid_view_rounded,
                  '🏥 Nearby': Icons.location_on_rounded,
                  '🚨 Emergency Care': Icons.emergency_rounded,
                  '🛏️ Available Beds': Icons.bed_rounded,
                  '🩸 Blood Stock': Icons.bloodtype_rounded,
                  '🧪 Diagnostic Labs': Icons.biotech_rounded,
                };

                final icon = icons[action] ?? Icons.local_hospital_rounded;

                final label = action
                    .replaceFirst('🏥 ', '')
                    .replaceFirst('🚨 ', '')
                    .replaceFirst('🛏️ ', '')
                    .replaceFirst('🩸 ', '')
                    .replaceFirst('🧪 ', '');

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _activeActionFilter = action);
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
                            ? const LinearGradient(
                                colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
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
                            label,
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
              color: isDark
                  ? Colors.redAccent.withValues(alpha: 0.075)
                  : Colors.redAccent.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.redAccent.withValues(alpha: isDark ? 0.22 : 0.16),
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
                    'Need urgent emergency hospital care?',
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
                    'Emergency Flow',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 6. HOSPITALS LIST OR EMPTY STATE
          if (hospitals.isEmpty)
            _buildNoHospitalsState()
          else if (MediaQuery.of(context).size.width >= 700)
            LayoutBuilder(
              builder: (context, constraints) {
                final gridWidth = constraints.maxWidth;
                final int crossCount = gridWidth >= 1150 ? 3 : 2;
                final double extent = gridWidth >= 1150 ? 370.0 : 415.0;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: extent,
                  ),
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    return _buildHospitalCard(hospitals[index], isDark);
                  },
                );
              },
            )
          else
            ...hospitals.map((h) => _buildHospitalCard(h, isDark)),
        ],
      ),
    );
  }

  // HOSPITAL CARD WIDGET
  Widget _buildHospitalCard(NearbyHospital h, bool isDark) {
    return DynamicHoverGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 22,
      padding: const EdgeInsets.all(16.0),
      onTap: () => _openHospitalProfile(h),
      hasTealGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.domain_rounded,
                      color: Colors.teal,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Multi-Specialty • ${h.distanceKm} km away',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          h.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
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
                          '${h.rating} (${h.reviewsCount})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: _border(isDark)),
              const SizedBox(height: 12),

              // Live Capacity Badges Row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCapacityBadge(
                    icon: Icons.hotel_rounded,
                    label: 'ICU Beds: ${h.icuAvailable}/${h.icuTotal}',
                    color: h.icuAvailable > 0 ? Colors.green : Colors.red,
                  ),
                  _buildCapacityBadge(
                    icon: Icons.king_bed_outlined,
                    label: 'General: ${h.availableBeds}/${h.totalBeds}',
                    color: Colors.blue,
                  ),
                  _buildCapacityBadge(
                    icon: Icons.bloodtype_outlined,
                    label: 'O- Blood: ${h.bloodStock['O-'] ?? 0} U',
                    color: (h.bloodStock['O-'] ?? 0) > 0
                        ? Colors.teal
                        : Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Facilities Chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: h.facilities.take(4).map((f) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkBackgroundColor
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Text(
                      f,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // Action Buttons Row (View Hospital vs Book)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openHospitalProfile(h),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal,
                        side: const BorderSide(color: Colors.teal),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Hospital',
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
                          onSuccess: widget.onBookingSuccess,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
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

  Widget _buildCapacityBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoHospitalsState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border(isDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.03),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.domain_disabled_rounded,
            color: AppTheme.textMuted,
            size: 44,
          ),
          const SizedBox(height: 12),
          const Text(
            'No hospitals matching search criteria',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'No hospital matches search "$_searchQuery" within distance ${_filterCriteria.maxDistanceKm.toInt()} km.',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _activeActionFilter = 'All';
                _searchQuery = '';
                _searchController.clear();
                _filterCriteria = const HospitalFilterCriteria();
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal,
              side: const BorderSide(color: Colors.teal),
            ),
            child: const Text('Reset Action & Smart Filters'),
          ),
        ],
      ),
    );
  }
}