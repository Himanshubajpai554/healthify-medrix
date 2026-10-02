import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';

class BloodFilterModal extends StatefulWidget {
  final String selectedGroup;
  final double maxDistanceKm;
  final String facilityType;
  final bool open24x7Only;
  final bool availableOnly;
  final String sortBy;
  final Function({
    required String selectedGroup,
    required double maxDistanceKm,
    required String facilityType,
    required bool open24x7Only,
    required bool availableOnly,
    required String sortBy,
  }) onApplyFilters;

  const BloodFilterModal({
    super.key,
    required this.selectedGroup,
    required this.maxDistanceKm,
    required this.facilityType,
    required this.open24x7Only,
    required this.availableOnly,
    required this.sortBy,
    required this.onApplyFilters,
  });

  static void show(
    BuildContext context, {
    required String selectedGroup,
    required double maxDistanceKm,
    required String facilityType,
    required bool open24x7Only,
    required bool availableOnly,
    required String sortBy,
    required Function({
      required String selectedGroup,
      required double maxDistanceKm,
      required String facilityType,
      required bool open24x7Only,
      required bool availableOnly,
      required String sortBy,
    }) onApplyFilters,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => BloodFilterModal(
        selectedGroup: selectedGroup,
        maxDistanceKm: maxDistanceKm,
        facilityType: facilityType,
        open24x7Only: open24x7Only,
        availableOnly: availableOnly,
        sortBy: sortBy,
        onApplyFilters: onApplyFilters,
      ),
    );
  }

  @override
  State<BloodFilterModal> createState() => _BloodFilterModalState();
}

class _BloodFilterModalState extends State<BloodFilterModal> {
  late String _group;
  late double _distance;
  late String _type;
  late bool _is24x7;
  late bool _available;
  late String _sort;

  final List<String> _groups = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<double> _distances = [2.0, 5.0, 10.0, 25.0];
  final List<String> _facilityTypes = ['All', 'Hospital', 'Standalone Blood Bank'];
  final List<String> _sortOptions = [
    'Nearest',
    'Most Available',
    'Recently Updated',
    'Highest Rated',
  ];

  @override
  void initState() {
    super.initState();
    _group = widget.selectedGroup;
    _distance = widget.maxDistanceKm;
    _type = widget.facilityType;
    _is24x7 = widget.open24x7Only;
    _available = widget.availableOnly;
    _sort = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header handle & title
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
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
                  Icon(Icons.filter_list_rounded, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Filter & Sort Blood Banks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _group = 'O+';
                    _distance = 25.0;
                    _type = 'All';
                    _is24x7 = false;
                    _available = false;
                    _sort = 'Nearest';
                  });
                },
                child: const Text('Reset', style: TextStyle(color: AppTheme.textMuted)),
              ),
            ],
          ),
          const Divider(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Blood Group Filter
                  const Text(
                    'Blood Group',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _groups.map((g) {
                      final isSel = _group == g;
                      return ChoiceChip(
                        label: Text(g),
                        selected: isSel,
                        selectedColor: Colors.redAccent.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.redAccent : AppTheme.textPrimary,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _group = g);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Distance Radius
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Distance Radius',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Within ${_distance.toInt()} km',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _distances.map((d) {
                      final isSel = _distance == d;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: isSel
                                  ? Colors.redAccent.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              side: BorderSide(
                                color: isSel ? Colors.redAccent : AppTheme.borderLight,
                                width: isSel ? 2 : 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => setState(() => _distance = d),
                            child: Text(
                              '${d.toInt()} km',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                color: isSel ? Colors.redAccent : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Facility Type
                  const Text(
                    'Facility Type',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _facilityTypes.map((t) {
                      final isSel = _type == t;
                      return FilterChip(
                        label: Text(t),
                        selected: isSel,
                        selectedColor: Colors.redAccent.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.redAccent : AppTheme.textPrimary,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _type = t);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Quick Toggles
                  const Text(
                    'Operational Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('24/7 Open Blood Banks Only', style: TextStyle(fontSize: 13.5)),
                    subtitle: const Text('Hide facilities with non-24h emergency desks', style: TextStyle(fontSize: 11.5)),
                    value: _is24x7,
                    activeTrackColor: Colors.redAccent,
                    onChanged: (val) => setState(() => _is24x7 = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Available Stock Only', style: TextStyle(fontSize: 13.5)),
                    subtitle: const Text('Hide blood banks with 0 units for selected group', style: TextStyle(fontSize: 11.5)),
                    value: _available,
                    activeTrackColor: Colors.redAccent,
                    onChanged: (val) => setState(() => _available = val),
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 20),

                  // Sort By
                  const Text(
                    'Sort Facilities By',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _sort,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _sortOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _sort = val);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onApplyFilters(
                  selectedGroup: _group,
                  maxDistanceKm: _distance,
                  facilityType: _type,
                  open24x7Only: _is24x7,
                  availableOnly: _available,
                  sortBy: _sort,
                );
              },
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
              label: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}