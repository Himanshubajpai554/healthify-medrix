import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_components.dart';

class HelpHeader extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const HelpHeader({
    super.key,
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
                children: [
                  const GlassIconContainer(
                    icon: Icons.support_agent_rounded,
                    size: 48,
                    iconSize: 26,
                    color: HealthifyGlassTheme.primaryTeal,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help & Support',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: HealthifyGlassTheme.getTextPrimary(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find answers, troubleshoot issues, or contact hospital support.',
                          style: TextStyle(
                            fontSize: 13,
                            color: HealthifyGlassTheme.getTextSecondary(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search Input Field
              TextField(
                onChanged: onSearchChanged,
                style: TextStyle(
                  fontSize: 13.5,
                  color: HealthifyGlassTheme.getTextPrimary(isDark),
                ),
                decoration: InputDecoration(
                  hintText: 'Search appointments, reports, prescriptions, availability...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: HealthifyGlassTheme.getTextMuted(isDark),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: HealthifyGlassTheme.getTextSecondary(isDark),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => onSearchChanged(''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: HealthifyGlassTheme.getGlassBorder(isDark),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: HealthifyGlassTheme.getGlassBorder(isDark),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
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
