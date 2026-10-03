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
        final isMobile = constraints.maxWidth < 850;

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
                            Flexible(
                              child: Text(
                                'Notifications',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isMobile ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                                ),
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
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (unreadCount > 0) ...[
                            Flexible(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onMarkAllRead,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.20 : 0.10),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.done_all_rounded, size: 16, color: HealthifyGlassTheme.primaryTeal),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'Mark All as Read',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: HealthifyGlassTheme.primaryTeal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onOpenPreferences,
                                borderRadius: BorderRadius.circular(20),
                                child: Ink(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          'Preferences',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onMarkAllRead,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: HealthifyGlassTheme.primaryTeal.withValues(alpha: isDark ? 0.20 : 0.10),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: HealthifyGlassTheme.primaryTeal.withValues(alpha: 0.4),
                                  width: 1.0,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.done_all_rounded, size: 15, color: HealthifyGlassTheme.primaryTeal),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Mark All Read',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: HealthifyGlassTheme.primaryTeal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onOpenPreferences,
                          borderRadius: BorderRadius.circular(18),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.tune_rounded, size: 15, color: Colors.white),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Preferences',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
