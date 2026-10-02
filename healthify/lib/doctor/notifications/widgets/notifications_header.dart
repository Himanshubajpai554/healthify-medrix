import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onMarkAllRead;
  final VoidCallback onOpenPreferences;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const NotificationsHeader({
    super.key,
    required this.unreadCount,
    required this.onMarkAllRead,
    required this.onOpenPreferences,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HealthifyGlassTheme.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        return GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GlassIconContainer(
                    icon: Icons.notifications_active_rounded,
                    size: 48,
                    iconSize: 26,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: isMobile ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: HealthifyGlassTheme.getTextPrimary(isDark),
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: HealthifyGlassTheme.primaryTeal,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$unreadCount New',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stay updated with important activity related to your clinical workflow.',
                          style: TextStyle(
                            fontSize: 13,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        if (unreadCount > 0) ...[
                          GlassSecondaryButton(
                            height: 40,
                            onPressed: onMarkAllRead,
                            child: const Row(
                              children: [
                                Icon(Icons.done_all_rounded, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Mark All as Read',
                                  style: TextStyle(fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        GlassPrimaryButton(
                          height: 40,
                          onPressed: onOpenPreferences,
                          child: const Row(
                            children: [
                              Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Preferences',
                                style: TextStyle(fontSize: 12.5, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              if (isMobile) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (unreadCount > 0) ...[
                      Expanded(
                        child: GlassSecondaryButton(
                          height: 38,
                          onPressed: onMarkAllRead,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.done_all_rounded, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Mark All Read',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: GlassPrimaryButton(
                        height: 38,
                        onPressed: onOpenPreferences,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Preferences',
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              // Search field
              TextField(
                onChanged: onSearchChanged,
                style: TextStyle(
                  fontSize: 13,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
                decoration: InputDecoration(
                  hintText: 'Search by keyword, patient name, or ID...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: HealthifyGlassTheme.getTextMuted(isDark),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => onSearchChanged(''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: HealthifyGlassTheme.getGlassBorder(isDark),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: HealthifyGlassTheme.getGlassBorder(isDark),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: HealthifyGlassTheme.primaryTeal,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
