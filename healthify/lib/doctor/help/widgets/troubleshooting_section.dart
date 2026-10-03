import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_help_models.dart';

class TroubleshootingSection extends StatelessWidget {
  final List<TroubleshootingGuideModel> guides;
  final VoidCallback onContactSupportTap;

  const TroubleshootingSection({
    super.key,
    required this.guides,
    required this.onContactSupportTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.build_circle_rounded,
                size: 40,
                iconSize: 20,
                color: Colors.deepOrange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Common Troubleshooting Steps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Possible causes and recommended steps for common technical issues.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: HealthifyGlassTheme.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          ...guides.map((guide) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: HealthifyGlassTheme.getGlassBorder(isDark),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Possible Causes:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextMuted(isDark),
                      ),
                    ),
                    const SizedBox(height: 3),
                    ...guide.possibleCauses.map((cause) => Text('• $cause', style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.getTextSecondary(isDark)))),
                    const SizedBox(height: 8),

                    Text(
                      'Recommended Steps:',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextMuted(isDark),
                      ),
                    ),
                    const SizedBox(height: 3),
                    ...guide.recommendedSteps.map((step) => Text('1. $step', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: HealthifyGlassTheme.getTextPrimary(isDark)))),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: GlassSecondaryButton(
                            height: 32,
                            onPressed: onContactSupportTap,
                            child: const Text(
                              'Still Having Issues? Contact Support',
                              style: TextStyle(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
