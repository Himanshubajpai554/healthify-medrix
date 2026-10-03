import 'dart:ui';
import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

class BedComparisonModal extends StatelessWidget {
  final List<HospitalBedData> hospitalsToCompare;

  const BedComparisonModal({
    super.key,
    required this.hospitalsToCompare,
  });

  static const Color _primary = Color(0xFF0D9488);

  Color _surface(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.045)
      : Colors.white.withValues(alpha: 0.72);

  Color _border(bool isDark) => isDark
      ? Colors.white.withValues(alpha: 0.085)
      : Colors.white.withValues(alpha: 0.88);

  Color _primaryText(bool isDark) =>
      isDark ? Colors.white : AppTheme.textPrimary;

  Color _secondaryText(bool isDark) =>
      isDark ? Colors.white.withValues(alpha: 0.55) : AppTheme.textSecondary;

  static void show(
    BuildContext context, {
    required List<HospitalBedData> hospitalsToCompare,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => BedComparisonModal(
        hospitalsToCompare: hospitalsToCompare,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayHospitals = hospitalsToCompare.take(3).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF061817) : const Color(0xFFF3FAF9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
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
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: _border(isDark)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.compare_arrows_rounded,
                        color: Colors.indigo,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hospital Bed Comparison',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: _primaryText(isDark),
                          ),
                        ),
                        Text(
                          'Side-by-side bed availability & facility analysis',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _secondaryText(isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: _primaryText(isDark)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Comparison Matrix
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    border: TableBorder.all(
                      color: _border(isDark),
                    ),
                    children: [
                      // Header Row: Metrics vs Hospitals
                      TableRow(
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: isDark ? 0.15 : 0.08),
                        ),
                        children: [
                          _buildTableCell('Hospital / Metric', isHeader: true, isDark: isDark),
                          ...displayHospitals.map(
                            (data) => _buildTableCell(
                              data.hospital.name,
                              isHeader: true,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      _buildRow(
                        'Distance & ETA',
                        (data) => '${data.hospital.distanceKm} km (${data.estimatedTravelTime})',
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'Rating',
                        (data) => '${data.hospital.rating} ⭐ (${data.hospital.reviewsCount})',
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'ICU Beds',
                        (data) {
                          final cat = data.categories.firstWhere(
                            (c) => c.name == 'ICU',
                            orElse: () => BedCategoryDetail(
                              name: 'ICU',
                              available: 0,
                              total: 0,
                              status: 'Full',
                              lastUpdated: DateTime.now(),
                            ),
                          );
                          return '${cat.available} / ${cat.total} (${cat.status})';
                        },
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'Emergency Beds',
                        (data) {
                          final cat = data.categories.firstWhere(
                            (c) => c.name == 'Emergency',
                            orElse: () => BedCategoryDetail(
                              name: 'Emergency',
                              available: 0,
                              total: 0,
                              status: 'Full',
                              lastUpdated: DateTime.now(),
                            ),
                          );
                          return '${cat.available} / ${cat.total} (${cat.status})';
                        },
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'General Ward Beds',
                        (data) {
                          final cat = data.categories.firstWhere(
                            (c) => c.name == 'General',
                            orElse: () => BedCategoryDetail(
                              name: 'General',
                              available: 0,
                              total: 0,
                              status: 'Full',
                              lastUpdated: DateTime.now(),
                            ),
                          );
                          return '${cat.available} / ${cat.total} (${cat.status})';
                        },
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'Private Rooms',
                        (data) {
                          final cat = data.categories.firstWhere(
                            (c) => c.name == 'Private',
                            orElse: () => BedCategoryDetail(
                              name: 'Private',
                              available: 0,
                              total: 0,
                              status: 'Full',
                              lastUpdated: DateTime.now(),
                            ),
                          );
                          return '${cat.available} / ${cat.total} (${cat.status})';
                        },
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'Pediatric Beds',
                        (data) {
                          final cat = data.categories.firstWhere(
                            (c) => c.name == 'Pediatric',
                            orElse: () => BedCategoryDetail(
                              name: 'Pediatric',
                              available: 0,
                              total: 0,
                              status: 'Full',
                              lastUpdated: DateTime.now(),
                            ),
                          );
                          return '${cat.available} / ${cat.total} (${cat.status})';
                        },
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'Maternity Beds',
                        (data) {
                          final cat = data.categories.firstWhere(
                            (c) => c.name == 'Maternity',
                            orElse: () => BedCategoryDetail(
                              name: 'Maternity',
                              available: 0,
                              total: 0,
                              status: 'Full',
                              lastUpdated: DateTime.now(),
                            ),
                          );
                          return '${cat.available} / ${cat.total} (${cat.status})';
                        },
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'Emergency Doctor',
                        (data) => data.emergencyDoctorAvailable ? '✓ Available 24/7' : '⚠️ On Call',
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'CT Scan Facility',
                        (data) => data.ctScanAvailable ? '✓ Available 24/7' : '⚠️ Limited',
                        displayHospitals,
                        isDark,
                      ),
                      _buildRow(
                        'Last Update',
                        (data) {
                          final diff = DateTime.now().difference(data.lastUpdated).inMinutes;
                          return diff < 60 ? '$diff min ago' : '${diff ~/ 60}h ago (Stale)';
                        },
                        displayHospitals,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildRow(
    String metricName,
    String Function(HospitalBedData) valueMapper,
    List<HospitalBedData> displayHospitals,
    bool isDark,
  ) {
    return TableRow(
      children: [
        _buildTableCell(metricName, isMetricLabel: true, isDark: isDark),
        ...displayHospitals.map(
          (data) => _buildTableCell(valueMapper(data), isDark: isDark),
        ),
      ],
    );
  }

  Widget _buildTableCell(
    String text, {
    required bool isDark,
    bool isHeader = false,
    bool isMetricLabel = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minWidth: 130, maxWidth: 220),
      child: Text(
        text,
        textAlign: isMetricLabel ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isHeader || isMetricLabel ? FontWeight.bold : FontWeight.w500,
          color: isHeader
              ? _primary
              : (isMetricLabel
                  ? _primaryText(isDark)
                  : _secondaryText(isDark)),
        ),
      ),
    );
  }
}