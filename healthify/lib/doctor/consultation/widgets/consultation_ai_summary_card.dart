import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../models/doctor_dashboard_models.dart';

class ConsultationAISummaryCard extends StatelessWidget {
  final AIPatientSummaryModel aiSummary;
  final VoidCallback onRefreshSummary;

  const ConsultationAISummaryCard({
    super.key,
    required this.aiSummary,
    required this.onRefreshSummary,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Clinical Record Summary',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      Text(
                        'Advisory overview of existing EHR entries',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              GlassSecondaryButton(
                height: 36,
                onPressed: onRefreshSummary,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 14, color: AppTheme.primaryTeal),
                    SizedBox(width: 4),
                    Text('Refresh Summary', style: TextStyle(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 12),

          Text(
            aiSummary.keyFindings,
            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.45, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          // Required Safety Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 13, color: AppTheme.textMuted),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'AI-generated summary — verify against original medical records. Does not make diagnostic claims or prescribe treatments.',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
