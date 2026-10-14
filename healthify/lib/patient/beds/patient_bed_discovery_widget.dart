import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import './bed_discovery_service.dart';
import './ai_bed_matcher_modal.dart';
import './bed_comparison_modal.dart';
import './bed_details_modal.dart';
import './bed_filter_modal.dart';

class PatientBedDiscoveryWidget extends StatefulWidget {
  const PatientBedDiscoveryWidget({super.key});

  @override
  State<PatientBedDiscoveryWidget> createState() =>
      _PatientBedDiscoveryWidgetState();
}

class _PatientBedDiscoveryWidgetState extends State<PatientBedDiscoveryWidget> {
  String _searchQuery = '';
  String _activeQuickFilter = 'All Beds';
  bool _isEmergencyMode = false;
  bool _isLoading = true;
  bool _isOffline = false;
  bool _hasLocationPermission = true;
  bool _showAvailabilityChangedAlert = true;

  BedFilterCriteria _filterCriteria = const BedFilterCriteria();
  final Set<String> _selectedRequirementTypes = {'ICU', 'Emergency'};
  final List<HospitalBedData> _selectedForComparison = [];

  final TextEditingController _searchController = TextEditingController();
  List<HospitalBedData> _bedData = const [];

  // ─────────────────────────────────────────────────────────────
  // Healthify Glass Theme — Light + Dark
  // ─────────────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF0D9488);

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
    double radius = 22,
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

  Widget _glassBackground({required bool isDark, required Widget child}) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: IgnorePointer(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withValues(alpha: isDark ? 0.065 : 0.055),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -90,
          child: IgnorePointer(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo.withValues(alpha: isDark ? 0.035 : 0.025),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }

  final List<Map<String, String>> _bedRequirements = [
    {'type': 'General', 'icon': '🛏️', 'title': 'General Ward'},
    {'type': 'Emergency', 'icon': '🚨', 'title': 'Emergency ER'},
    {'type': 'ICU', 'icon': '❤️', 'title': 'ICU / Critical Care'},
    {'type': 'Pediatric', 'icon': '👶', 'title': 'Pediatric (PICU)'},
    {'type': 'Maternity', 'icon': '🤰', 'title': 'Maternity Ward'},
    {'type': 'Private', 'icon': '🏥', 'title': 'Private Room'},
  ];

  final List<String> _quickFilterChips = [
    'All Beds',
    'ICU',
    'Emergency',
    'General',
    'Private',
    'Pediatric',
    'Maternity',
  ];

  @override
  void initState() {
    super.initState();
    _loadBedData();
  }

  Future<void> _loadBedData() async {
    try {
      final results = await BedDiscoveryService.getHospitalBedDataList();
      if (!mounted) return;
      setState(() {
        _bedData = results;
        _isLoading = false;
        _isOffline = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isOffline = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HospitalBedData> get _filteredHospitals {
    var list = List<HospitalBedData>.of(_bedData);

    // Emergency mode filter
    if (_isEmergencyMode) {
      list = list
          .where(
            (d) => d.hospital.emergencyStatusKnown && d.hospital.isEmergencyOpen,
          )
          .toList();
    }

    // Filter by quick filter chip
    if (_activeQuickFilter != 'All Beds') {
      list = list.where((d) {
        return d.categories.any(
          (c) =>
              c.name.toLowerCase() == _activeQuickFilter.toLowerCase() &&
              c.available > 0,
        );
      }).toList();
    }

    // Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((d) {
        return d.hospital.name.toLowerCase().contains(q) ||
            d.hospital.address.toLowerCase().contains(q) ||
            d.categories.any((c) => c.name.toLowerCase().contains(q));
      }).toList();
    }

    // Filter criteria
    list = list.where((d) {
      final matchesDist = !d.hospital.distanceAvailable ||
          d.hospital.distanceKm <= _filterCriteria.maxDistanceKm;
      final matchesEr =
          !_filterCriteria.requiresEmergency || d.hospital.isEmergencyOpen;
      final matchesIcu =
          !_filterCriteria.requiresIcu ||
          d.categories.any((c) => c.name == 'ICU' && c.available > 0);
      return matchesDist && matchesEr && matchesIcu;
    }).toList();

    // Sort options
    if (_filterCriteria.sortBy == 'nearest') {
      list.sort(
        (a, b) {
          if (a.hospital.distanceAvailable != b.hospital.distanceAvailable) {
            return a.hospital.distanceAvailable ? -1 : 1;
          }
          return a.hospital.distanceKm.compareTo(b.hospital.distanceKm);
        },
      );
    } else if (_filterCriteria.sortBy == 'most_available') {
      list.sort((a, b) {
        final sumA = a.categories.fold(0, (prev, c) => prev + c.available);
        final sumB = b.categories.fold(0, (prev, c) => prev + c.available);
        return sumB.compareTo(sumA);
      });
    } else if (_filterCriteria.sortBy == 'earliest_updated') {
      list.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    }

    return list;
  }

  String _formatTimestamp(DateTime dt) {
    if (dt.millisecondsSinceEpoch == 0) return 'Update time unavailable';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours}h ago';
  }

  void _toggleComparison(HospitalBedData data) {
    setState(() {
      final exists = _selectedForComparison.any(
        (b) => b.hospital.id == data.hospital.id,
      );
      if (exists) {
        _selectedForComparison.removeWhere(
          (b) => b.hospital.id == data.hospital.id,
        );
      } else {
        if (_selectedForComparison.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You can compare a maximum of 3 hospitals at a time.',
              ),
            ),
          );
          return;
        }
        _selectedForComparison.add(data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _filteredHospitals;

    return _glassBackground(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. PAGE HEADER & LOCATION BAR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border(isDark)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.17 : 0.035),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.king_bed_rounded,
                          color: Colors.indigo,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Find Available Beds',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _primaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Using current location (GPS Active: Downtown Central)',
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.teal.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.my_location_rounded,
                              size: 14,
                              color: Colors.teal,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Hospitals',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'See live bed availability that hospitals have shared with patients.',
                  style: TextStyle(fontSize: 13, color: _secondaryText(isDark)),
                ),
                const SizedBox(height: 16),

                // Search Input Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      cursorColor: const Color(0xFF0D9488),
                      decoration: InputDecoration(
                        hintText: 'Search hospital, bed type, address...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.55)
                              : AppTheme.textSecondary,
                          fontSize: 13,
                        ),

                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF0D9488),
                        ),

                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.55)
                                      : AppTheme.textSecondary,
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
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.085)
                                : Colors.white.withValues(alpha: 0.88),
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.085)
                                : Colors.white.withValues(alpha: 0.88),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: const Color(
                              0xFF0D9488,
                            ).withValues(alpha: isDark ? 0.55 : 0.40),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Emergency Mode Banner Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isEmergencyMode = !_isEmergencyMode;
                });
              },
              icon: Icon(
                _isEmergencyMode
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                color: Colors.red,
                size: 18,
              ),
              label: Text(
                _isEmergencyMode
                    ? '🚨 Emergency Mode ACTIVE (Showing ER Open Only)'
                    : '🚨 Switch to Emergency Bed Search Mode',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: _isEmergencyMode
                    ? Colors.red.withValues(alpha: isDark ? 0.12 : 0.07)
                    : _surfaceStrong(isDark),
                side: BorderSide(
                  color: Colors.red.withValues(alpha: isDark ? 0.40 : 0.28),
                  width: 1.3,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // PROMINENT EMERGENCY NOTICE
          if (_isEmergencyMode) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: isDark ? 0.09 : 0.055),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.red.withValues(alpha: isDark ? 0.30 : 0.20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'For a life-threatening emergency, contact local emergency services (911/108) immediately. Bed availability shown here is live but changes rapidly.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // AVAILABILITY CHANGED NOTIFICATION BANNER
          if (_showAvailabilityChangedAlert && !_isEmergencyMode) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: isDark ? 0.075 : 0.045),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: isDark ? 0.22 : 0.16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Availability update: St. Jude Memorial recently updated ICU bed status (3 available).',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.blue,
                    ),
                    onPressed: () =>
                        setState(() => _showAvailabilityChangedAlert = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 2. BED REQUIREMENT SELECTOR SECTION
          Text(
            'What type of bed are you looking for?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryText(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select one or multiple bed types to filter available capacity.',
            style: TextStyle(fontSize: 12.5, color: _secondaryText(isDark)),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _bedRequirements.map((item) {
              final type = item['type']!;
              final isSelected = _selectedRequirementTypes.contains(type);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_selectedRequirementTypes.length > 1) {
                        _selectedRequirementTypes.remove(type);
                      }
                    } else {
                      _selectedRequirementTypes.add(type);
                    }
                    _activeQuickFilter =
                        isSelected && _selectedRequirementTypes.isEmpty
                        ? 'All Beds'
                        : type;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _primary.withValues(alpha: isDark ? 0.14 : 0.09)
                        : _surfaceStrong(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? _primary : _border(isDark),
                      width: isSelected ? 1.6 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.08 : 0.02,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['icon']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        item['type']!,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected ? _primary : _primaryText(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 3. QUICK FILTERS & ACTIONS ROW
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._quickFilterChips.map((chip) {
                  final isSelected = _activeQuickFilter == chip;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(chip),
                      selected: isSelected,
                      selectedColor: _primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _primaryText(isDark),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _activeQuickFilter = chip);
                      },
                    ),
                  );
                }),
                const SizedBox(width: 4),
                OutlinedButton.icon(
                  onPressed: () {
                    BedFilterModal.show(
                      context,
                      initialCriteria: _filterCriteria,
                      onApplyFilters: (updated) {
                        setState(() => _filterCriteria = updated);
                      },
                    );
                  },
                  icon: const Icon(Icons.filter_list_rounded, size: 16),
                  label: const Text(
                    'Filter & Sort',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // TOOLS ROW: AI MATCHER & COMPARISON
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AiBedMatcherModal.show(
                      context,
                      onHospitalSelected: (selected) {
                        BedDetailsModal.show(context, bedData: selected);
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.purple,
                    size: 16,
                  ),
                  label: const Text(
                    'AI Bed Matcher',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.purple.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectedForComparison.length < 2
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Select 2 or 3 hospitals using the "Compare" check box on cards to compare.',
                              ),
                            ),
                          );
                        }
                      : () {
                          BedComparisonModal.show(
                            context,
                            hospitalsToCompare: _selectedForComparison,
                          );
                        },
                  icon: const Icon(
                    Icons.compare_arrows_rounded,
                    color: Colors.indigo,
                    size: 16,
                  ),
                  label: Text(
                    _selectedForComparison.isEmpty
                        ? 'Compare (0)'
                        : 'Compare (${_selectedForComparison.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.indigo.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 4. RESULTS HEADING & LIST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${results.length} Hospitals Reporting Bed Availability',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _primaryText(isDark),
                ),
              ),
              const Text(
                'Live Feed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // EDGE STATES HANDLING
          if (_isLoading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            ),
          ] else if (!_hasLocationPermission) ...[
            _buildEdgeStateCard(
              icon: Icons.location_off_rounded,
              title: 'Location Permission Required',
              subtitle:
                  'Please enable GPS location to calculate accurate travel time and distance to nearby hospital beds.',
              buttonText: 'Grant Location Access',
              onTap: () => setState(() => _hasLocationPermission = true),
            ),
          ] else if (_isOffline) ...[
            _buildEdgeStateCard(
              icon: Icons.wifi_off_rounded,
              title: 'Network Disconnected',
              subtitle: 'Could not refresh hospital-published bed availability.',
              buttonText: 'Retry Connection',
              onTap: () {
                setState(() => _isLoading = true);
                _loadBedData();
              },
            ),
          ] else if (results.isEmpty) ...[
            _buildEdgeStateCard(
              icon: Icons.king_bed_outlined,
              title: 'No Matching Available Beds Nearby',
              subtitle:
                  'No verified hospital has published matching bed availability for these filters.',
              buttonText: 'Reset Filters & Expand Distance',
              onTap: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _activeQuickFilter = 'All Beds';
                  _filterCriteria = const BedFilterCriteria();
                  _isEmergencyMode = false;
                });
              },
            ),
          ] else if (MediaQuery.of(context).size.width >= 600) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width >= 1200
                    ? 3
                    : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 360,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return _buildHospitalBedResultCard(results[index], isDark);
              },
            ),
          ] else ...[
            // LIST OF HOSPITALS WITH COMPACT, INFO-RICH BED CARDS
            Column(
              children: results.map((bedData) {
                return _buildHospitalBedResultCard(bedData, isDark);
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),

          // PRODUCT TRUST FOOTER DISCLAIMER
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surface(isDark),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border(isDark)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.025),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      'MEDRIX Availability Data Policy',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '• Bed availability counts are reported directly by hospital admission desks.\n• Data is updated continuously, but rapid emergency admissions can alter capacity.\n• Always call the hospital admission desk to confirm availability before travelling.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _secondaryText(isDark),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEdgeStateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _glassCard(
      isDark: isDark,
      padding: const EdgeInsets.all(24),
      radius: 22,
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalBedResultCard(HospitalBedData bedData, bool isDark) {
    final h = bedData.hospital;
    final isStale = bedData.isStale;
    final isCompared = _selectedForComparison.any(
      (b) => b.hospital.id == bedData.hospital.id,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1000;
        final isDesktop = width >= 1000;

        final horizontalPadding = isMobile
            ? 14.0
            : isTablet
            ? 18.0
            : 22.0;

        final titleSize = isMobile
            ? 16.0
            : isTablet
            ? 17.0
            : 18.0;

        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 18),
          decoration: BoxDecoration(
            color: _surface(isDark),
            borderRadius: BorderRadius.circular(isMobile ? 18 : 22),
            border: Border.all(
              color: isCompared ? Colors.indigo : _border(isDark),
              width: isCompared ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.035),
                blurRadius: isMobile ? 18 : 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isMobile ? 18 : 22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================================================
                    // HEADER
                    // =========================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hospital identity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    h.name,
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryText(isDark),
                                      height: 1.2,
                                    ),
                                  ),

                                  // Rating
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(
                                        alpha: 0.15,
                                      ),
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
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 7),

                              // Location
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 1),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      size: 15,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '${h.distanceAvailable ? '${h.distanceKm} km • ${bedData.estimatedTravelTime} • ' : 'Distance unavailable • '}'
                                      '${h.address}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                        height: 1.35,
                                      ),
                                      maxLines: isMobile ? 2 : 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Compare
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _toggleComparison(bedData),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: isCompared,
                                    activeColor: Colors.indigo,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (_) =>
                                        _toggleComparison(bedData),
                                  ),
                                  const Text(
                                    'Compare',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 14 : 18),

                    // =========================================================
                    // STATUS + UPDATED
                    // =========================================================
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: _border(isDark)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isStale
                                ? Icons.warning_amber_rounded
                                : Icons.history_rounded,
                            size: 15,
                            color: isStale
                                ? Colors.amber.shade900
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              isStale
                                  ? 'Updated ${_formatTimestamp(bedData.lastUpdated)} • Stale Data'
                                  : 'Updated ${_formatTimestamp(bedData.lastUpdated)}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isStale
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isStale
                                    ? Colors.amber.shade900
                                    : AppTheme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isMobile ? 14 : 16),

                    Divider(height: 1, color: _border(isDark)),

                    SizedBox(height: isMobile ? 14 : 16),

                    // =========================================================
                    // BED CATEGORY SECTION
                    // =========================================================
                    Row(
                      children: [
                        Icon(
                          Icons.hotel_rounded,
                          size: 17,
                          color: _primaryText(isDark),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Bed Availability',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.bold,
                            color: _primaryText(isDark),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: bedData.categories.map((cat) {
                        return _buildBedCategoryBadge(cat);
                      }).toList(),
                    ),

                    SizedBox(height: isMobile ? 18 : 20),

                    // =========================================================
                    // ACTION AREA
                    // =========================================================
                    if (isMobile)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHospitalActionButton(
                            icon: Icons.phone_outlined,
                            label: 'Call Hospital',
                            outlined: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Calling ${h.name} Admission Line (${h.phone})...',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 9),
                          _buildHospitalActionButton(
                            icon: Icons.navigation_outlined,
                            label: 'Directions',
                            outlined: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Getting directions to ${h.name}. '
                                    'Est. travel time: '
                                    '${bedData.estimatedTravelTime}',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 9),
                          _buildHospitalActionButton(
                            icon: Icons.arrow_forward_rounded,
                            label: 'View Beds',
                            outlined: false,
                            onTap: () {
                              BedDetailsModal.show(context, bedData: bedData);
                            },
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _buildHospitalActionButton(
                              icon: Icons.phone_outlined,
                              label: 'Call Hospital',
                              outlined: true,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Calling ${h.name} Admission Line (${h.phone})...',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildHospitalActionButton(
                              icon: Icons.navigation_outlined,
                              label: 'Directions',
                              outlined: true,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Getting directions to ${h.name}. '
                                      'Est. travel time: '
                                      '${bedData.estimatedTravelTime}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: isDesktop ? 1 : 2,
                            child: _buildHospitalActionButton(
                              icon: Icons.arrow_forward_rounded,
                              label: 'View Beds',
                              outlined: false,
                              onTap: () {
                                BedDetailsModal.show(context, bedData: bedData);
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHospitalActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool outlined,
  }) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildBedCategoryBadge(BedCategoryDetail cat) {
    Color badgeColor;

    if (cat.available == 0) {
      badgeColor = Colors.red;
    } else if (cat.available <= 3) {
      badgeColor = Colors.amber.shade800;
    } else {
      badgeColor = Colors.green;
    }

    final bool isCritical = cat.available == 0;
    final bool isLow = cat.available > 0 && cat.available <= 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(cat.icon, style: const TextStyle(fontSize: 13)),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${cat.available}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'available',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isCritical
                      ? 'Full'
                      : isLow
                      ? 'Low'
                      : 'Available',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
