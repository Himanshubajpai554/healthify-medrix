import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';
import '../../models/notification_models.dart';

class NotificationsFilterToolbar extends StatelessWidget {
  final NotificationCategory selectedCategory;
  final ValueChanged<NotificationCategory> onCategorySelected;
  final Function(NotificationCategory) getCategoryCount;

  const NotificationsFilterToolbar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.getCategoryCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    // List of categories to show in filter toolbar
    final categories = [
      NotificationCategory.all,
      NotificationCategory.unread,
      NotificationCategory.emergency,
      NotificationCategory.appointments,
      NotificationCategory.patients,
      NotificationCategory.reports,
      NotificationCategory.prescriptions,
      NotificationCategory.system,
      NotificationCategory.hospital,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          final count = getCategoryCount(cat);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onCategorySelected(cat),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.25 : 0.15)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(20),
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
                      size: 15,
                      color: isSelected
                          ? HealthifyGlassTheme.primaryTeal
                          : HealthifyGlassTheme.getTextSecondary(isDark),
                    ),
                    const SizedBox(width: 6),
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
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? HealthifyGlassTheme.primaryTeal
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
