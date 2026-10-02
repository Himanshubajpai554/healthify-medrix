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

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? AppTheme.darkBorderLight : AppTheme.borderLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.compare_arrows_rounded, color: Colors.indigo, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Hospital Bed Availability Comparison',
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

          // Comparison Matrix
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder.all(
                    color: isDark ? AppTheme.darkBorderLight : AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  children: [
                    // Header Row: Metrics vs Hospitals
                    TableRow(
                      decoration: BoxDecoration(color: isDark ? AppTheme.darkCardColor : Colors.grey.shade100),
                      children: [
                        _buildTableCell('Factual Metric', isHeader: true),
                        ...hospitalsToCompare.map((data) => _buildTableCell(data.hospital.name, isHeader: true)),
                      ],
                    ),
                    _buildRow('Distance (km)', (data) => '${data.hospital.distanceKm} km (${data.estimatedTravelTime})'),
                    _buildRow('Rating', (data) => '${data.hospital.rating} ⭐ (${data.hospital.reviewsCount})'),
                    _buildRow('ICU Beds Available', (data) {
                      final icu = data.categories.firstWhere((c) => c.name == 'ICU', orElse: () => BedCategoryDetail(name: 'ICU', available: 0, total: 0, status: 'Full', lastUpdated: DateTime.now()));
                      return '${icu.available} / ${icu.total} (${icu.status})';
                    }),
                    _buildRow('Emergency Beds', (data) {
                      final er = data.categories.firstWhere((c) => c.name == 'Emergency', orElse: () => BedCategoryDetail(name: 'Emergency', available: 0, total: 0, status: 'Full', lastUpdated: DateTime.now()));
                      return '${er.available} / ${er.total} (${er.status})';
                    }),
                    _buildRow('General Ward Beds', (data) {
                      final gen = data.categories.firstWhere((c) => c.name == 'General', orElse: () => BedCategoryDetail(name: 'General', available: 0, total: 0, status: 'Full', lastUpdated: DateTime.now()));
                      return '${gen.available} / ${gen.total} (${gen.status})';
                    }),
                    _buildRow('Private Rooms', (data) {
                      final priv = data.categories.firstWhere((c) => c.name == 'Private', orElse: () => BedCategoryDetail(name: 'Private', available: 0, total: 0, status: 'Full', lastUpdated: DateTime.now()));
                      return '${priv.available} / ${priv.total} (${priv.status})';
                    }),
                    _buildRow('Pediatric Beds', (data) {
                      final ped = data.categories.firstWhere((c) => c.name == 'Pediatric', orElse: () => BedCategoryDetail(name: 'Pediatric', available: 0, total: 0, status: 'Full', lastUpdated: DateTime.now()));
                      return '${ped.available} / ${ped.total} (${ped.status})';
                    }),
                    _buildRow('Emergency Doctor', (data) => data.emergencyDoctorAvailable ? '✓ Available 24/7' : '⚠️ On Call'),
                    _buildRow('CT Scan Availability', (data) => data.ctScanAvailable ? '✓ Available 24/7' : '⚠️ Limited'),
                    _buildRow('Last Updated Time', (data) {
                      final diff = DateTime.now().difference(data.lastUpdated).inMinutes;
                      return diff < 60 ? '$diff min ago' : '${diff ~/ 60} hours ago (Stale)';
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildRow(String metricName, String Function(HospitalBedData) valueMapper) {
    return TableRow(
      children: [
        _buildTableCell(metricName, isMetricLabel: true),
        ...hospitalsToCompare.map((data) => _buildTableCell(valueMapper(data))),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isMetricLabel = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 200),
      child: Text(
        text,
        textAlign: isMetricLabel ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isHeader || isMetricLabel ? FontWeight.bold : FontWeight.w500,
          color: isHeader ? Colors.teal : AppTheme.textPrimary,
        ),
      ),
    );
  }
}