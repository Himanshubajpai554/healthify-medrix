import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';
import './bed_discovery_service.dart';

class AiBedMatcherModal extends StatefulWidget {
  final Function(HospitalBedData selectedHospital) onHospitalSelected;

  const AiBedMatcherModal({
    super.key,
    required this.onHospitalSelected,
  });

  static void show(
    BuildContext context, {
    required Function(HospitalBedData selectedHospital) onHospitalSelected,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => AiBedMatcherModal(
        onHospitalSelected: onHospitalSelected,
      ),
    );
  }

  @override
  State<AiBedMatcherModal> createState() => _AiBedMatcherModalState();
}

class _AiBedMatcherModalState extends State<AiBedMatcherModal> {
  String _careRequirement = 'Critical Care / ICU';
  String _bedType = 'ICU';
  double _radius = 10.0;
  bool _isSearching = false;
  List<HospitalBedData>? _matchResults;

  final List<String> _careOptions = [
    'Critical Care / ICU',
    'Emergency & Trauma Assist',
    'General Surgery Recovery',
    'Child / Pediatric Care',
    'Maternity & Labor Support',
  ];

  final List<String> _bedTypeOptions = [
    'ICU',
    'Emergency',
    'General',
    'Private',
    'Pediatric',
    'Maternity',
  ];

  void _performMatching() {
    setState(() {
      _isSearching = true;
      _matchResults = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      final all = await BedDiscoveryService.getHospitalBedDataList();
      final matched = all.where((data) {
        final matchesRadius = data.hospital.distanceKm <= _radius;
        final hasBedType = data.categories.any((c) => c.name == _bedType && c.available > 0);
        return matchesRadius && hasBedType;
      }).toList();

      setState(() {
        _isSearching = false;
        _matchResults = matched;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorderLight : AppTheme.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.psychology_rounded, color: Colors.purple, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'AI Available Bed Matcher',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Body Form & Results
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disclaimers
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'ℹ️ This is a real-time availability matching tool designed to find hospitals reporting suitable bed capacity. This is NOT a medical diagnosis or treatment recommendation.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Care Requirement Selector
                  const Text('1. Select Patient Care Need:', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _careRequirement,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: _careOptions.map((opt) {
                      return DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 13.5)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _careRequirement = val);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Required Bed Category
                  const Text('2. Required Bed Type:', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bedTypeOptions.map((type) {
                      final isSel = _bedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSel,
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppTheme.textPrimary,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (sel) {
                          if (sel) setState(() => _bedType = type);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Maximum Search Radius
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('3. Maximum Search Radius:', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                      Text('Within ${_radius.toInt()} km', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple)),
                    ],
                  ),
                  Slider(
                    value: _radius,
                    min: 2.0,
                    max: 25.0,
                    divisions: 23,
                    activeColor: Colors.purple,
                    label: '${_radius.toInt()} km',
                    onChanged: (val) => setState(() => _radius = val),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _isSearching ? null : _performMatching,
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Find Matching Available Beds', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  // RESULTS SECTION
                  if (_isSearching) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: Colors.purple),
                      ),
                    ),
                  ] else if (_matchResults != null) ...[
                    Text(
                      '${_matchResults!.length} hospitals currently report available $_bedType beds within ${_radius.toInt()} km:',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    if (_matchResults!.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 32),
                            SizedBox(height: 8),
                            Text('No Available Beds Match Your Criteria', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text('Try expanding your distance radius or selecting alternate bed types.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: _matchResults!.map((data) {
                          final category = data.categories.firstWhere((c) => c.name == _bedType);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              title: Text(data.hospital.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                              subtitle: Text('${data.hospital.distanceKm} km away • ${category.available} $_bedType beds reported available'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onHospitalSelected(data);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('View Bed Details', style: TextStyle(fontSize: 11.5)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}