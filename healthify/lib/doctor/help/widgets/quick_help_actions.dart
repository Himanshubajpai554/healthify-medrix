import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class QuickHelpActions extends StatelessWidget {
  final VoidCallback onSearchCenterTap;
  final VoidCallback onContactSupportTap;
  final VoidCallback onReportProblemTap;
  final VoidCallback onContactAdminTap;

  const QuickHelpActions({
    super.key,
    required this.onSearchCenterTap,
    required this.onContactSupportTap,
    required this.onReportProblemTap,
    required this.onContactAdminTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 550 ? 2 : 2);
        final cardAspectRatio = constraints.maxWidth > 900 ? 1.7 : (constraints.maxWidth > 550 ? 1.8 : 1.55);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: cardAspectRatio,
          children: [
            _buildActionCard(
              context: context,
              title: 'Help Articles',
              description: 'Browse workflow guides & FAQ solutions.',
              icon: Icons.article_rounded,
              color: HealthifyGlassTheme.primaryTeal,
              buttonLabel: 'Browse Articles',
              onTap: onSearchCenterTap,
            ),
            _buildActionCard(
              context: context,
              title: 'Contact Support',
              description: 'Submit a ticket to IT and support specialists.',
              icon: Icons.confirmation_number_rounded,
              color: Colors.blue,
              buttonLabel: 'Submit Ticket',
              onTap: onContactSupportTap,
            ),
            _buildActionCard(
              context: context,
              title: 'Report a Problem',
              description: 'Tell us about a technical issue or data bug.',
              icon: Icons.bug_report_rounded,
              color: Colors.redAccent,
              buttonLabel: 'Report Problem',
              onTap: onReportProblemTap,
            ),
            _buildActionCard(
              context: context,
              title: 'Hospital Admin',
              description: 'Contact IT & Operations Director directly.',
              icon: Icons.domain_rounded,
              color: Colors.purple,
              buttonLabel: 'Contact Admin',
              onTap: onContactAdminTap,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIconContainer(
                icon: icon,
                size: 38,
                iconSize: 19,
                color: color,
                borderRadius: 10,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: HealthifyGlassTheme.getTextPrimary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                height: 1.3,
                color: HealthifyGlassTheme.getTextSecondary(isDark),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          GlassSecondaryButton(
            height: 32,
            onPressed: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(buttonLabel, style: const TextStyle(fontSize: 11.5)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
