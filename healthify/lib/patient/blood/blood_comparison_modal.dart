import 'package:flutter/material.dart';
import '../../shared/widgets/glass_components.dart';
import '../../theme/app_theme.dart';
import '../models/patient_portal_models.dart';

class BloodComparisonModal extends StatelessWidget {
  final List<BloodBankData> banks;
  final String selectedGroup;

  const BloodComparisonModal({
    super.key,
    required this.banks,
    required this.selectedGroup,
  });

  static void show(
    BuildContext context, {
    required List<BloodBankData> banks,
    required String selectedGroup,
  }) {
    showHealthifyGlassBottomSheet(
      context: context,
      builder: (context) => BloodComparisonModal(
        banks: banks.take(3).toList(),
        selectedGroup: selectedGroup,
      ),
    );
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
            children: [
              const Icon(Icons.compare_arrows_rounded, color: Colors.teal, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Compare Blood Banks ($selectedGroup)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Side-by-side availability matrix for ${banks.length} nearby blood centers.',
            style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
          ),
          const Divider(height: 24),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? AppTheme.darkCardColor : Colors.grey.shade100,
                  ),
                  columns: [
                    const DataColumn(
                      label: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...banks.map((b) {
                      return DataColumn(
                        label: SizedBox(
                          width: 140,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                b.type,
                                style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  rows: [
                    // Distance
                    DataRow(cells: [
                      const DataCell(Text('Distance', style: TextStyle(fontWeight: FontWeight.w600))),
                      ...banks.map((b) => DataCell(Text('${b.distance} (${b.travelTime})'))),
                    ]),

                    // Rating
                    DataRow(cells: [
                      const DataCell(Text('Rating', style: TextStyle(fontWeight: FontWeight.w600))),
                      ...banks.map((b) => DataCell(Text('⭐ ${b.rating} (${b.reviewCount})'))),
                    ]),

                    // Selected Group Units
                    DataRow(cells: [
                      DataCell(Text('$selectedGroup Units', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))),
                      ...banks.map((b) {
                        final stock = b.getStockForGroup(selectedGroup);
                        final units = stock?.unitsAvailable ?? 0;
                        final status = stock?.status ?? 'Unknown';
                        return DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$units Units',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                              ),
                              Text(
                                status,
                                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }),
                    ]),

                    // 24/7 Desk
                    DataRow(cells: [
                      const DataCell(Text('24/7 Service', style: TextStyle(fontWeight: FontWeight.w600))),
                      ...banks.map((b) => DataCell(
                        Icon(
                          b.is24x7 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: b.is24x7 ? Colors.green : Colors.grey,
                          size: 18,
                        ),
                      )),
                    ]),

                    // Accepts Voluntary Donations
                    DataRow(cells: [
                      const DataCell(Text('Voluntary Donations', style: TextStyle(fontWeight: FontWeight.w600))),
                      ...banks.map((b) => DataCell(
                        Text(b.acceptsDonations ? 'Yes' : 'Hospital Only', style: const TextStyle(fontSize: 12)),
                      )),
                    ]),

                    // Contact Phone
                    DataRow(cells: [
                      const DataCell(Text('Contact Desk', style: TextStyle(fontWeight: FontWeight.w600))),
                      ...banks.map((b) => DataCell(
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling ${b.phone}...')),
                            );
                          },
                          child: const Text(
                            'Call Desk',
                            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close Comparison'),
            ),
          ),
        ],
      ),
    );
  }
}