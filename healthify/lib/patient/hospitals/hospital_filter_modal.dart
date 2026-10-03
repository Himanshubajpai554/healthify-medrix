import 'dart:ui';

import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';

class HospitalFilterCriteria {
  final double maxDistanceKm;
  final bool requiresEmergency;
  final bool requiresIcu;
  final double minRating;
  final String sortBy; // 'relevance', 'distance', 'icu', 'rating'

  const HospitalFilterCriteria({
    this.maxDistanceKm = 25.0,
    this.requiresEmergency = false,
    this.requiresIcu = false,
    this.minRating = 0.0,
    this.sortBy = 'relevance',
  });

  HospitalFilterCriteria copyWith({
    double? maxDistanceKm,
    bool? requiresEmergency,
    bool? requiresIcu,
    double? minRating,
    String? sortBy,
  }) {
    return HospitalFilterCriteria(
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      requiresEmergency: requiresEmergency ?? this.requiresEmergency,
      requiresIcu: requiresIcu ?? this.requiresIcu,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class HospitalFilterModal extends StatefulWidget {
  final HospitalFilterCriteria initialCriteria;
  final Function(HospitalFilterCriteria updated) onApplyFilters;

  const HospitalFilterModal({
    super.key,
    required this.initialCriteria,
    required this.onApplyFilters,
  });

  static void show(
    BuildContext context, {
    required HospitalFilterCriteria initialCriteria,
    required Function(HospitalFilterCriteria updated) onApplyFilters,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => HospitalFilterModal(
        initialCriteria: initialCriteria,
        onApplyFilters: onApplyFilters,
      ),
    );
  }

  @override
  State<HospitalFilterModal> createState() => _HospitalFilterModalState();
}

class _HospitalFilterModalState extends State<HospitalFilterModal> {
  late HospitalFilterCriteria _criteria;

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF0F766E);

  @override
  void initState() {
    super.initState();
    _criteria = widget.initialCriteria;
  }

  void _resetFilters() {
    setState(() {
      _criteria = const HospitalFilterCriteria();
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
                // Handle Bar
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
                        'Filter & Sort Hospitals',
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
                    _buildSortChip('icu', 'Free ICU Beds', isDark),
                    _buildSortChip('rating', 'Highest Rated ⭐', isDark),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. MAXIMUM DISTANCE SLIDER
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

                const SizedBox(height: 12),

                // 3. CAPABILITY SWITCHES
                _buildSwitchCard(
                  isDark: isDark,
                  title: '24/7 Emergency Care Only',
                  subtitle: 'Filter hospitals with active ER trauma units',
                  value: _criteria.requiresEmergency,
                  onChanged: (val) => setState(
                    () =>
                        _criteria = _criteria.copyWith(requiresEmergency: val),
                  ),
                  icon: Icons.emergency_rounded,
                  accent: Colors.redAccent,
                ),

                const SizedBox(height: 8),

                _buildSwitchCard(
                  isDark: isDark,
                  title: 'Available ICU Beds Only',
                  subtitle: 'Must have at least 1 free ICU bed right now',
                  value: _criteria.requiresIcu,
                  onChanged: (val) => setState(
                    () => _criteria = _criteria.copyWith(requiresIcu: val),
                  ),
                  icon: Icons.local_hospital_rounded,
                  accent: _primary,
                ),

                const SizedBox(height: 18),

                // 4. MINIMUM RATING
                Text(
                  'Minimum Hospital Rating',
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
                      'Apply Hospital Filters',
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

  Widget _buildSwitchCard({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color accent,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _surfaceStrong(isDark),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: value
                  ? accent.withValues(alpha: isDark ? 0.28 : 0.20)
                  : _border(isDark),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _primaryText(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _secondaryText(isDark),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                activeTrackColor: _primary,
                activeThumbColor: Colors.white,
                inactiveTrackColor: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
                inactiveThumbColor: isDark ? Colors.white70 : Colors.white,
                onChanged: onChanged,
              ),
            ],
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
