import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/patient_profile_models.dart';

class ConsultationHistoryTab extends StatelessWidget {
  final List<MedicalHistoryItemModel> historyItems;

  const ConsultationHistoryTab({
    super.key,
    required this.historyItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chronological Medical & Consultation History',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const Text(
          'Review previous visits, lab releases, and procedures for context',
          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 16),

        if (historyItems.isEmpty)
          const GlassCard(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No previous medical history recorded.', style: TextStyle(color: AppTheme.textMuted)),
            ),
          )
        else
          Column(
            children: historyItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.icon, color: item.badgeColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.badgeColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.status,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: item.badgeColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.date} • ${item.doctorName} (${item.department})',
                              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.summary,
                              style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
