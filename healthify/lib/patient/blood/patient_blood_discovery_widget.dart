import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import './blood_discovery_service.dart';
import './ai_blood_matcher_modal.dart';
import './blood_comparison_modal.dart';
import './blood_details_modal.dart';
import './blood_filter_modal.dart';
import './blood_request_modal.dart';
import './donation_centers_modal.dart';

class PatientBloodDiscoveryWidget extends StatefulWidget {
  const PatientBloodDiscoveryWidget({super.key});

  @override
  State<PatientBloodDiscoveryWidget> createState() =>
      _PatientBloodDiscoveryWidgetState();
}

class _PatientBloodDiscoveryWidgetState
    extends State<PatientBloodDiscoveryWidget> {
  String _selectedGroup = 'O+';
  double _maxDistanceKm = 25.0;
  String _facilityType = 'All';
  bool _open24x7Only = false;
  bool _availableOnly = false;
  String _sortBy = 'Nearest';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final List<BloodBankData> _selectedForComparison = [];

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
                color: Colors.redAccent.withValues(
                  alpha: isDark ? 0.028 : 0.020,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Limited':
        return Colors.orange;
      case 'Critical / Low':
        return Colors.deepOrange;
      case 'Unavailable':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _openFilters() {
    BloodFilterModal.show(
      context,
      selectedGroup: _selectedGroup,
      maxDistanceKm: _maxDistanceKm,
      facilityType: _facilityType,
      open24x7Only: _open24x7Only,
      availableOnly: _availableOnly,
      sortBy: _sortBy,
      onApplyFilters:
          ({
            required selectedGroup,
            required maxDistanceKm,
            required facilityType,
            required open24x7Only,
            required availableOnly,
            required sortBy,
          }) {
            setState(() {
              _selectedGroup = selectedGroup;
              _maxDistanceKm = maxDistanceKm;
              _facilityType = facilityType;
              _open24x7Only = open24x7Only;
              _availableOnly = availableOnly;
              _sortBy = sortBy;
            });
          },
    );
  }

  void _toggleComparison(BloodBankData bank) {
    setState(() {
      if (_selectedForComparison.any((b) => b.id == bank.id)) {
        _selectedForComparison.removeWhere((b) => b.id == bank.id);
      } else {
        if (_selectedForComparison.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can compare up to 3 blood banks at a time.'),
            ),
          );
        } else {
          _selectedForComparison.add(bank);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloodBanks = BloodDiscoveryService.getBloodBanks(
      selectedGroup: _selectedGroup,
      maxDistanceKm: _maxDistanceKm,
      facilityType: _facilityType,
      open24x7Only: _open24x7Only,
      availableOnly: _availableOnly,
      searchQuery: _searchQuery,
      sortBy: _sortBy,
    );
    final userRequests = BloodDiscoveryService.getUserRequests();

    return _glassBackground(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner & Location Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.bloodtype_rounded,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Find Blood Availability',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Icon(
                          Icons.my_location_rounded,
                          size: 13,
                          color: Colors.teal,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Location: Near me (Central District)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: Colors.redAccent,
                ),
                onPressed: _openFilters,
                tooltip: 'Filter Blood Banks',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Intro subtitle
          Text(
            'Find nearby hospitals and blood banks with reported blood availability.',
            style: TextStyle(fontSize: 13, color: _secondaryText(isDark)),
          ),

          const SizedBox(height: 16),

          // URGENT BLOOD SEARCH / SOS BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFFB91C1C).withValues(alpha: 0.78),
                        const Color(0xFF7F1D1D).withValues(alpha: 0.82),
                      ]
                    : [
                        const Color(0xFFDC2626).withValues(alpha: 0.96),
                        const Color(0xFF991B1B).withValues(alpha: 0.96),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withValues(
                    alpha: isDark ? 0.14 : 0.22,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Need Blood Urgently?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => AIBloodMatcherModal.show(
                        context,
                        initialBloodGroup: _selectedGroup,
                      ),
                      icon: const Icon(
                        Icons.flash_on_rounded,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        'Find Blood Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Availability can change quickly. Please confirm with the hospital or blood bank before travelling.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // BLOOD GROUP SELECTOR GRID
          Text(
            'What blood group do you need?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _primaryText(isDark),
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _bloodGroups.length,
            itemBuilder: (context, index) {
              final group = _bloodGroups[index];
              final isSelected = _selectedGroup == group;

              return InkWell(
                onTap: () => setState(() => _selectedGroup = group),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.redAccent
                        : (isDark ? AppTheme.darkCardColor : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.redAccent
                          : AppTheme.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      group,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Search Bar & Filter Action Row
          Row(
            children: [
              Expanded(
                child: ClipRRect(
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
                        hintText: 'Search blood banks or hospital name...',
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
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: _openFilters,
                icon: const Icon(Icons.tune_rounded, color: Colors.redAccent),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                tooltip: 'Filter Options',
              ),
            ],
          ),
          SizedBox(height: 16),

          // Quick Utility Actions Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => AIBloodMatcherModal.show(
                    context,
                    initialBloodGroup: _selectedGroup,
                  ),
                  icon: const Icon(
                    Icons.psychology_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'AI Matcher',
                    style: TextStyle(fontSize: 12.5, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => BloodRequestModal.show(
                    context,
                    initialBloodGroup: _selectedGroup,
                  ),
                  icon: const Icon(
                    Icons.assignment_outlined,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    'Request Blood',
                    style: TextStyle(fontSize: 12.5, color: Colors.redAccent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_selectedForComparison.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => BloodComparisonModal.show(
                      context,
                      banks: _selectedForComparison,
                      selectedGroup: _selectedGroup,
                    ),
                    icon: const Icon(
                      Icons.compare_arrows_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Compare (${_selectedForComparison.length})',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                if (_selectedForComparison.isNotEmpty) const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => DonationCentersModal.show(context),
                  icon: const Icon(
                    Icons.volunteer_activism_rounded,
                    size: 16,
                    color: Colors.amber,
                  ),
                  label: const Text(
                    'Donate Blood',
                    style: TextStyle(fontSize: 12.5, color: Colors.amber),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.amber),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // ACTIVE PATIENT BLOOD REQUESTS (If any)
          if (userRequests.isNotEmpty) ...[
            const Text(
              'Your Blood Requests',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...userRequests.map((req) => _buildUserRequestCard(context, req)),
            const SizedBox(height: 20),
          ],

          // NEARBY BLOOD RESULTS SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Blood Banks with $_selectedGroup Stock (${bloodBanks.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryText(isDark),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sorted by $_sortBy',
                style: TextStyle(fontSize: 11.5, color: _secondaryText(isDark)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (bloodBanks.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.bloodtype_outlined,
                    size: 48,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No blood banks found for $_selectedGroup within ${_maxDistanceKm.toInt()} km.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Try expanding your distance radius or search using the AI Blood Matcher.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {
                      _maxDistanceKm = 50.0;
                      _facilityType = 'All';
                      _availableOnly = false;
                    }),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text(
                      'Expand Distance to 50km',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: _primary),
                  ),
                ],
              ),
            )
          else if (MediaQuery.of(context).size.width >= 600)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width >= 1200
                    ? 3
                    : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: MediaQuery.of(context).size.width >= 1200
                    ? 360
                    : 410,
              ),
              itemCount: bloodBanks.length,
              itemBuilder: (context, index) {
                return _buildBloodBankCard(context, bloodBanks[index]);
              },
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bloodBanks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final bank = bloodBanks[index];
                return _buildBloodBankCard(context, bank);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUserRequestCard(BuildContext context, BloodRequestModel req) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _primary.withValues(alpha: isDark ? 0.22 : 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.10 : 0.025),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              req.bloodGroup,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Request ${req.id} • ${req.unitsNeeded} Units (${req.componentType})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: _primaryText(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        req.status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Hospital: ${req.hospitalName} • Matched: ${req.matchedBankName ?? 'Searching...'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodBankCard(BuildContext context, BloodBankData bank) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stock = bank.getStockForGroup(_selectedGroup);
    final units = stock?.unitsAvailable ?? 0;
    final status = stock?.status ?? 'Information Unavailable';
    final statusColor = _getStatusColor(status);
    final minutesAgo = DateTime.now().difference(bank.lastUpdated).inMinutes;
    final isCompared = _selectedForComparison.any((b) => b.id == bank.id);

    return Container(
      decoration: BoxDecoration(
        color: _surface(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCompared ? _primary : _border(isDark),
          width: isCompared ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.035),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Title, Type badge, Checkbox comparison
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bank.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _primaryText(isDark),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${bank.type} • ⭐ ${bank.rating} (${bank.reviewCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: _secondaryText(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isCompared
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: isCompared ? Colors.teal : AppTheme.textMuted,
                        ),
                        onPressed: () => _toggleComparison(bank),
                        tooltip: 'Compare facility',
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Distance & Freshness
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: _secondaryText(isDark),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '📍 ${bank.distance} (${bank.travelTime})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            bank.isStale
                                ? Icons.warning_amber_rounded
                                : Icons.access_time_rounded,
                            size: 13,
                            color: bank.isStale
                                ? Colors.amber
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Updated $minutesAgo min ago',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: bank.isStale
                                  ? Colors.amber
                                  : _secondaryText(isDark),
                              fontWeight: bank.isStale
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Highlight Stock Badge for Selected Group
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: statusColor.withValues(alpha: 0.2),
                          child: Text(
                            _selectedGroup,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$units Units Reported Available',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              Text(
                                'Status: $status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _secondaryText(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (bank.is24x7)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '24/7 OPEN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Mini stock chips for other groups
                  const Text(
                    'Other Blood Group Reserves:',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: bank.stocks.take(6).map((s) {
                      final color = _getStatusColor(s.status);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          '${s.bloodGroup}: ${s.unitsAvailable}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Calling ${bank.name} (${bank.phone})...',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Colors.teal,
                          ),
                          label: const Text(
                            'Call Bank',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.teal),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => BloodDetailsModal.show(
                            context,
                            bank: bank,
                            selectedGroup: _selectedGroup,
                          ),
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            'View All Stock',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
    );
  }
}
