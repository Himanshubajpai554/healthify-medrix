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

  final List<String> _availabilities = ['Anytime', 'Available Today', 'Available Tomorrow'];

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
            // Header
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.tune_rounded, color: Colors.indigo, size: 24),
                    SizedBox(width: 10),
                    Text('Filter & Sort Doctors', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 1. SORT BY OPTIONS
            const Text('Sort By', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSortChip('relevance', 'Relevance'),
                _buildSortChip('distance', 'Nearest Distance'),
                _buildSortChip('availability', 'Earliest Slots'),
                _buildSortChip('rating', 'Highest Rated ⭐'),
              ],
            ),

            const SizedBox(height: 20),

            // 2. DEPARTMENT / SPECIALTY
            const Text('Specialty / Department', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _criteria.department,
              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _criteria = _criteria.copyWith(department: val));
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.local_hospital_rounded, color: Colors.indigo),
              ),
            ),

            const SizedBox(height: 20),

            // 3. MAX DISTANCE SLIDER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Maximum Distance', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                Text('Within ${_criteria.maxDistanceKm.toInt()} km', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            Slider(
              value: _criteria.maxDistanceKm,
              min: 2.0,
              max: 50.0,
              divisions: 24,
              activeColor: Colors.indigo,
              onChanged: (val) => setState(() => _criteria = _criteria.copyWith(maxDistanceKm: val)),
            ),

            const SizedBox(height: 16),

            // 4. AVAILABILITY
            const Text('Availability', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: _availabilities.map((avail) {
                final isSelected = _criteria.availability == avail;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    selected: isSelected,
                    label: Text(avail),
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _criteria = _criteria.copyWith(availability: avail));
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 5. MINIMUM RATING
            const Text('Minimum Rating', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [0.0, 4.0, 4.5, 4.8].map((rating) {
                final isSelected = _criteria.minRating == rating;
                final label = rating == 0.0 ? 'Any Rating' : '$rating+ ⭐';
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
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
                  ),
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
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
      selectedColor: Colors.indigo,
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