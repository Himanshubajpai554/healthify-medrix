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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: Colors.teal, size: 24),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Filter & Sort Hospitals',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 1. SORT BY
            const Text('Sort By', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSortChip('relevance', 'Relevance'),
                _buildSortChip('distance', 'Nearest Distance'),
                _buildSortChip('icu', 'Free ICU Beds'),
                _buildSortChip('rating', 'Highest Rated ⭐'),
              ],
            ),

            const SizedBox(height: 20),

            // 2. MAXIMUM DISTANCE SLIDER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Maximum Distance', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                Text('Within ${_criteria.maxDistanceKm.toInt()} km', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              ],
            ),
            Slider(
              value: _criteria.maxDistanceKm,
              min: 2.0,
              max: 50.0,
              divisions: 24,
              activeColor: Colors.teal,
              onChanged: (val) => setState(() => _criteria = _criteria.copyWith(maxDistanceKm: val)),
            ),

            const SizedBox(height: 16),

            // 3. CAPABILITY SWITCHES
            SwitchListTile(
              title: const Text('24/7 Emergency Care Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Filter hospitals with active ER trauma units', style: TextStyle(fontSize: 12)),
              value: _criteria.requiresEmergency,
              onChanged: (val) => setState(() => _criteria = _criteria.copyWith(requiresEmergency: val)),
            ),

            SwitchListTile(
              title: const Text('Available ICU Beds Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('Must have at least 1 free ICU bed right now', style: TextStyle(fontSize: 12)),
              value: _criteria.requiresIcu,
              onChanged: (val) => setState(() => _criteria = _criteria.copyWith(requiresIcu: val)),
            ),

            const SizedBox(height: 16),

            // 4. MINIMUM RATING
            const Text('Minimum Hospital Rating', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
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
                  selectedColor: Colors.amber,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.black : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _criteria = _criteria.copyWith(minRating: rating));
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onApplyFilters(_criteria);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Apply Hospital Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _criteria.sortBy == value;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: Colors.teal,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.white : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) setState(() => _criteria = _criteria.copyWith(sortBy: value));
      },
    );
  }
}