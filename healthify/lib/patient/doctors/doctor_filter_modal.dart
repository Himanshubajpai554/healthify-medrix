import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';

class DoctorFilterCriteria {
  final String department;
  final double maxDistanceKm;
  final String availability;
  final double minRating;
  final double maxFee;
  final String sortBy; // 'relevance', 'distance', 'availability', 'rating'

  const DoctorFilterCriteria({
    this.department = 'All',
    this.maxDistanceKm = 20.0,
    this.availability = 'Anytime',
    this.minRating = 0.0,
    this.maxFee = 500.0,
    this.sortBy = 'relevance',
  });

  DoctorFilterCriteria copyWith({
    String? department,
    double? maxDistanceKm,
    String? availability,
    double? minRating,
    double? maxFee,
    String? sortBy,
  }) {
    return DoctorFilterCriteria(
      department: department ?? this.department,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      availability: availability ?? this.availability,
      minRating: minRating ?? this.minRating,
      maxFee: maxFee ?? this.maxFee,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class DoctorFilterModal extends StatefulWidget {
  final DoctorFilterCriteria initialCriteria;
  final Function(DoctorFilterCriteria updated) onApplyFilters;

  const DoctorFilterModal({
    super.key,
    required this.initialCriteria,
    required this.onApplyFilters,
  });

  static void show(
    BuildContext context, {
    required DoctorFilterCriteria initialCriteria,
    required Function(DoctorFilterCriteria updated) onApplyFilters,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => DoctorFilterModal(
        initialCriteria: initialCriteria,
        onApplyFilters: onApplyFilters,
      ),
    );
  }

  @override
  State<DoctorFilterModal> createState() => _DoctorFilterModalState();
}

class _DoctorFilterModalState extends State<DoctorFilterModal> {
  late DoctorFilterCriteria _criteria;

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  final List<String> _departments = [
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

  final List<String> _availabilities = [
    'Anytime',
    'Available Today',
    'Available Tomorrow',
  ];

  @override
  void initState() {
    super.initState();
    _criteria = widget.initialCriteria;
  }

  void _resetFilters() {
    setState(() {
      _criteria = const DoctorFilterCriteria();
    });
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
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: isDark ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: _primary.withValues(
                            alpha: isDark ? 0.18 : 0.12,
                          ),
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: _primary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Filter & Sort Doctors',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: _primaryText(isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: _resetFilters,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        'Reset All',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(height: 1, color: _border(isDark)),
                const SizedBox(height: 18),

                // 1. SORT BY
                Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _secondaryText(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSortChip('relevance', 'Relevance', isDark),
                    _buildSortChip('distance', 'Nearest Distance', isDark),
                    _buildSortChip('availability', 'Earliest Slots', isDark),
                    _buildSortChip('rating', 'Highest Rated ⭐', isDark),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. DEPARTMENT / SPECIALTY
                Text(
                  'Specialty / Department',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _secondaryText(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _criteria.department,
                  items: _departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(
                        () => _criteria = _criteria.copyWith(department: val),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _secondaryText(isDark),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.local_hospital_rounded,
                      color: _primary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: _surfaceStrong(isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _border(isDark)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _border(isDark)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: _primary.withValues(alpha: isDark ? 0.55 : 0.40),
                      ),
                    ),
                  ),
                  style: TextStyle(color: _primaryText(isDark), fontSize: 13.5),
                  dropdownColor: isDark
                      ? const Color(0xFF102422)
                      : Colors.white,
                ),

                const SizedBox(height: 20),

                // 3. MAX DISTANCE SLIDER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Maximum Distance',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: _secondaryText(isDark),
                      ),
                    ),
                    Text(
                      'Within ${_criteria.maxDistanceKm.toInt()} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _primary,
                    inactiveTrackColor: _primary.withValues(
                      alpha: isDark ? 0.16 : 0.12,
                    ),
                    thumbColor: _primary,
                    overlayColor: _primary.withValues(alpha: 0.10),
                    valueIndicatorColor: _primaryDark,
                  ),
                  child: Slider(
                    value: _criteria.maxDistanceKm,
                    min: 2.0,
                    max: 50.0,
                    divisions: 24,
                    onChanged: (val) => setState(
                      () => _criteria = _criteria.copyWith(maxDistanceKm: val),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 4. AVAILABILITY
                Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _secondaryText(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availabilities.map((avail) {
                    final isSelected = _criteria.availability == avail;

                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(avail),
                      selectedColor: _primary,
                      backgroundColor: _surfaceStrong(isDark),
                      side: BorderSide(
                        color: isSelected ? _primary : _border(isDark),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : _primaryText(isDark),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(
                            () => _criteria = _criteria.copyWith(
                              availability: avail,
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // 5. MINIMUM RATING
                Text(
                  'Minimum Rating',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _secondaryText(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [0.0, 4.0, 4.5, 4.8].map((rating) {
                    final isSelected = _criteria.minRating == rating;
                    final label = rating == 0.0 ? 'Any Rating' : '$rating+ ⭐';

                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(label),
                      selectedColor: Colors.amber.withValues(
                        alpha: isDark ? 0.88 : 0.95,
                      ),
                      backgroundColor: _surfaceStrong(isDark),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.amber.withValues(alpha: 0.75)
                            : _border(isDark),
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.black87)
                            : _primaryText(isDark),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(
                            () => _criteria = _criteria.copyWith(
                              minRating: rating,
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onApplyFilters(_criteria);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: _primary.withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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

  Widget _buildSortChip(String value, String label, bool isDark) {
    final isSelected = _criteria.sortBy == value;

    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: _primary,
      backgroundColor: _surfaceStrong(isDark),
      side: BorderSide(color: isSelected ? _primary : _border(isDark)),
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.white : _primaryText(isDark),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) {
          setState(() => _criteria = _criteria.copyWith(sortBy: value));
        }
      },
    );
  }
}
