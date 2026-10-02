import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_help_models.dart';

class HelpArticleDetailDrawer extends StatefulWidget {
  final HelpArticleModel article;
  final VoidCallback onClose;
  final Function(bool helpful) onRateHelpful;

  const HelpArticleDetailDrawer({
    super.key,
    required this.article,
    required this.onClose,
    required this.onRateHelpful,
  });

  @override
  State<HelpArticleDetailDrawer> createState() => _HelpArticleDetailDrawerState();
}

class _HelpArticleDetailDrawerState extends State<HelpArticleDetailDrawer> {
  bool? _ratedHelpful;

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              GlassIconContainer(
                icon: widget.article.category.icon,
                size: 44,
                iconSize: 22,
                color: widget.article.category.color,
                borderRadius: 12,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.article.category.label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: widget.article.category.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Help Article',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: widget.onClose,
                tooltip: 'Close Article',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Title & Last Updated
          Text(
            widget.article.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HealthifyGlassTheme.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated on ${_formatDate(widget.article.lastUpdated)} • ${widget.article.helpfulCount} doctors found this helpful',
            style: TextStyle(
              fontSize: 12,
              color: HealthifyGlassTheme.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 16),

          // Overview Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Text(
              widget.article.shortDescription,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: HealthifyGlassTheme.getTextPrimary(isDark),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Step-by-Step Instructions
          Text(
            'INSTRUCTIONS & WORKFLOW STEPS',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: HealthifyGlassTheme.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 12),

          ...widget.article.contentSteps.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final stepText = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$idx',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : HealthifyGlassTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        stepText,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: HealthifyGlassTheme.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Helpful Rating Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: HealthifyGlassTheme.getGlassBorder(isDark),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _ratedHelpful == null
                        ? 'Was this article helpful?'
                        : (_ratedHelpful! ? 'Thank you for your feedback!' : 'Thanks! We will improve this guide.'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: HealthifyGlassTheme.getTextPrimary(isDark),
                    ),
                  ),
                ),
                if (_ratedHelpful == null) ...[
                  GlassSecondaryButton(
                    height: 34,
                    onPressed: () {
                      setState(() => _ratedHelpful = true);
                      widget.onRateHelpful(true);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.thumb_up_alt_rounded, size: 14),
                        SizedBox(width: 4),
                        Text('Yes', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassSecondaryButton(
                    height: 34,
                    onPressed: () {
                      setState(() => _ratedHelpful = false);
                      widget.onRateHelpful(false);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.thumb_down_alt_rounded, size: 14),
                        SizedBox(width: 4),
                        Text('No', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
