import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_help_models.dart';

class FaqAccordionSection extends StatefulWidget {
  final List<HelpArticleModel> articles;
  final ValueChanged<HelpArticleModel> onSelectArticle;

  const FaqAccordionSection({
    super.key,
    required this.articles,
    required this.onSelectArticle,
  });

  @override
  State<FaqAccordionSection> createState() => _FaqAccordionSectionState();
}

class _FaqAccordionSectionState extends State<FaqAccordionSection> {
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    if (widget.articles.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              GlassIconContainer(
                icon: Icons.search_off_rounded,
                size: 54,
                iconSize: 26,
                color: HealthifyGlassTheme.getTextMuted(isDark),
              ),
              const SizedBox(height: 14),
              Text(
                'No Help Articles Found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try another search term or clear active category filters.',
                style: TextStyle(
                  fontSize: 13,
                  color: HealthifyGlassTheme.getTextSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassIconContainer(
                icon: Icons.quiz_rounded,
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
                      'Frequently Asked Questions & Workflow Articles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      'Clear step-by-step guidance for provider clinical workflows.',
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

          ...widget.articles.map((article) {
            final isExpanded = _expandedId == article.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isExpanded
                        ? HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4)
                        : HealthifyGlassTheme.getGlassBorder(isDark),
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: Key(article.id),
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedId = expanded ? article.id : null;
                      });
                    },
                    leading: GlassIconContainer(
                      icon: article.category.icon,
                      size: 36,
                      iconSize: 18,
                      color: article.category.color,
                      borderRadius: 10,
                    ),
                    title: Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: HealthifyGlassTheme.getTextPrimary(isDark),
                      ),
                    ),
                    subtitle: Text(
                      article.category.label,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: article.category.color,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.shortDescription,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: HealthifyGlassTheme.getTextSecondary(isDark),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.03)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: HealthifyGlassTheme.getGlassBorder(isDark),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SUMMARY STEPS:',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: HealthifyGlassTheme.getTextMuted(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...article.contentSteps.take(3).map((step) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Expanded(
                                            child: Text(
                                              step,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GlassPrimaryButton(
                                  height: 34,
                                  onPressed: () => widget.onSelectArticle(article),
                                  child: const Row(
                                    children: [
                                      Text('Read Full Article', style: TextStyle(fontSize: 11.5, color: Colors.white)),
                                      SizedBox(width: 5),
                                      Icon(Icons.menu_book_rounded, size: 14, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
