import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/doctor_help_models.dart';

class CommonTopicsGrid extends StatelessWidget {
  final HelpArticleCategory? selectedCategory;
  final ValueChanged<HelpArticleCategory?> onCategorySelected;

  const CommonTopicsGrid({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BROWSE HELP TOPICS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: HealthifyGlassTheme.getTextMuted(isDark),
              ),
            ),
            if (selectedCategory != null)
              TextButton(
                onPressed: () => onCategorySelected(null),
                child: const Text(
                  'Show All Topics',
                  style: TextStyle(fontSize: 12, color: HealthifyGlassTheme.primaryTeal),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: HelpArticleCategory.values.map((cat) {
              final isSelected = selectedCategory == cat;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    if (isSelected) {
                      onCategorySelected(null);
                    } else {
                      onCategorySelected(cat);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.15)
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.03)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? HealthifyGlassTheme.primaryTeal
                            : HealthifyGlassTheme.getGlassBorder(isDark),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected ? HealthifyGlassTheme.primaryTeal : cat.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.white : HealthifyGlassTheme.primaryTeal)
                                : HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
