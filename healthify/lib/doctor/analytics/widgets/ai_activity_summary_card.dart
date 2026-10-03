import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class AIActivitySummaryCard extends StatelessWidget {
  final String summaryText;
  final VoidCallback onRefreshSummary;

  const AIActivitySummaryCard({
    super.key,
    required this.summaryText,
    required this.onRefreshSummary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.purple.shade900.withValues(alpha: 0.15) : const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.purple.shade700 : const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: isDark ? Colors.purple.shade300 : Colors.purple.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI Activity Summary',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.purple.shade200 : Colors.purple.shade900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GlassSecondaryButton(
                onPressed: onRefreshSummary,
                height: 32,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 14),
                    SizedBox(width: 4),
                    Text('Refresh', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summaryText,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.purple.shade100 : const Color(0xFF581C87),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'AI-generated summary based on recorded activity — AI does not evaluate clinical competence or rank doctor performance.',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
