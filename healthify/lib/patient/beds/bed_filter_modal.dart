import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';

class BedFilterCriteria {
  final String selectedBedType; // 'All', 'ICU', 'Emergency', 'General', 'Private', 'Pediatric', 'Maternity'
  final double maxDistanceKm; // 2, 5, 10, 25
  final bool requiresEmergency;
  final bool requiresIcu;
  final double minRating;
  final String sortBy; // 'nearest', 'most_available', 'earliest_updated'

  const BedFilterCriteria({
    this.selectedBedType = 'All',
    this.maxDistanceKm = 25.0,
    this.requiresEmergency = false,
    this.requiresIcu = false,
    this.minRating = 0.0,
    this.sortBy = 'nearest',
  });

  BedFilterCriteria copyWith({
    String? selectedBedType,
    double? maxDistanceKm,
    bool? requiresEmergency,
    bool? requiresIcu,
    double? minRating,
    String? sortBy,
  }) {
    return BedFilterCriteria(
      selectedBedType: selectedBedType ?? this.selectedBedType,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      requiresEmergency: requiresEmergency ?? this.requiresEmergency,
      requiresIcu: requiresIcu ?? this.requiresIcu,
      minRating: minRating ?? this.minRating,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class BedFilterModal extends StatefulWidget {
  final BedFilterCriteria initialCriteria;
  final ValueChanged<BedFilterCriteria> onApplyFilters;

  const BedFilterModal({
    super.key,
    required this.initialCriteria,
    required this.onApplyFilters,
  });

  static void show(
    BuildContext context, {
    required BedFilterCriteria initialCriteria,
    required ValueChanged<BedFilterCriteria> onApplyFilters,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => BedFilterModal(
        initialCriteria: initialCriteria,
        onApplyFilters: onApplyFilters,
      ),
    );
  }

  @override
  State<BedFilterModal> createState() => _BedFilterModalState();
}

class _BedFilterModalState extends State<BedFilterModal> {
  late String _bedType;
  late double _distance;
  late bool _requiresEr;
  late bool _requiresIcu;
  late double _minRating;
  late String _sortBy;

  final List<String> _bedTypes = [
    'All',
    'ICU',
    'Emergency',
    'General',
    'Private',
    'Pediatric',
    'Maternity',
  ];

  final List<double> _distanceOptions = [2.0, 5.0, 10.0, 25.0];

  @override
  void initState() {
    super.initState();
    _bedType = widget.initialCriteria.selectedBedType;
    _distance = widget.initialCriteria.maxDistanceKm;
    _requiresEr = widget.initialCriteria.requiresEmergency;
    _requiresIcu = widget.initialCriteria.requiresIcu;
    _minRating = widget.initialCriteria.minRating;
    _sortBy = widget.initialCriteria.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Sort Bed Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _bedType = 'All';
                      _distance = 25.0;
                      _requiresEr = false;
                      _requiresIcu = false;
                      _minRating = 0.0;
                      _sortBy = 'nearest';
                    });
                  },
                  child: const Text('Reset', style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // 1. Bed Type Filter
            const Text(
              'Bed Category',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bedTypes.map((type) {
                final isSelected = _bedType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12.5,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _bedType = type);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 2. Maximum Distance Radius
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maximum Distance Radius',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Within ${_distance.toInt()} km',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: _distanceOptions.map((dist) {
                final isSelected = _distance == dist;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('${dist.toInt()} km'),
                      selected: isSelected,
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _distance = dist);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 3. Sort Options
            const Text(
              'Sort Results By',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSortOptionChip('Nearest', 'nearest'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSortOptionChip('Most Available', 'most_available'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSortOptionChip('Earliest Updated', 'earliest_updated'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 4. Emergency & ICU Constraints
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('24/7 Emergency Department Open', style: TextStyle(fontSize: 13.5)),
              subtitle: const Text('Only show hospitals with active ER docks', style: TextStyle(fontSize: 11.5)),
              value: _requiresEr,
              onChanged: (val) => setState(() => _requiresEr = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Must Have Available ICU Beds', style: TextStyle(fontSize: 13.5)),
              subtitle: const Text('Hide hospitals with 0 ICU capacity', style: TextStyle(fontSize: 11.5)),
              value: _requiresIcu,
              onChanged: (val) => setState(() => _requiresIcu = val),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(
                    BedFilterCriteria(
                      selectedBedType: _bedType,
                      maxDistanceKm: _distance,
                      requiresEmergency: _requiresEr,
                      requiresIcu: _requiresIcu,
                      minRating: _minRating,
                      sortBy: _sortBy,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptionChip(String label, String value) {
    final isSelected = _sortBy == value;
    return InkWell(
      onTap: () => setState(() => _sortBy = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal.withValues(alpha: 0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.teal : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}