import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class HelpSupportSection extends StatelessWidget {
  const HelpSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      children: [
        // 1. FAQ & Documentation
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.help_outline_rounded,
                    size: 40,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help Center & Clinical Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Find answers to clinical workflow questions and provider guidelines.',
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

              _buildFaqItem(
                question: 'How do I update my weekly OPD consultation schedule?',
                answer:
                    'Navigate to Settings -> Availability & Schedule -> Edit Schedule. Changes sync immediately with the central booking system.',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildFaqItem(
                question: 'How are emergency cases assigned to my ER queue?',
                answer:
                    'Emergency cases are assigned by authorized ER Triage Officers when your status is set to Available and emergency assignments are enabled.',
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildFaqItem(
                question: 'How do I request hospital verification for updated qualifications?',
                answer:
                    'Upload scanned degree certificates or council registration updates to the Hospital Medical Board via Contact Hospital Admin below.',
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Direct Administrator Contact & Support Actions
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GlassIconContainer(
                    icon: Icons.contact_support_rounded,
                    size: 40,
                    iconSize: 20,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Hospital IT & Administrator',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          'Reach out to hospital operations for account privileges or technical assistance.',
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

              Row(
                children: [
                  Expanded(
                    child: GlassPrimaryButton(
                      height: 42,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Connecting to Medrix Hospital IT Desk (Ext: 4400)...'),
                            backgroundColor: HealthifyGlassTheme.primaryTeal,
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.headset_mic_rounded, size: 16, color: Colors.white),
                          SizedBox(width: 6),
                          Text('Contact Hospital Admin', style: TextStyle(fontSize: 12.5, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassSecondaryButton(
                      height: 42,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening technical problem report ticket dialog...'),
                            backgroundColor: HealthifyGlassTheme.primaryTeal,
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bug_report_outlined, size: 16),
                          SizedBox(width: 6),
                          Text('Report a Problem', style: TextStyle(fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: HealthifyGlassTheme.getGlassBorder(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: TextStyle(
              fontSize: 12.5,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
